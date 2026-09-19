/**
 * Generates and fully warms one in-memory launch-default hand.
 *
 * This production-prompt smoke test writes no Firestore data and prints no
 * private cards.
 */

import {randomUUID} from "node:crypto";
import {generateLiveHandDefinition} from "../src/live_hand_generation";
import {DEFAULT_LIVE_SETUP, buildLiveSetupKey} from "../src/live_setup";
import {prepareLiveHand} from "../src/live_tree";

async function main(): Promise<void> {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) throw new Error("GEMINI_API_KEY is required.");
  const setupKey = buildLiveSetupKey(DEFAULT_LIVE_SETUP);
  const hand = await generateLiveHandDefinition({
    apiKey,
    setup: DEFAULT_LIVE_SETUP,
    setupKey,
    variationSeed: `smoke:${randomUUID()}`,
  });
  const prepared = await prepareLiveHand({apiKey, hand});
  console.log(JSON.stringify({
    ok: true,
    setupKey,
    handId: hand.handId,
    seatCount: hand.seats.length,
    rootActionCount: prepared.root.legalActions.length,
    warmedBranches: prepared.warmEdges.length,
    childStatuses: prepared.warmEdges.map((edge) => edge.child.state.status),
    everyHeroNodeCoached: prepared.warmEdges.every(
      (edge) =>
        edge.child.state.status !== "playing" || edge.child.rubric !== null,
    ),
  }, null, 2));
}

void main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
