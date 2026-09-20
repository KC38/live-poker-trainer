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

  test("all-in opponents do not zero Hero's effective stack", () => {
    const hand = definition();
    const state = createInitialLiveState(hand);
    const hero = state.players[hand.setup.heroSeat];
    hero.stack = 136;
    hero.contribution = 100;
    hero.streetBet = 0;
    for (const player of state.players) {
      if (player.seat === hero.seat) continue;
      player.folded = player.seat > 2;
      player.stack = 0;
      player.allIn = !player.folded;
      player.streetBet = player.folded ? 0 : 80;
      player.contribution = player.folded ? 0 : 100;
    }
    state.street = "turn";
    state.highestBet = 80;
    state.actorSeat = hero.seat;
    const facts = buildCoachingFacts({
      hand,
      state,
      legalActions: [],
      publicHistory: [],
    });
    expect(facts.heroStack).toBe(136);
    expect(facts.effectiveStack).toBe(136);
    expect(facts.spr).toBe(0.5);
  });

  test("a micro stack still reports a non-zero SPR", () => {
    const hand = definition();
    const state = createInitialLiveState(hand);
    const hero = state.players[hand.setup.heroSeat];
    hero.stack = 26;
    hero.contribution = 200;
    for (const player of state.players) {
      if (player.seat === hero.seat) continue;
      player.folded = player.seat > 1;
      player.stack = 0;
      player.allIn = !player.folded;
      player.contribution = player.folded ? 0 : 589;
    }
    state.actorSeat = hero.seat;
    const facts = buildCoachingFacts({
      hand,
      state,
      legalActions: [],
      publicHistory: [],
      equityIterations: 1,
    });
    expect(facts.effectiveStack).toBe(26);
    expect(facts.pot).toBe(789);
    expect(facts.spr).toBe(0.03);
  });

  test("flop nut straight is labeled straight with flush draw", () => {
    const hand = definition();
    hand.seats[hand.setup.heroSeat].holeCards = ["Js", "Ts"];
    hand.runout = ["Qs", "9s", "8d", "2c", "3h"];
    const state = createInitialLiveState(hand);
    state.street = "flop";
    state.board = hand.runout.slice(0, 3);
    state.actorSeat = hand.setup.heroSeat;
    const facts = buildCoachingFacts({
      hand,
      state,
      legalActions: [],
      publicHistory: [],
      equityIterations: 1,
    });
    expect(facts.heroFeatures).toEqual(
      expect.arrayContaining(["straight", "flush-draw"]),
    );
    expect(facts.heroFeatures).not.toContain("high-card");
  });

  test("pair and trips strength tags follow the board", () => {
    const hand = definition();
    hand.seats[hand.setup.heroSeat].holeCards = ["Ah", "Qc"];
    hand.runout = ["Kh", "Qh", "9c", "5d", "Qd"];
    const turn = createInitialLiveState(hand);
    turn.street = "turn";
    turn.board = hand.runout.slice(0, 4);
    turn.actorSeat = hand.setup.heroSeat;
    const turnFacts = buildCoachingFacts({
      hand,
      state: turn,
      legalActions: [],
      publicHistory: [],
      equityIterations: 1,
    });
    expect(turnFacts.heroFeatures).toEqual(
      expect.arrayContaining(["one-pair", "second-pair"]),
    );
    expect(turnFacts.heroFeatures).not.toContain("trips");

    const river = createInitialLiveState(hand);
    river.street = "river";
    river.board = hand.runout.slice(0, 5);
    river.actorSeat = hand.setup.heroSeat;
    const riverFacts = buildCoachingFacts({
      hand,
      state: river,
      legalActions: [],
      publicHistory: [],
      equityIterations: 1,
    });
    expect(riverFacts.heroFeatures).toEqual(
      expect.arrayContaining(["trips-or-better", "trips"]),
    );
    expect(riverFacts.heroFeatures).not.toContain("second-pair");
    expect(riverFacts.heroFeatures).not.toContain("one-pair");
  });
});
