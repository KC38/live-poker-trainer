/**
 * Unit tests for deterministic situation validation.
 */

import { describe, expect, it } from "vitest";
import {
  filterUnseenSituationIds,
  shouldRefillPool,
  validateSituation,
} from "./validate_situation";
import { minimalFoldSituation } from "./test_fixtures";
import { hashSituationStructure } from "./content_hash";
import type { SituationPayload } from "./situation_types";

/**
 * Rewires the preflop CALL edge through authored flop/turn/river Hero nodes
 * into a river showdown terminal.
 */
function wirePreflopCallToRiverShowdown(
  payload: SituationPayload,
  options: {
    terminalId: string;
    board: string[];
    pot: number;
    stacks: number[];
    winnerSeats: number[];
    heroNetChips: number;
  },
): SituationPayload {
  const {terminalId, board, pot, stacks, winnerSeats, heroNetChips} = options;
  payload.runouts = [
    {street: "flop", cards: board.slice(0, 3)},
    {street: "turn", cards: board.slice(3, 4)},
    {street: "river", cards: board.slice(4, 5)},
  ];
  const open = payload.nodes.open;
  if (open.type !== "hero") throw new Error("expected hero open");
  const call = open.actions.find((action) => action.kind === "CALL");
  if (!call) throw new Error("expected CALL");
  call.nextNodeId = "sd_flop";

  payload.nodes.sd_flop = {
    type: "hero",
    id: "sd_flop",
    street: "flop",
    pot,
    stacks: [...stacks],
    streetBets: [0, 0],
    board: board.slice(0, 3),
    foldedSeats: [],
    toAct: payload.heroSeat,
    callAmount: 0,
    minRaiseTo: payload.bigBlind,
    actions: [{
      actionKey: "CHECK_FLOP",
      kind: "CHECK",
      coaching: "Checking keeps the showdown path controlled.",
      verdict: "correct",
      evDeltaBb: 0,
      optimalActionKey: "CHECK_FLOP",
      nextNodeId: "sd_turn",
    }],
  };
  payload.nodes.sd_turn = {
    type: "hero",
    id: "sd_turn",
    street: "turn",
    pot,
    stacks: [...stacks],
    streetBets: [0, 0],
    board: board.slice(0, 4),
    foldedSeats: [],
    toAct: payload.heroSeat,
    callAmount: 0,
    minRaiseTo: payload.bigBlind,
    actions: [{
      actionKey: "CHECK_TURN",
      kind: "CHECK",
      coaching: "Checking preserves showdown value on the turn.",
      verdict: "correct",
      evDeltaBb: 0,
      optimalActionKey: "CHECK_TURN",
      nextNodeId: "sd_river",
    }],
  };
  payload.nodes.sd_river = {
    type: "hero",
    id: "sd_river",
    street: "river",
    pot,
    stacks: [...stacks],
    streetBets: [0, 0],
    board: [...board],
    foldedSeats: [],
    toAct: payload.heroSeat,
    callAmount: 0,
    minRaiseTo: payload.bigBlind,
    actions: [{
      actionKey: "CHECK_RIVER",
      kind: "CHECK",
      coaching: "Checking realizes showdown value on the river.",
      verdict: "correct",
      evDeltaBb: 0,
      optimalActionKey: "CHECK_RIVER",
      nextNodeId: terminalId,
    }],
  };

  const terminal = payload.nodes[terminalId];
  if (!terminal || terminal.type !== "terminal") {
    throw new Error(`expected terminal ${terminalId}`);
  }
  terminal.reason = "showdown";
  terminal.street = "river";
  terminal.board = [...board];
  terminal.foldedSeats = [];
  terminal.stacks = [...stacks];
  terminal.pot = pot;
  terminal.winnerSeats = [...winnerSeats];
  terminal.heroNetChips = heroNetChips;

  delete payload.nodes.villain_folds_limp;
  return payload;
}

