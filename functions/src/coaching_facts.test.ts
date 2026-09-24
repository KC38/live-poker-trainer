/**
 * Unit tests for exploit-coach facts: hand labels, position, and privacy.
 */

import {describe, expect, it} from "vitest";
import {
  assertFairCoachingFacts,
  buildCoachingFacts,
  type CoachingFacts,
} from "./coaching_facts";
import {createInitialLiveState} from "./live_poker_engine";
import {
  LIVE_PAYLOAD_VERSION,
  type LiveHandDefinition,
  type LiveStreet,
} from "./live_types";

function factsFor(options: {
  seatCount?: number;
  heroSeat?: number;
  buttonSeat?: number;
  heroCards?: [string, string];
  street?: LiveStreet;
  board?: string[];
  contributions?: number[];
  heroStack?: number;
  highestBet?: number;
  heroStreetBet?: number;
} = {}): ReturnType<typeof buildCoachingFacts> {
  const seatCount = options.seatCount ?? 2;
  const heroSeat = options.heroSeat ?? 0;
  const buttonSeat = options.buttonSeat ?? 0;
  const heroCards = options.heroCards ?? ["Ah", "Kd"];
  const street = options.street ?? "flop";
  const board = options.board ?? [];
  const hand: LiveHandDefinition = {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "live-hand-v3.0",
    handId: "facts-hand",
    setupKey: "test",
    setup: {
      mode: "random",
      seatCount,
      smallBlind: 1,
      bigBlind: 2,
      maxStackDepthBb: 200,
      heroSeat,
    },
    buttonSeat,
    seats: Array.from({length: seatCount}, (_, seat) => ({
      seat,
      name: seat === heroSeat ? "Hero" : `V${seat}`,
      archetype: seat === heroSeat ? "HERO" as const : "TAG" as const,
      startingStack: 200,
      holeCards: seat === heroSeat ? heroCards : ["8c", "9c"],
    })),
    runout: ["2s", "3d", "4h", "5c", "6s"],
    source: "gemini",
    modelId: "test",
  };
  const state = createInitialLiveState(hand);
  state.street = street;
  state.board = [...board];
  state.actorSeat = heroSeat;
  state.highestBet = options.highestBet ?? 0;
  for (const player of state.players) {
    if (player.seat === heroSeat) {
      player.stack = options.heroStack ?? player.stack;
      player.streetBet = options.heroStreetBet ?? 0;
      player.folded = false;
    } else {
      player.folded = true;
    }
    if (options.contributions) {
      player.contribution = options.contributions[player.seat] ?? 0;
    }
  }
  return buildCoachingFacts({
    hand,
    state,
    legalActions: [],
    publicHistory: [],
    equityIterations: 1,
  });
}

describe("hero feature labels", () => {
  it("labels preflop shape without inventing a board feature", () => {
    expect(factsFor({
      street: "preflop",
      heroCards: ["Ah", "Kh"],
    }).heroFeatures).toEqual(["suited", "connected", "high-card"]);
    expect(factsFor({
      street: "preflop",
      heroCards: ["8h", "8d"],
    }).heroFeatures).toEqual(["pocket-pair"]);
    expect(factsFor({
      street: "preflop",
      heroCards: ["9h", "7h"],
    }).heroFeatures).toEqual(["suited"]);
    expect(factsFor({
      street: "preflop",
      heroCards: ["7h", "2d"],
    }).heroFeatures).toEqual(["unpaired"]);
    expect(factsFor({street: "preflop"}).boardTexture).toEqual(["preflop"]);
  });

  it("tags pair strength, sets, and trips from the board", () => {
    expect(factsFor({
      heroCards: ["Ah", "Ad"],
      board: ["Ks", "7d", "2h"],
    }).heroFeatures).toEqual(["one-pair", "overpair"]);
    expect(factsFor({
      heroCards: ["5h", "5d"],
      board: ["Ks", "9d", "7h"],
    }).heroFeatures).toEqual(["one-pair", "underpair"]);
    expect(factsFor({
      heroCards: ["Ah", "Kd"],
      board: ["As", "9d", "2h"],
    }).heroFeatures).toEqual(["one-pair", "top-pair"]);
    expect(factsFor({
      heroCards: ["7h", "6d"],
      board: ["Ks", "9d", "7c"],
    }).heroFeatures).toEqual(["one-pair", "third-pair"]);
    expect(factsFor({
      street: "turn",
      heroCards: ["4h", "3d"],
      board: ["Ks", "9d", "7c", "4d"],
    }).heroFeatures).toEqual(["one-pair", "weak-pair"]);
    expect(factsFor({
      heroCards: ["Ah", "Kd"],
      board: ["Qs", "Qh", "2d"],
    }).heroFeatures).toEqual(["one-pair"]);
    expect(factsFor({
      heroCards: ["9h", "9d"],
      board: ["9s", "4c", "2h"],
    }).heroFeatures).toEqual(["trips-or-better", "set"]);
    expect(factsFor({
      heroCards: ["Ah", "Qd"],
      board: ["Qh", "Qc", "2d"],
    }).heroFeatures).toEqual(["trips-or-better", "trips"]);
  });

  it("labels draws only when the made hand is below a straight", () => {
    expect(factsFor({
      heroCards: ["9h", "8d"],
      board: ["Tc", "7d", "2h"],
    }).heroFeatures).toEqual(["high-card", "oesd"]);
    expect(factsFor({
      heroCards: ["Jh", "Td"],
      board: ["9c", "7d", "2h"],
    }).heroFeatures).toEqual(["high-card", "gutshot"]);
    expect(factsFor({
      heroCards: ["Ah", "Kh"],
      board: ["Qh", "9d", "2h"],
    }).heroFeatures).toEqual(["high-card", "flush-draw"]);
    expect(factsFor({
      heroCards: ["As", "Kd"],
      board: ["Qh", "Jc", "Ts"],
    }).heroFeatures).toEqual(["straight"]);
    expect(factsFor({
      heroCards: ["As", "Ks"],
      board: ["Qs", "9s", "2s"],
    }).heroFeatures).toEqual(["flush"]);
    expect(factsFor({
      heroCards: ["Ah", "Kh"],
      board: ["Qh", "Jh", "Th"],
    }).heroFeatures).toEqual(["straight-flush"]);
    expect(factsFor({
      heroCards: ["Ah", "Ad"],
      board: ["As", "Ac", "2d"],
    }).heroFeatures).toEqual(["quads"]);
    expect(factsFor({
      heroCards: ["Ah", "Ad"],
      board: ["As", "Kd", "Kc"],
    }).heroFeatures).toEqual(["full-house"]);
    expect(factsFor({
      heroCards: ["Ah", "Kd"],
      board: ["As", "Kc", "2d"],
    }).heroFeatures).toEqual(["two-pair"]);
  });
});

