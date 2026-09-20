/**
 * Authoritative No-Limit Hold'em state machine for live training.
 *
 * The engine accepts only server-generated fixed action ids, uses cent-exact
 * chip arithmetic, handles incomplete all-in raises, refunds unmatched chips,
 * and settles independent main/side pots. Gemini may choose among legal ids
 * but never supplies resulting stacks, pots, actors, boards, or payouts.
 */

import {createHash} from "node:crypto";
import {
  compareHandScores,
  evaluateSevenCards,
  type HandScore,
} from "./holdem_evaluator";
import {splitPotBySeat} from "./payout";
import type {
  LiveActionBucket,
  LiveActionEvent,
  LiveHandDefinition,
  LiveHandState,
  LiveLegalAction,
  LivePlayerState,
  LivePotResult,
  LiveStreet,
} from "./live_types";

/** Creates the canonical state after forced blind posts. */
export function createInitialLiveState(
  hand: LiveHandDefinition,
): LiveHandState {
  const count = hand.setup.seatCount;
  if (hand.seats.length !== count) {
    throw new Error("hand seat count does not match setup");
  }
  const players: LivePlayerState[] = hand.seats
    .slice()
    .sort((left, right) => left.seat - right.seat)
    .map((seat) => ({
      seat: seat.seat,
      stack: money(seat.startingStack),
      streetBet: 0,
      contribution: 0,
      folded: false,
      allIn: false,
      acted: false,
      lastFacedBet: 0,
    }));
  const sbSeat = count === 2 ?
    hand.buttonSeat :
    clockwise(hand.buttonSeat, count);
  const bbSeat = clockwise(sbSeat, count);
  postForced(players[sbSeat], hand.setup.smallBlind);
  postForced(players[bbSeat], hand.setup.bigBlind);
  const actorSeat = count === 2 ?
    hand.buttonSeat :
    clockwise(bbSeat, count);
  return {
    street: "preflop",
    board: [],
    players,
    actorSeat,
    highestBet: Math.max(...players.map((player) => player.streetBet)),
    minRaiseIncrement: hand.setup.bigBlind,
    actionNumber: 0,
    status: "playing",
    winnerSeats: [],
    pots: [],
    payouts: {},
  };
}

/** Stable hash used as the shared lazy-tree node id. */
export function hashLiveState(
  state: LiveHandState,
  history: readonly LiveActionEvent[] = [],
): string {
  const canonical = {
    street: state.street,
    board: state.board,
    actorSeat: state.actorSeat,
    highestBet: cents(state.highestBet),
    minRaiseIncrement: cents(state.minRaiseIncrement),
    status: state.status,
    terminalReason: state.terminalReason,
    players: state.players.map((player) => ({
      seat: player.seat,
      stack: cents(player.stack),
      streetBet: cents(player.streetBet),
      contribution: cents(player.contribution),
      folded: player.folded,
      allIn: player.allIn,
      acted: player.acted,
      lastFacedBet: cents(player.lastFacedBet),
    })),
    history: history.map((event) => ({
      seat: event.seat,
      street: event.street,
      actionId: event.actionId,
    })),
  };
  return createHash("sha256")
    .update(JSON.stringify(canonical))
    .digest("hex")
    .slice(0, 32);
}

/** Returns every fixed legal action for the current actor. */
export function legalLiveActions(
  hand: LiveHandDefinition,
  state: LiveHandState,
): LiveLegalAction[] {
  if (state.status !== "playing" || state.actorSeat === null) return [];
  const player = state.players[state.actorSeat];
  if (!canAct(player)) return [];
  const callAmount = money(Math.min(
    Math.max(0, state.highestBet - player.streetBet),
    player.stack,
  ));
  const free = callAmount === 0;
  const maxTo = money(player.streetBet + player.stack);
  const actions: LiveLegalAction[] = [];

  if (free) {
    actions.push(action("CHECK", "CHECK", undefined, "Check"));
  } else {
    actions.push(action("FOLD", "FOLD", undefined, "Fold"));
    actions.push(action(
      "CALL",
      "CALL",
      money(player.streetBet + callAmount),
      callAmount === player.stack ?
        `Call all-in ${format(callAmount)}` :
        `Call ${format(callAmount)}`,
    ));
  }

  if (!mayAggress(state, player, maxTo)) return actions;
  const candidates = aggressiveTargets(hand, state, player, callAmount);
  const seenTargets = new Set<number>();
  const minimumTo = money(state.highestBet + state.minRaiseIncrement);
  const legalMinimumTo = money(
    state.highestBet < state.minRaiseIncrement ?
      state.minRaiseIncrement :
      minimumTo,
  );
  const chip = chipUnit(hand);
  for (const candidate of candidates) {
    const target = snapAtLeast(candidate.amountTo, legalMinimumTo, chip);
    if (
      target <= state.highestBet ||
      target < legalMinimumTo ||
      target >= maxTo ||
      seenTargets.has(cents(target))
    ) {
      continue;
    }
    seenTargets.add(cents(target));
    actions.push(action(
      candidate.bucket,
      state.highestBet === 0 ? "BET" : "RAISE",
      target,
      `${state.highestBet === 0 ? "Bet" : "Raise to"} ${format(target)}`,
    ));
  }
  if (maxTo > state.highestBet) {
    actions.push(action(
      "ALL_IN",
      "ALL_IN",
      maxTo,
      `All-in ${format(player.stack)}`,
    ));
  }
  return dedupeActions(actions);
}

