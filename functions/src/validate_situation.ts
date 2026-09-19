/**
 * Deterministic validators for branching situations.
 *
 * Invalid payloads must never be stored as servable. Checks cover graph
 * structure, cards, betting legality/sizing, street/runout consistency,
 * pot/chip conservation along scripted edges, and coaching completeness.
 */

import { normalizeCard, isValidCard } from "./setup_key";
import { compareHandScores, evaluateSevenCards } from "./holdem_evaluator";
import { splitPotBySeat } from "./payout";
import {
  PAYLOAD_VERSION,
  SIZING_BUCKETS,
  type HeroActionEdge,
  type HeroDecisionNode,
  type SituationNode,
  type SituationPayload,
  type SizingBucket,
  type Street,
  VILLAIN_ARCHETYPES,
} from "./situation_types";

const EPS = 0.005;
const CENT_PRECISION_EPS = 1e-9;
const BOARD_LEN: Record<Street, number> = {
  preflop: 0,
  flop: 3,
  turn: 4,
  river: 5,
};

export interface ValidationIssue {
  code: string;
  message: string;
  nodeId?: string;
}

export interface ValidationResult {
  ok: boolean;
  issues: ValidationIssue[];
}

/** Derives terminal winners solely from folded state and authored cards. */
export function deriveTerminalWinnerSeats(
  payload: SituationPayload,
  terminal: Extract<SituationNode, { type: "terminal" }>,
): number[] {
  const activeSeats = Array.from(
    { length: payload.seatCount },
    (_, seat) => seat,
  ).filter((seat) => !terminal.foldedSeats.includes(seat));
  if (terminal.reason === "fold") {
    return activeSeats.length === 1 ? activeSeats : [];
  }
  if (terminal.street !== "river" || terminal.board.length !== 5) return [];
  const scored = activeSeats
    .map((seat) => {
      const hole = payload.holeCards.find(
        (entry) => entry.seat === seat,
      )?.cards;
      if (!hole || hole.length !== 2) return null;
      return { seat, score: evaluateSevenCards([...hole, ...terminal.board]) };
    })
    .filter(
      (value): value is { seat: number; score: readonly number[] } =>
        value !== null,
    );
  if (scored.length !== activeSeats.length || scored.length === 0) return [];
  let best = scored[0].score;
  for (const entry of scored.slice(1)) {
    if (compareHandScores(entry.score, best) > 0) best = entry.score;
  }
  return scored
    .filter((entry) => compareHandScores(entry.score, best) === 0)
    .map((entry) => entry.seat)
    .sort((a, b) => a - b);
}

/**
 * Validates a situation payload. Returns all issues found (does not throw).
 */
export function validateSituation(payload: unknown): ValidationResult {
  const issues: ValidationIssue[] = [];
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    return {
      ok: false,
      issues: [{ code: "type", message: "payload must be object" }],
    };
  }
  const p = payload as SituationPayload;

  if (p.payloadVersion !== PAYLOAD_VERSION) {
    issues.push({
      code: "payloadVersion",
      message: `expected payloadVersion ${PAYLOAD_VERSION}`,
    });
  }
  if (!p.setupKey || typeof p.setupKey !== "string") {
    issues.push({ code: "setupKey", message: "setupKey required" });
  }
  if (p.setupMode !== "random" && p.setupMode !== "custom") {
    issues.push({
      code: "setupMode",
      message: "setupMode must be random|custom",
    });
  }
  if (!Number.isInteger(p.seatCount) || p.seatCount < 2 || p.seatCount > 9) {
    issues.push({ code: "seatCount", message: "seatCount must be 2..9" });
  }
  for (const field of ["smallBlind", "bigBlind", "startingStack"] as const) {
    if (
      typeof p[field] !== "number" ||
      !Number.isFinite(p[field]) ||
      !(p[field] > 0)
    ) {
      issues.push({ code: field, message: `${field} must be positive` });
    } else {
      checkCentPrecision(p[field], field, issues);
    }
  }
  if (typeof p.ante !== "number" || !Number.isFinite(p.ante) || p.ante < 0) {
    issues.push({ code: "ante", message: "ante must be >= 0" });
  } else {
    checkCentPrecision(p.ante, "ante", issues);
  }
  if (
    !Number.isInteger(p.buttonSeat) ||
    p.buttonSeat < 0 ||
    p.buttonSeat >= p.seatCount
  ) {
    issues.push({ code: "buttonSeat", message: "buttonSeat out of range" });
  }
  if (
    !Number.isInteger(p.heroSeat) ||
    p.heroSeat < 0 ||
    p.heroSeat >= p.seatCount
  ) {
    issues.push({ code: "heroSeat", message: "heroSeat out of range" });
  }

  validateLineup(p, issues);
  validateHoleCards(p, issues);
  validateRunouts(p, issues);
  validateGraph(p, issues);

  // Always run deep node checks; graph issues are independent.
  validateNodesDeep(p, issues);
  validateReachableTransitions(p, issues);

  return { ok: issues.length === 0, issues };
}

/**
 * Throws if validation fails.
 */
export function assertValidSituation(payload: unknown): SituationPayload {
  const result = validateSituation(payload);
  if (!result.ok) {
    const summary = result.issues
      .slice(0, 8)
      .map((i) => `${i.code}: ${i.message}`)
      .join("; ");
    throw new Error(`situation validation failed: ${summary}`);
  }
  return payload as SituationPayload;
}

function validateLineup(p: SituationPayload, issues: ValidationIssue[]): void {
  if (!Array.isArray(p.lineup) || p.lineup.length !== p.seatCount) {
    issues.push({
      code: "lineup",
      message: "lineup must have seatCount entries",
    });
    return;
  }
  const seats = new Set<number>();
  let heroes = 0;
  for (const seat of p.lineup) {
    if (!seat || typeof seat !== "object") {
      issues.push({ code: "lineup", message: "invalid lineup entry" });
      continue;
    }
    if (!Number.isInteger(seat.seat) || seats.has(seat.seat)) {
      issues.push({
        code: "lineup",
        message: "duplicate or invalid seat index",
      });
    }
    seats.add(seat.seat);
    if (seat.archetype === "HERO") {
      heroes += 1;
      if (seat.seat !== p.heroSeat) {
        issues.push({
          code: "lineup",
          message: "HERO seat must equal heroSeat",
        });
      }
    } else if (
      !(VILLAIN_ARCHETYPES as readonly string[]).includes(seat.archetype)
    ) {
      issues.push({
        code: "lineup",
        message: `bad archetype ${String(seat.archetype)}`,
      });
    }
    if (
      typeof seat.startingStack !== "number" ||
      !Number.isFinite(seat.startingStack) ||
      seat.startingStack !== p.startingStack
    ) {
      issues.push({
        code: "lineup",
        message: "every lineup startingStack must equal payload.startingStack",
      });
    }
    if (
      typeof seat.startingStack === "number" &&
      Number.isFinite(seat.startingStack)
    ) {
      checkCentPrecision(seat.startingStack, "lineup startingStack", issues);
    }
  }
  if (heroes !== 1) {
    issues.push({ code: "lineup", message: "exactly one HERO required" });
  }
  for (let i = 0; i < p.seatCount; i++) {
    if (!seats.has(i)) {
      issues.push({ code: "lineup", message: `missing seat ${i}` });
    }
  }
}

