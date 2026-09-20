/**
 * Tests for the authoritative live poker state machine.
 */

import {describe, expect, test} from "vitest";
import {
  applyLiveAction,
  buildSidePots,
  createInitialLiveState,
  legalLiveActions,
  settleLiveShowdown,
} from "./live_poker_engine";
import {
  LIVE_PAYLOAD_VERSION,
  type LiveHandDefinition,
  type LiveHandState,
} from "./live_types";

function hand(stacks: number[] = [400, 400, 400]): LiveHandDefinition {
  return {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "live-hand-v3",
    handId: "hand-1",
    setupKey: "random|s3|max400|sb1|bb2",
    setup: {
      mode: "random",
      seatCount: stacks.length,
      smallBlind: 1,
      bigBlind: 2,
      maxStackDepthBb: 200,
      heroSeat: 0,
    },
    buttonSeat: 0,
    seats: stacks.map((stack, seat) => ({
      seat,
      name: seat === 0 ? "Hero" : `Villain ${seat}`,
      archetype: seat === 0 ? "HERO" : "TAG",
      startingStack: stack,
      holeCards: ([
        ["Ah", "Ad"],
        ["Kh", "Kd"],
        ["Qh", "Qd"],
      ][seat] ?? ["Jh", "Jd"]) as [string, string],
    })),
    runout: ["2c", "3c", "4c", "5s", "9d"],
    source: "gemini",
    modelId: "test",
  };
}