/**
 * Applies one exact legal action and automatically advances streets or settles
 * the hand when no further player decision is required.
 */
export function applyLiveAction(options: {
  hand: LiveHandDefinition;
  state: LiveHandState;
  actionId: string;
}): {state: LiveHandState; event: LiveActionEvent} {
  const state = cloneState(options.state);
  const legal = legalLiveActions(options.hand, state);
  const selected = state.actorSeat === null ?
    null :
    resolveOfferedAction(legal, options.actionId, state);
  if (!selected || state.actorSeat === null) {
    throw new Error(`illegal or stale action id: ${options.actionId}`);
  }
  const seat = state.actorSeat;
  const player = state.players[seat];
  const previousHighest = state.highestBet;
  const previousMinimum = state.minRaiseIncrement;
  const event: LiveActionEvent = {
    sequence: state.actionNumber,
    seat,
    street: state.street,
    actionId: selected.actionId,
    kind: selected.kind,
    bucket: selected.bucket,
    ...(selected.amountTo === undefined ? {} : {amountTo: selected.amountTo}),
  };

  switch (selected.kind) {
  case "FOLD":
    player.folded = true;
    player.acted = true;
    player.lastAction = "FOLD";
    player.lastFacedBet = state.highestBet;
    break;
  case "CHECK":
    player.acted = true;
    player.lastAction = "CHECK";
    player.lastFacedBet = state.highestBet;
    break;
  case "CALL":
    commitTo(player, selected.amountTo ?? player.streetBet);
    player.acted = true;
    player.lastAction = player.allIn ? "CALL ALL-IN" : "CALL";
    player.lastFacedBet = state.highestBet;
    break;
  case "BET":
  case "RAISE":
  case "ALL_IN": {
    const target = selected.amountTo ?? player.streetBet;
    commitTo(player, target);
    const raiseIncrement = money(player.streetBet - previousHighest);
    const fullRaise = raiseIncrement >= previousMinimum;
    if (player.streetBet > previousHighest) {
      state.highestBet = player.streetBet;
    }
    if (fullRaise) {
      state.minRaiseIncrement = raiseIncrement;
      for (const other of state.players) {
        if (other.seat !== seat && canAct(other)) {
          other.acted = false;
          // A check (or earlier call) is no longer the last thing this seat
          // did once a bet reopens them. Leave the pill blank until they act.
          delete other.lastAction;
        }
      }
    }
    player.acted = true;
    player.lastAction = selected.kind === "ALL_IN" ? "ALL-IN" : selected.kind;
    player.lastFacedBet = state.highestBet;
    break;
  }
  }
  state.actionNumber += 1;

  if (seat === options.hand.setup.heroSeat && selected.kind === "FOLD") {
    state.status = "hero_folded";
    state.actorSeat = null;
    return {state, event};
  }

  const active = state.players.filter((candidate) => !candidate.folded);
  if (active.length === 1) {
    settleSingleWinner(state, active[0].seat);
    return {state, event};
  }

  const next = findNextActor(state, seat);
  if (next !== null) {
    state.actorSeat = next;
    return {state, event};
  }
  advanceRoundOrShowdown(options.hand, state);
  return {state, event};
}

/** Total committed chips currently in main and side pots. */
export function livePotSize(state: LiveHandState): number {
  return money(state.players.reduce(
    (total, player) => total + player.contribution,
    0,
  ));
}

/** True when the actor is the Hero. */
export function liveHeroToAct(
  hand: LiveHandDefinition,
  state: LiveHandState,
): boolean {
  return state.status === "playing" &&
    state.actorSeat === hand.setup.heroSeat;
}

