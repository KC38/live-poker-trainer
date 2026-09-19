/**
 * Pool metadata, generation leases, and situation publication.
 */

import {randomUUID} from "crypto";
import {
  FieldValue,
  getFirestore,
  type CollectionReference,
  type DocumentReference,
  type Firestore,
} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {HttpsError} from "firebase-functions/v2/https";
import {hashSituationStructure} from "./content_hash";
import {
  generateValidatedSituation,
  type GenerateSituationResult,
} from "./gemini";
import {
  GENERATION_LEASE_MS,
  INITIAL_POOL_SIZE,
  NEVER_SERVED_LOW_WATER,
  REFILL_BATCH_SIZE,
  SITUATION_SCHEMA_VERSION,
  type PoolRefillReason,
  type TableSetupInput,
} from "./situation_types";
import {buildSetupKey, modeFromSetupKey} from "./setup_key";
import {shouldRefillPool} from "./validate_situation";

export const MAX_GLOBAL_SETUPS = 500;

/**
 * Returns refs for a setup pool.
 */
export function poolRefs(
  db: Firestore,
  setupKey: string,
): {
  setupRef: DocumentReference;
  situations: CollectionReference;
} {
  const setupRef = db.collection("tableSetups").doc(setupKey);
  return {
    setupRef,
    situations: setupRef.collection("situations"),
  };
}

/**
 * Ensures the setup metadata doc exists.
 */
