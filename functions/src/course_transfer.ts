/**
 * Anonymous → linked account progress transfer.
 *
 * Issue requires an anonymous auth token. Redeem requires a non-anonymous
 * destination token. Receipts are Admin-only; clients never invent source UIDs.
 */

import {createHash, randomBytes, randomUUID} from "node:crypto";
import {
  FieldValue,
  getFirestore,
  type DocumentData,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {courseBank} from "./course_catalog";

/** Short window to redeem a transfer after issue. */
export const TRANSFER_RECEIPT_TTL_MS = 15 * 60 * 1000;

/** Retain tombstoned anonymous course data for recovery / audit. */
export const TOMBSTONE_RECOVERY_MS = 30 * 24 * 60 * 60 * 1000;

/** Cleanup batch size for scheduled TTL sweeps. */
export const TRANSFER_CLEANUP_BATCH = 40;

export type TransferReceiptStatus =
  | "issued"
  | "consumed"
  | "expired"
  | "revoked";

export interface IssueTransferResult {
  receiptId: string;
  nonce: string;
  expiresAtMs: number;
  catalogVersion: string;
  sourceUid: string;
}

export interface RedeemTransferResult {
  receiptId: string;
  sourceUid: string;
  destinationUid: string;
  catalogVersion: string;
  mergedLessonCount: number;
  transferredXp: number;
  liveTrainingTransferred: boolean;
  duplicate: boolean;
}

function nonEmpty(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return value.trim();
}

function optionalString(value: unknown): string | undefined {
  return typeof value === "string" && value.trim() ? value.trim() : undefined;
}

function record(raw: unknown, label: string): Record<string, unknown> {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", `${label} must be an object.`);
  }
  return raw as Record<string, unknown>;
}

function hashNonce(nonce: string): string {
  return createHash("sha256").update(nonce, "utf8").digest("hex");
}

function receiptRef(db: Firestore, receiptId: string) {
  return db.collection("courseTransferReceipts").doc(receiptId);
}

function courseProfileRef(db: Firestore, uid: string) {
  return db.collection("users").doc(uid).collection("course").doc("main");
}

function entitlementRef(db: Firestore, uid: string) {
  return db
    .collection("users")
    .doc(uid)
    .collection("entitlements")
    .doc("liveTraining");
}

function mergeReceiptRef(db: Firestore, destinationUid: string, receiptId: string) {
  return db
    .collection("users")
    .doc(destinationUid)
    .collection("courseTransferMerges")
    .doc(receiptId);
}