/** Calculates independent main/side pots without mutating state. */
export function buildSidePots(state: LiveHandState): Array<{
  amount: number;
  eligibleSeats: number[];
}> {
  const levels = [...new Set(
    state.players
      .map((player) => cents(player.contribution))
      .filter((value) => value > 0),
  )].sort((left, right) => left - right);
  const pots: Array<{amount: number; eligibleSeats: number[]}> = [];
  let previous = 0;
  for (const level of levels) {
    const contributors = state.players.filter(
      (player) => cents(player.contribution) >= level,
    );
    const amountCents = (level - previous) * contributors.length;
    const eligibleSeats = contributors
      .filter((player) => !player.folded)
      .map((player) => player.seat)
      .sort((left, right) => left - right);
    if (amountCents > 0 && eligibleSeats.length > 0) {
      pots.push({amount: amountCents / 100, eligibleSeats});
    }
    previous = level;
  }
  return pots;
}

function aggressiveTargets(
  hand: LiveHandDefinition,
  state: LiveHandState,
  player: LivePlayerState,
  callAmount: number,
): Array<{bucket: LiveActionBucket; amountTo: number}> {
  const bb = hand.setup.bigBlind;
  const pot = livePotSize(state);
  const minTo = state.highestBet < state.minRaiseIncrement ?
    state.minRaiseIncrement :
    state.highestBet + state.minRaiseIncrement;
  if (state.street === "preflop") {
    if (state.highestBet <= bb) {
      return [
        {bucket: "OPEN_2_5_BB", amountTo: 2.5 * bb},
        {bucket: "OPEN_3_BB", amountTo: 3 * bb},
        {bucket: "OPEN_4_BB", amountTo: 4 * bb},
      ];
    }
    return [
      {bucket: "RAISE_MIN", amountTo: minTo},
      {bucket: "RERAISE_3X", amountTo: state.highestBet * 3},
      {bucket: "RERAISE_4X", amountTo: state.highestBet * 4},
    ];
  }
  if (callAmount === 0) {
    return [
      {bucket: "BET_33", amountTo: player.streetBet + pot * 0.33},
      {bucket: "BET_67", amountTo: player.streetBet + pot * 0.67},
      {bucket: "BET_100", amountTo: player.streetBet + pot},
    ];
  }
  const potAfterCall = money(pot + callAmount);
  return [
    {bucket: "RAISE_MIN", amountTo: minTo},
    {
      bucket: "RAISE_50",
      amountTo: player.streetBet + callAmount + potAfterCall * 0.5,
    },
    {
      bucket: "RAISE_100",
      amountTo: player.streetBet + callAmount + potAfterCall,
    },
  ];
}

function mayAggress(
  state: LiveHandState,
  player: LivePlayerState,
  maxTo: number,
): boolean {
  if (maxTo <= state.highestBet) return false;
  if (
    player.acted &&
    player.streetBet < state.highestBet &&
    state.highestBet - player.lastFacedBet < state.minRaiseIncrement
  ) {
    // One or more incomplete raises have not yet accumulated to a full raise.
    return false;
  }
  return state.players.some(
    (other) =>
      other.seat !== player.seat &&
      !other.folded &&
      !other.allIn &&
      other.stack > 0,
  );
}

function findNextActor(state: LiveHandState, afterSeat: number): number | null {
  for (let step = 1; step <= state.players.length; step++) {
    const seat = (afterSeat + step) % state.players.length;
    const player = state.players[seat];
    if (
      canAct(player) &&
      (!player.acted || player.streetBet < state.highestBet)
    ) {
      return seat;
    }
  }
  return null;
}

function advanceRoundOrShowdown(
  hand: LiveHandDefinition,
  state: LiveHandState,
): void {
  const active = state.players.filter((player) => !player.folded);
  if (active.length <= 1) {
    settleSingleWinner(state, active[0]?.seat ?? 0);
    return;
  }
  const withChips = active.filter((player) => !player.allIn && player.stack > 0);
  if (state.street === "river" || withChips.length < 2) {
    revealFullBoard(hand, state);
    settleLiveShowdown(hand, state);
    return;
  }
  state.street = nextStreet(state.street);
  state.board = boardForStreet(hand, state.street);
  state.highestBet = 0;
  state.minRaiseIncrement = hand.setup.bigBlind;
  for (const player of state.players) {
    player.streetBet = 0;
    player.acted = false;
    player.lastFacedBet = 0;
    // A new street has no action yet. Keep FOLD so folded seats stay marked;
    // leave everyone else unlabeled so a flop raise is not still "RAISE"
    // while the hero can check the turn.
    if (!player.folded) delete player.lastAction;
  }
  state.actorSeat = firstActiveLeftOfButton(hand, state);
  if (state.actorSeat === null) {
    revealFullBoard(hand, state);
    settleLiveShowdown(hand, state);
  }
}