describe("board texture", () => {
  it("separates suit, pair, and connectivity tags", () => {
    expect(factsFor({board: ["Ah", "8d", "2c"]}).boardTexture).toEqual([
      "rainbow",
      "disconnected",
    ]);
    expect(factsFor({board: ["8s", "8h", "2c"]}).boardTexture).toEqual([
      "paired",
      "rainbow",
      "disconnected",
    ]);
    expect(factsFor({board: ["Ah", "Kh", "Qh"]}).boardTexture).toEqual([
      "monotone",
      "connected",
      "broadway-heavy",
    ]);
    expect(factsFor({
      street: "turn",
      board: ["Ah", "Kh", "Qh", "Jh"],
    }).boardTexture).toEqual([
      "four-flush",
      "connected",
      "broadway-heavy",
    ]);
    expect(factsFor({board: ["Ah", "Kh", "2c"]}).boardTexture).toEqual([
      "two-tone",
      "disconnected",
      "broadway-heavy",
    ]);
    expect(factsFor({board: ["9h", "8d", "7c"]}).boardTexture).toEqual([
      "rainbow",
      "connected",
    ]);
  });
});

describe("position and pot odds", () => {
  it("names seats from the button, including heads-up", () => {
    const sixMax: Array<[number, string]> = [
      [0, "BTN"],
      [1, "SB"],
      [2, "BB"],
      [3, "UTG"],
      [4, "HJ"],
      [5, "CO"],
    ];
    for (const [heroSeat, position] of sixMax) {
      expect(factsFor({
        seatCount: 6,
        heroSeat,
        buttonSeat: 0,
        street: "preflop",
      }).position).toBe(position);
    }
    expect(factsFor({
      seatCount: 2,
      heroSeat: 0,
      buttonSeat: 0,
      street: "preflop",
    }).position).toBe("BTN");
    expect(factsFor({
      seatCount: 2,
      heroSeat: 1,
      buttonSeat: 0,
      street: "preflop",
    }).position).toBe("BB");
  });

  it("rounds pot odds and caps the call at the hero stack", () => {
    const priced = factsFor({
      contributions: [6, 0],
      highestBet: 1,
      heroStreetBet: 0,
      heroStack: 200,
    });
    expect(priced.pot).toBe(6);
    expect(priced.callAmount).toBe(1);
    expect(priced.potOddsPercent).toBe(14.3);

    const capped = factsFor({
      contributions: [96, 0],
      highestBet: 20,
      heroStack: 4,
    });
    expect(capped.callAmount).toBe(4);
    expect(capped.potOddsPercent).toBe(4);

    expect(factsFor({
      contributions: [10, 0],
      highestBet: 0,
    }).potOddsPercent).toBe(0);
  });
});

describe("assertFairCoachingFacts", () => {
  it("rejects hidden-card field names and accepts a clean projection", () => {
    const facts = factsFor();
    expect(() => assertFairCoachingFacts(facts)).not.toThrow();
    const poisoned = {...facts} as CoachingFacts & {runout?: string};
    poisoned.runout = "Ah";
    expect(() => assertFairCoachingFacts(poisoned)).toThrow(/runout/);
  });

  it("throws when the hero seat is missing from the definition", () => {
    const hand: LiveHandDefinition = {
      payloadVersion: LIVE_PAYLOAD_VERSION,
      schemaVersion: "live-hand-v3.0",
      handId: "facts-hand",
      setupKey: "test",
      setup: {
        mode: "random",
        seatCount: 2,
        smallBlind: 1,
        bigBlind: 2,
        maxStackDepthBb: 200,
        heroSeat: 0,
      },
      buttonSeat: 0,
      seats: [
        {
          seat: 1,
          name: "Villain",
          archetype: "TAG",
          startingStack: 200,
          holeCards: ["8c", "9c"],
        },
      ],
      runout: ["2s", "3d", "4h", "5c", "6s"],
      source: "gemini",
      modelId: "test",
    };
    const state = createInitialLiveState({
      ...hand,
      seats: [
        {
          seat: 0,
          name: "Hero",
          archetype: "HERO",
          startingStack: 200,
          holeCards: ["Ah", "Kd"],
        },
        hand.seats[0],
      ],
    });
    expect(() => buildCoachingFacts({
      hand,
      state,
      legalActions: [],
      publicHistory: [],
    })).toThrow(/hero definition missing/);
  });
});