function validateHoleCards(
  p: SituationPayload,
  issues: ValidationIssue[],
): void {
  if (!Array.isArray(p.heroHand) || p.heroHand.length !== 2) {
    issues.push({ code: "heroHand", message: "heroHand must be two cards" });
    return;
  }
  const cards: string[] = [];
  for (const c of p.heroHand) {
    if (!isValidCard(String(c))) {
      issues.push({ code: "heroHand", message: `invalid card ${String(c)}` });
    } else {
      cards.push(normalizeCard(String(c)));
    }
  }
  if (cards.length === 2 && cards[0] === cards[1]) {
    issues.push({
      code: "heroHand",
      message: "hero hole cards must be unique",
    });
  }
  if (!Array.isArray(p.holeCards) || p.holeCards.length !== p.seatCount) {
    issues.push({
      code: "holeCards",
      message: "holeCards must cover every seat exactly once",
    });
    return;
  }
  const seats = new Set<number>();
  const used = new Set<string>();
  for (const entry of p.holeCards) {
    if (
      !entry ||
      !Number.isInteger(entry.seat) ||
      entry.seat < 0 ||
      entry.seat >= p.seatCount ||
      seats.has(entry.seat)
    ) {
      issues.push({
        code: "holeCards",
        message: "invalid or duplicate hole-card seat",
      });
      continue;
    }
    seats.add(entry.seat);
    if (!Array.isArray(entry.cards) || entry.cards.length !== 2) {
      issues.push({
        code: "holeCards",
        message: `seat ${entry.seat} needs two cards`,
      });
      continue;
    }
    for (const card of entry.cards) {
      if (!isValidCard(String(card))) {
        issues.push({
          code: "holeCards",
          message: `invalid card ${String(card)}`,
        });
        continue;
      }
      const normalized = normalizeCard(String(card));
      if (used.has(normalized)) {
        issues.push({
          code: "card_unique",
          message: `duplicate card ${normalized}`,
        });
      }
      used.add(normalized);
    }
  }
  const heroCards = p.holeCards.find(
    (entry) => entry.seat === p.heroSeat,
  )?.cards;
  if (
    !heroCards ||
    heroCards.length !== 2 ||
    heroCards.some(
      (card, index) =>
        !isValidCard(String(card)) ||
        !isValidCard(String(p.heroHand?.[index])) ||
        normalizeCard(String(card)) !==
          normalizeCard(String(p.heroHand[index])),
    )
  ) {
    issues.push({
      code: "heroHand",
      message: "heroHand must equal hero holeCards entry",
    });
  }
}

function validateRunouts(p: SituationPayload, issues: ValidationIssue[]): void {
  if (!Array.isArray(p.runouts)) {
    issues.push({ code: "runouts", message: "runouts must be an array" });
    return;
  }
  const used = new Set<string>();
  if (Array.isArray(p.holeCards)) {
    for (const entry of p.holeCards) {
      if (!Array.isArray(entry?.cards)) continue;
      for (const c of entry.cards) {
        if (isValidCard(String(c))) used.add(normalizeCard(String(c)));
      }
    }
  }
  const byStreet = new Map<string, string[]>();
  for (const runout of p.runouts) {
    if (!runout || typeof runout !== "object") {
      issues.push({ code: "runouts", message: "invalid runout entry" });
      continue;
    }
    if (
      runout.street !== "flop" &&
      runout.street !== "turn" &&
      runout.street !== "river"
    ) {
      issues.push({ code: "runouts", message: `bad street ${runout.street}` });
      continue;
    }
    if (byStreet.has(runout.street)) {
      issues.push({
        code: "runouts",
        message: `duplicate runout for ${runout.street}`,
      });
    }
    if (!Array.isArray(runout.cards)) {
      issues.push({ code: "runouts", message: "cards must be array" });
      continue;
    }
    const expected =
      runout.street === "flop" ? 3 : runout.street === "turn" ? 1 : 1;
    if (runout.cards.length !== expected) {
      issues.push({
        code: "runouts",
        message:
          `${runout.street} runout must add ${expected} card(s) ` +
          `(got ${runout.cards.length})`,
      });
    }
    const normalized: string[] = [];
    for (const c of runout.cards) {
      if (!isValidCard(String(c))) {
        issues.push({ code: "runouts", message: `invalid card ${String(c)}` });
        continue;
      }
      const n = normalizeCard(String(c));
      if (used.has(n)) {
        issues.push({
          code: "card_unique",
          message: `duplicate card ${n}`,
        });
      }
      used.add(n);
      normalized.push(n);
    }
    byStreet.set(runout.street, normalized);
  }
}

function validateGraph(p: SituationPayload, issues: ValidationIssue[]): void {
  if (!p.nodes || typeof p.nodes !== "object" || Array.isArray(p.nodes)) {
    issues.push({ code: "nodes", message: "nodes map required" });
    return;
  }
  if (!p.rootNodeId || !p.nodes[p.rootNodeId]) {
    issues.push({ code: "root", message: "rootNodeId missing from nodes" });
    return;
  }

  const root = p.nodes[p.rootNodeId];
  validateCanonicalRoot(p, root, issues);

  const ids = Object.keys(p.nodes);
  if (ids.length > 12) {
    issues.push({
      code: "graph_size",
      message: `situation graph must contain at most 12 nodes (got ${ids.length})`,
    });
  }
  for (const id of ids) {
    const node = p.nodes[id];
    if (!node || node.id !== id) {
      issues.push({
        code: "nodes",
        message: `node id mismatch for ${id}`,
        nodeId: id,
      });
    }
  }

  const adjacency = new Map<string, string[]>();
  for (const id of ids) {
    adjacency.set(id, outgoing(p.nodes[id]));
  }

  // Existence of targets
  for (const [from, targets] of adjacency) {
    for (const to of targets) {
      if (!p.nodes[to]) {
        issues.push({
          code: "graph",
          message: `missing nextNodeId ${to}`,
          nodeId: from,
        });
      }
    }
  }

  // Reachability from root (BFS)
  const reachable = new Set<string>();
  const queue = [p.rootNodeId];
  while (queue.length > 0) {
    const cur = queue.shift()!;
    if (reachable.has(cur)) continue;
    reachable.add(cur);
    for (const next of adjacency.get(cur) ?? []) {
      if (!reachable.has(next)) queue.push(next);
    }
  }
  for (const id of ids) {
    if (!reachable.has(id)) {
      issues.push({
        code: "reachability",
        message: `node unreachable from root: ${id}`,
        nodeId: id,
      });
    }
  }

  // Acyclicity via DFS color marks
  const color = new Map<string, 0 | 1 | 2>();
  const visit = (id: string): void => {
    const c = color.get(id) ?? 0;
    if (c === 1) {
      issues.push({
        code: "cycle",
        message: `cycle involving ${id}`,
        nodeId: id,
      });
      return;
    }
    if (c === 2) return;
    color.set(id, 1);
    for (const next of adjacency.get(id) ?? []) {
      if (p.nodes[next]) visit(next);
    }
    color.set(id, 2);
  };
  visit(p.rootNodeId);

  // Every leaf must be terminal; every non-terminal must have outs
  for (const id of reachable) {
    const node = p.nodes[id];
    const outs = adjacency.get(id) ?? [];
    if (node.type === "terminal") {
      if (outs.length > 0) {
        issues.push({
          code: "terminal",
          message: "terminal nodes cannot have edges",
          nodeId: id,
        });
      }
    } else if (outs.length === 0) {
      issues.push({
        code: "leaf",
        message: "non-terminal node has no outgoing edges",
        nodeId: id,
      });
    }
  }
}

