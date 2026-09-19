/**
 * Quality and privacy invariants for live deals, tendencies, and coaching.
 */

import {describe, expect, test} from "vitest";
import {buildCoachingFacts, assertFairCoachingFacts} from "./coaching_facts";
import {
  buildRandomLiveLineup,
  validateLiveHandDefinition,
} from "./live_hand_generation";
import {
  createInitialLiveState,
  legalLiveActions,
} from "./live_poker_engine";
import {DEFAULT_LIVE_SETUP, buildLiveSetupKey} from "./live_setup";
import {generateTendencyProfile, validateTendencyProfile} from "./tendency_profiles";
import {
  LIVE_PAYLOAD_VERSION,
  type LiveHandDefinition,
} from "./live_types";
import type {VillainArchetype} from "./situation_types";

function definition(): LiveHandDefinition {
  const setup = DEFAULT_LIVE_SETUP;
  const lineup = buildRandomLiveLineup(setup, "quality-seed");
  const cards = [
    ["Ah", "Qd"],
    ["Ks", "Kh"],
    ["Jc", "Tc"],
    ["9s", "9h"],
    ["7c", "6c"],
    ["Ad", "Kd"],
  ] as Array<[string, string]>;
  return {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "live-hand-v3.0",
    handId: "quality-hand",
    setupKey: buildLiveSetupKey(setup),
    setup,
    buttonSeat: 3,
    seats: lineup.map((seat) => ({
      ...seat,
      startingStack: seat.seat === 0 ? 400 : 80 + seat.seat * 50,
      holeCards: cards[seat.seat],
    })),
    runout: ["2s", "3d", "4h", "8d", "Qc"],
    source: "gemini",
    modelId: "test",
  };
}

describe("live quality invariants", () => {
  test("every generated tendency remains inside its archetype template", () => {
    const archetypes: VillainArchetype[] = [
      "NIT",
      "CALLING_STATION",
      "MANIAC",
      "TAG",
      "LAG",
    ];
    for (const archetype of archetypes) {
      for (let index = 0; index < 50; index++) {
        const profile = generateTendencyProfile(archetype, `seed-${index}`);
        expect(validateTendencyProfile(profile)).toEqual([]);
        expect(profile.reads.length).toBeGreaterThanOrEqual(2);
      }
    }
  });

  test("random lineups vary by hand and expose bounded villain reads", () => {
    const first = buildRandomLiveLineup(DEFAULT_LIVE_SETUP, "first");
    const second = buildRandomLiveLineup(DEFAULT_LIVE_SETUP, "second");
    expect(first.map((seat) => seat.archetype)).not.toEqual(
      second.map((seat) => seat.archetype),
    );
    expect(first[0].archetype).toBe("HERO");
    expect(first.slice(1).every((seat) => seat.tendency)).toBe(true);
  });

  test("deal validator rejects collisions and out-of-bounds stacks", () => {
    const hand = definition();
    expect(validateLiveHandDefinition(hand)).toEqual([]);
    const invalid: LiveHandDefinition = {
      ...hand,
      seats: hand.seats.map((seat) =>
        seat.seat === 1 ?
          {...seat, startingStack: 20, holeCards: ["Ah", "2d"]} :
          seat,
      ),
    };
    expect(validateLiveHandDefinition(invalid)).toEqual(
      expect.arrayContaining([
        expect.stringContaining("outside 20..max BB"),
        expect.stringContaining("globally unique"),
      ]),
    );
  });

  test("coaching facts exclude villain cards and future runout", () => {
    const hand = definition();
    const state = createInitialLiveState(hand);
    // Move actor directly to Hero for a pure projection/privacy test.
    state.actorSeat = hand.setup.heroSeat;
    const facts = buildCoachingFacts({
      hand,
      state,
      legalActions: legalLiveActions(hand, state),
      publicHistory: [],
    });
    expect(() => assertFairCoachingFacts(facts)).not.toThrow();
    const serialized = JSON.stringify(facts);
    expect(serialized).toContain("Ah");
    expect(serialized).toContain("Qd");
    expect(serialized).not.toContain("Kh");
    expect(serialized).not.toContain("2s");
  });

  test("changing hidden cards and future runout cannot change coaching facts", () => {
    const first = definition();
    const second: LiveHandDefinition = {
      ...first,
      seats: first.seats.map((seat) =>
        seat.seat === 1 ? {...seat, holeCards: ["5s", "5h"]} : seat,
      ),
      runout: ["6s", "7d", "8h", "Td", "Jc"],
    };
    const firstState = createInitialLiveState(first);
    const secondState = createInitialLiveState(second);
    firstState.actorSeat = 0;
    secondState.actorSeat = 0;
    const project = (hand: LiveHandDefinition, state: typeof firstState) =>
      buildCoachingFacts({
        hand,
        state,
        legalActions: legalLiveActions(hand, state),
        publicHistory: [],
      });
    expect(project(first, firstState)).toEqual(project(second, secondState));
  });
});
