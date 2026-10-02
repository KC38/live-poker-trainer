/**
 * Duolingo-style course hearts: five-heart ceiling, passive time refill,
 * gem full refill, practice +1, and rewarded-ad +1.
 */

import {
  FieldValue,
  getFirestore,
  type DocumentData,
  type DocumentReference,
  type DocumentSnapshot,
  type Firestore,
  type Transaction,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

/** Max hearts on a course profile. Shared by new users and attempt ceilings. */
export const DEFAULT_LESSON_LIVES = 5;

/** One heart every six hours (Duolingo wiki timing). */
export const HEART_REFILL_INTERVAL_MS = 6 * 60 * 60 * 1000;

/** Gems for a full heart refill outside a lesson (Duolingo-scale). */
export const GEMS_FULL_HEART_REFILL = 650;

/** Minimum gap between rewarded-ad heart claims (anti double-tap). */
export const AD_HEART_COOLDOWN_MS = 15 * 1000;

/** Cap rewarded-ad heart claims per local calendar day. */
export const AD_HEART_DAILY_MAX = 5;

/** Heart replenishment methods exposed by refillCourseHearts. */
export type HeartRefillMethod = "gems" | "ad" | "practice";

/** Snapshot of heart fields used by passive accrual and refill callables. */
export interface HeartState {
  livesRemaining: number;
  livesMax: number;
  livesNextRefillAtMs: number | null;
  gems: number;
  heartsAdClaimsLocalDate: string | null;
  heartsAdClaimsToday: number;
  lastHeartAdClaimAtMs: number | null;
}

/** Result of applying passive time-based heart accrual. */
export interface PassiveHeartRefillResult extends HeartState {
  heartsRestored: number;
  changed: boolean;
}

/**
 * Hearts are per user (course profile), not reset per lesson.
 * Missing / invalid values fall back to a full current ceiling.
 * Legacy profiles that were full at an older max are topped to the new max.
 */
export function profileLivesFromData(data: DocumentData | undefined): {
  livesRemaining: number;
  livesMax: number;
} {
  const livesMaxRaw = Number(data?.livesMax ?? DEFAULT_LESSON_LIVES);
  const storedMax = Number.isFinite(livesMaxRaw) && livesMaxRaw > 0 ?
    Math.floor(livesMaxRaw) :
    DEFAULT_LESSON_LIVES;
  const livesMax = Math.max(storedMax, DEFAULT_LESSON_LIVES);
  const remainingRaw = Number(data?.livesRemaining ?? storedMax);
  let livesRemaining = Number.isFinite(remainingRaw) ?
    Math.max(0, Math.min(livesMax, Math.floor(remainingRaw))) :
    livesMax;
  // Migration: full at the old ceiling → full at the new ceiling.
  if (
    Number.isFinite(remainingRaw) &&
    Math.floor(remainingRaw) === storedMax &&
    storedMax < DEFAULT_LESSON_LIVES
  ) {
    livesRemaining = DEFAULT_LESSON_LIVES;
  }
  return {livesRemaining, livesMax};
}

/** Reads refill timer + ad-claim counters from a profile document. */
export function heartStateFromData(data: DocumentData | undefined): HeartState {
  const lives = profileLivesFromData(data);
  const nextRaw = data?.livesNextRefillAtMs;
  const livesNextRefillAtMs = Number.isFinite(Number(nextRaw)) &&
      Number(nextRaw) > 0 ?
    Math.floor(Number(nextRaw)) :
    null;
  const gemsRaw = Number(data?.gems ?? 0);
  const gems = Number.isFinite(gemsRaw) ? Math.max(0, Math.floor(gemsRaw)) : 0;
  const adDate = typeof data?.heartsAdClaimsLocalDate === "string" ?
    data.heartsAdClaimsLocalDate :
    null;
  const adCountRaw = Number(data?.heartsAdClaimsToday ?? 0);
  const heartsAdClaimsToday = Number.isFinite(adCountRaw) ?
    Math.max(0, Math.floor(adCountRaw)) :
    0;
  const lastAdRaw = Number(data?.lastHeartAdClaimAtMs ?? 0);
  const lastHeartAdClaimAtMs = Number.isFinite(lastAdRaw) && lastAdRaw > 0 ?
    Math.floor(lastAdRaw) :
    null;
  return {
    ...lives,
    livesNextRefillAtMs,
    gems,
    heartsAdClaimsLocalDate: adDate,
    heartsAdClaimsToday,
    lastHeartAdClaimAtMs,
  };
}

/**
 * Accrues +1 heart per elapsed refill interval while below the ceiling.
 * Clears the timer when full; starts one when below max with no timer.
 */
export function applyPassiveHeartRefill(
  state: HeartState,
  nowMs: number,
  intervalMs: number = HEART_REFILL_INTERVAL_MS,
): PassiveHeartRefillResult {
  const livesMax = Math.max(state.livesMax, DEFAULT_LESSON_LIVES);
  let livesRemaining = Math.max(0, Math.min(livesMax, state.livesRemaining));
  let nextAt = state.livesNextRefillAtMs;
  let heartsRestored = 0;

  if (livesRemaining >= livesMax) {
    const changed = livesRemaining !== state.livesRemaining ||
      livesMax !== state.livesMax ||
      nextAt !== null;
    return {
      ...state,
      livesRemaining: livesMax,
      livesMax,
      livesNextRefillAtMs: null,
      heartsRestored: 0,
      changed,
    };
  }

  if (nextAt == null) {
    nextAt = nowMs + intervalMs;
  }

  while (livesRemaining < livesMax && nextAt != null && nowMs >= nextAt) {
    livesRemaining += 1;
    heartsRestored += 1;
    if (livesRemaining >= livesMax) {
      nextAt = null;
    } else {
      nextAt = nextAt + intervalMs;
    }
  }

  const changed = livesRemaining !== state.livesRemaining ||
    livesMax !== state.livesMax ||
    nextAt !== state.livesNextRefillAtMs;
  return {
    ...state,
    livesRemaining,
    livesMax,
    livesNextRefillAtMs: nextAt,
    heartsRestored,
    changed,
  };
}

/**
 * After a life is spent, ensure a refill timer is running when below max.
 */
export function scheduleHeartRefillAfterLoss(options: {
  livesRemaining: number;
  livesMax: number;
  livesNextRefillAtMs: number | null;
  nowMs: number;
  intervalMs?: number;
}): number | null {
  const intervalMs = options.intervalMs ?? HEART_REFILL_INTERVAL_MS;
  if (options.livesRemaining >= options.livesMax) {
    return null;
  }
  if (
    options.livesNextRefillAtMs != null &&
    options.livesNextRefillAtMs > options.nowMs
  ) {
    return options.livesNextRefillAtMs;
  }
  return options.nowMs + intervalMs;
}

/** Adds hearts without exceeding the ceiling; manages the refill timer. */
export function grantHearts(options: {
  state: HeartState;
  amount: number;
  nowMs: number;
  fillToMax?: boolean;
  intervalMs?: number;
}): PassiveHeartRefillResult {
  const intervalMs = options.intervalMs ?? HEART_REFILL_INTERVAL_MS;
  const livesMax = Math.max(options.state.livesMax, DEFAULT_LESSON_LIVES);
  const before = Math.max(0, Math.min(livesMax, options.state.livesRemaining));
  const after = options.fillToMax ?
    livesMax :
    Math.min(livesMax, before + Math.max(0, Math.floor(options.amount)));
  const heartsRestored = after - before;
  let nextAt: number | null = options.state.livesNextRefillAtMs;
  if (after >= livesMax) {
    nextAt = null;
  } else if (nextAt == null) {
    nextAt = options.nowMs + intervalMs;
  }
  return {
    ...options.state,
    livesRemaining: after,
    livesMax,
    livesNextRefillAtMs: nextAt,
    heartsRestored,
    changed: heartsRestored > 0 ||
      livesMax !== options.state.livesMax ||
      nextAt !== options.state.livesNextRefillAtMs,
  };
}

/** Firestore patch for heart fields after passive or active refill. */
export function heartFieldsToFirestore(state: HeartState): DocumentData {
  return {
    livesRemaining: state.livesRemaining,
    livesMax: state.livesMax,
    livesNextRefillAtMs: state.livesNextRefillAtMs,
    heartsAdClaimsLocalDate: state.heartsAdClaimsLocalDate,
    heartsAdClaimsToday: state.heartsAdClaimsToday,
    lastHeartAdClaimAtMs: state.lastHeartAdClaimAtMs,
  };
}

/** Derived ad-heart availability for clients (Home refill sheet). */
export function adHeartAvailability(options: {
  state: HeartState;
  localDate: string;
  nowMs: number;
}): {
  adClaimsRemainingToday: number;
  nextAdClaimAtMs: number | null;
} {
  const claimsToday = options.state.heartsAdClaimsLocalDate === options.localDate ?
    options.state.heartsAdClaimsToday :
    0;
  const adClaimsRemainingToday = Math.max(0, AD_HEART_DAILY_MAX - claimsToday);
  let nextAdClaimAtMs: number | null = null;
  if (options.state.lastHeartAdClaimAtMs != null) {
    const readyAt = options.state.lastHeartAdClaimAtMs + AD_HEART_COOLDOWN_MS;
    if (readyAt > options.nowMs) {
      nextAdClaimAtMs = readyAt;
    }
  }
  return {adClaimsRemainingToday, nextAdClaimAtMs};
}

export interface RefillCourseHeartsResult {
  method: HeartRefillMethod;
  livesRemaining: number;
  livesMax: number;
  livesNextRefillAtMs: number | null;
  heartsRestored: number;
  gems: number;
  gemsSpent: number;
  duplicate: boolean;
  nextAdClaimAtMs: number | null;
  adClaimsRemainingToday: number;
}

/**
 * Applies gems / ad / practice heart refill with idempotent receipts.
 */
export async function refillCourseHeartsForUser(options: {
  uid: string;
  raw: unknown;
  localDate: string;
  nowMs?: number;
  db?: Firestore;
}): Promise<RefillCourseHeartsResult> {
  const db = options.db ?? getFirestore();
  const nowMs = options.nowMs ?? Date.now();
  const input = asRecord(options.raw, "request");
  const method = parseMethod(input.method);
  const idempotencyKey = nonEmpty(input.idempotencyKey, "idempotencyKey");
  nonEmpty(input.clientVersion, "clientVersion");

  const profileRef = db.collection("users").doc(options.uid)
    .collection("course").doc("main");
  const receiptRef = db.collection("users").doc(options.uid)
    .collection("courseHeartRefills").doc(idempotencyKey);

  return db.runTransaction(async (tx) => {
    // Firestore requires every read before any write in a transaction.
    const receiptSnap = await tx.get(receiptRef);
    const profileSnap = await tx.get(profileRef);
    if (receiptSnap.exists) {
      const prior = receiptSnap.data()?.result as
        | RefillCourseHeartsResult
        | undefined;
      if (!prior) {
        throw new HttpsError(
          "already-exists",
          "idempotencyKey was reused without a stored result.",
        );
      }
      return {...prior, duplicate: true};
    }
    if (!profileSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "Initialize the course profile before refilling hearts.",
      );
    }

    const profileData = profileSnap.data() ?? {};
    const openAttemptRef = openAttemptRefFromProfile({
      db,
      uid: options.uid,
      profileData,
    });
    const openAttemptSnap = openAttemptRef ?
      await tx.get(openAttemptRef) :
      null;

    const passive = applyPassiveHeartRefill(
      heartStateFromData(profileData),
      nowMs,
    );
    let next = passive;
    let gemsSpent = 0;

    if (method === "gems") {
      if (next.livesRemaining >= next.livesMax) {
        throw new HttpsError(
          "failed-precondition",
          "Hearts are already full.",
        );
      }
      if (next.gems < GEMS_FULL_HEART_REFILL) {
        throw new HttpsError(
          "failed-precondition",
          `Need ${GEMS_FULL_HEART_REFILL} gems to refill hearts.`,
        );
      }
      gemsSpent = GEMS_FULL_HEART_REFILL;
      next = {
        ...grantHearts({state: next, amount: 0, nowMs, fillToMax: true}),
        gems: next.gems - gemsSpent,
      };
    } else if (method === "ad") {
      if (next.livesRemaining >= next.livesMax) {
        throw new HttpsError(
          "failed-precondition",
          "Hearts are already full.",
        );
      }
      const adDay = options.localDate;
      const claimsToday = next.heartsAdClaimsLocalDate === adDay ?
        next.heartsAdClaimsToday :
        0;
      if (claimsToday >= AD_HEART_DAILY_MAX) {
        throw new HttpsError(
          "resource-exhausted",
          "Daily ad heart limit reached. Try again tomorrow.",
        );
      }
      if (
        next.lastHeartAdClaimAtMs != null &&
        nowMs - next.lastHeartAdClaimAtMs < AD_HEART_COOLDOWN_MS
      ) {
        throw new HttpsError(
          "resource-exhausted",
          "Ad heart cooldown active. Wait before watching another ad.",
        );
      }
      const granted = grantHearts({state: next, amount: 1, nowMs});
      next = {
        ...granted,
        gems: next.gems,
        heartsAdClaimsLocalDate: adDay,
        heartsAdClaimsToday: claimsToday + 1,
        lastHeartAdClaimAtMs: nowMs,
      };
    } else {
      // practice — client calls after finishing a practice/replay session.
      if (next.livesRemaining >= next.livesMax) {
        throw new HttpsError(
          "failed-precondition",
          "Hearts are already full.",
        );
      }
      next = {
        ...grantHearts({state: next, amount: 1, nowMs}),
        gems: next.gems,
      };
    }

    const availability = adHeartAvailability({
      state: next,
      localDate: options.localDate,
      nowMs,
    });
    const result: RefillCourseHeartsResult = {
      method,
      livesRemaining: next.livesRemaining,
      livesMax: next.livesMax,
      livesNextRefillAtMs: next.livesNextRefillAtMs,
      heartsRestored: next.heartsRestored,
      gems: next.gems,
      gemsSpent,
      duplicate: false,
      nextAdClaimAtMs: availability.nextAdClaimAtMs,
      adClaimsRemainingToday: availability.adClaimsRemainingToday,
    };

    const profilePatch: DocumentData = {
      ...heartFieldsToFirestore(next),
      gems: next.gems,
      updatedAt: FieldValue.serverTimestamp(),
    };
    tx.set(profileRef, profilePatch, {merge: true});
    writeOpenAttemptHearts({
      tx,
      attemptRef: openAttemptRef,
      attemptSnap: openAttemptSnap,
      livesRemaining: next.livesRemaining,
      livesMax: next.livesMax,
    });
    tx.create(receiptRef, {
      idempotencyKey,
      method,
      result,
      createdAt: FieldValue.serverTimestamp(),
      createdAtMs: nowMs,
    });
    return result;
  });
}

