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
  SituationGenerationError,
  type GenerateSituationResult,
} from "./gemini";
import {
  emptyGenerationUsage,
  type GenerationUsage,
} from "./generation_usage";
import {
  ASAP_INITIAL_COUNT,
  GEMINI_MODEL_ID,
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
      generationMetrics: {
        ...emptyGenerationUsage(),
        completedRunCount: 0,
        successfulRunCount: 0,
        failedRunCount: 0,
        publishedSituationCount: 0,
      },
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

  const publishFn = async (
    generatedResult: GenerateSituationResult,
    generationRunId: string,
  ) => {
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
        generationRunId,
        generationUsage: generatedResult.usage,
        validationFailureCount: generatedResult.validationFailureCount,
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
  };

  // Empty pools: publish a small ASAP wave first so fetches can allocate,
  // then fill the remainder under the same lease.
  const isEmptyPool = situationCount === 0;
  const firstWaveSize = isEmptyPool ?
    Math.min(ASAP_INITIAL_COUNT, batchSize) :
    batchSize;
  const secondWaveSize = isEmptyPool ?
    Math.max(0, batchSize - firstWaveSize) :
    0;

  try {
    const firstWave = await runConcurrentGenerationBatch({
      apiKey: options.apiKey,
      setup: options.setup,
      setupKey,
      leaseId,
      batchSize: firstWaveSize,
      variationOffset: 0,
      generateFn,
      publishFn,
      recordRunFn: (run) => recordGenerationRun(db, run),
    });
    added += firstWave.added;
    skipped += firstWave.skipped;
    errors.push(...firstWave.errors);

    if (secondWaveSize > 0) {
      const secondWave = await runConcurrentGenerationBatch({
        apiKey: options.apiKey,
        setup: options.setup,
        setupKey,
        leaseId,
        batchSize: secondWaveSize,
        variationOffset: firstWaveSize,
        generateFn,
        publishFn,
        recordRunFn: (run) => recordGenerationRun(db, run),
      });
      added += secondWave.added;
      skipped += secondWave.skipped;
      errors.push(...secondWave.errors);
    }

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

export interface GenerationRunTelemetry {
  runId: string;
  setupKey: string;
  modelId: string;
  status: "published" | "duplicate" | "failed";
  usage: GenerationUsage;
  validationFailureCount: number;
  error?: string;
}

/**
 * Persists one idempotent generation-run record and setup-level token totals.
 */
export async function recordGenerationRun(
  db: Firestore,
  run: GenerationRunTelemetry,
): Promise<void> {
  const {setupRef} = poolRefs(db, run.setupKey);
  const runRef = setupRef.collection("generationRuns").doc(run.runId);
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(runRef);
    if (existing.exists) return;

    tx.set(runRef, {
      ...run,
      error: run.error?.slice(0, 1000) ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      setupRef,
      {
        generationMetrics: {
          pricingVersion: run.usage.pricingVersion,
          modelRequestCount: FieldValue.increment(
            run.usage.modelRequestCount,
          ),
          promptTokenCount: FieldValue.increment(
            run.usage.promptTokenCount,
          ),
          cachedContentTokenCount: FieldValue.increment(
            run.usage.cachedContentTokenCount,
          ),
          candidatesTokenCount: FieldValue.increment(
            run.usage.candidatesTokenCount,
          ),
          thoughtsTokenCount: FieldValue.increment(
            run.usage.thoughtsTokenCount,
          ),
          totalTokenCount: FieldValue.increment(run.usage.totalTokenCount),
          estimatedCostUsdMicros: FieldValue.increment(
            run.usage.estimatedCostUsdMicros,
          ),
          completedRunCount: FieldValue.increment(1),
          successfulRunCount: FieldValue.increment(
            run.status === "failed" ? 0 : 1,
          ),
          failedRunCount: FieldValue.increment(
            run.status === "failed" ? 1 : 0,
          ),
          publishedSituationCount: FieldValue.increment(
            run.status === "published" ? 1 : 0,
          ),
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
  });
}

/**
 * Generates a bounded batch in parallel and publishes each valid result as
 * soon as it succeeds (does not wait for sibling Gemini jobs).
 */
export async function runConcurrentGenerationBatch(options: {
  apiKey: string;
  setup: TableSetupInput;
  setupKey: string;
  leaseId: string;
  batchSize: number;
  /** Offset applied to variation seeds when running multi-wave refills. */
  variationOffset?: number;
  generateFn: typeof generateValidatedSituation;
  publishFn: (
    result: GenerateSituationResult,
    generationRunId: string,
  ) => Promise<boolean>;
  recordRunFn?: (run: GenerationRunTelemetry) => Promise<void>;
}): Promise<{added: number; skipped: number; errors: string[]}> {
  const variationOffset = options.variationOffset ?? 0;
  const outcomes = await Promise.all(
    Array.from({length: options.batchSize}, async (_, index) => {
      const variationIndex = variationOffset + index;
      const runId = `${options.leaseId}-${variationIndex}`;
      try {
        const generated = await options.generateFn({
          apiKey: options.apiKey,
          setup: options.setup,
          setupKey: options.setupKey,
          variationSeed: `${options.leaseId}:${variationIndex}`,
          maxAttempts: 3,
        });
        const published = await options.publishFn(generated, runId);
        await recordRunSafely(options.recordRunFn, {
          runId,
          setupKey: options.setupKey,
          modelId: generated.modelId,
          status: published ? "published" : "duplicate",
          usage: generated.usage ?? emptyGenerationUsage(),
          validationFailureCount: generated.validationFailureCount ?? 0,
        });
        return published ?
          {kind: "added" as const} :
          {kind: "skipped" as const};
      } catch (err) {
        const message = errorMessage(err);
        await recordRunSafely(options.recordRunFn, {
          runId,
          setupKey: options.setupKey,
          modelId: GEMINI_MODEL_ID,
          status: "failed",
          usage: err instanceof SituationGenerationError ?
            err.usage :
            emptyGenerationUsage(),
          validationFailureCount: err instanceof SituationGenerationError ?
            err.validationFailureCount :
            0,
          error: message,
        });
        logger.warn("refill item failed", {
          setupKey: options.setupKey,
          error: message,
        });
        return {kind: "error" as const, message};
      }
    }),
  );

  let added = 0;
  let skipped = 0;
  const errors: string[] = [];
  for (const outcome of outcomes) {
    if (outcome.kind === "added") added += 1;
    else if (outcome.kind === "skipped") skipped += 1;
    else errors.push(outcome.message);
  }
  return {added, skipped, errors};
}

async function recordRunSafely(
  recordRunFn: ((run: GenerationRunTelemetry) => Promise<void>) | undefined,
  run: GenerationRunTelemetry,
): Promise<void> {
  if (!recordRunFn) return;
  try {
    await recordRunFn(run);
  } catch (err) {
    logger.error("generation usage recording failed", {
      runId: run.runId,
      setupKey: run.setupKey,
      error: errorMessage(err),
    });
  }
}