describe("live poker engine", () => {
  test("never offers a free fold", () => {
    const definition = hand();
    let state = createInitialLiveState(definition);
    // Button opens to $6, SB folds, BB calls. Flop checks to Hero.
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "OPEN_3_BB:600",
    }).state;
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "FOLD",
    }).state;
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "CALL:600",
    }).state;
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "CHECK",
    }).state;

    const actions = legalLiveActions(definition, state);
    expect(state.street).toBe("flop");
    expect(state.actorSeat).toBe(0);
    expect(actions.some((candidate) => candidate.kind === "CHECK")).toBe(true);
    expect(actions.some((candidate) => candidate.kind === "FOLD")).toBe(false);
    expect(actions.map((candidate) => candidate.bucket)).toEqual(
      expect.arrayContaining(["BET_33", "BET_67", "BET_100", "ALL_IN"]),
    );
  });

  test("snaps postflop sizes onto the small blind", () => {
    const definition = hand([400, 400]);
    const state: LiveHandState = {
      street: "flop",
      board: ["Kc", "Td", "5s"],
      players: [
        {
          seat: 0,
          stack: 299,
          streetBet: 0,
          contribution: 101,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 400,
          streetBet: 0,
          contribution: 0,
          folded: false,
          allIn: false,
          acted: true,
          lastFacedBet: 0,
        },
      ],
      actorSeat: 0,
      highestBet: 0,
      minRaiseIncrement: 2,
      actionNumber: 4,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };

    const actions = legalLiveActions(definition, state);
    expect(actions.find((candidate) => candidate.bucket === "BET_33")?.amountTo)
      .toBe(33);
    expect(actions.find((candidate) => candidate.bucket === "BET_67")?.amountTo)
      .toBe(68);
    expect(actions.find((candidate) => candidate.bucket === "BET_100")?.amountTo)
      .toBe(101);
    expect(actions.find((candidate) => candidate.kind === "ALL_IN")?.amountTo)
      .toBe(299);
  });

  test("all-in label is the chips left, not the raise-to total", () => {
    const definition = hand([280, 400]);
    const state: LiveHandState = {
      street: "preflop",
      board: [],
      players: [
        {
          seat: 0,
          stack: 279,
          streetBet: 1,
          contribution: 1,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 392,
          streetBet: 8,
          contribution: 8,
          folded: false,
          allIn: false,
          acted: true,
          lastFacedBet: 2,
        },
      ],
      actorSeat: 0,
      highestBet: 8,
      minRaiseIncrement: 6,
      actionNumber: 3,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };

    const allIn = legalLiveActions(definition, state)
      .find((candidate) => candidate.kind === "ALL_IN");
    expect(allIn?.label).toBe("All-in $279");
    expect(allIn?.amountTo).toBe(280);
  });

  test("a short-stack call names the chips it actually costs", () => {
    const definition = hand([49, 400]);
    const state: LiveHandState = {
      street: "river",
      board: ["Kc", "Td", "5s", "2h", "9c"],
      players: [
        {
          seat: 0,
          stack: 49,
          streetBet: 0,
          contribution: 161,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 0,
          streetBet: 149,
          contribution: 400,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 149,
        },
      ],
      actorSeat: 0,
      highestBet: 149,
      minRaiseIncrement: 149,
      actionNumber: 12,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };

    const actions = legalLiveActions(definition, state);
    const call = actions.find((candidate) => candidate.kind === "CALL");
    expect(call?.label).toBe("Call all-in $49");
    expect(call?.amountTo).toBe(49);
    expect(actions.some((candidate) => candidate.kind === "RAISE")).toBe(false);
  });

  test("still applies a pre-snap action id at the size that was offered", () => {
    const definition = hand([400, 400]);
    const state: LiveHandState = {
      street: "flop",
      board: ["Kc", "Td", "5s"],
      players: [
        {
          seat: 0,
          stack: 299,
          streetBet: 0,
          contribution: 101,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 400,
          streetBet: 0,
          contribution: 0,
          folded: false,
          allIn: false,
          acted: true,
          lastFacedBet: 0,
        },
      ],
      actorSeat: 0,
      highestBet: 0,
      minRaiseIncrement: 2,
      actionNumber: 4,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };

    const applied = applyLiveAction({
      hand: definition,
      state,
      actionId: "BET_33:3333",
    });
    expect(applied.state.players[0].streetBet).toBe(33.33);
    expect(() => applyLiveAction({
      hand: definition,
      state,
      actionId: "BET_33:100",
    })).toThrow(/illegal or stale/);

    const centPot: LiveHandState = {
      ...state,
      players: [
        {...state.players[0], contribution: 48, stack: 272},
        state.players[1],
      ],
    };
    const retried = applyLiveAction({
      hand: definition,
      state: centPot,
      actionId: "BET_33:1584",
    });
    expect(retried.state.players[0].streetBet).toBe(15.84);
  });

  test("drops previous-street action labels when the next street starts", () => {
    const definition = hand();
    let state = createInitialLiveState(definition);
    const act = (actionId: string): void => {
      state = applyLiveAction({hand: definition, state, actionId}).state;
    };
    act("OPEN_3_BB:600");
    act("FOLD");
    act("CALL:600");
    expect(state.street).toBe("flop");
    while (state.street === "flop" && state.status === "playing") {
      const check = legalLiveActions(definition, state).find(
        (candidate) => candidate.kind === "CHECK",
      );
      if (!check) {
        throw new Error("expected a check to finish the flop");
      }
      act(check.actionId);
    }
    expect(state.street).toBe("turn");
    for (const player of state.players) {
      if (player.folded) {
        expect(player.lastAction).toBe("FOLD");
      } else {
        expect(player.lastAction).toBeUndefined();
      }
    }
  });

  test("clears a check label when a later bet reopens the seat", () => {
    const definition = hand([400, 400, 400]);
    let state = createInitialLiveState(definition);
    const act = (actionId: string): void => {
      state = applyLiveAction({hand: definition, state, actionId}).state;
    };
    act("OPEN_3_BB:600");
    act("CALL:600");
    act("CALL:600");
    expect(state.street).toBe("flop");
    // SB checks, BB checks, button bets. The earlier checks must not stay
    // painted once those seats are facing the bet again.
    act("CHECK");
    expect(state.players[1].lastAction).toBe("CHECK");
    act("CHECK");
    expect(state.players[2].lastAction).toBe("CHECK");
    const bet = legalLiveActions(definition, state).find(
      (candidate) => candidate.bucket === "BET_33",
    );
    expect(bet).toBeDefined();
    act(bet!.actionId);
    expect(state.players[0].lastAction).toBe("BET");
    expect(state.players[1].lastAction).toBeUndefined();
    expect(state.players[2].lastAction).toBeUndefined();
    expect(state.players[1].acted).toBe(false);
    expect(state.players[2].acted).toBe(false);
  });

  test("an incomplete all-in does not reopen raising", () => {
    const definition = hand([400, 7, 400]);
    let state = createInitialLiveState(definition);
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "OPEN_3_BB:600",
    }).state;
    // SB can only shove to $7, a $1 raise over $6 and below the $4 full raise.
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "ALL_IN:700",
    }).state;
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "CALL:700",
    }).state;

    expect(state.actorSeat).toBe(0);
    const reopened = legalLiveActions(definition, state);
    expect(reopened.map((candidate) => candidate.kind)).toEqual([
      "FOLD",
      "CALL",
    ]);
  });

  test("builds and settles main and side pots independently", () => {
    const definition = hand([100, 200, 300]);
    const state: LiveHandState = {
      street: "river",
      board: [...definition.runout],
      players: [
        {
          seat: 0,
          stack: 0,
          streetBet: 0,
          contribution: 100,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 0,
          streetBet: 0,
          contribution: 200,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 0,
        },
        {
          seat: 2,
          stack: 100,
          streetBet: 0,
          contribution: 200,
          folded: false,
          allIn: false,
          acted: true,
          lastFacedBet: 0,
        },
      ],
      actorSeat: null,
      highestBet: 0,
      minRaiseIncrement: 2,
      actionNumber: 8,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };

    expect(buildSidePots(state)).toEqual([
      {amount: 300, eligibleSeats: [0, 1, 2]},
      {amount: 200, eligibleSeats: [1, 2]},
    ]);

    settleLiveShowdown(definition, state);

    // Hero's wheel beats overpairs in the $300 main pot. Kings beat queens
    // in the $200 side pot.
    expect(state.pots).toEqual([
      {amount: 300, eligibleSeats: [0, 1, 2], winnerSeats: [0]},
      {amount: 200, eligibleSeats: [1, 2], winnerSeats: [1]},
    ]);
    expect(state.payouts).toEqual({"0": 300, "1": 200});
    expect(state.players.map((player) => player.stack)).toEqual([300, 200, 100]);
  });

  test("refunds unmatched excess before side-pot settlement", () => {
    const definition = hand([100, 200, 300]);
    const state: LiveHandState = {
      street: "river",
      board: [...definition.runout],
      players: [
        {
          seat: 0,
          stack: 0,
          streetBet: 0,
          contribution: 100,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 0,
          streetBet: 0,
          contribution: 200,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 0,
        },
        {
          seat: 2,
          stack: 0,
          streetBet: 100,
          contribution: 300,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 0,
        },
      ],
      actorSeat: null,
      highestBet: 100,
      minRaiseIncrement: 2,
      actionNumber: 8,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };

    settleLiveShowdown(definition, state);

    expect(state.players[2].contribution).toBe(200);
    expect(state.players[2].stack).toBe(100);
    expect(state.pots.map((pot) => pot.amount)).toEqual([300, 200]);
  });

  test("cumulative short all-ins reopen action after a full increment", () => {
    const definition = hand([110, 15, 20, 120]);
    let state: LiveHandState = {
      street: "flop",
      board: ["2c", "3c", "4c"],
      players: [
        {
          seat: 0,
          stack: 100,
          streetBet: 10,
          contribution: 10,
          folded: false,
          allIn: false,
          acted: true,
          lastFacedBet: 10,
        },
        {
          seat: 1,
          stack: 5,
          streetBet: 10,
          contribution: 10,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 10,
        },
        {
          seat: 2,
          stack: 10,
          streetBet: 10,
          contribution: 10,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 10,
        },
        {
          seat: 3,
          stack: 100,
          streetBet: 20,
          contribution: 20,
          folded: false,
          allIn: false,
          acted: true,
          lastFacedBet: 20,
        },
      ],
      actorSeat: 1,
      highestBet: 10,
      minRaiseIncrement: 10,
      actionNumber: 3,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "ALL_IN:1500",
    }).state;
    state = applyLiveAction({
      hand: definition,
      state,
      actionId: "ALL_IN:2000",
    }).state;

    expect(state.actorSeat).toBe(0);
    expect(
      legalLiveActions(definition, state).some(
        (candidate) => candidate.kind === "RAISE",
      ),
    ).toBe(true);
  });

  test("permits completing an incomplete opening all-in to one big blind", () => {
    const definition = hand([100, 0.5, 100]);
    const state: LiveHandState = {
      street: "flop",
      board: ["2c", "3c", "4c"],
      players: [
        {
          seat: 0,
          stack: 100,
          streetBet: 0,
          contribution: 10,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 0,
        },
        {
          seat: 1,
          stack: 0,
          streetBet: 0.5,
          contribution: 10.5,
          folded: false,
          allIn: true,
          acted: true,
          lastFacedBet: 0.5,
        },
        {
          seat: 2,
          stack: 100,
          streetBet: 0,
          contribution: 10,
          folded: false,
          allIn: false,
          acted: false,
          lastFacedBet: 0,
        },
      ],
      actorSeat: 0,
      highestBet: 0.5,
      minRaiseIncrement: 2,
      actionNumber: 4,
      status: "playing",
      winnerSeats: [],
      pots: [],
      payouts: {},
    };
    const minimum = legalLiveActions(definition, state).find(
      (candidate) => candidate.bucket === "RAISE_MIN",
    );
    expect(minimum?.amountTo).toBe(2);
  });
});
