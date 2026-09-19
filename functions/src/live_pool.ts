/**
 * Firestore pool management for validated and branch-warmed live hands.
 *
 * Inventory is measured per user: a shared ready hand is unseen until that
 * user receives it. Every new setup starts with ten ready hands; a user with
 * five or fewer unseen hands queues ten more shared definitions. Allocation
 * blocks only when that user has zero unseen ready hands.
 */

import {randomUUID} from "node:crypto";
import {
  FieldPath,
  FieldValue,
  Timestamp,
  getFirestore,
  type DocumentData,
  type Firestore,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {generateLiveHandDefinition} from "./live_hand_generation";
import {buildLiveSetupKey} from "./live_setup";
import {prepareLiveHand, type PreparedLiveNode} from "./live_tree";
import {
  LIVE_INITIAL_POOL_SIZE,
  LIVE_REFILL_BATCH_SIZE,
  LIVE_UNSEEN_LOW_WATER,
  type LiveHandDefinition,
  type LiveTableSetup,
} from "./live_types";

const LIVE_GENERATION_LEASE_MS = 15 * 60 * 1000;

interface LiveSetupDoc {
  setupKey: string;
  setup: LiveTableSetup;
  handCount: number;
  generation: {
    status: "queued" | "generating" | "idle";
    leaseId: string | null;
    leaseExpiresAtMs: number | null;
    requestedBatch: number;
    lastError?: string | null;
  };
}

export interface AllocatedLiveHand {
  definition: LiveHandDefinition;
  root: PreparedLiveNode;
  setupKey: string;
  unseenRemaining: number;
}

/** Ensures a setup exists and queues its initial ten-hand warm pool. */
export async function ensureLiveSetup(options: {
  setup: LiveTableSetup;
  db?: Firestore;
}): Promise<string> {
  const db = options.db ?? getFirestore();
  const setupKey = buildLiveSetupKey(options.setup);
  const ref = db.collection("liveTableSetups").doc(setupKey);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (snapshot.exists) return;
    tx.create(ref, {
      setupKey,
      setup: options.setup,
      handCount: 0,
      generation: {
        status: "queued",
        leaseId: null,
        leaseExpiresAtMs: null,
        requestedBatch: LIVE_INITIAL_POOL_SIZE,
        lastError: null,
      },
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return setupKey;
}

/**
 * Allocates one unseen ready hand and creates a resumable server session.
 */
export async function allocateLiveHandForUser(options: {
  uid: string;
  setup: LiveTableSetup;
  startRequestId?: string;
  sessionId?: string;
  db?: Firestore;
}): Promise<AllocatedLiveHand> {
  const db = options.db ?? getFirestore();
  const setupKey = await ensureLiveSetup({setup: options.setup, db});
  const setupRef = db.collection("liveTableSetups").doc(setupKey);
  const setupSnapshot = await setupRef.get();
  const setupHandCount = Number(setupSnapshot.data()?.handCount ?? 0);
  if (setupHandCount < LIVE_INITIAL_POOL_SIZE) {
    await requestLiveRefill({db, setupKey});
    throw new HttpsError(
      "unavailable",
      "Initial live hand pool is generating. Retry in a moment.",
    );
  }
  const hands = setupRef.collection("hands");
  const receipts = db
    .collection("users")
    .doc(options.uid)
    .collection("liveHandReceipts");
  const unseen = (await unseenReadyHands(db, hands, receipts))
    .sort((left, right) => {
      const served = Number(left.data().timesServed ?? 0) -
        Number(right.data().timesServed ?? 0);
      if (served !== 0) return served;
      return left.id.localeCompare(right.id);
    });
  if (unseen.length === 0) {
    await requestLiveRefill({db, setupKey});
    throw new HttpsError(
      "unavailable",
      "Live hand pool is generating. Retry in a moment.",
    );
  }
  const chosen = unseen[0];
  const rootHash = String(chosen.data().rootStateHash ?? "");
  const rootRef = chosen.ref.collection("nodes").doc(rootHash);
  const receiptRef = receipts.doc(chosen.id);
  const allocated = await db.runTransaction(async (tx) => {
    const [hand, receipt, root] = await Promise.all([
      tx.get(chosen.ref),
      tx.get(receiptRef),
      tx.get(rootRef),
    ]);
    if (!hand.exists || hand.data()?.status !== "ready" || receipt.exists) {
      return null;
    }
    const definition = hand.data()?.definition as LiveHandDefinition | undefined;
    const rootData = root.data();
    if (!definition || !isPreparedNodeData(rootData)) {
      throw new HttpsError("internal", "Ready hand is missing its warm root.");
    }
    tx.create(receiptRef, {
      handId: chosen.id,
      setupKey,
      status: "allocated",
      ...(options.startRequestId === undefined ?
        {} :
        {startRequestId: options.startRequestId}),
      ...(options.sessionId === undefined ? {} : {sessionId: options.sessionId}),
      allocatedAt: FieldValue.serverTimestamp(),
    });
    tx.update(chosen.ref, {
      timesServed: FieldValue.increment(1),
      lastServedAt: FieldValue.serverTimestamp(),
    });
    return {
      definition,
      root: preparedNodeFromData(rootData),
    };
  });
  if (!allocated) {
    // A concurrent allocation won the receipt. Re-run selection.
    return allocateLiveHandForUser(options);
  }
  const unseenRemaining = unseen.length - 1;
  if (shouldRefillLiveUnseen(unseenRemaining)) {
    await requestLiveRefill({db, setupKey});
  }
  return {
    ...allocated,
    setupKey,
    unseenRemaining,
  };
}

/** Per-user low-water policy: five or fewer unseen queues ten more. */
export function shouldRefillLiveUnseen(unseenRemaining: number): boolean {
  return unseenRemaining <= LIVE_UNSEEN_LOW_WATER;
}

async function unseenReadyHands(
  db: Firestore,
  hands: FirebaseFirestore.CollectionReference,
  receipts: FirebaseFirestore.CollectionReference,
): Promise<QueryDocumentSnapshot[]> {
  const unseen: QueryDocumentSnapshot[] = [];
  let cursor: QueryDocumentSnapshot | undefined;
  for (;;) {
    let query = hands
      .where("status", "==", "ready")
      .orderBy("timesServed")
      .orderBy(FieldPath.documentId())
      .limit(50);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    const receiptSnapshots = page.empty ?
      [] :
      await db.getAll(...page.docs.map((doc) => receipts.doc(doc.id)));
    for (let index = 0; index < page.docs.length; index++) {
      const doc = page.docs[index];
      if (!receiptSnapshots[index].exists) unseen.push(doc);
      // Seven means at least six remain after this allocation, above low water.
      if (unseen.length >= LIVE_UNSEEN_LOW_WATER + 2) return unseen;
    }
    if (page.size < 50) return unseen;
    cursor = page.docs.at(-1);
  }
}

/** Idempotently queues a ten-hand refill unless a lease is already active. */
export async function requestLiveRefill(options: {
  db?: Firestore;
  setupKey: string;
}): Promise<void> {
  const db = options.db ?? getFirestore();
  const ref = db.collection("liveTableSetups").doc(options.setupKey);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) return;
    const data = snapshot.data() as LiveSetupDoc;
    const generation = data.generation;
    const now = Date.now();
    if (
      generation?.status === "queued" ||
      (generation?.status === "generating" &&
        Number(generation.leaseExpiresAtMs ?? 0) > now)
    ) {
      return;
    }
    tx.update(ref, {
      "generation.status": "queued",
      "generation.leaseId": null,
      "generation.leaseExpiresAtMs": null,
      "generation.requestedBatch": LIVE_REFILL_BATCH_SIZE,
      "generation.lastError": null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}

/**
 * Expands one setup refill into independent per-hand jobs.
 *
 * One warmed hand can require several sequential perspective-isolated model
 * calls. Separate jobs keep every invocation inside event-function deadlines.
 */
export async function refillQueuedLiveSetup(options: {
  setupKey: string;
  db?: Firestore;
}): Promise<{queued: number; leaseHeldByOther: boolean}> {
  const db = options.db ?? getFirestore();
  const setupRef = db.collection("liveTableSetups").doc(options.setupKey);
  const queued = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(setupRef);
    if (!snapshot.exists) return 0;
    const data = snapshot.data() as LiveSetupDoc;
    if (data.generation?.status !== "queued") return 0;
    const leaseId = randomUUID();
    const batchSize = Number(
      data.generation.requestedBatch || LIVE_REFILL_BATCH_SIZE,
    );
    tx.update(setupRef, {
      "generation.status": "generating",
      "generation.leaseId": leaseId,
      "generation.leaseExpiresAtMs": Date.now() + LIVE_GENERATION_LEASE_MS,
      "generation.completedJobs": 0,
      "generation.successfulJobs": 0,
      updatedAt: FieldValue.serverTimestamp(),
    });
    for (let index = 0; index < batchSize; index++) {
      tx.create(
        db.collection("liveGenerationJobs").doc(`${leaseId}-${index}`),
        {
          status: "queued",
          setupKey: options.setupKey,
          setup: data.setup,
          leaseId,
          variationIndex: index,
          attempt: 0,
          createdAt: FieldValue.serverTimestamp(),
        },
      );
    }
    return batchSize;
  });
  return {queued, leaseHeldByOther: queued === 0};
}

/** Returns true when a setup write represents queued live generation. */
export function isQueuedLiveGeneration(data: DocumentData | undefined): boolean {
  return data?.generation?.status === "queued";
}

/** Returns true when a per-hand generation job is ready to run. */
export function isQueuedLiveGenerationJob(
  data: DocumentData | undefined,
): boolean {
  return data?.status === "queued";
}

/** Requeues setup leases whose job wave stopped producing heartbeats. */
export async function recoverExpiredLiveGenerationLeases(options: {
  db?: Firestore;
  nowMs?: number;
} = {}): Promise<number> {
  const db = options.db ?? getFirestore();
  const nowMs = options.nowMs ?? Date.now();
  const queuedSnapshot = await db
    .collection("liveTableSetups")
    .where("generation.status", "==", "queued")
    .limit(500)
    .get();
  let recovered = 0;
  for (const setup of queuedSnapshot.docs) {
    const result = await refillQueuedLiveSetup({db, setupKey: setup.id});
    if (result.queued > 0) recovered++;
  }
  const snapshot = await db
    .collection("liveTableSetups")
    .where("generation.status", "==", "generating")
    .limit(500)
    .get();
  for (const setup of snapshot.docs) {
    if (Number(setup.data()?.generation?.leaseExpiresAtMs ?? 0) > nowMs) {
      continue;
    }
    await requestLiveRefill({db, setupKey: setup.id});
    recovered++;
  }
  return recovered;
}

/** Generates and publishes one fully warmed hand job. */
export async function processLiveGenerationJob(options: {
  jobId: string;
  apiKey: string;
  db?: Firestore;
}): Promise<{published: boolean; retried: boolean}> {
  const db = options.db ?? getFirestore();
  const jobRef = db.collection("liveGenerationJobs").doc(options.jobId);
  const claimId = randomUUID();
  const claimed = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(jobRef);
    if (!snapshot.exists || snapshot.data()?.status !== "queued") return null;
    const data = snapshot.data()!;
    const setupRef = db.collection("liveTableSetups").doc(String(data.setupKey));
    const setupSnapshot = await tx.get(setupRef);
    if (
      !setupSnapshot.exists ||
      setupSnapshot.data()?.generation?.leaseId !== data.leaseId
    ) {
      return null;
    }
    tx.update(jobRef, {
      status: "generating",
      claimId,
      leaseExpiresAtMs: Date.now() + LIVE_GENERATION_LEASE_MS,
      startedAt: FieldValue.serverTimestamp(),
    });
    tx.update(setupRef, {
      "generation.leaseExpiresAtMs": Date.now() + LIVE_GENERATION_LEASE_MS,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return data;
  });
  if (!claimed) return {published: false, retried: false};
  const setupKey = String(claimed.setupKey);
  const setup = claimed.setup as LiveTableSetup;
  const leaseId = String(claimed.leaseId);
  const attempt = Number(claimed.attempt ?? 0);
  const setupRef = db.collection("liveTableSetups").doc(setupKey);
  try {
    const variationSeed =
      `${leaseId}:${claimed.variationIndex}:${attempt}:${Date.now()}`;
    const definition = await generateLiveHandDefinition({
      apiKey: options.apiKey,
      setup,
      setupKey,
      variationSeed,
    });
    const prepared = await prepareLiveHand({
      apiKey: options.apiKey,
      hand: definition,
    });
    const published = await publishPreparedHandJob({
      db,
      setupRef,
      jobRef,
      leaseId,
      claimId,
      definition,
      prepared,
    });
    if (!published) throw new Error("generation job lost its lease");
    return {published: true, retried: false};
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const retried = await failOrRetryLiveJob({
      db,
      setupRef,
      jobRef,
      leaseId,
      claimId,
      attempt,
      error: message,
    });
    return {published: false, retried};
  }
}

async function failOrRetryLiveJob(options: {
  db: Firestore;
  setupRef: FirebaseFirestore.DocumentReference;
  jobRef: FirebaseFirestore.DocumentReference;
  leaseId: string;
  claimId: string;
  attempt: number;
  error: string;
}): Promise<boolean> {
  return options.db.runTransaction(async (tx) => {
    const [snapshot, jobSnapshot] = await Promise.all([
      tx.get(options.setupRef),
      tx.get(options.jobRef),
    ]);
    if (
      !snapshot.exists ||
      snapshot.data()?.generation?.leaseId !== options.leaseId ||
      !jobSnapshot.exists ||
      jobSnapshot.data()?.status !== "generating" ||
      jobSnapshot.data()?.claimId !== options.claimId
    ) {
      return false;
    }
    if (options.attempt < 2) {
      tx.update(options.jobRef, {
        status: "queued",
        claimId: null,
        leaseExpiresAtMs: null,
        attempt: options.attempt + 1,
        lastError: options.error,
        updatedAt: FieldValue.serverTimestamp(),
      });
      return true;
    }
    const generation = snapshot.data()?.generation ?? {};
    const completed = Number(generation.completedJobs ?? 0) + 1;
    const successful = Number(generation.successfulJobs ?? 0);
    const requested = Number(generation.requestedBatch ?? 0);
    const finished = completed >= requested;
    tx.update(options.jobRef, {
      status: "failed",
      error: options.error,
      claimId: null,
      leaseExpiresAtMs: null,
      completedAt: FieldValue.serverTimestamp(),
    });
    tx.update(options.setupRef, {
      "generation.completedJobs": completed,
      "generation.successfulJobs": successful,
      "generation.status": finished ? "idle" : "generating",
      "generation.leaseId": finished ? null : options.leaseId,
      "generation.leaseExpiresAtMs": finished ?
        null :
        Date.now() + LIVE_GENERATION_LEASE_MS,
      "generation.lastError": options.error,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return false;
  });
}

async function publishPreparedHandJob(options: {
  db: Firestore;
  setupRef: FirebaseFirestore.DocumentReference;
  jobRef: FirebaseFirestore.DocumentReference;
  leaseId: string;
  claimId: string;
  definition: LiveHandDefinition;
  prepared: Awaited<ReturnType<typeof prepareLiveHand>>;
}): Promise<boolean> {
  const handRef = options.setupRef.collection("hands").doc(
    options.definition.handId,
  );
  return options.db.runTransaction(async (tx) => {
    const [setupSnapshot, jobSnapshot, handSnapshot] = await Promise.all([
      tx.get(options.setupRef),
      tx.get(options.jobRef),
      tx.get(handRef),
    ]);
    if (
      !setupSnapshot.exists ||
      setupSnapshot.data()?.generation?.leaseId !== options.leaseId ||
      !jobSnapshot.exists ||
      jobSnapshot.data()?.status !== "generating" ||
      jobSnapshot.data()?.claimId !== options.claimId
    ) {
      return false;
    }
    if (handSnapshot.exists) {
      throw new Error("duplicate generated hand");
    }
    const generation = setupSnapshot.data()?.generation ?? {};
    const completed = Number(generation.completedJobs ?? 0) + 1;
    const successful = Number(generation.successfulJobs ?? 0) + 1;
    const requested = Number(generation.requestedBatch ?? 0);
    const finished = completed >= requested;
    tx.create(handRef, {
      handId: options.definition.handId,
      setupKey: options.definition.setupKey,
      definition: options.definition,
      status: "ready",
      rootStateHash: options.prepared.root.stateHash,
      warmBranchCount: options.prepared.warmEdges.length,
      timesServed: 0,
      generatedAt: FieldValue.serverTimestamp(),
    });
    writeNodeTransaction(tx, handRef, options.prepared.root);
    for (const edge of options.prepared.warmEdges) {
      writeNodeTransaction(tx, handRef, edge.child);
      tx.set(
        handRef
          .collection("nodes")
          .doc(edge.parentStateHash)
          .collection("actions")
          .doc(actionDocId(edge.actionId)),
        {
          status: "ready",
          actionId: edge.actionId,
          childStateHash: edge.child.stateHash,
          events: edge.events,
          coaching: edge.coaching,
          generatedAt: FieldValue.serverTimestamp(),
        },
      );
    }
    tx.update(options.jobRef, {
      status: "published",
      handId: options.definition.handId,
      claimId: null,
      leaseExpiresAtMs: null,
      completedAt: FieldValue.serverTimestamp(),
    });
    tx.update(options.setupRef, {
      handCount: FieldValue.increment(1),
      "generation.completedJobs": completed,
      "generation.successfulJobs": successful,
      "generation.status": finished ? "idle" : "generating",
      "generation.leaseId": finished ? null : options.leaseId,
      "generation.leaseExpiresAtMs": finished ?
        null :
        Date.now() + LIVE_GENERATION_LEASE_MS,
      "generation.lastError": null,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return true;
  });
}

function writeNodeTransaction(
  tx: FirebaseFirestore.Transaction,
  handRef: FirebaseFirestore.DocumentReference,
  node: PreparedLiveNode,
): void {
  tx.set(handRef.collection("nodes").doc(node.stateHash), {
    stateHash: node.stateHash,
    state: node.state,
    history: node.history,
    legalActions: node.legalActions,
    rubric: node.rubric,
    createdAt: FieldValue.serverTimestamp(),
  });
}

export function actionDocId(actionId: string): string {
  return Buffer.from(actionId).toString("base64url");
}

function isPreparedNodeData(
  data: DocumentData | undefined,
): data is DocumentData & {
  stateHash: string;
  state: PreparedLiveNode["state"];
  history: PreparedLiveNode["history"];
  legalActions: PreparedLiveNode["legalActions"];
  rubric: PreparedLiveNode["rubric"];
} {
  return !!data &&
    typeof data.stateHash === "string" &&
    !!data.state &&
    Array.isArray(data.history) &&
    Array.isArray(data.legalActions);
}

export function preparedNodeFromData(
  data: DocumentData,
): PreparedLiveNode {
  if (!isPreparedNodeData(data)) throw new Error("invalid prepared node data");
  return {
    stateHash: data.stateHash,
    state: data.state,
    history: data.history,
    legalActions: data.legalActions,
    rubric: data.rubric ?? null,
  };
}

/** Lease expiry helper used by tests and operational diagnostics. */
export function liveLeaseExpired(
  expiresAt: Timestamp | number | null | undefined,
  nowMs = Date.now(),
): boolean {
  if (expiresAt instanceof Timestamp) return expiresAt.toMillis() <= nowMs;
  return Number(expiresAt ?? 0) <= nowMs;
}