function settleSingleWinner(state: LiveHandState, winnerSeat: number): void {
  refundUncalled(state);
  const pot = livePotSize(state);
  state.players[winnerSeat].stack = money(
    state.players[winnerSeat].stack + pot,
  );
  state.status = "complete";
  state.terminalReason = "fold";
  state.actorSeat = null;
  state.winnerSeats = [winnerSeat];
  state.pots = [{
    amount: pot,
    eligibleSeats: [winnerSeat],
    winnerSeats: [winnerSeat],
  }];
  state.payouts = {[String(winnerSeat)]: pot};
}

/** Settles a river/all-in state into independently evaluated side pots. */
export function settleLiveShowdown(
  hand: LiveHandDefinition,
  state: LiveHandState,
): void {
  refundUncalled(state);
  const pots = buildSidePots(state);
  const payouts: Record<string, number> = {};
  const results: LivePotResult[] = [];
  const allWinners = new Set<number>();
  for (const pot of pots) {
    const winners = bestSeats(hand, state, pot.eligibleSeats);
    for (const payout of splitPotBySeat(pot.amount, winners)) {
      payouts[String(payout.seat)] = money(
        (payouts[String(payout.seat)] ?? 0) + payout.amount,
      );
      state.players[payout.seat].stack = money(
        state.players[payout.seat].stack + payout.amount,
      );
      allWinners.add(payout.seat);
    }
    results.push({
      amount: pot.amount,
      eligibleSeats: pot.eligibleSeats,
      winnerSeats: winners,
    });
  }
  state.status = "complete";
  state.terminalReason = "showdown";
  state.actorSeat = null;
  state.pots = results;
  state.payouts = payouts;
  state.winnerSeats = [...allWinners].sort((left, right) => left - right);
}

function bestSeats(
  hand: LiveHandDefinition,
  state: LiveHandState,
  seats: number[],
): number[] {
  let best: HandScore | null = null;
  const scored = seats.map((seat) => {
    const cards = hand.seats.find((entry) => entry.seat === seat)?.holeCards;
    if (!cards) throw new Error(`missing hole cards for seat ${seat}`);
    const score = evaluateSevenCards([...cards, ...state.board]);
    if (best === null || compareHandScores(score, best) > 0) best = score;
    return {seat, score};
  });
  return scored
    .filter((entry) => compareHandScores(entry.score, best!) === 0)
    .map((entry) => entry.seat)
    .sort((left, right) => left - right);
}

function refundUncalled(state: LiveHandState): void {
  const ordered = state.players
    .map((player) => ({
      player,
      contribution: cents(player.contribution),
    }))
    .sort((left, right) => right.contribution - left.contribution);
  if (
    ordered.length < 2 ||
    ordered[0].contribution <= ordered[1].contribution
  ) {
    return;
  }
  const refundCents = ordered[0].contribution - ordered[1].contribution;
  const player = ordered[0].player;
  player.contribution = money(player.contribution - refundCents / 100);
  player.stack = money(player.stack + refundCents / 100);
  player.streetBet = Math.min(player.streetBet, player.contribution);
}

function firstActiveLeftOfButton(
  hand: LiveHandDefinition,
  state: LiveHandState,
): number | null {
  for (let step = 1; step <= state.players.length; step++) {
    const seat = (hand.buttonSeat + step) % state.players.length;
    if (canAct(state.players[seat])) return seat;
  }
  return null;
}

function revealFullBoard(
  hand: LiveHandDefinition,
  state: LiveHandState,
): void {
  state.street = "river";
  state.board = [...hand.runout];
  for (const player of state.players) {
    player.streetBet = 0;
    player.acted = true;
  }
  state.highestBet = 0;
}

function boardForStreet(
  hand: LiveHandDefinition,
  street: LiveStreet,
): string[] {
  switch (street) {
  case "preflop":
    return [];
  case "flop":
    return hand.runout.slice(0, 3);
  case "turn":
    return hand.runout.slice(0, 4);
  case "river":
    return [...hand.runout];
  }
}

function nextStreet(street: LiveStreet): LiveStreet {
  switch (street) {
  case "preflop":
    return "flop";
  case "flop":
    return "turn";
  case "turn":
  case "river":
    return "river";
  }
}

function postForced(player: LivePlayerState, amount: number): void {
  const posted = money(Math.min(player.stack, amount));
  player.stack = money(player.stack - posted);
  player.streetBet = posted;
  player.contribution = posted;
  player.allIn = player.stack === 0;
}