/** Issues a short-lived, single-use transfer receipt for an anonymous UID. */
export async function issueAnonymousProgressTransferForUser(options: {
  uid: string;
  isAnonymous: boolean;
  raw?: unknown;
  db?: Firestore;
  nowMs?: number;
}): Promise<IssueTransferResult> {
  if (!options.isAnonymous) {
    throw new HttpsError(
      "failed-precondition",
      "Only anonymous sessions can issue a progress transfer.",
    );
  }
  const db = options.db ?? getFirestore();
  const input = record(options.raw ?? {}, "request");
  const catalogVersion =
    optionalString(input.catalogVersion) ?? courseBank.catalogVersion;
  const nowMs = options.nowMs ?? Date.now();
  const expiresAtMs = nowMs + TRANSFER_RECEIPT_TTL_MS;
  const receiptId = randomUUID();
  const nonce = randomBytes(32).toString("hex");
  const nonceHash = hashNonce(nonce);
  const expireAt = new Date(expiresAtMs);

  await receiptRef(db, receiptId).set({
    receiptId,
    sourceUid: options.uid,
    nonceHash,
    catalogVersion,
    status: "issued" satisfies TransferReceiptStatus,
    createdAtMs: nowMs,
    expiresAtMs,
    expireAt,
    consumedDestinationUid: null,
    consumedAtMs: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {
    receiptId,
    nonce,
    expiresAtMs,
    catalogVersion,
    sourceUid: options.uid,
  };
}

/** Redeems a transfer into the authenticated non-anonymous destination. */
export async function redeemAnonymousProgressTransferForUser(options: {
  uid: string;
  isAnonymous: boolean;
  raw: unknown;
  db?: Firestore;
  nowMs?: number;
  /** Forged client entitlement claims are ignored. */
  clientEntitlementClaim?: unknown;
}): Promise<RedeemTransferResult> {
  if (options.isAnonymous) {
    throw new HttpsError(
      "failed-precondition",
      "Sign into a permanent account before redeeming a transfer.",
    );
  }
  // Never trust client entitlement payloads — only server-authored grants.
  void options.clientEntitlementClaim;

  const db = options.db ?? getFirestore();
  const input = record(options.raw, "request");
  const receiptId = nonEmpty(input.receiptId, "receiptId");
  const nonce = nonEmpty(input.nonce, "nonce");
  const nowMs = options.nowMs ?? Date.now();
  const nonceHash = hashNonce(nonce);
  const destUid = options.uid;
  const receiptDoc = receiptRef(db, receiptId);
  const destMergeDoc = mergeReceiptRef(db, destUid, receiptId);

  return db.runTransaction(async (tx) => {
    const [receiptSnap, mergeSnap] = await Promise.all([
      tx.get(receiptDoc),
      tx.get(destMergeDoc),
    ]);

    if (mergeSnap.exists) {
      const prior = mergeSnap.data()?.result as RedeemTransferResult | undefined;
      if (prior && prior.receiptId === receiptId && prior.destinationUid === destUid) {
        return {...prior, duplicate: true};
      }
      throw new HttpsError(
        "already-exists",
        "Transfer merge receipt conflicts with a prior result.",
      );
    }

    if (!receiptSnap.exists) {
      throw new HttpsError("not-found", "Unknown transfer receipt.");
    }
    const receipt = receiptSnap.data()!;
    const status = String(receipt.status ?? "") as TransferReceiptStatus;
    const sourceUid = String(receipt.sourceUid ?? "");
    const expiresAtMs = Number(receipt.expiresAtMs ?? 0);
    const storedHash = String(receipt.nonceHash ?? "");
    const catalogVersion = String(
      receipt.catalogVersion ?? courseBank.catalogVersion,
    );

    if (!sourceUid || sourceUid === destUid) {
      throw new HttpsError(
        "failed-precondition",
        "Invalid transfer source for this destination.",
      );
    }
    if (storedHash !== nonceHash) {
      throw new HttpsError("permission-denied", "Invalid transfer nonce.");
    }
    if (status === "consumed") {
      const consumedDest = optionalString(receipt.consumedDestinationUid);
      if (consumedDest === destUid) {
        // Destination lost its merge doc; rebuild idempotent response.
        const rebuilt = await readMergedResultFromReceipt(receipt, destUid);
        return {...rebuilt, duplicate: true};
      }
      throw new HttpsError(
        "failed-precondition",
        "Transfer receipt was already redeemed.",
      );
    }
    if (status !== "issued") {
      throw new HttpsError(
        "failed-precondition",
        `Transfer receipt is ${status}.`,
      );
    }
    if (nowMs > expiresAtMs) {
      tx.set(receiptDoc, {
        status: "expired" satisfies TransferReceiptStatus,
        updatedAt: FieldValue.serverTimestamp(),
        updatedAtMs: nowMs,
      }, {merge: true});
      throw new HttpsError("deadline-exceeded", "Transfer receipt expired.");
    }

    const sourceProfileRef = courseProfileRef(db, sourceUid);
    const destProfileRef = courseProfileRef(db, destUid);
    const sourceEntitlementDoc = entitlementRef(db, sourceUid);
    const destEntitlementDoc = entitlementRef(db, destUid);

    const [
      sourceProfileSnap,
      destProfileSnap,
      sourceEntitlementSnap,
      destEntitlementSnap,
    ] = await Promise.all([
      tx.get(sourceProfileRef),
      tx.get(destProfileRef),
      tx.get(sourceEntitlementDoc),
      tx.get(destEntitlementDoc),
    ]);

    if (sourceProfileSnap.exists && sourceProfileSnap.data()?.tombstoned === true) {
      throw new HttpsError(
        "failed-precondition",
        "Anonymous source progress was already transferred.",
      );
    }

    const sourceProfile = sourceProfileSnap.data() ?? {};
    const destProfile = destProfileSnap.data() ?? {};
    // Read the open attempt before any writes. Profile merge keeps the guest
    // resume pointer, but that doc lives under the anonymous uid.
    const sourceResume = sourceProfile.resume ?? null;
    const destinationResume = destProfile.resume ?? null;
    const sourceAttemptId = destinationResume == null &&
      sourceResume &&
      typeof sourceResume === "object" ?
      optionalString((sourceResume as DocumentData).attemptId) :
      undefined;
    const sourceAttemptSnap = sourceAttemptId ?
      await tx.get(
        db.collection("users").doc(sourceUid)
          .collection("courseAttempts").doc(sourceAttemptId),
      ) :
      null;
    const copiedAttempt = inProgressAttemptForDestination({
      destinationResume,
      sourceResume,
      sourceAttempt: sourceAttemptSnap?.data(),
      sourceUid,
      destinationUid: destUid,
    });
    const merged = mergeCourseProfiles(sourceProfile, destProfile, catalogVersion);
    const entitlement = mergeLiveEntitlement({
      source: sourceEntitlementSnap.data(),
      destination: destEntitlementSnap.data(),
      nowMs,
      sourceUid,
    });

    tx.set(destProfileRef, {
      ...merged.profile,
      updatedAt: FieldValue.serverTimestamp(),
      updatedAtMs: nowMs,
      createdAt: destProfileSnap.exists ?
        destProfile.createdAt ?? FieldValue.serverTimestamp() :
        FieldValue.serverTimestamp(),
    }, {merge: true});

    if (entitlement.writeDestination) {
      tx.set(destEntitlementDoc, entitlement.destinationDoc, {merge: true});
    }

    if (copiedAttempt) {
      const attemptId = String(copiedAttempt.attemptId);
      tx.set(
        db.collection("users").doc(destUid)
          .collection("courseAttempts").doc(attemptId),
        {
          ...copiedAttempt,
          updatedAt: FieldValue.serverTimestamp(),
          updatedAtMs: nowMs,
        },
      );
    }

    const tombstoneExpireAt = new Date(nowMs + TOMBSTONE_RECOVERY_MS);
    tx.set(sourceProfileRef, {
      tombstoned: true,
      tombstonedAtMs: nowMs,
      tombstoneReason: "transferred",
      transferredToUid: destUid,
      transferReceiptId: receiptId,
      expireAt: tombstoneExpireAt,
      updatedAt: FieldValue.serverTimestamp(),
      updatedAtMs: nowMs,
    }, {merge: true});

    tx.set(db.collection("courseTombstones").doc(sourceUid), {
      sourceUid,
      destinationUid: destUid,
      transferReceiptId: receiptId,
      tombstonedAtMs: nowMs,
      expireAt: tombstoneExpireAt,
      status: "pending_delete",
      createdAt: FieldValue.serverTimestamp(),
    });

    if (sourceEntitlementSnap.exists && entitlement.clearSource) {
      tx.set(sourceEntitlementDoc, {
        tombstoned: true,
        tombstonedAtMs: nowMs,
        transferredToUid: destUid,
        transferReceiptId: receiptId,
        expireAt: tombstoneExpireAt,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }

    const result: RedeemTransferResult = {
      receiptId,
      sourceUid,
      destinationUid: destUid,
      catalogVersion,
      mergedLessonCount: merged.mergedLessonCount,
      transferredXp: merged.transferredXp,
      liveTrainingTransferred: entitlement.transferred,
      duplicate: false,
    };

    tx.set(receiptDoc, {
      status: "consumed" satisfies TransferReceiptStatus,
      consumedDestinationUid: destUid,
      consumedAtMs: nowMs,
      mergedLessonCount: result.mergedLessonCount,
      transferredXp: result.transferredXp,
      liveTrainingTransferred: result.liveTrainingTransferred,
      updatedAt: FieldValue.serverTimestamp(),
      updatedAtMs: nowMs,
      // Keep expireAt for TTL after consumption audit window.
      expireAt: tombstoneExpireAt,
    }, {merge: true});

    tx.set(destMergeDoc, {
      receiptId,
      sourceUid,
      result,
      createdAtMs: nowMs,
      createdAt: FieldValue.serverTimestamp(),
    });

    return result;
  });
}

function readMergedResultFromReceipt(
  receipt: DocumentData,
  destUid: string,
): RedeemTransferResult {
  return {
    receiptId: String(receipt.receiptId ?? ""),
    sourceUid: String(receipt.sourceUid ?? ""),
    destinationUid: destUid,
    catalogVersion: String(receipt.catalogVersion ?? courseBank.catalogVersion),
    mergedLessonCount: Number(receipt.mergedLessonCount ?? 0),
    transferredXp: Number(receipt.transferredXp ?? 0),
    liveTrainingTransferred: receipt.liveTrainingTransferred === true,
    duplicate: true,
  };
}

/**
 * Attempt payload to store on the linked account, or null when nothing open
 * should move.
 *
 * Redeem keeps the guest resume when the destination has no pointer of its
 * own. That pointer names `courseAttempts/{attemptId}` under the anonymous
 * uid. Leaving it there makes the next lesson start miss the attempt and
 * restart the lesson at the first activity.
 */
export function inProgressAttemptForDestination(options: {
  destinationResume: unknown;
  sourceResume: unknown;
  sourceAttempt: DocumentData | undefined;
  sourceUid: string;
  destinationUid: string;
}): DocumentData | null {
  if (options.destinationResume != null) return null;
  if (!options.sourceResume || typeof options.sourceResume !== "object") {
    return null;
  }
  if (!options.sourceAttempt) return null;

  const resume = options.sourceResume as DocumentData;
  const attemptId = optionalString(resume.attemptId);
  const lessonId = optionalString(resume.lessonId);
  if (!attemptId || !lessonId) return null;

  const data = options.sourceAttempt;
  const storedAttemptId = optionalString(data.attemptId);
  if (storedAttemptId && storedAttemptId !== attemptId) return null;
  if (String(data.lessonId ?? "") !== lessonId) return null;
  const status = String(data.status ?? "");
  if (status !== "in_progress" && status !== "remediation") return null;
  const attemptUid = optionalString(data.uid);
  if (attemptUid && attemptUid !== options.sourceUid) return null;

  return {
    ...data,
    attemptId,
    uid: options.destinationUid,
    lessonId,
    status,
  };
}

/** Pure merge of two course profile maps (destination-wins for conflicts). */
export function mergeCourseProfiles(
  source: DocumentData,
  destination: DocumentData,
  catalogVersion: string,
): {
  profile: DocumentData;
  mergedLessonCount: number;
  transferredXp: number;
} {
  const sourceCompleted = stringArray(source.completedLessonIds);
  const destCompleted = stringArray(destination.completedLessonIds);
  const completedLessonIds = uniqueStrings([...destCompleted, ...sourceCompleted]);
  const newLessons = sourceCompleted.filter((id) => !destCompleted.includes(id));

  const masteryByLessonId: Record<string, number> = {
    ...(destination.masteryByLessonId as Record<string, number> ?? {}),
  };
  const sourceMastery =
    (source.masteryByLessonId as Record<string, number> | undefined) ?? {};
  for (const [lessonId, value] of Object.entries(sourceMastery)) {
    const current = Number(masteryByLessonId[lessonId] ?? 0);
    const incoming = Number(value ?? 0);
    masteryByLessonId[lessonId] = Math.max(current, incoming);
  }

  const destXp = Number(destination.lifetimeXp ?? 0);
  const sourceXp = Number(source.lifetimeXp ?? 0);
  // Transfer only XP associated with lessons the destination lacked.
  const transferredXp = newLessons.length === 0 ?
    0 :
    Math.max(0, Math.min(sourceXp, sourceXp));
  // Prefer destination baseline + transferred source XP once; never double on retry.
  const lifetimeXp = destXp + (newLessons.length > 0 ? sourceXp : 0);

  const destStreak = Number(destination.currentStreak ?? 0);
  const sourceStreak = Number(source.currentStreak ?? 0);
  const destLongest = Number(destination.longestStreak ?? 0);
  const sourceLongest = Number(source.longestStreak ?? 0);

  const destAccepted = Number(destination.acceptedAnswers ?? 0);
  const sourceAccepted = Number(source.acceptedAnswers ?? 0);
  const destScored = Number(destination.totalScoredAnswers ?? 0);
  const sourceScored = Number(source.totalScoredAnswers ?? 0);
  const acceptedAnswers = destAccepted + sourceAccepted;
  const totalScoredAnswers = destScored + sourceScored;

  const experienceBand =
    optionalString(destination.experienceBand) ??
    optionalString(source.experienceBand) ??
    null;
  const dailyGoalMinutes =
    Number.isFinite(Number(destination.dailyGoalMinutes)) ?
      Number(destination.dailyGoalMinutes) :
      Number.isFinite(Number(source.dailyGoalMinutes)) ?
        Number(source.dailyGoalMinutes) :
        null;
  const recommendedLessonId =
    optionalString(destination.recommendedLessonId) ??
    optionalString(source.recommendedLessonId) ??
    null;

  return {
    profile: {
      catalogVersion:
        optionalString(destination.catalogVersion) ??
        optionalString(source.catalogVersion) ??
        catalogVersion,
      lifetimeXp,
      currentStreak: Math.max(destStreak, sourceStreak),
      longestStreak: Math.max(destLongest, sourceLongest),
      lastStudyLocalDate:
        optionalString(destination.lastStudyLocalDate) ??
        optionalString(source.lastStudyLocalDate) ??
        null,
      timezone:
        optionalString(destination.timezone) ??
        optionalString(source.timezone) ??
        "UTC",
      acceptedAnswers,
      totalScoredAnswers,
      acceptedAccuracy: totalScoredAnswers === 0 ?
        0 :
        acceptedAnswers / totalScoredAnswers,
      masteryByLessonId,
      completedLessonIds,
      currentLessonId:
        optionalString(destination.currentLessonId) ??
        optionalString(source.currentLessonId) ??
        null,
      resume: destination.resume ?? source.resume ?? null,
      experienceBand,
      dailyGoalMinutes,
      recommendedLessonId,
      firstLessonCompletedAtMs:
        Number(destination.firstLessonCompletedAtMs ?? 0) ||
        Number(source.firstLessonCompletedAtMs ?? 0) ||
        null,
      legacyLifetimeXp:
        Number(destination.legacyLifetimeXp ?? 0) ||
        Number(source.legacyLifetimeXp ?? 0) ||
        null,
      legacyXpCatalogVersion:
        optionalString(destination.legacyXpCatalogVersion) ??
        optionalString(source.legacyXpCatalogVersion) ??
        null,
      legacyXpLabel:
        destination.legacyXpLabel === "legacy_academy" ||
        source.legacyXpLabel === "legacy_academy" ?
          "legacy_academy" :
          null,
    },
    mergedLessonCount: newLessons.length,
    transferredXp: newLessons.length > 0 ? transferredXp : 0,
  };
}

/** Server-side Live Training entitlement merge; never trusts client claims. */
export function mergeLiveEntitlement(options: {
  source: DocumentData | undefined;
  destination: DocumentData | undefined;
  nowMs: number;
  sourceUid: string;
}): {
  writeDestination: boolean;
  clearSource: boolean;
  transferred: boolean;
  destinationDoc: DocumentData;
} {
  const sourceGrant = options.source?.unrestrictedAccess === true &&
    options.source?.tombstoned !== true;
  const destGrant = options.destination?.unrestrictedAccess === true;

  if (!sourceGrant) {
    return {
      writeDestination: false,
      clearSource: false,
      transferred: false,
      destinationDoc: {},
    };
  }
  if (destGrant) {
    // Preserve stronger/existing destination grant; still tombstone source copy.
    return {
      writeDestination: true,
      clearSource: true,
      transferred: false,
      destinationDoc: {
        unrestrictedAccess: true,
        source: options.destination?.source ?? "preexisting",
        originalEntitlementSource:
          options.destination?.originalEntitlementSource ??
          options.destination?.source ??
          "preexisting",
        transferredFromUid: options.destination?.transferredFromUid ?? null,
        updatedAt: FieldValue.serverTimestamp(),
        updatedAtMs: options.nowMs,
      },
    };
  }

  return {
    writeDestination: true,
    clearSource: true,
    transferred: true,
    destinationDoc: {
      unrestrictedAccess: true,
      source: "anonymous_transfer",
      originalEntitlementSource:
        options.source?.source ?? "anonymous_course",
      transferredFromUid: options.sourceUid,
      grantedAt: options.source?.grantedAt ?? FieldValue.serverTimestamp(),
      grantedAtMs: Number(options.source?.grantedAtMs ?? options.nowMs),
      grantedByAttemptId: options.source?.grantedByAttemptId ?? null,
      grantedByLessonId: options.source?.grantedByLessonId ?? null,
      updatedAt: FieldValue.serverTimestamp(),
      updatedAtMs: options.nowMs,
    },
  };
}

/** Deletes expired receipts and tombstoned anonymous course docs past recovery. */
export async function cleanupExpiredCourseTransfers(options?: {
  db?: Firestore;
  nowMs?: number;
  limit?: number;
}): Promise<{receiptsDeleted: number; profilesDeleted: number}> {
  const db = options?.db ?? getFirestore();
  const nowMs = options?.nowMs ?? Date.now();
  const limit = options?.limit ?? TRANSFER_CLEANUP_BATCH;
  const now = new Date(nowMs);

  let receiptsDeleted = 0;
  const expiredReceipts = await db
    .collection("courseTransferReceipts")
    .where("expireAt", "<=", now)
    .limit(limit)
    .get();
  for (const docSnap of expiredReceipts.docs) {
    await docSnap.ref.delete();
    receiptsDeleted += 1;
  }

  let profilesDeleted = 0;
  const tombstoned = await db
    .collection("courseTombstones")
    .where("expireAt", "<=", now)
    .limit(limit)
    .get();
  for (const docSnap of tombstoned.docs) {
    const sourceUid = String(docSnap.data().sourceUid ?? docSnap.id);
    await deleteTombstonedUserCourseData(db, sourceUid);
    await docSnap.ref.delete();
    profilesDeleted += 1;
  }

  return {receiptsDeleted, profilesDeleted};
}

async function deleteTombstonedUserCourseData(
  db: Firestore,
  sourceUid: string,
): Promise<void> {
  const userRef = db.collection("users").doc(sourceUid);
  const subcollections = [
    "course",
    "courseAttempts",
    "courseStepReceipts",
    "courseReviews",
    "courseXpLedger",
    "courseStartRequests",
    "courseRateLimits",
    "courseTransferMerges",
  ];
  for (const name of subcollections) {
    const snap = await userRef.collection(name).limit(TRANSFER_CLEANUP_BATCH).get();
    for (const child of snap.docs) {
      await child.ref.delete();
    }
  }
  const entitlement = await userRef.collection("entitlements").doc("liveTraining")
    .get();
  if (entitlement.exists && entitlement.data()?.tombstoned === true) {
    await entitlement.ref.delete();
  }
}

function stringArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map(String).filter((v) => v.length > 0);
}

function uniqueStrings(values: string[]): string[] {
  return [...new Set(values)];
}