function validateCanonicalRoot(
  p: SituationPayload,
  root: SituationNode,
  issues: ValidationIssue[],
): void {
  const fail = (message: string): void => {
    issues.push({ code: "root", message, nodeId: root.id });
  };
  if (root.type !== "scripted") {
    fail("root node must be scripted");
    return;
  }
  if (root.street !== "preflop") fail("root street must be preflop");
  if (root.pot !== 0) fail("root pot must be 0");
  if (
    !Array.isArray(root.stacks) ||
    root.stacks.length !== p.seatCount ||
    root.stacks.some((stack) => stack !== p.startingStack)
  ) {
    fail("every root stack must equal payload.startingStack");
  }
  if (
    !Array.isArray(root.streetBets) ||
    root.streetBets.length !== p.seatCount ||
    root.streetBets.some((bet) => bet !== 0)
  ) {
    fail("every root streetBet must be 0");
  }
  if (!Array.isArray(root.foldedSeats) || root.foldedSeats.length !== 0) {
    fail("root foldedSeats must be empty");
  }
  if (!Array.isArray(root.board) || root.board.length !== 0) {
    fail("root board must be empty");
  }

  const forcedPosts = [];
  if (p.ante > 0) {
    for (let seat = 0; seat < p.seatCount; seat++) {
      forcedPosts.push({ seat, kind: "POST_ANTE", amountTo: p.ante });
    }
  }
  const smallBlindSeat = p.seatCount === 2
    ? p.buttonSeat
    : (p.buttonSeat + 1) % p.seatCount;
  const bigBlindSeat = p.seatCount === 2
    ? (p.buttonSeat + 1) % p.seatCount
    : (p.buttonSeat + 2) % p.seatCount;
  forcedPosts.push({
    seat: smallBlindSeat,
    kind: "POST_SB",
    amountTo: p.ante + p.smallBlind,
  });
  forcedPosts.push({
    seat: bigBlindSeat,
    kind: "POST_BB",
    amountTo: p.ante + p.bigBlind,
  });

  for (let i = 0; i < forcedPosts.length; i++) {
    const expected = forcedPosts[i];
    const actual = root.actions?.[i];
    if (
      !actual ||
      actual.seat !== expected.seat ||
      actual.kind !== expected.kind ||
      actual.amountTo !== expected.amountTo
    ) {
      fail(
        "root actions must begin with the complete canonical forced-post ledger",
      );
      return;
    }
  }
  const extraForced = root.actions
    ?.slice(forcedPosts.length)
    .some((action) =>
      action.kind === "POST_ANTE" ||
      action.kind === "POST_SB" ||
      action.kind === "POST_BB"
    );
  if (extraForced) {
    fail("root forced-post ledger has an extra or duplicate post");
  }
}

function outgoing(node: SituationNode): string[] {
  if (node.type === "hero") {
    return node.actions.map((a) => a.nextNodeId);
  }
  if (node.type === "scripted") {
    return [node.nextNodeId];
  }
  return [];
}

function validateNodesDeep(
  p: SituationPayload,
  issues: ValidationIssue[],
): void {
  if (!p.nodes || typeof p.nodes !== "object" || Array.isArray(p.nodes)) {
    return;
  }
  const boardPrefix = buildBoardPrefixes(p);
  for (const node of Object.values(p.nodes)) {
    if (node.type === "hero") {
      validateHeroNode(p, node, boardPrefix, issues);
    } else if (node.type === "scripted") {
      validateScriptedNode(p, node, boardPrefix, issues);
    } else if (node.type === "terminal") {
      validateTerminalNode(p, node, boardPrefix, issues);
    } else {
      issues.push({ code: "nodes", message: "unknown node type" });
    }
  }
}

function buildBoardPrefixes(p: SituationPayload): Record<Street, string[]> {
  const flop = p.runouts.find((r) => r.street === "flop")?.cards ?? [];
  const turn = p.runouts.find((r) => r.street === "turn")?.cards ?? [];
  const river = p.runouts.find((r) => r.street === "river")?.cards ?? [];
  const flopN = flop.map((c) => normalizeCard(String(c)));
  const turnN = turn.map((c) => normalizeCard(String(c)));
  const riverN = river.map((c) => normalizeCard(String(c)));
  return {
    preflop: [],
    flop: flopN,
    turn: [...flopN, ...turnN],
    river: [...flopN, ...turnN, ...riverN],
  };
}