describe("validateSituation", () => {
  it("accepts a minimal valid tree", () => {
    const result = validateSituation(minimalFoldSituation());
    if (!result.ok) {
      console.error(result.issues);
    }
    expect(result.ok).toBe(true);
  });

  it("accepts the canonical heads-up root and rejects reversed blinds", () => {
    const payload = minimalFoldSituation();
    expect(validateSituation(payload).ok).toBe(true);

    const root = payload.nodes.root;
    if (root.type !== "scripted") throw new Error("expected scripted root");
    expect(root.actions.slice(0, 2)).toEqual([
      { seat: 0, kind: "POST_SB", amountTo: 1 },
      { seat: 1, kind: "POST_BB", amountTo: 2 },
    ]);
    root.actions = [
      { seat: 1, kind: "POST_SB", amountTo: 1 },
      { seat: 0, kind: "POST_BB", amountTo: 2 },
    ];

    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((issue) => issue.code === "root")).toBe(true);
  });

  it("keeps the three-handed button-left blind convention", () => {
    const payload = minimalFoldSituation();
    payload.seatCount = 3;
    const root = payload.nodes.root;
    if (root.type !== "scripted") throw new Error("expected scripted root");
    root.stacks = [200, 200, 200];
    root.streetBets = [0, 0, 0];
    root.actions = [
      {seat: 1, kind: "POST_SB", amountTo: 1},
      {seat: 2, kind: "POST_BB", amountTo: 2},
    ];

    const result = validateSituation(payload);
    expect(result.issues.some((issue) => issue.code === "root")).toBe(false);

    root.actions = [
      {seat: 0, kind: "POST_SB", amountTo: 1},
      {seat: 1, kind: "POST_BB", amountTo: 2},
    ];
    expect(
      validateSituation(payload).issues.some((issue) => issue.code === "root"),
    ).toBe(true);
  });

  it.each([
    [
      "redistributed stacks",
      (root: Extract<SituationPayload["nodes"][string], {type: "scripted"}>) => {
        root.stacks = [199, 201];
      },
    ],
    [
      "nonzero pot",
      (root: Extract<SituationPayload["nodes"][string], {type: "scripted"}>) => {
        root.pot = 1;
      },
    ],
    [
      "nonzero street bets",
      (root: Extract<SituationPayload["nodes"][string], {type: "scripted"}>) => {
        root.streetBets = [1, 0];
      },
    ],
    [
      "pre-folded seats",
      (root: Extract<SituationPayload["nodes"][string], {type: "scripted"}>) => {
        root.foldedSeats = [1];
      },
    ],
    [
      "a nonempty board",
      (root: Extract<SituationPayload["nodes"][string], {type: "scripted"}>) => {
        root.board = ["2c"];
      },
    ],
  ])("rejects canonical root state with %s", (_, mutate) => {
    const payload = minimalFoldSituation();
    const root = payload.nodes.root;
    if (root.type !== "scripted") throw new Error("expected scripted root");
    mutate(root);
    const result = validateSituation(payload);
    expect(result.issues.some((issue) => issue.code === "root")).toBe(true);
  });

  it("requires the root node to be scripted", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero node");
    payload.nodes.root = {...structuredClone(open), id: "root"};
    expect(
      validateSituation(payload).issues.some(
        (issue) =>
          issue.code === "root" && issue.message.includes("must be scripted"),
      ),
    ).toBe(true);
  });

  it.each([
    [
      "missing post",
      (actions: Extract<
        SituationPayload["nodes"][string],
        {type: "scripted"}
      >["actions"]) => actions.pop(),
    ],
    [
      "wrong blind seat",
      (actions: Extract<
        SituationPayload["nodes"][string],
        {type: "scripted"}
      >["actions"]) => {
        actions[0].seat = 1;
      },
    ],
    [
      "wrong total commitment",
      (actions: Extract<
        SituationPayload["nodes"][string],
        {type: "scripted"}
      >["actions"]) => {
        actions[1].amountTo = 3;
      },
    ],
    [
      "duplicate forced post",
      (actions: Extract<
        SituationPayload["nodes"][string],
        {type: "scripted"}
      >["actions"]) => {
        actions.push({ seat: 0, kind: "POST_BB", amountTo: 2 });
      },
    ],
  ])("rejects a %s in the root ledger", (_, mutate) => {
    const payload = minimalFoldSituation();
    const root = payload.nodes.root;
    if (root.type !== "scripted") throw new Error("expected scripted root");
    mutate(root.actions);
    const result = validateSituation(payload);
    expect(result.issues.some((issue) => issue.code === "root")).toBe(true);
  });

  it("allows voluntary actions after the forced-post prefix", () => {
    const payload = minimalFoldSituation();
    const root = payload.nodes.root;
    if (root.type !== "scripted") throw new Error("expected scripted root");
    root.actions.push({seat: 1, kind: "CALL", amountTo: 2});

    expect(
      validateSituation(payload).issues.some((issue) => issue.code === "root"),
    ).toBe(false);
  });

  it.each([
    [
      "small blind",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.smallBlind += 0.001;
      },
    ],
    [
      "big blind",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.bigBlind += 0.001;
      },
    ],
    [
      "ante",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.ante += 0.001;
      },
    ],
    [
      "setup starting stack",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.startingStack += 0.001;
      },
    ],
    [
      "lineup starting stack",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.lineup[0].startingStack += 0.001;
      },
    ],
    [
      "node pot",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.nodes.open.pot += 0.001;
      },
    ],
    [
      "node stack",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.nodes.open.stacks[0] += 0.001;
      },
    ],
    [
      "street bet",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        if (p.nodes.open.type === "terminal") {
          throw new Error("expected non-terminal node");
        }
        p.nodes.open.streetBets[0] += 0.001;
      },
    ],
    [
      "call amount",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        if (p.nodes.open.type !== "hero") throw new Error("expected hero node");
        p.nodes.open.callAmount += 0.001;
      },
    ],
    [
      "minimum raise",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        if (p.nodes.open.type !== "hero") throw new Error("expected hero node");
        p.nodes.open.minRaiseTo += 0.001;
      },
    ],
    [
      "hero edge amount",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        if (p.nodes.open.type !== "hero") throw new Error("expected hero node");
        p.nodes.open.actions[1].amountTo! += 0.001;
      },
    ],
    [
      "scripted amount",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        if (p.nodes.root.type !== "scripted") {
          throw new Error("expected scripted node");
        }
        p.nodes.root.actions[0].amountTo! += 0.001;
      },
    ],
    [
      "terminal pot",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.nodes.term_check.pot += 0.001;
      },
    ],
    [
      "terminal stack",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        p.nodes.term_check.stacks[0] += 0.001;
      },
    ],
    [
      "terminal hero net",
      (p: ReturnType<typeof minimalFoldSituation>) => {
        if (p.nodes.term_check.type !== "terminal") {
          throw new Error("expected terminal");
        }
        p.nodes.term_check.heroNetChips += 0.001;
      },
    ],
  ])("rejects non-cent %s", (_, mutate) => {
    const payload = minimalFoldSituation();
    mutate(payload);

    const result = validateSituation(payload);

    expect(result.ok).toBe(false);
    expect(
      result.issues.some((issue) => issue.code === "money_precision"),
    ).toBe(true);
  });

  it("rejects graphs larger than the generation budget", () => {
    const payload = minimalFoldSituation();
    const template = payload.nodes.term_fold;
    for (let i = 0; i < 20; i++) {
      const id = `extra_${i}`;
      payload.nodes[id] = { ...structuredClone(template), id };
    }
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((issue) => issue.code === "graph_size")).toBe(
      true,
    );
  });

  it("rejects a showdown terminal reached before the river", () => {
    const payload = minimalFoldSituation();
    const terminal = payload.nodes.term_call_open;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.reason = "showdown";
    terminal.street = "river";
    terminal.board = ["2c", "7d", "Jh", "9s", "3h"];
    terminal.foldedSeats = [];
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes("reached from the river"),
      ),
    ).toBe(true);
  });

  it.each([
    [
      "pot",
      (payload: ReturnType<typeof minimalFoldSituation>) => {
        const child = payload.nodes.face_3bet;
        if (child.type !== "scripted")
          throw new Error("expected scripted node");
        child.pot += 1;
      },
    ],
    [
      "stack",
      (payload: ReturnType<typeof minimalFoldSituation>) => {
        const child = payload.nodes.face_3bet;
        if (child.type !== "scripted")
          throw new Error("expected scripted node");
        child.stacks[0] -= 1;
      },
    ],
    [
      "street bet",
      (payload: ReturnType<typeof minimalFoldSituation>) => {
        const child = payload.nodes.face_3bet;
        if (child.type !== "scripted")
          throw new Error("expected scripted node");
        child.streetBets[0] += 1;
      },
    ],
  ])("rejects a locally valid child with the wrong %s", (_, mutate) => {
    const payload = minimalFoldSituation();
    mutate(payload);
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "transition")).toBe(true);
  });

  it("accepts an exact same-street transition", () => {
    const payload = minimalFoldSituation();
    const result = validateSituation(payload);
    expect(result.ok).toBe(true);
  });

  it("rejects an inflated terminal pot", () => {
    const payload = minimalFoldSituation();
    const terminal = payload.nodes.term_check;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.pot += 1;

    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes("terminal pot mismatch"),
      ),
    ).toBe(true);
  });

  it("rejects terminal stacks that differ from simulated stacks", () => {
    const payload = minimalFoldSituation();
    const terminal = payload.nodes.term_check;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.stacks[0] -= 1;

    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes("terminal stacks"),
      ),
    ).toBe(true);
  });

  it.each([{winnerSeats: []}, {winnerSeats: [0, 0]}, {winnerSeats: [2]}])(
    "rejects invalid terminal winners $winnerSeats",
    ({winnerSeats}) => {
      const payload = minimalFoldSituation();
      const terminal = payload.nodes.term_check;
      if (terminal.type !== "terminal") throw new Error("expected terminal");
      terminal.winnerSeats = winnerSeats;

      const result = validateSituation(payload);
      expect(result.ok).toBe(false);
      expect(
        result.issues.some(
          (issue) =>
            issue.code === "terminal" && issue.message.includes("winnerSeats"),
        ),
      ).toBe(true);
    },
  );

  it("rejects an incorrect terminal heroNetChips", () => {
    const payload = minimalFoldSituation();
    const terminal = payload.nodes.term_check;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.heroNetChips += 10;

    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "terminal" &&
          issue.message.includes("heroNetChips mismatch"),
      ),
    ).toBe(true);
  });

  it("rejects hero as winner after the hero folds", () => {
    const payload = minimalFoldSituation();
    const terminal = payload.nodes.term_fold;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.winnerSeats = [payload.heroSeat];
    terminal.heroNetChips = 16;

    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes("hero cannot win"),
      ),
    ).toBe(true);
  });

  it("accepts a valid equal split pot", () => {
    const payload = wirePreflopCallToRiverShowdown(minimalFoldSituation(), {
      terminalId: "term_call_open",
      board: ["2s", "3s", "4s", "5s", "6s"],
      pot: 4,
      stacks: [198, 198],
      winnerSeats: [0, 1],
      heroNetChips: 0,
    });

    const result = validateSituation(payload);
    if (!result.ok) console.error(result.issues);
    expect(result.ok).toBe(true);
  });

  it("rejects a live path without a Hero decision on every street", () => {
    const payload = wirePreflopCallToRiverShowdown(minimalFoldSituation(), {
      terminalId: "term_call_open",
      board: ["2s", "3s", "4s", "5s", "6s"],
      pot: 4,
      stacks: [198, 198],
      winnerSeats: [0, 1],
      heroNetChips: 0,
    });
    payload.nodes.sd_turn = {
      type: "scripted",
      id: "sd_turn",
      street: "turn",
      pot: 4,
      stacks: [198, 198],
      streetBets: [0, 0],
      board: ["2s", "3s", "4s", "5s"],
      foldedSeats: [],
      actions: [{seat: 1, kind: "CHECK"}],
      nextNodeId: "sd_river",
    };

    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "hero_street_coverage" &&
          issue.message.includes("turn"),
      ),
    ).toBe(true);
  });

  it("validates heroNetChips against the hero's split-pot share", () => {
    const payload = wirePreflopCallToRiverShowdown(minimalFoldSituation(), {
      terminalId: "term_call_open",
      board: ["2s", "3s", "4s", "5s", "6s"],
      pot: 4,
      stacks: [198, 198],
      winnerSeats: [1, 0],
      heroNetChips: 0,
    });

    const result = validateSituation(payload);
    if (!result.ok) console.error(result.issues);
    expect(result.ok).toBe(true);

    const terminal = payload.nodes.term_call_open;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.heroNetChips = -0.01;
    expect(
      validateSituation(payload).issues.some(
        (issue) =>
          issue.code === "terminal" &&
          issue.message.includes("heroNetChips mismatch"),
      ),
    ).toBe(true);
  });

  it("accepts a one-street transition with reset commitments", () => {
    const payload = minimalFoldSituation();
    const face = payload.nodes.face_3bet;
    const flop = payload.nodes.hero_vs_3bet;
    const open = payload.nodes.open;
    const checkTerminal = payload.nodes.term_fold;
    const betTerminal = payload.nodes.term_4bet;
    if (
      face.type !== "scripted" ||
      flop.type !== "hero" ||
      open.type !== "hero" ||
      checkTerminal.type !== "terminal" ||
      betTerminal.type !== "terminal"
    ) {
      throw new Error("unexpected fixture node types");
    }

    face.actions = [{ seat: 1, kind: "CALL", amountTo: 5 }];
    open.actions = open.actions.filter((action) => action.kind !== "ALL_IN");
    flop.street = "flop";
    flop.pot = 10;
    flop.stacks = [195, 195];
    flop.streetBets = [0, 0];
    flop.board = ["2c", "7d", "Jh"];
    flop.callAmount = 0;
    flop.minRaiseTo = 2;
    flop.actions = [
      {
        actionKey: "CHECK",
        kind: "CHECK",
        coaching: "Checking realizes equity without inflating the pot.",
        verdict: "correct",
        evDeltaBb: 0,
        optimalActionKey: "CHECK",
        nextNodeId: "villain_folds_flop_check",
      },
      {
        actionKey: "BET_33",
        kind: "BET",
        amountTo: 2,
        sizingBucket: "33",
        coaching: "A small bet is possible but not preferred here.",
        verdict: "close",
        evDeltaBb: -0.1,
        optimalActionKey: "CHECK",
        nextNodeId: "villain_folds_flop_bet",
      },
    ];
    payload.nodes.villain_folds_flop_check = {
      type: "scripted",
      id: "villain_folds_flop_check",
      street: "flop",
      pot: 10,
      stacks: [195, 195],
      streetBets: [0, 0],
      board: ["2c", "7d", "Jh"],
      foldedSeats: [],
      actions: [{ seat: 1, kind: "FOLD" }],
      nextNodeId: "term_fold",
    };
    payload.nodes.villain_folds_flop_bet = {
      type: "scripted",
      id: "villain_folds_flop_bet",
      street: "flop",
      pot: 12,
      stacks: [193, 195],
      streetBets: [2, 0],
      board: ["2c", "7d", "Jh"],
      foldedSeats: [],
      actions: [{ seat: 1, kind: "FOLD" }],
      nextNodeId: "term_4bet",
    };
    checkTerminal.reason = "fold";
    checkTerminal.street = "flop";
    checkTerminal.board = ["2c", "7d", "Jh"];
    checkTerminal.foldedSeats = [1];
    checkTerminal.stacks = [195, 195];
    checkTerminal.pot = 10;
    checkTerminal.winnerSeats = [0];
    checkTerminal.heroNetChips = 5;
    betTerminal.reason = "fold";
    betTerminal.street = "flop";
    betTerminal.board = ["2c", "7d", "Jh"];
    betTerminal.foldedSeats = [1];
    betTerminal.stacks = [193, 195];
    betTerminal.pot = 12;
    betTerminal.winnerSeats = [0];
    betTerminal.heroNetChips = 5;
    delete payload.nodes.term_call;
    delete payload.nodes.term_shove;
    delete payload.nodes.villain_folds_shove;
    delete payload.nodes.villain_folds_4bet;
    delete payload.nodes.villain_folds_call;

    const result = validateSituation(payload);
    if (!result.ok) console.error(result.issues);
    expect(result.ok).toBe(true);
  });

  it.each([
    ["CHECK", "CHECK is illegal", undefined],
    ["CALL", "CALL amountTo", 4],
    ["RAISE", "RAISE must increase", 4],
    ["ALL_IN", "scripted action exceeds stack", 300],
  ] as const)(
    "rejects illegal scripted %s state changes",
    (kind, message, amountTo) => {
      const payload = minimalFoldSituation();
      const node = payload.nodes.face_3bet;
      if (node.type !== "scripted") throw new Error("expected scripted node");
      node.actions = [{ seat: 1, kind, amountTo }];
      const result = validateSituation(payload);
      expect(result.ok).toBe(false);
      expect(
        result.issues.some(
          (issue) =>
            issue.code === "transition" && issue.message.includes(message),
        ),
      ).toBe(true);
    },
  );

  it("rejects a transition that skips a street", () => {
    const payload = minimalFoldSituation();
    const child = payload.nodes.face_3bet;
    if (child.type !== "scripted") throw new Error("expected scripted node");
    child.street = "turn";
    child.board = ["2c", "7d", "Jh", "9s"];
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes("advance exactly one street"),
      ),
    ).toBe(true);
  });

  it("rejects cycles", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero node");
    open.actions[0].nextNodeId = "root";
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "cycle")).toBe(true);
  });

  it("rejects duplicate cards", () => {
    const payload = minimalFoldSituation();
    payload.runouts[0].cards = ["As", "7d", "Jh"];
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "card_unique")).toBe(true);
  });

  it("rejects non-canonical lineup stacks", () => {
    const payload = minimalFoldSituation();
    payload.lineup[1].startingStack = payload.startingStack + 1;
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((issue) => issue.code === "lineup")).toBe(true);
  });

  it("rejects incomplete hole-card coverage", () => {
    const payload = minimalFoldSituation();
    payload.holeCards.pop();
    const result = validateSituation(payload);
    expect(result.issues.some((issue) => issue.code === "holeCards")).toBe(
      true,
    );
  });

  it("rejects heroHand mismatch and global hole-card collisions", () => {
    const payload = minimalFoldSituation();
    payload.holeCards[0].cards = ["Ah", "Kd"];
    payload.holeCards[1].cards[0] = "Kd";
    const result = validateSituation(payload);
    expect(result.issues.some((issue) => issue.code === "heroHand")).toBe(true);
    expect(result.issues.some((issue) => issue.code === "card_unique")).toBe(
      true,
    );
  });

  it("rejects folded-state propagation mismatches", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero node");
    open.foldedSeats = [1];
    const result = validateSituation(payload);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" && issue.message.includes("foldedSeats"),
      ),
    ).toBe(true);
  });

  it("rejects a folded scripted actor", () => {
    const payload = minimalFoldSituation();
    const node = payload.nodes.face_3bet;
    if (node.type !== "scripted") throw new Error("expected scripted node");
    node.foldedSeats = [1];
    const result = validateSituation(payload);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "folded" && issue.message.includes("cannot act"),
      ),
    ).toBe(true);
  });

  it("rejects the wrong deterministic showdown winner", () => {
    const payload = wirePreflopCallToRiverShowdown(minimalFoldSituation(), {
      terminalId: "term_call_open",
      board: ["2s", "3s", "4s", "5s", "6s"],
      pot: 4,
      stacks: [198, 198],
      winnerSeats: [1],
      heroNetChips: -2,
    });
    const result = validateSituation(payload);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "terminal" &&
          issue.message.includes("deterministic winners"),
      ),
    ).toBe(true);
  });

  it("rejects missing FOLD when facing a bet", () => {
    const payload = minimalFoldSituation();
    const hero = payload.nodes.hero_vs_3bet;
    if (hero.type === "hero") {
      // Keep the edge target so the graph stays reachable; swap kind to CHECK.
      const fold = hero.actions.find((a) => a.kind === "FOLD");
      if (!fold) throw new Error("expected FOLD");
      fold.kind = "CHECK";
      fold.actionKey = "CHECK";
      fold.coaching = "Checking is never legal when facing a raise.";
    }
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "coverage")).toBe(true);
  });

  it("rejects non-preflop roots", () => {
    const payload = minimalFoldSituation();
    const root = payload.nodes.root;
    if (root.type === "scripted") {
      root.street = "flop";
      root.board = ["2c", "7d", "Jh"];
    }
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "root")).toBe(true);
  });

  it("rejects invalid verdicts", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero node");
    open.actions[0].verdict = "wrong" as "incorrect";
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "verdict")).toBe(true);
  });

  it("rejects optimalActionKey references that are not correct edges", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero node");
    for (const action of open.actions) {
      action.optimalActionKey = "CHECK";
    }
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(result.issues.some((i) => i.code === "optimal_action")).toBe(true);
  });

  it("hashes structurally equal payloads identically ignoring coaching", () => {
    const a = minimalFoldSituation();
    const b = minimalFoldSituation();
    if (b.nodes.open.type === "hero") {
      b.nodes.open.actions[0].coaching = "Different coaching text entirely.";
    }
    expect(hashSituationStructure(a)).toBe(hashSituationStructure(b));
  });
});

describe("allocation helpers", () => {
  it("filters unseen ids", () => {
    const unseen = filterUnseenSituationIds(["a", "b", "c"], new Set(["b"]));
    expect(unseen).toEqual(["a", "c"]);
  });

  it("refills at low water", () => {
    expect(shouldRefillPool(3)).toBe(true);
    expect(shouldRefillPool(1)).toBe(true);
    expect(shouldRefillPool(0)).toBe(true);
    expect(shouldRefillPool(4)).toBe(false);
  });
});