/**
 * Awards +1 heart when a learner finishes a heart-refill Practice run.
 *
 * Voluntary map reviews do not grant hearts — only attempts started from the
 * refill sheet's Practice action (restoreHeartOnComplete on the attempt).
 * Idempotent via the completion receipt path (caller gates once per attempt).
 */
export function practiceHeartGrantFromCompletion(options: {
  state: HeartState;
  nowMs: number;
  restoreHeartOnComplete: boolean;
}): PassiveHeartRefillResult | null {
  if (!options.restoreHeartOnComplete) return null;
  if (options.state.livesRemaining >= options.state.livesMax) return null;
  return grantHearts({state: options.state, amount: 1, nowMs: options.nowMs});
}

/** Resolves the open attempt doc from profile.resume, if any. */
export function openAttemptRefFromProfile(options: {
  db: Firestore;
  uid: string;
  profileData: DocumentData;
}): DocumentReference | null {
  const resume = options.profileData.resume;
  if (!resume || typeof resume !== "object") return null;
  const attemptId = String((resume as DocumentData).attemptId ?? "").trim();
  if (!attemptId) return null;
  return options.db.collection("users").doc(options.uid)
    .collection("courseAttempts").doc(attemptId);
}

/** Writes heart fields onto an already-read open attempt (write phase only). */
function writeOpenAttemptHearts(options: {
  tx: Transaction;
  attemptRef: DocumentReference | null;
  attemptSnap: DocumentSnapshot | null;
  livesRemaining: number;
  livesMax: number;
}): void {
  const attemptRef = options.attemptRef;
  const attemptSnap = options.attemptSnap;
  if (!attemptRef || !attemptSnap?.exists) return;
  const status = String(attemptSnap.data()?.status ?? "");
  if (status !== "in_progress" && status !== "remediation") return;
  const patch: DocumentData = {
    livesRemaining: options.livesRemaining,
    livesMax: options.livesMax,
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (status === "remediation" && options.livesRemaining > 0) {
    patch.status = "in_progress";
  }
  options.tx.set(attemptRef, patch, {merge: true});
}

function parseMethod(raw: unknown): HeartRefillMethod {
  const value = String(raw ?? "").trim();
  if (value === "gems" || value === "ad" || value === "practice") {
    return value;
  }
  throw new HttpsError(
    "invalid-argument",
    "method must be gems, ad, or practice.",
  );
}

function asRecord(value: unknown, label: string): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new HttpsError("invalid-argument", `${label} must be an object.`);
  }
  return value as Record<string, unknown>;
}

function nonEmpty(value: unknown, field: string): string {
  const text = String(value ?? "").trim();
  if (!text) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return text;
}