function validateHeroNode(
  p: SituationPayload,
  node: HeroDecisionNode,
  boards: Record<Street, string[]>,
  issues: ValidationIssue[],
): void {
  checkStateArrays(p, node, issues);
  checkFoldedSeats(p, node, issues);
  if (node.foldedSeats?.includes(node.toAct)) {
    issues.push({
      code: "folded",
      message: "current hero cannot already be folded",
      nodeId: node.id,
    });
  }
  checkBoardMatch(node.id, node.street, node.board, boards, issues);

  if (
    typeof node.callAmount !== "number" ||
    !Number.isFinite(node.callAmount) ||
    node.callAmount < -EPS ||
    typeof node.minRaiseTo !== "number" ||
    !Number.isFinite(node.minRaiseTo) ||
    node.minRaiseTo < -EPS
  ) {
    issues.push({
      code: "state",
      message: "callAmount and minRaiseTo must be finite and non-negative",
      nodeId: node.id,
    });
  } else {
    checkCentPrecision(node.callAmount, "callAmount", issues, node.id);
    checkCentPrecision(node.minRaiseTo, "minRaiseTo", issues, node.id);
  }

  if (node.toAct !== p.heroSeat) {
    issues.push({
      code: "toAct",
      message: "hero node toAct must be heroSeat",
      nodeId: node.id,
    });
  }
  if (!Array.isArray(node.actions) || node.actions.length === 0) {
    issues.push({
      code: "actions",
      message: "hero node needs actions",
      nodeId: node.id,
    });
    return;
  }

  const keys = new Set<string>();
  const kinds = new Set<string>();
  const correctKeys = new Set<string>();
  const optimalKeys = new Set<string>();
  const heroBet = node.streetBets[p.heroSeat] ?? 0;
  const highestBet = Math.max(...node.streetBets);
  const derivedCallAmount = Math.max(0, highestBet - heroBet);
  if (Math.abs(node.callAmount - derivedCallAmount) > EPS) {
    issues.push({
      code: "transition",
      message:
        `callAmount mismatch: expected ${derivedCallAmount}, ` +
        `got ${node.callAmount}`,
      nodeId: node.id,
    });
  }
  for (const action of node.actions) {
    validateHeroAction(p, node, action, issues);
    if (keys.has(action.actionKey)) {
      issues.push({
        code: "actions",
        message: `duplicate actionKey ${action.actionKey}`,
        nodeId: node.id,
      });
    }
    keys.add(action.actionKey);
    kinds.add(action.kind);
    if (action.verdict === "correct") {
      correctKeys.add(action.actionKey);
    }
    if (typeof action.optimalActionKey === "string") {
      optimalKeys.add(action.optimalActionKey);
    }
  }

  if (correctKeys.size === 0) {
    issues.push({
      code: "verdict",
      message: "hero node must have at least one correct action",
      nodeId: node.id,
    });
  }
  if (optimalKeys.size !== 1) {
    issues.push({
      code: "optimal_action",
      message: "all edges must use one consistent optimalActionKey",
      nodeId: node.id,
    });
  } else {
    const optimalKey = [...optimalKeys][0];
    if (!keys.has(optimalKey)) {
      issues.push({
        code: "optimal_action",
        message: `optimalActionKey ${optimalKey} does not exist in node`,
        nodeId: node.id,
      });
    } else if (!correctKeys.has(optimalKey)) {
      issues.push({
        code: "optimal_action",
        message: `optimalActionKey ${optimalKey} must point to a correct edge`,
        nodeId: node.id,
      });
    }
  }

  // Legal action coverage
  const facingBet = derivedCallAmount > EPS;
  if (facingBet) {
    if (!kinds.has("FOLD")) {
      issues.push({
        code: "coverage",
        message: "facing a bet requires FOLD",
        nodeId: node.id,
      });
    }
    if (!kinds.has("CALL") && !kinds.has("ALL_IN")) {
      issues.push({
        code: "coverage",
        message: "facing a bet requires CALL or ALL_IN",
        nodeId: node.id,
      });
    }
    if (kinds.has("CHECK")) {
      issues.push({
        code: "coverage",
        message: "CHECK illegal when facing a bet",
        nodeId: node.id,
      });
    }
    if (kinds.has("BET")) {
      issues.push({
        code: "coverage",
        message: "BET illegal when facing a bet (use RAISE)",
        nodeId: node.id,
      });
    }
  } else {
    if (!kinds.has("CHECK") && !kinds.has("BET") && !kinds.has("ALL_IN")) {
      issues.push({
        code: "coverage",
        message: "checked-to node needs CHECK or BET",
        nodeId: node.id,
      });
    }
    if (kinds.has("FOLD")) {
      issues.push({
        code: "coverage",
        message: "FOLD illegal when not facing a bet",
        nodeId: node.id,
      });
    }
    if (kinds.has("CALL")) {
      issues.push({
        code: "coverage",
        message: "CALL illegal when callAmount is 0",
        nodeId: node.id,
      });
    }
    if (kinds.has("RAISE")) {
      issues.push({
        code: "coverage",
        message: "RAISE illegal when not facing a bet (use BET)",
        nodeId: node.id,
      });
    }
  }
}

