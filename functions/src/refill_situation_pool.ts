/**
 * Firestore-triggered asynchronous situation-pool refill worker.
 */

import {getFirestore, type Firestore} from "firebase-admin/firestore";
import {maybeRefillPool, type RefillResult} from "./pool";
import {parseTableSetupInput} from "./setup_key";
import type {TableSetupInput} from "./situation_types";

/**
 * Returns true only for the queued state that should wake the worker.
 */
export function isQueuedGeneration(
  data: Record<string, unknown> | undefined,
): boolean {
  const generation = data?.generation;
  return Boolean(
    generation &&
      typeof generation === "object" &&
      (generation as {status?: unknown}).status === "queued",
  );
}

/**
 * Reconstructs the canonical generation input persisted on a setup document.
 */
export function setupInputFromDocument(
  data: Record<string, unknown>,
): TableSetupInput {
  const mode = data.mode;
  const raw: Record<string, unknown> = {
    mode,
    seatCount: data.seatCount,
    smallBlind: data.smallBlind,
    bigBlind: data.bigBlind,
    ante: data.ante,
    startingStack: data.startingStack,
  };

  if (mode === "custom") {
    raw.buttonSeat = data.buttonSeat;
    raw.heroSeat = data.heroSeat;
    if (Array.isArray(data.lineup)) {
      raw.lineup = data.lineup;
    } else if (Array.isArray(data.lineupArchetypes)) {
      raw.lineup = data.lineupArchetypes.map((archetype, seat) => ({
        seat,
        archetype,
      }));
    }
  }
  return parseTableSetupInput(raw);
}

/**
 * Runs one queued refill. The lease acquisition re-checks that the current
 * document is still queued, making stale/retried trigger deliveries no-ops.
 */
export async function refillQueuedSetup(options: {
  setupKey: string;
  afterData: Record<string, unknown> | undefined;
  apiKey: string;
  db?: Firestore;
  refill?: typeof maybeRefillPool;
}): Promise<RefillResult | null> {
  if (!isQueuedGeneration(options.afterData)) return null;
  const setup = setupInputFromDocument(options.afterData ?? {});
  return (options.refill ?? maybeRefillPool)({
    db: options.db ?? getFirestore(),
    apiKey: options.apiKey,
    setup,
    setupKey: options.setupKey,
    force: true,
    requireQueued: true,
  });
}
