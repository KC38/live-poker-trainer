/**
 * Unit tests for allocation prioritization and lease helpers.
 */

import {describe, expect, it, vi} from "vitest";
import {
  DISTINCT_SETUPS_PER_DAY,
  convertDealReservationToPreparingPoll,
  enforceSituationFetchLimits,
  FETCHES_PER_HOUR,
  isPreparingPollState,
  PREPARING_POLLS_PER_HOUR,
  prioritizeCandidates,
} from "./fetch_situation";
import {canAcquireLease, ensureTableSetupDoc, MAX_GLOBAL_SETUPS} from "./pool";
import {mergeProgressDelta, emptyProgress} from "./progress_stats";
import {
  deriveTerminalHeroNetChips,
  validatePathAgainstSituation,
} from "./record_progress";
import {minimalFoldSituation} from "./test_fixtures";
import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore} from "firebase-admin/firestore";
import type {TableSetupInput} from "./situation_types";

describe("prioritizeCandidates", () => {
  it("prefers never-served over previously served", () => {
    const ids = prioritizeCandidates({
      neverServedIds: ["n1", "n2"],
      otherIds: ["o1"],
      receiptIds: new Set(["n1"]),
    });
    expect(ids).toEqual(["n2"]);
  });

  it("falls back to other unseen when never-served exhausted", () => {
    const ids = prioritizeCandidates({
      neverServedIds: ["n1"],
      otherIds: ["o1", "o2"],
      receiptIds: new Set(["n1", "o1"]),
    });
    expect(ids).toEqual(["o2"]);
  });
});

describe("canAcquireLease", () => {
  it("allows idle or expired leases", () => {
    expect(
      canAcquireLease({status: "idle", leaseExpiresAtMs: null, nowMs: 1000}),
    ).toBe(true);
    expect(
      canAcquireLease({
        status: "generating",
        leaseExpiresAtMs: 500,
        nowMs: 1000,
      }),
    ).toBe(true);
  });

  it("blocks active leases", () => {
    expect(
      canAcquireLease({
        status: "generating",
        leaseExpiresAtMs: 2000,
        nowMs: 1000,
      }),
    ).toBe(false);
  });
});

function quotaDb(
  initial: Record<string, unknown>,
): {
  db: Firestore;
  state: Record<string, unknown>;
  written: Record<string, unknown>;
} {
  const state = {...initial};
  const written: Record<string, unknown> = {};
  const ref = {};
  const tx = {
    get: vi.fn().mockImplementation(async () => ({data: () => ({...state})})),
    set: vi.fn((_ref, value) => {
      Object.assign(state, value);
      Object.assign(written, value);
    }),
  };
  const doc = vi.fn(() => ({
    collection: vi.fn(() => ({doc: vi.fn(() => ref)})),
  }));
  const db = {
    collection: vi.fn(() => ({doc})),
    runTransaction: vi.fn((callback) => callback(tx)),
  } as unknown as Firestore;
  return {db, state, written};
}