function validateHeroAction(
  p: SituationPayload,
  node: HeroDecisionNode,
  action: HeroActionEdge,
  issues: ValidationIssue[],
): void {
  if (
    action.amountTo !== undefined &&
    (typeof action.amountTo !== "number" || !Number.isFinite(action.amountTo))
  ) {
    issues.push({
      code: "sizing",
      message: `amountTo must be finite for ${action.actionKey}`,
      nodeId: node.id,
    });
  } else if (action.amountTo !== undefined) {
    checkCentPrecision(action.amountTo, "edge amountTo", issues, node.id);
  }
  if (!action.actionKey || typeof action.actionKey !== "string") {
    issues.push({
      code: "action",
      message: "actionKey required",
      nodeId: node.id,
    });
  }
  if (
    !action.coaching ||
    typeof action.coaching !== "string" ||
    action.coaching.trim().length < 8
  ) {
    issues.push({
      code: "coaching",
      message: `coaching missing/too short for ${action.actionKey}`,
      nodeId: node.id,
    });
  }
  if (
    action.verdict !== "correct" &&
    action.verdict !== "incorrect" &&
    action.verdict !== "close"
  ) {
    issues.push({
      code: "verdict",
      message: `invalid verdict for ${action.actionKey}`,
      nodeId: node.id,
    });
  }
  if (
    typeof action.evDeltaBb !== "number" ||
    !Number.isFinite(action.evDeltaBb)
  ) {
    issues.push({
      code: "ev_delta",
      message: `evDeltaBb must be finite for ${action.actionKey}`,
      nodeId: node.id,
    });
  } else if (action.verdict === "correct" && Math.abs(action.evDeltaBb) > EPS) {
    issues.push({
      code: "ev_delta",
      message: `correct action ${action.actionKey} must have evDeltaBb near 0`,
      nodeId: node.id,
    });
  } else if (
    (action.verdict === "incorrect" || action.verdict === "close") &&
    action.evDeltaBb > 0
  ) {
    issues.push({
      code: "ev_delta",
      message: `non-best action ${action.actionKey} must have evDeltaBb <= 0`,
      nodeId: node.id,
    });
  }
  if (!action.optimalActionKey || typeof action.optimalActionKey !== "string") {
    issues.push({
      code: "optimal_action",
      message: `optimalActionKey required for ${action.actionKey}`,
      nodeId: node.id,
    });
  }
  // Coaching must not contradict the action kind in an obvious way
  const coachingLower = (action.coaching ?? "").toLowerCase();
  if (
    action.kind === "FOLD" &&
    /\balways\s+raise\b|\bmust\s+raise\b|\bnever\s+fold\b/.test(coachingLower)
  ) {
    issues.push({
      code: "coaching_contradiction",
      message: `coaching contradicts FOLD for ${action.actionKey}`,
      nodeId: node.id,
    });
  }

  const heroStack = node.stacks[p.heroSeat] ?? 0;
  const heroBet = node.streetBets[p.heroSeat] ?? 0;
  const maxTo = heroStack + heroBet;

  switch (action.kind) {
    case "FOLD":
    case "CHECK":
      if (action.amountTo !== undefined && action.amountTo !== 0) {
        issues.push({
          code: "sizing",
          message: `${action.kind} must not set amountTo`,
          nodeId: node.id,
        });
      }
      break;
    case "CALL": {
      const highestBet = Math.max(...node.streetBets);
      if (action.amountTo === undefined) {
        issues.push({
          code: "sizing",
          message: "CALL requires amountTo",
          nodeId: node.id,
        });
      } else if (
        Math.abs(action.amountTo - Math.min(highestBet, maxTo)) > EPS
      ) {
        issues.push({
          code: "sizing",
          message: `CALL amountTo mismatch (got ${action.amountTo})`,
          nodeId: node.id,
        });
      }
      break;
    }
    case "BET":
    case "RAISE":
    case "ALL_IN": {
      if (action.amountTo === undefined || action.amountTo <= 0) {
        issues.push({
          code: "sizing",
          message: `${action.kind} requires positive amountTo`,
          nodeId: node.id,
        });
        break;
      }
      if (action.amountTo > maxTo + EPS) {
        issues.push({
          code: "sizing",
          message: `${action.kind} exceeds stack`,
          nodeId: node.id,
        });
      }
      if (
        (action.kind === "BET" || action.kind === "RAISE") &&
        action.amountTo <= heroBet + EPS
      ) {
        issues.push({
          code: "sizing",
          message: `${action.kind} must increase hero street commitment`,
          nodeId: node.id,
        });
      }
      if (
        action.kind === "RAISE" &&
        action.amountTo <= Math.max(...node.streetBets) + EPS
      ) {
        issues.push({
          code: "sizing",
          message: "RAISE must exceed the current wager",
          nodeId: node.id,
        });
      }
      if (action.kind !== "ALL_IN" && action.amountTo + EPS < node.minRaiseTo) {
        // Allow BET open when minRaiseTo may equal BB
        if (action.kind === "BET" && node.callAmount <= EPS) {
          if (action.amountTo + EPS < p.bigBlind) {
            issues.push({
              code: "sizing",
              message: "BET below big blind",
              nodeId: node.id,
            });
          }
        } else {
          issues.push({
            code: "sizing",
            message: `${action.kind} below minRaiseTo`,
            nodeId: node.id,
          });
        }
      }
      if (action.kind === "ALL_IN" && Math.abs(action.amountTo - maxTo) > EPS) {
        issues.push({
          code: "sizing",
          message: "ALL_IN amountTo must equal stack+streetBet",
          nodeId: node.id,
        });
      }
      if (action.sizingBucket !== undefined) {
        if (
          !(SIZING_BUCKETS as readonly string[]).includes(action.sizingBucket)
        ) {
          issues.push({
            code: "sizing",
            message: `unknown sizingBucket ${action.sizingBucket}`,
            nodeId: node.id,
          });
        } else {
          checkSizingBucket(p, node, action, action.sizingBucket, issues);
        }
      }
      break;
    }
    default:
      issues.push({
        code: "action",
        message: `unknown kind ${String((action as HeroActionEdge).kind)}`,
        nodeId: node.id,
      });
  }
}

function checkSizingBucket(
  p: SituationPayload,
  node: HeroDecisionNode,
  action: HeroActionEdge,
  bucket: SizingBucket,
  issues: ValidationIssue[],
): void {
  if (action.amountTo === undefined) return;
  const heroBet = node.streetBets[p.heroSeat] ?? 0;
  if (bucket === "ALL_IN") {
    const maxTo = (node.stacks[p.heroSeat] ?? 0) + heroBet;
    if (Math.abs(action.amountTo - maxTo) > EPS) {
      issues.push({
        code: "sizing",
        message: "ALL_IN bucket mismatch",
        nodeId: node.id,
      });
    }
    return;
  }
  if (bucket === "MIN") {
    const minTarget =
      node.callAmount > EPS
        ? node.minRaiseTo
        : Math.max(p.bigBlind, node.minRaiseTo);
    if (action.amountTo + EPS < minTarget) {
      issues.push({
        code: "sizing",
        message: "MIN bucket below legal minimum",
        nodeId: node.id,
      });
    }
  }
  // Percentage buckets are curated labels; amount legality is enforced above.
}

function validateScriptedNode(
  p: SituationPayload,
  node: Extract<SituationNode, { type: "scripted" }>,
  boards: Record<Street, string[]>,
  issues: ValidationIssue[],
): void {
  checkStateArrays(p, node, issues);
  checkFoldedSeats(p, node, issues);
  checkBoardMatch(node.id, node.street, node.board, boards, issues);
  if (!Array.isArray(node.actions) || node.actions.length === 0) {
    issues.push({
      code: "scripted",
      message: "scripted node needs actions",
      nodeId: node.id,
    });
    return;
  }

  simulateScriptedActions(p, node, issues);
}

interface BettingState {
  pot: number;
  stacks: number[];
  streetBets: number[];
  foldedSeats: Set<number>;
}

function validateReachableTransitions(
  p: SituationPayload,
  issues: ValidationIssue[],
): void {
  if (!p.nodes?.[p.rootNodeId]) return;
  const reachable = new Set<string>();
  const queue = [p.rootNodeId];
  while (queue.length > 0) {
    const id = queue.shift()!;
    if (reachable.has(id) || !p.nodes[id]) continue;
    reachable.add(id);
    queue.push(...outgoing(p.nodes[id]));
  }

  for (const id of reachable) {
    const node = p.nodes[id];
    if (node.type === "hero") {
      for (const action of node.actions ?? []) {
        const target = p.nodes[action.nextNodeId];
        if (!target) continue;
        const state = simulateHeroAction(p, node, action);
        validateTransition(
          p,
          node,
          target,
          state,
          action.kind === "FOLD",
          issues,
        );
      }
    } else if (node.type === "scripted") {
      const target = p.nodes[node.nextNodeId];
      if (!target) continue;
      // Action legality is reported by validateScriptedNode. Simulate with a
      // private sink here so transition checking does not duplicate issues.
      const state = simulateScriptedActions(p, node, []);
      if (state) {
        validateTransition(p, node, target, state, false, issues);
      }
    }
  }
}

function stateFromNode(
  p: SituationPayload,
  node: {
    pot: number;
    stacks: number[];
    streetBets: number[];
    foldedSeats: number[];
  },
): BettingState | null {
  if (
    typeof node.pot !== "number" ||
    !Array.isArray(node.stacks) ||
    !Array.isArray(node.streetBets) ||
    node.stacks.length !== p.seatCount ||
    node.streetBets.length !== p.seatCount
  ) {
    return null;
  }
  return {
    pot: node.pot,
    stacks: [...node.stacks],
    streetBets: [...node.streetBets],
    foldedSeats: new Set(node.foldedSeats),
  };
}