export async function ensureTableSetupDoc(
  db: Firestore,
  setup: TableSetupInput,
  setupKey: string = buildSetupKey(setup),
): Promise<void> {
  const {setupRef} = poolRefs(db, setupKey);
  const limitRef = db.collection("system").doc("situationPoolLimits");
  await db.runTransaction(async (tx) => {
    const [snap, limitSnap] = await Promise.all([
      tx.get(setupRef),
      tx.get(limitRef),
    ]);
    if (snap.exists) return;

    const setupCount = Number(limitSnap.data()?.setupCount ?? 0);
    if (!Number.isSafeInteger(setupCount) || setupCount < 0) {
      throw new Error("Invalid global setup counter");
    }
    if (setupCount >= MAX_GLOBAL_SETUPS) {
      throw new HttpsError(
        "resource-exhausted",
        "Global table setup capacity reached. Retry with an existing setup.",
      );
    }

    tx.set(setupRef, {
      setupKey,
      mode: setup.mode,
      seatCount: setup.seatCount,
      smallBlind: setup.smallBlind,
      bigBlind: setup.bigBlind,
      ante: setup.ante ?? 0,
      startingStack: setup.startingStack,
      buttonSeat: setup.buttonSeat ?? null,
      heroSeat: setup.heroSeat ?? null,
      lineupArchetypes: setup.lineup?.map((s) => s.archetype) ?? null,
      lineup:
        setup.lineup?.map((seat) => ({
          seat: seat.seat,
          archetype: seat.archetype,
          ...(seat.name ? {name: seat.name} : {}),
        })) ?? null,
      situationCount: 0,
      neverServedCount: 0,
      generation: {
        status: "idle",
        leaseId: null,
        leaseExpiresAtMs: null,
        lastBatchSize: 0,
        lastError: null,
        requestedAt: null,
        requestReason: null,
      },
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(limitRef, {
      setupCount: setupCount + 1,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
}

export interface RefillResult {
  attempted: boolean;
  added: number;
  skipped: number;
  errors: string[];
  leaseHeldByOther: boolean;
}

/**
 * Queues a refill exactly once while no active generation lease exists.
 *
 * An already queued request and a non-expired generating lease are left
 * untouched. Expired generation leases can be replaced by a queued request.
 */
export async function requestPoolRefill(options: {
  db: Firestore;
  setupKey: string;
  reason: PoolRefillReason;
  nowMs?: number;
}): Promise<boolean> {
  const {setupRef} = poolRefs(options.db, options.setupKey);
  const nowMs = options.nowMs ?? Date.now();
  return options.db.runTransaction(async (tx) => {
    const snap = await tx.get(setupRef);
    const generation = (snap.data()?.generation ?? {}) as {
      status?: string;
      leaseExpiresAtMs?: number | null;
    };
    if (generation.status === "queued") return false;
    if (
      generation.status === "generating" &&
      Number(generation.leaseExpiresAtMs ?? 0) > nowMs
    ) {
      return false;
    }

    tx.set(
      setupRef,
      {
        generation: {
          status: "queued",
          leaseId: null,
          leaseExpiresAtMs: null,
          lastBatchSize: 0,
          lastError: null,
          requestedAt: FieldValue.serverTimestamp(),
          requestReason: options.reason,
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    return true;
  });
}

/**
 * Tries to acquire a generation lease and publish a batch of situations.
 *
 * Concurrent callers without the lease return quickly with leaseHeldByOther.
 */
export async function maybeRefillPool(options: {
  db?: Firestore;
  apiKey: string;
  setup: TableSetupInput;
  setupKey?: string;
  batchSize?: number;
  force?: boolean;
  requireQueued?: boolean;
  generateFn?: typeof generateValidatedSituation;
}): Promise<RefillResult> {
  const db = options.db ?? getFirestore();
  const setupKey = options.setupKey ?? buildSetupKey(options.setup);
  await ensureTableSetupDoc(db, options.setup, setupKey);

  const {setupRef, situations} = poolRefs(db, setupKey);
  const setupSnap = await setupRef.get();
  const data = setupSnap.data() ?? {};
  const neverServed = Number(data.neverServedCount ?? 0);
  const situationCount = Number(data.situationCount ?? 0);
  const batchSize =
    options.batchSize ??
    (situationCount === 0 ? INITIAL_POOL_SIZE : REFILL_BATCH_SIZE);

  if (
    !options.force &&
    situationCount > 0 &&
    !shouldRefillPool(neverServed, NEVER_SERVED_LOW_WATER)
  ) {
    return {
      attempted: false,
      added: 0,
      skipped: 0,
      errors: [],
      leaseHeldByOther: false,
    };
  }

  const leaseId = randomUUID();
  const acquired = await acquireGenerationLease(
    db,
    setupKey,
    leaseId,
    Date.now(),
    GENERATION_LEASE_MS,
    options.requireQueued ?? false,
  );
  if (!acquired) {
    return {
      attempted: false,
      added: 0,
      skipped: 0,
      errors: [],
      leaseHeldByOther: true,
    };
  }

  const generateFn = options.generateFn ?? generateValidatedSituation;
  let added = 0;
  let skipped = 0;
  const errors: string[] = [];

  try {
    const batch = await runConcurrentGenerationBatch({
      apiKey: options.apiKey,
      setup: options.setup,
      setupKey,
      leaseId,
      batchSize,
      generateFn,
      publishFn: async (generatedResult) => {
        const contentHash = hashSituationStructure(generatedResult.payload);
        const situationId = contentHash.slice(0, 32);
        const ref = situations.doc(situationId);
        return db.runTransaction(async (tx) => {
          const existing = await tx.get(ref);
          if (existing.exists) return false;
          tx.set(ref, {
            situationId,
            setupKey,
            payload: generatedResult.payload,
            payloadVersion: generatedResult.payload.payloadVersion,
            schemaVersion:
              generatedResult.payload.schemaVersion ?? SITUATION_SCHEMA_VERSION,
            source: "gemini",
            modelId: generatedResult.modelId,
            contentHash,
            timesServed: 0,
            generatedAt: FieldValue.serverTimestamp(),
            validation: {
              ok: true,
              checkedAt: FieldValue.serverTimestamp(),
            },
          });
          tx.set(
            setupRef,
            {
              situationCount: FieldValue.increment(1),
              neverServedCount: FieldValue.increment(1),
              updatedAt: FieldValue.serverTimestamp(),
            },
            {merge: true},
          );
          return true;
        });
      },
    });
    added = batch.added;
    skipped = batch.skipped;
    errors.push(...batch.errors);

    await finishGenerationLease({
      db,
      setupKey,
      leaseId,
      added,
      lastError: errors[0] ?? null,
    });
  } catch (err) {
    await releaseGenerationLease(db, setupKey, leaseId, errorMessage(err));
    throw err;
  }

  logger.info("pool refill completed", {
    setupKey,
    mode: modeFromSetupKey(setupKey),
    added,
    skipped,
    errors: errors.length,
  });

  return {
    attempted: true,
    added,
    skipped,
    errors,
    leaseHeldByOther: false,
  };
}

/**
 * Transactionally acquires a generation lease when idle or expired.
 */
export async function acquireGenerationLease(
  db: Firestore,
  setupKey: string,
  leaseId: string,
  nowMs: number = Date.now(),
  ttlMs: number = GENERATION_LEASE_MS,
  requireQueued: boolean = false,
): Promise<boolean> {
  const {setupRef} = poolRefs(db, setupKey);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(setupRef);
    const data = snap.data() ?? {};
    const gen = (data.generation ?? {}) as {
      status?: string;
      leaseExpiresAtMs?: number | null;
    };
    const expires = Number(gen.leaseExpiresAtMs ?? 0);
    const held = gen.status === "generating" && expires > nowMs;
    if (held) return false;
    if (requireQueued && gen.status !== "queued") return false;

    tx.set(
      setupRef,
      {
        generation: {
          status: "generating",
          leaseId,
          leaseExpiresAtMs: nowMs + ttlMs,
          lastBatchSize: 0,
          lastError: null,
          requestedAt: null,
          requestReason: null,
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    return true;
  });
}

/**
 * Clears a lease after failure (only if we still own it).
 */
export async function releaseGenerationLease(
  db: Firestore,
  setupKey: string,
  leaseId: string,
  lastError?: string,
): Promise<void> {
  const {setupRef} = poolRefs(db, setupKey);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(setupRef);
    const data = snap.data() ?? {};
    const gen = (data.generation ?? {}) as {leaseId?: string | null};
    if (gen.leaseId !== leaseId) return;
    tx.set(
      setupRef,
      {
        generation: {
          status: "idle",
          leaseId: null,
          leaseExpiresAtMs: null,
          lastBatchSize: 0,
          lastError: lastError ?? null,
          requestedAt: null,
          requestReason: null,
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
  });
}

/**
 * Pure lease decision helper for unit tests.
 */
export function canAcquireLease(options: {
  status: string;
  leaseExpiresAtMs: number | null;
  nowMs: number;
}): boolean {
  if (options.status !== "generating") return true;
  const expires = options.leaseExpiresAtMs ?? 0;
  return expires <= options.nowMs;
}

async function finishGenerationLease(options: {
  db: Firestore;
  setupKey: string;
  leaseId: string;
  added: number;
  lastError: string | null;
}): Promise<void> {
  const {setupRef} = poolRefs(options.db, options.setupKey);
  await options.db.runTransaction(async (tx) => {
    const snap = await tx.get(setupRef);
    const generation = (snap.data()?.generation ?? {}) as {
      leaseId?: string | null;
    };
    if (generation.leaseId !== options.leaseId) return;
    tx.set(
      setupRef,
      {
        generation: {
          status: "idle",
          leaseId: null,
          leaseExpiresAtMs: null,
          lastBatchSize: options.added,
          lastError: options.lastError,
          requestedAt: null,
          requestReason: null,
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
  });
}

function errorMessage(err: unknown): string {
  return err instanceof Error ? err.message : String(err);
}

/**
 * Generates a bounded batch in parallel and publishes each valid result.
 */
export async function runConcurrentGenerationBatch(options: {
  apiKey: string;
  setup: TableSetupInput;
  setupKey: string;
  leaseId: string;
  batchSize: number;
  generateFn: typeof generateValidatedSituation;
  publishFn: (result: GenerateSituationResult) => Promise<boolean>;
}): Promise<{added: number; skipped: number; errors: string[]}> {
  const generated = await Promise.allSettled(
    Array.from({length: options.batchSize}, (_, index) =>
      options.generateFn({
        apiKey: options.apiKey,
        setup: options.setup,
        setupKey: options.setupKey,
        variationSeed: `${options.leaseId}:${index}`,
        maxAttempts: 3,
      }),
    ),
  );

  const errors: string[] = [];
  const publishable: GenerateSituationResult[] = [];
  for (const result of generated) {
    if (result.status === "fulfilled") {
      publishable.push(result.value);
    } else {
      const message = errorMessage(result.reason);
      errors.push(message);
      logger.warn("refill item failed", {
        setupKey: options.setupKey,
        error: message,
      });
    }
  }

  const published = await Promise.all(
    publishable.map((result) => options.publishFn(result)),
  );
  const added = published.filter(Boolean).length;
  return {
    added,
    skipped: published.length - added,
    errors,
  };
}