describe("server fetch limits", () => {
  it("rejects the 121st request in one hour", async () => {
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const hourStart = Date.UTC(2026, 8, 18, 12);
    const {db} = quotaDb({
      requestWindowStartMs: hourStart,
      requestCount: FETCHES_PER_HOUR,
      setupDay: "2026-09-18",
      setupKeys: ["same"],
    });
    await expect(enforceSituationFetchLimits({
      db, uid: "u", setupKey: "same", nowMs,
    })).rejects.toMatchObject({code: "resource-exhausted"});
  });

  it("allows an existing setup but rejects a ninth distinct setup", async () => {
    const keys = Array.from(
      {length: DISTINCT_SETUPS_PER_DAY},
      (_, index) => `setup-${index}`,
    );
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const existing = quotaDb({
      requestWindowStartMs: Date.UTC(2026, 8, 18, 12),
      requestCount: 1,
      setupDay: "2026-09-18",
      setupKeys: keys,
    });
    await expect(enforceSituationFetchLimits({
      db: existing.db, uid: "u", setupKey: keys[0], nowMs,
    })).resolves.toBeUndefined();
    expect(existing.written.setupKeys).toEqual(keys);

    const novel = quotaDb({
      requestWindowStartMs: Date.UTC(2026, 8, 18, 12),
      requestCount: 1,
      setupDay: "2026-09-18",
      setupKeys: keys,
    });
    await expect(enforceSituationFetchLimits({
      db: novel.db, uid: "u", setupKey: "setup-8", nowMs,
    })).rejects.toMatchObject({code: "resource-exhausted"});
  });

  it("increments only preparing-poll quota state", async () => {
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const hourStart = Date.UTC(2026, 8, 18, 12);
    const quota = quotaDb({
      requestWindowStartMs: hourStart,
      requestCount: 7,
      setupDay: "2026-09-18",
      setupKeys: ["known"],
    });

    await enforceSituationFetchLimits({
      db: quota.db,
      uid: "u",
      setupKey: "different",
      preparingPoll: true,
      nowMs,
    });

    expect(quota.state.pollWindowStartMs).toBe(hourStart);
    expect(quota.state.pollCount).toBe(1);
    expect(quota.state.requestCount).toBe(7);
    expect(quota.state.setupKeys).toEqual(["known"]);
    expect(Object.keys(quota.written).sort()).toEqual([
      "pollCount",
      "pollWindowStartMs",
    ]);
  });

  it("accepts 720 preparing polls then rejects the next one", async () => {
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const quota = quotaDb({});

    for (let i = 0; i < PREPARING_POLLS_PER_HOUR; i++) {
      await enforceSituationFetchLimits({
        db: quota.db,
        uid: "u",
        setupKey: "known",
        preparingPoll: true,
        nowMs,
      });
    }

    expect(quota.state.pollCount).toBe(PREPARING_POLLS_PER_HOUR);
    await expect(enforceSituationFetchLimits({
      db: quota.db,
      uid: "u",
      setupKey: "known",
      preparingPoll: true,
      nowMs,
    })).rejects.toMatchObject({
      code: "resource-exhausted",
      message: expect.stringContaining("30 minute(s)"),
    });
  });

  it("resets preparing-poll quota in a new hour", async () => {
    const previousHour = Date.UTC(2026, 8, 18, 12);
    const currentHour = Date.UTC(2026, 8, 18, 13);
    const quota = quotaDb({
      pollWindowStartMs: previousHour,
      pollCount: PREPARING_POLLS_PER_HOUR,
      requestWindowStartMs: previousHour,
      requestCount: 11,
      setupDay: "2026-09-18",
      setupKeys: ["known"],
    });

    await enforceSituationFetchLimits({
      db: quota.db,
      uid: "u",
      setupKey: "different",
      preparingPoll: true,
      nowMs: currentHour + 1,
    });

    expect(quota.state.pollWindowStartMs).toBe(currentHour);
    expect(quota.state.pollCount).toBe(1);
    expect(quota.state.requestCount).toBe(11);
    expect(quota.state.setupKeys).toEqual(["known"]);
  });

  it("counts first and ordinary fetch requests", async () => {
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const quota = quotaDb({
      pollWindowStartMs: Date.UTC(2026, 8, 18, 12),
      pollCount: 19,
    });

    await enforceSituationFetchLimits({
      db: quota.db,
      uid: "u",
      setupKey: "new",
      preparingPoll: false,
      nowMs,
    });
    await enforceSituationFetchLimits({
      db: quota.db,
      uid: "u",
      setupKey: "new",
      preparingPoll: false,
      nowMs,
    });

    expect(quota.state.requestCount).toBe(2);
    expect(quota.state.setupKeys).toEqual(["new"]);
    expect(quota.state.pollCount).toBe(19);
  });

  it("converts a reserved deal slot into a preparing poll", async () => {
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const hourStart = Date.UTC(2026, 8, 18, 12);
    const quota = quotaDb({
      requestWindowStartMs: hourStart,
      requestCount: 40,
      pollWindowStartMs: hourStart,
      pollCount: 3,
      setupDay: "2026-09-18",
      setupKeys: ["known"],
    });

    await convertDealReservationToPreparingPoll({
      db: quota.db,
      uid: "u",
      nowMs,
    });

    expect(quota.state.requestCount).toBe(39);
    expect(quota.state.pollCount).toBe(4);
    expect(quota.state.setupKeys).toEqual(["known"]);
  });
});

describe("isPreparingPollState", () => {
  it("treats missing, idle, and generating empty pools as prep", () => {
    expect(isPreparingPollState({
      exists: false,
      situationCount: 0,
    })).toBe(true);
    expect(isPreparingPollState({
      exists: true,
      situationCount: 0,
      generationStatus: "idle",
    })).toBe(true);
    expect(isPreparingPollState({
      exists: true,
      situationCount: 0,
      generationStatus: "queued",
    })).toBe(true);
    expect(isPreparingPollState({
      exists: true,
      situationCount: 2,
      generationStatus: "generating",
    })).toBe(false);
  });
});

