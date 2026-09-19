/**
 * Queues refill for popular Random Pool setups so cold starts are rare.
 */

import {getFirestore, type Firestore} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {
  ensureTableSetupDoc,
  poolRefs,
  requestPoolRefill,
} from "./pool";
import {buildSetupKey} from "./setup_key";
import {
  NEVER_SERVED_LOW_WATER,
  type TableSetupInput,
} from "./situation_types";
import {shouldRefillPool} from "./validate_situation";

/** Popular seat counts for Random Pool pre-warm. */
export const PREWARM_SEAT_COUNTS = [6, 9] as const;

/** Popular stack depths (BB) for Random Pool pre-warm. */
export const PREWARM_STACK_DEPTH_BB = [100, 200] as const;

/** Default stakes used for Random Pool pre-warm. */
export const PREWARM_SMALL_BLIND = 1;
export const PREWARM_BIG_BLIND = 2;

/**
 * Builds the canonical Random setups that should stay warm.
 */
export function commonRandomSetups(): TableSetupInput[] {
  const setups: TableSetupInput[] = [];
  for (const seatCount of PREWARM_SEAT_COUNTS) {
    for (const stackBb of PREWARM_STACK_DEPTH_BB) {
      setups.push({
        mode: "random",
        seatCount,
        smallBlind: PREWARM_SMALL_BLIND,
        bigBlind: PREWARM_BIG_BLIND,
        ante: 0,
        startingStack: stackBb * PREWARM_BIG_BLIND,
      });
    }
  }
  return setups;
}

export interface PrewarmResult {
  setupKey: string;
  queued: boolean;
  neverServedCount: number;
  situationCount: number;
}

/**
 * Ensures each common setup exists and queues a refill when inventory is low.
 *
 * Does not call Gemini directly — the existing Firestore worker handles work.
 */
export async function prewarmCommonSituationPools(options: {
  db?: Firestore;
  setups?: TableSetupInput[];
  ensureSetup?: typeof ensureTableSetupDoc;
  queueRefill?: typeof requestPoolRefill;
} = {}): Promise<PrewarmResult[]> {
  const db = options.db ?? getFirestore();
  const setups = options.setups ?? commonRandomSetups();
  const ensureSetup = options.ensureSetup ?? ensureTableSetupDoc;
  const queueRefill = options.queueRefill ?? requestPoolRefill;
  const results: PrewarmResult[] = [];

  for (const setup of setups) {
    const setupKey = buildSetupKey(setup);
    await ensureSetup(db, setup, setupKey);
    const snap = await poolRefs(db, setupKey).setupRef.get();
    const data = snap.data() ?? {};
    const neverServedCount = Number(data.neverServedCount ?? 0);
    const situationCount = Number(data.situationCount ?? 0);
    const needsRefill =
      situationCount === 0 ||
      shouldRefillPool(neverServedCount, NEVER_SERVED_LOW_WATER);

    let queued = false;
    if (needsRefill) {
      queued = await queueRefill({
        db,
        setupKey,
        reason: situationCount === 0 ? "empty" : "low-water",
      });
    }

    results.push({
      setupKey,
      queued,
      neverServedCount,
      situationCount,
    });
    logger.info("prewarm setup checked", {
      setupKey,
      queued,
      neverServedCount,
      situationCount,
      needsRefill,
    });
  }

  return results;
}