function simulateHeroAction(
  p: SituationPayload,
  node: HeroDecisionNode,
  action: HeroActionEdge,
): BettingState | null {
  const state = stateFromNode(p, node);
  if (!state) return null;
  if (action.kind === "FOLD") {
    state.foldedSeats.add(p.heroSeat);
    return state;
  }
  if (action.kind === "CHECK") return state;
  if (typeof action.amountTo !== "number") return null;
  return commitTo(state, p.heroSeat, action.amountTo);
}

function simulateScriptedActions(
  p: SituationPayload,
  node: Extract<SituationNode, { type: "scripted" }>,
  issues: ValidationIssue[],
): BettingState | null {
  let state = stateFromNode(p, node);
  if (!state || !Array.isArray(node.actions)) return null;
  for (const action of node.actions) {
    if (
      action.amountTo !== undefined &&
      typeof action.amountTo === "number" &&
      Number.isFinite(action.amountTo)
    ) {
      checkCentPrecision(action.amountTo, "scripted amountTo", issues, node.id);
    }
    if (
      !Number.isInteger(action.seat) ||
      action.seat < 0 ||
      action.seat >= p.seatCount
    ) {
      issues.push({
        code: "scripted",
        message: `bad seat ${action.seat}`,
        nodeId: node.id,
      });
      continue;
    }
    if (
      action.seat === p.heroSeat &&
      action.kind !== "POST_SB" &&
      action.kind !== "POST_BB" &&
      action.kind !== "POST_ANTE"
    ) {
      issues.push({
        code: "scripted",
        message: "scripted non-blind action cannot be hero",
        nodeId: node.id,
      });
    }
    if (state.foldedSeats.has(action.seat)) {
      issues.push({
        code: "folded",
        message: `folded seat ${action.seat} cannot act`,
        nodeId: node.id,
      });
      continue;
    }

    const seat: number = action.seat;
    const previous = state.streetBets[seat];
    const highest = Math.max(...state.streetBets);
    const maxTo = previous + state.stacks[seat];
    const facing = highest - previous;
    if (action.kind === "FOLD" || action.kind === "CHECK") {
      if (action.amountTo !== undefined && action.amountTo !== 0) {
        transitionIssue(
          node.id,
          `${action.kind} must not set amountTo`,
          issues,
        );
      }
      if (action.kind === "CHECK" && facing > EPS) {
        transitionIssue(node.id, "CHECK is illegal when facing a call", issues);
      }
      if (action.kind === "FOLD") state.foldedSeats.add(seat);
      continue;
    }
    if (
      typeof action.amountTo !== "number" ||
      !Number.isFinite(action.amountTo) ||
      action.amountTo < 0
    ) {
      transitionIssue(node.id, `${action.kind} needs amountTo`, issues);
      continue;
    }
    if (action.amountTo + EPS < previous) {
      transitionIssue(node.id, "amountTo regresses street commitment", issues);
      continue;
    }
    if (action.amountTo > maxTo + EPS) {
      transitionIssue(node.id, "scripted action exceeds stack", issues);
      continue;
    }
    if (
      action.kind === "CALL" &&
      Math.abs(action.amountTo - Math.min(highest, maxTo)) > EPS
    ) {
      transitionIssue(
        node.id,
        "CALL amountTo does not match amount faced",
        issues,
      );
    }
    if (
      action.kind === "BET" &&
      (facing > EPS || action.amountTo <= highest + EPS)
    ) {
      transitionIssue(node.id, "BET must increase an unopened wager", issues);
    }
    if (action.kind === "RAISE" && action.amountTo <= highest + EPS) {
      transitionIssue(node.id, "RAISE must increase the current wager", issues);
    }
    if (action.kind === "ALL_IN" && Math.abs(action.amountTo - maxTo) > EPS) {
      transitionIssue(node.id, "ALL_IN must commit the full stack", issues);
    }
    state = commitTo(state, seat, action.amountTo) ?? state;
  }
  return state;
}

function commitTo(
  state: BettingState,
  seat: number,
  amountTo: number,
): BettingState | null {
  const added = amountTo - state.streetBets[seat];
  if (added < -EPS || added > state.stacks[seat] + EPS) return null;
  const next: BettingState = {
    pot: state.pot + Math.max(0, added),
    stacks: [...state.stacks],
    streetBets: [...state.streetBets],
    foldedSeats: new Set(state.foldedSeats),
  };
  next.stacks[seat] -= Math.max(0, added);
  next.streetBets[seat] = amountTo;
  return next;
}

function validateTransition(
  p: SituationPayload,
  source: Exclude<SituationNode, { type: "terminal" }>,
  target: SituationNode,
  state: BettingState | null,
  heroFold: boolean,
  issues: ValidationIssue[],
): void {
  if (!state) return;
  if (target.type === "terminal") {
    if (heroFold && target.reason !== "fold") {
      transitionIssue(
        source.id,
        "FOLD edge must reach a fold terminal",
        issues,
      );
    }
    if (target.reason === "fold" && target.street !== source.street) {
      transitionIssue(
        source.id,
        "FOLD terminal must stay on the same street",
        issues,
      );
    }
    if (heroFold && target.winnerSeats?.includes(p.heroSeat)) {
      transitionIssue(source.id, "hero cannot win after choosing FOLD", issues);
    }
    if (streetIndex(target.street) < streetIndex(source.street)) {
      transitionIssue(
        source.id,
        "terminal street cannot move backwards",
        issues,
      );
    }
    compareNumber(source.id, "terminal pot", target.pot, state.pot, issues);
    compareArray(
      source.id,
      "terminal stacks",
      target.stacks,
      state.stacks,
      issues,
    );
    compareSeatSet(source.id, target.foldedSeats, state.foldedSeats, issues);
    return;
  }

  const delta = streetIndex(target.street) - streetIndex(source.street);
  if (delta !== 0 && delta !== 1) {
    transitionIssue(
      source.id,
      "transition must stay on street or advance exactly one street",
      issues,
    );
    return;
  }
  compareNumber(source.id, "pot", target.pot, state.pot, issues);
  compareArray(source.id, "stacks", target.stacks, state.stacks, issues);
  compareSeatSet(source.id, target.foldedSeats, state.foldedSeats, issues);
  if (delta === 0) {
    compareArray(
      source.id,
      "streetBets",
      target.streetBets,
      state.streetBets,
      issues,
    );
  } else if (target.streetBets.some((amount) => Math.abs(amount) > EPS)) {
    transitionIssue(source.id, "new street must reset streetBets", issues);
  }
}