describe("global setup cap", () => {
  it("rejects first creation when the global cap is reached", async () => {
    const setupRef = {};
    const limitRef = {};
    const db = {
      collection: vi.fn((name: string) => ({
        doc: vi.fn(() => name === "tableSetups" ? {
          ...setupRef,
          collection: vi.fn(() => ({})),
        } : limitRef),
      })),
      runTransaction: vi.fn(async (callback) => callback({
        get: vi.fn(async (ref) => ref === limitRef ? {
          data: () => ({setupCount: MAX_GLOBAL_SETUPS}),
        } : {exists: false}),
        set: vi.fn(),
      })),
    } as unknown as Firestore;
    const setup: TableSetupInput = {
      mode: "random",
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      ante: 0,
      startingStack: 100,
    };
    await expect(ensureTableSetupDoc(db, setup, "key"))
      .rejects.toMatchObject({code: "resource-exhausted"});
  });
});

describe("mergeProgressDelta", () => {
  it("accumulates hands and EV", () => {
    const next = mergeProgressDelta(emptyProgress(), {
      heroNetBb: 1.5,
      totalEvDeltaBb: -1.2,
      archetype: "TAG",
      decisionCount: 2,
      correctCount: 1,
      streetStats: {
        preflop: {decisionCount: 2, correctCount: 1, evDeltaBb: -1.2},
      },
    });
    expect(next.handsCompleted).toBe(1);
    expect(next.netEvBb).toBe(-1.2);
    expect(next.netResultBb).toBe(1.5);
    expect(next.totalSpots).toBe(2);
    expect(next.correctSpots).toBe(1);
    expect(next.streetAccuracy.preflop.played).toBe(2);
    expect(next.streetAccuracy.preflop.correct).toBe(1);
    expect(next.archetypeAccuracy.TAG.evBb).toBe(-1.2);
  });
});

describe("validatePathAgainstSituation", () => {
  it("accepts a legal fold path", () => {
    const payload = minimalFoldSituation();
    const traversal = validatePathAgainstSituation(payload, {
      situationId: "x",
      setupKey: payload.setupKey,
      pathNodeIds: ["open", "hero_vs_3bet"],
      chosenActionKeys: ["RAISE_100", "FOLD"],
      terminalNodeId: "term_fold",
      // Deliberately false: grading and result must come from server payload.
      heroNetChips: 999999,
    });
    expect(traversal.terminal.heroNetChips).toBe(-5);
    expect(traversal.grading).toEqual({
      decisionCount: 2,
      correctCount: 1,
      totalEvDeltaBb: -1,
      streetStats: {
        preflop: {decisionCount: 2, correctCount: 1, evDeltaBb: -1},
      },
      chosenActionKinds: ["RAISE", "FOLD"],
    });
    expect(traversal.actions.map((action) => action.kind)).toEqual([
      "POST_SB",
      "POST_BB",
      "RAISE",
      "RAISE",
      "FOLD",
    ]);
  });

  it("rejects illegal action keys", () => {
    const payload = minimalFoldSituation();
    expect(() =>
      validatePathAgainstSituation(payload, {
        situationId: "x",
        setupKey: payload.setupKey,
        pathNodeIds: ["open"],
        chosenActionKeys: ["RAISE_999"],
        terminalNodeId: "term_check",
        heroNetChips: 0,
      }),
    ).toThrow(HttpsError);
  });

  it("re-derives hero results from terminal payout state", () => {
    const payload = minimalFoldSituation();
    const terminal = payload.nodes.term_fold;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.heroNetChips = 999999;

    expect(deriveTerminalHeroNetChips(payload, terminal)).toBe(-5);
  });

  it.each([
    [0, 194.99, 0],
    [1, 195, 0],
  ])(
    "derives the seat-specific odd-cent share for hero seat %i",
    (heroSeat, heroStack, expectedNet) => {
      const payload = minimalFoldSituation();
      payload.heroSeat = heroSeat;
      payload.heroHand = payload.holeCards[heroSeat].cards;
      payload.lineup = payload.lineup.map((seat) => ({
        ...seat,
        archetype: seat.seat === heroSeat ? "HERO" : "TAG",
      }));
      payload.runouts = [
        {street: "flop", cards: ["2s", "3s", "4s"]},
        {street: "turn", cards: ["5s"]},
        {street: "river", cards: ["6s"]},
      ];
      const terminal = payload.nodes.term_call_open;
      if (terminal.type !== "terminal") throw new Error("expected terminal");
      terminal.street = "river";
      terminal.board = ["2s", "3s", "4s", "5s", "6s"];
      terminal.foldedSeats = [];
      terminal.stacks = [194.99, 195];
      terminal.stacks[heroSeat] = heroStack;
      terminal.pot = 10.01;
      terminal.winnerSeats = [1, 0];

      expect(deriveTerminalHeroNetChips(payload, terminal)).toBe(expectedNet);
    },
  );
});