function commitTo(player: LivePlayerState, amountTo: number): void {
  const target = money(Math.min(
    Math.max(player.streetBet, amountTo),
    player.streetBet + player.stack,
  ));
  const added = money(target - player.streetBet);
  player.stack = money(player.stack - added);
  player.streetBet = target;
  player.contribution = money(player.contribution + added);
  player.allIn = player.stack === 0;
}

function canAct(player: LivePlayerState): boolean {
  return !player.folded && !player.allIn && player.stack > 0;
}

/**
 * Honors an action id stored on an older node.
 *
 * Sizing snaps change fresh ids (`BET_33:1584` becomes `BET_33:1600`). The
 * button the player already saw must still apply, at that exact size, as long
 * as the same bucket is still legal and the amount fits the stack.
 */
function resolveOfferedAction(
  legal: LiveLegalAction[],
  actionId: string,
  state: LiveHandState,
): LiveLegalAction | null {
  if (state.actorSeat === null) return null;
  const player = state.players[state.actorSeat];
  const exact = legal.find((candidate) => candidate.actionId === actionId);
  if (exact) return exact;
  const separator = actionId.lastIndexOf(":");
  if (separator <= 0) return null;
  const bucket = actionId.slice(0, separator);
  const amountTo = money(Number(actionId.slice(separator + 1)) / 100);
  if (!Number.isFinite(amountTo)) return null;
  const template = legal.find((candidate) => candidate.bucket === bucket);
  if (!template || template.amountTo === undefined) return null;
  const maxTo = money(player.streetBet + player.stack);
  if (amountTo > maxTo + 0.001) return null;
  if (template.kind === "CALL" || template.kind === "ALL_IN") {
    return Math.abs(template.amountTo - amountTo) <= 0.001 ? template : null;
  }
  // Preset buttons snap to the chip, so the size on an older button can sit
  // a few cents under the new preset. The real floor is still the min bet.
  const legalMinimumTo = money(
    state.highestBet < state.minRaiseIncrement ?
      state.minRaiseIncrement :
      state.highestBet + state.minRaiseIncrement,
  );
  if (amountTo + 0.001 < Math.min(legalMinimumTo, maxTo)) return null;
  return {
    ...template,
    actionId,
    amountTo,
    label: `${template.kind === "BET" ? "Bet" : "Raise to"} ${format(amountTo)}`,
  };
}

function action(
  bucket: LiveActionBucket,
  kind: LiveLegalAction["kind"],
  amountTo: number | undefined,
  label: string,
): LiveLegalAction {
  const target = amountTo === undefined ? "" : `:${cents(amountTo)}`;
  return {
    actionId: `${bucket}${target}`,
    kind,
    bucket,
    label,
    ...(amountTo === undefined ? {} : {amountTo}),
  };
}

function dedupeActions(actions: LiveLegalAction[]): LiveLegalAction[] {
  const seen = new Set<string>();
  return actions.filter((candidate) => {
    const target = candidate.amountTo === undefined ?
      candidate.bucket :
      `${candidate.kind}:${cents(candidate.amountTo)}`;
    if (seen.has(target)) return false;
    seen.add(target);
    return true;
  });
}

function clockwise(seat: number, count: number): number {
  return (seat + 1) % count;
}

function cloneState(state: LiveHandState): LiveHandState {
  return {
    ...state,
    board: [...state.board],
    players: state.players.map((player) => ({...player})),
    winnerSeats: [...state.winnerSeats],
    pots: state.pots.map((pot) => ({
      amount: pot.amount,
      eligibleSeats: [...pot.eligibleSeats],
      winnerSeats: [...pot.winnerSeats],
    })),
    payouts: {...state.payouts},
  };
}

function cents(value: number): number {
  return Math.round(value * 100);
}

function money(value: number): number {
  return cents(value) / 100;
}

/** Live cash bets use the small blind as the chip. All-ins stay exact. */
function chipUnit(hand: LiveHandDefinition): number {
  return hand.setup.smallBlind > 0 ? hand.setup.smallBlind : 1;
}

function snapToChip(amount: number, unit: number): number {
  const rounded = money(amount);
  if (!(unit > 0)) return rounded;
  return money(Math.round(rounded / unit) * unit);
}

/** Nearest chip, bumped up only when that would be an illegal under-min size. */
function snapAtLeast(amount: number, minimum: number, unit: number): number {
  const nearest = snapToChip(amount, unit);
  if (nearest + 0.001 >= minimum) return nearest;
  if (!(unit > 0)) return money(minimum);
  return money(Math.ceil((minimum - 0.001) / unit) * unit);
}

function format(value: number): string {
  return `$${money(value).toFixed(Number.isInteger(money(value)) ? 0 : 2)}`;
}