function streetIndex(street: Street): number {
  return ["preflop", "flop", "turn", "river"].indexOf(street);
}

function compareNumber(
  nodeId: string,
  field: string,
  actual: number,
  expected: number,
  issues: ValidationIssue[],
): void {
  if (
    typeof actual !== "number" ||
    !Number.isFinite(actual) ||
    !Number.isFinite(expected) ||
    Math.abs(actual - expected) > EPS
  ) {
    transitionIssue(
      nodeId,
      `${field} mismatch: expected ${expected}, got ${actual}`,
      issues,
    );
  }
}

function compareArray(
  nodeId: string,
  field: string,
  actual: number[],
  expected: number[],
  issues: ValidationIssue[],
): void {
  if (
    !Array.isArray(actual) ||
    actual.length !== expected.length ||
    actual.some(
      (value, i) =>
        typeof value !== "number" ||
        !Number.isFinite(value) ||
        !Number.isFinite(expected[i]) ||
        Math.abs(value - expected[i]) > EPS,
    )
  ) {
    transitionIssue(nodeId, `${field} does not match simulated state`, issues);
  }
}

function compareSeatSet(
  nodeId: string,
  actual: number[],
  expected: Set<number>,
  issues: ValidationIssue[],
): void {
  if (
    !Array.isArray(actual) ||
    actual.length !== expected.size ||
    actual.some((seat) => !expected.has(seat))
  ) {
    transitionIssue(nodeId, "foldedSeats do not match simulated state", issues);
  }
}

function transitionIssue(
  nodeId: string,
  message: string,
  issues: ValidationIssue[],
): void {
  issues.push({ code: "transition", message, nodeId });
}

function validateTerminalNode(
  p: SituationPayload,
  node: Extract<SituationNode, { type: "terminal" }>,
  boards: Record<Street, string[]>,
  issues: ValidationIssue[],
): void {
  const totalStartingChips = p.startingStack * p.seatCount;
  checkFoldedSeats(p, node, issues);
  if (
    node.reason !== "fold" &&
    node.reason !== "showdown" &&
    node.reason !== "all_in_runout"
  ) {
    issues.push({
      code: "terminal",
      message: "invalid terminal reason",
      nodeId: node.id,
    });
  }
  if (
    typeof node.heroNetChips !== "number" ||
    !Number.isFinite(node.heroNetChips)
  ) {
    issues.push({
      code: "terminal",
      message: "heroNetChips required",
      nodeId: node.id,
    });
  } else {
    checkCentPrecision(
      node.heroNetChips,
      "terminal heroNetChips",
      issues,
      node.id,
    );
  }
  if (
    typeof node.pot !== "number" ||
    !Number.isFinite(node.pot) ||
    node.pot < -EPS ||
    node.pot > totalStartingChips + EPS
  ) {
    issues.push({
      code: "terminal",
      message: "pot must be finite and within total starting chips",
      nodeId: node.id,
    });
  } else {
    checkCentPrecision(node.pot, "terminal pot", issues, node.id);
  }

  const stacksValid =
    Array.isArray(node.stacks) &&
    node.stacks.length === p.seatCount &&
    node.stacks.every(
      (stack) =>
        typeof stack === "number" &&
        Number.isFinite(stack) &&
        stack >= -EPS &&
        stack <= totalStartingChips + EPS,
    );
  if (!stacksValid) {
    issues.push({
      code: "terminal",
      message:
        "terminal stacks must contain one finite, non-negative value per seat",
      nodeId: node.id,
    });
  } else {
    for (const stack of node.stacks) {
      checkCentPrecision(stack, "terminal stack", issues, node.id);
    }
  }

  const winnerSeatsValid =
    Array.isArray(node.winnerSeats) &&
    node.winnerSeats.length > 0 &&
    node.winnerSeats.every(
      (seat) => Number.isInteger(seat) && seat >= 0 && seat < p.seatCount,
    ) &&
    new Set(node.winnerSeats).size === node.winnerSeats.length;
  if (!winnerSeatsValid) {
    issues.push({
      code: "terminal",
      message: "winnerSeats must be nonempty, unique, and in range",
      nodeId: node.id,
    });
  }
  if (
    node.reason === "fold" &&
    Array.isArray(node.winnerSeats) &&
    node.winnerSeats.length !== 1
  ) {
    issues.push({
      code: "terminal",
      message: "fold terminal must have exactly one winner",
      nodeId: node.id,
    });
  }
  const activeSeats = Array.from(
    { length: p.seatCount },
    (_, seat) => seat,
  ).filter((seat) => !node.foldedSeats?.includes(seat));
  if (node.reason === "fold" && activeSeats.length !== 1) {
    issues.push({
      code: "terminal",
      message: "fold terminal must have exactly one non-folded seat",
      nodeId: node.id,
    });
  } else if (
    node.reason === "fold" &&
    winnerSeatsValid &&
    node.winnerSeats[0] !== activeSeats[0]
  ) {
    issues.push({
      code: "terminal",
      message: "fold terminal winner must be the only non-folded seat",
      nodeId: node.id,
    });
  }

  if (
    stacksValid &&
    typeof node.pot === "number" &&
    Number.isFinite(node.pot) &&
    Number.isFinite(totalStartingChips)
  ) {
    const terminalTotal =
      node.pot + node.stacks.reduce((total, stack) => total + stack, 0);
    if (Math.abs(terminalTotal - totalStartingChips) > EPS) {
      issues.push({
        code: "terminal",
        message:
          `terminal chip conservation mismatch: expected ` +
          `${totalStartingChips}, got ${terminalTotal}`,
        nodeId: node.id,
      });
    }
  }

  if (
    stacksValid &&
    winnerSeatsValid &&
    typeof node.pot === "number" &&
    Number.isFinite(node.pot)
  ) {
    const payouts = splitPotBySeat(node.pot, node.winnerSeats);
    const finalStacks = node.stacks.map(
      (stack, seat) =>
        stack + (payouts.find((payout) => payout.seat === seat)?.amount ?? 0),
    );
    if (
      payouts.length !== node.winnerSeats.length ||
      finalStacks.some(
        (stack) =>
          !Number.isFinite(stack) ||
          stack < -EPS ||
          stack > totalStartingChips + EPS,
      )
    ) {
      issues.push({
        code: "terminal",
        message: "terminal payout is negative, non-finite, or overflows chips",
        nodeId: node.id,
      });
    }

    const heroStartingStack = p.lineup?.find(
      (seat) => seat.seat === p.heroSeat,
    )?.startingStack;
    if (
      typeof heroStartingStack === "number" &&
      Number.isFinite(heroStartingStack) &&
      typeof node.heroNetChips === "number" &&
      Number.isFinite(node.heroNetChips)
    ) {
      const expectedHeroNet = finalStacks[p.heroSeat] - heroStartingStack;
      if (Math.abs(node.heroNetChips - expectedHeroNet) > EPS) {
        issues.push({
          code: "terminal",
          message:
            `heroNetChips mismatch: expected ${expectedHeroNet}, ` +
            `got ${node.heroNetChips}`,
          nodeId: node.id,
        });
      }
    }
  }

  if (
    (node.reason === "showdown" || node.reason === "all_in_runout") &&
    node.street !== "river"
  ) {
    issues.push({
      code: "street",
      message: `${node.reason} terminal must finish on the river`,
      nodeId: node.id,
    });
  }
  if (
    (node.reason === "showdown" || node.reason === "all_in_runout") &&
    node.street === "river" &&
    Array.isArray(node.board) &&
    node.board.length === 5 &&
    winnerSeatsValid
  ) {
    const scored = activeSeats
      .map((seat) => {
        const hole = p.holeCards?.find((entry) => entry.seat === seat)?.cards;
        if (!hole || hole.length !== 2) return null;
        try {
          return { seat, score: evaluateSevenCards([...hole, ...node.board]) };
        } catch {
          return null;
        }
      })
      .filter(
        (value): value is { seat: number; score: readonly number[] } =>
          value !== null,
      );
    if (scored.length === activeSeats.length && scored.length > 0) {
      let best = scored[0].score;
      for (const entry of scored.slice(1)) {
        if (compareHandScores(entry.score, best) > 0) best = entry.score;
      }
      const derived = scored
        .filter((entry) => compareHandScores(entry.score, best) === 0)
        .map((entry) => entry.seat)
        .sort((a, b) => a - b);
      const authored = [...node.winnerSeats].sort((a, b) => a - b);
      if (
        derived.length !== authored.length ||
        derived.some((seat, index) => seat !== authored[index])
      ) {
        issues.push({
          code: "terminal",
          message: `winnerSeats must equal deterministic winners ${derived.join(",")}`,
          nodeId: node.id,
        });
      }
    }
  }

  // Board length and cards must match the declared terminal street.
  if (Array.isArray(node.board)) {
    const expected = BOARD_LEN[node.street];
    if (node.board.length !== expected) {
      issues.push({
        code: "street",
        message: `terminal board length ${node.board.length} != ${expected}`,
        nodeId: node.id,
      });
    }
    checkBoardMatch(node.id, node.street, node.board, boards, issues);
  }
}

function checkStateArrays(
  p: SituationPayload,
  node: { id: string; stacks: number[]; streetBets: number[]; pot: number },
  issues: ValidationIssue[],
): void {
  if (!Array.isArray(node.stacks) || node.stacks.length !== p.seatCount) {
    issues.push({
      code: "state",
      message: "stacks length must equal seatCount",
      nodeId: node.id,
    });
  } else if (
    node.stacks.some(
      (s) => typeof s !== "number" || !Number.isFinite(s) || s < -EPS,
    )
  ) {
    issues.push({
      code: "state",
      message: "stacks must be non-negative numbers",
      nodeId: node.id,
    });
  } else {
    for (const stack of node.stacks) {
      checkCentPrecision(stack, "node stack", issues, node.id);
    }
  }
  if (
    !Array.isArray(node.streetBets) ||
    node.streetBets.length !== p.seatCount
  ) {
    issues.push({
      code: "state",
      message: "streetBets length must equal seatCount",
      nodeId: node.id,
    });
  } else if (
    node.streetBets.some(
      (bet) => typeof bet !== "number" || !Number.isFinite(bet) || bet < -EPS,
    )
  ) {
    issues.push({
      code: "state",
      message: "streetBets must be non-negative finite numbers",
      nodeId: node.id,
    });
  } else {
    for (const bet of node.streetBets) {
      checkCentPrecision(bet, "streetBet", issues, node.id);
    }
  }
  if (
    typeof node.pot !== "number" ||
    !Number.isFinite(node.pot) ||
    node.pot < -EPS
  ) {
    issues.push({
      code: "state",
      message: "pot must be non-negative",
      nodeId: node.id,
    });
  } else {
    checkCentPrecision(node.pot, "node pot", issues, node.id);
  }
}

function checkFoldedSeats(
  p: SituationPayload,
  node: { id: string; foldedSeats: number[] },
  issues: ValidationIssue[],
): void {
  if (
    !Array.isArray(node.foldedSeats) ||
    new Set(node.foldedSeats).size !== node.foldedSeats.length ||
    node.foldedSeats.some(
      (seat) => !Number.isInteger(seat) || seat < 0 || seat >= p.seatCount,
    )
  ) {
    issues.push({
      code: "folded",
      message: "foldedSeats must be unique and in range",
      nodeId: node.id,
    });
  }
}

function checkCentPrecision(
  value: number,
  field: string,
  issues: ValidationIssue[],
  nodeId?: string,
): void {
  const cents = value * 100;
  if (Math.abs(cents - Math.round(cents)) > CENT_PRECISION_EPS) {
    issues.push({
      code: "money_precision",
      message: `${field} must have at most 2 decimal places`,
      nodeId,
    });
  }
}

function checkBoardMatch(
  nodeId: string,
  street: Street,
  board: string[],
  boards: Record<Street, string[]>,
  issues: ValidationIssue[],
): void {
  const expected = boards[street] ?? [];
  if (!Array.isArray(board)) {
    issues.push({
      code: "street",
      message: "board must be array",
      nodeId,
    });
    return;
  }
  if (board.length !== BOARD_LEN[street]) {
    issues.push({
      code: "street",
      message: `board length ${board.length} != ${BOARD_LEN[street]} for ${street}`,
      nodeId,
    });
  }
  if (expected.length === 0 && street !== "preflop") {
    // Missing runout for this street — only error if board claims cards
    if (board.length > 0) {
      issues.push({
        code: "runouts",
        message: `missing runout data for ${street}`,
        nodeId,
      });
    }
    return;
  }
  for (let i = 0; i < Math.min(board.length, expected.length); i++) {
    if (!isValidCard(String(board[i]))) {
      issues.push({
        code: "street",
        message: `invalid board card ${String(board[i])}`,
        nodeId,
      });
      continue;
    }
    if (normalizeCard(String(board[i])) !== expected[i]) {
      issues.push({
        code: "street",
        message: `board card mismatch at ${street}[${i}]`,
        nodeId,
      });
    }
  }
}

/**
 * Pure helper used by allocation tests: filters candidate situation ids to
 * those the user has not already received.
 */
export function filterUnseenSituationIds(
  candidateIds: string[],
  receiptIds: Set<string>,
): string[] {
  return candidateIds.filter((id) => !receiptIds.has(id));
}

/**
 * Whether the pool should refill based on never-served remaining count.
 */
export function shouldRefillPool(
  neverServedRemaining: number,
  lowWater: number = 1,
): boolean {
  return neverServedRemaining <= lowWater;
}
