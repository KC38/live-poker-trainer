/**
 * Deterministic, fair-information facts supplied to the exploit coach.
 *
 * This module deliberately accepts public state plus Hero's cards only. It
 * cannot inspect villain cards or unrevealed runout entries.
 */

import type {
  LiveActionEvent,
  LiveHandDefinition,
  LiveHandState,
  LiveLegalAction,
} from "./live_types";
import {livePotSize} from "./live_poker_engine";
import {
  estimateProfileEquity,
  RANGE_EQUITY_VERSION,
} from "./range_equity";
import {evaluateHoleAndBoard} from "./holdem_evaluator";

export interface CoachingFacts {
  street: LiveHandState["street"];
  heroSeat: number;
  buttonSeat: number;
  heroCards: [string, string];
  board: string[];
  pot: number;
  callAmount: number;
  potOddsPercent: number;
  estimatedEquityPercent: number;
  rangeModelVersion: typeof RANGE_EQUITY_VERSION;
  heroStack: number;
  effectiveStack: number;
  effectiveStackBb: number;
  spr: number;
  activePlayerCount: number;
  position: string;
  boardTexture: string[];
  heroFeatures: string[];
  legalActions: LiveLegalAction[];
  publicHistory: LiveActionEvent[];
  visibleOpponents: Array<{
    seat: number;
    name: string;
    archetype: string;
    stack: number;
    folded: boolean;
    tendency: LiveHandDefinition["seats"][number]["tendency"];
  }>;
}

/** Builds the complete model context without hidden opponent information. */
export function buildCoachingFacts(options: {
  hand: LiveHandDefinition;
  state: LiveHandState;
  legalActions: LiveLegalAction[];
  publicHistory: LiveActionEvent[];
  equityIterations?: number;
}): CoachingFacts {
  const {hand, state} = options;
  const heroSeat = hand.setup.heroSeat;
  const hero = state.players[heroSeat];
  const heroDefinition = hand.seats.find((seat) => seat.seat === heroSeat);
  if (!heroDefinition) throw new Error("hero definition missing");
  const pot = livePotSize(state);
  const callAmount = Math.min(
    Math.max(0, state.highestBet - hero.streetBet),
    hero.stack,
  );
  const activeOpponents = state.players.filter(
    (player) => player.seat !== heroSeat && !player.folded,
  );
  const equityOpponents = activeOpponents
    .map((player) => {
      const tendency = hand.seats.find(
        (seat) => seat.seat === player.seat,
      )?.tendency;
      return tendency ? {seat: player.seat, profile: tendency} : null;
    })
    .filter((value): value is NonNullable<typeof value> => value !== null);
  const contesting = activeOpponents.filter((player) => player.stack > 0);
  // An all-in player's remaining stack is 0. That must not collapse SPR to 0
  // while Hero still has chips to call; use the deepest stack that can still
  // put money in, or Hero's own stack when nobody else can.
  const deepestOpponent = contesting.length === 0 ?
    hero.stack :
    Math.max(...contesting.map((player) => player.stack));
  const effectiveStack = activeOpponents.length === 0 ?
    hero.stack :
    Math.min(hero.stack, deepestOpponent);
  return {
    street: state.street,
    heroSeat,
    buttonSeat: hand.buttonSeat,
    heroCards: heroDefinition.holeCards,
    board: [...state.board],
    pot,
    callAmount,
    potOddsPercent: callAmount <= 0 ?
      0 :
      roundOne((callAmount / (pot + callAmount)) * 100),
    estimatedEquityPercent: estimateProfileEquity({
      heroCards: heroDefinition.holeCards,
      board: state.board,
      opponents: equityOpponents,
      publicHistory: options.publicHistory,
      iterations: options.equityIterations,
    }),
    rangeModelVersion: RANGE_EQUITY_VERSION,
    heroStack: hero.stack,
    effectiveStack,
    effectiveStackBb: roundOne(effectiveStack / hand.setup.bigBlind),
    spr: pot <= 0 ? 0 : roundSpr(effectiveStack / pot),
    activePlayerCount: activeOpponents.length + 1,
    position: positionLabel(hand, heroSeat),
    boardTexture: boardTexture(state.board),
    heroFeatures: heroFeatures(heroDefinition.holeCards, state.board),
    legalActions: options.legalActions.map((candidate) => ({...candidate})),
    publicHistory: options.publicHistory.map((event) => ({...event})),
    visibleOpponents: hand.seats
      .filter((seat) => seat.seat !== heroSeat)
      .map((seat) => {
        const player = state.players[seat.seat];
        return {
          seat: seat.seat,
          name: seat.name,
          archetype: seat.archetype,
          stack: player.stack,
          folded: player.folded,
          tendency: seat.tendency,
        };
      }),
  };
}

/** Rejects accidental hidden-data fields before any coaching request. */
export function assertFairCoachingFacts(value: CoachingFacts): void {
  const serialized = JSON.stringify(value).toLowerCase();
  for (const forbidden of [
    "runout",
    "villaincards",
    "opponentcards",
    "holecardsbyseat",
  ]) {
    if (serialized.includes(forbidden)) {
      throw new Error(`coaching context contains forbidden field ${forbidden}`);
    }
  }
}

function positionLabel(hand: LiveHandDefinition, seat: number): string {
  const distance = (seat - hand.buttonSeat + hand.setup.seatCount) %
    hand.setup.seatCount;
  if (distance === 0) return "BTN";
  if (hand.setup.seatCount === 2) return "BB";
  if (distance === 1) return "SB";
  if (distance === 2) return "BB";
  const fromButton = hand.setup.seatCount - distance;
  if (fromButton === 1) return "CO";
  if (fromButton === 2) return "HJ";
  return "UTG";
}

function boardTexture(board: readonly string[]): string[] {
  if (board.length === 0) return ["preflop"];
  const features: string[] = [];
  const ranks = board.map((card) => rankValue(card[0]));
  const suits = board.map((card) => card[1]);
  const uniqueRanks = new Set(ranks);
  if (uniqueRanks.size < ranks.length) features.push("paired");
  const suitCounts = frequency(suits);
  const maxSuit = Math.max(...suitCounts.values());
  if (maxSuit >= 3) features.push(maxSuit >= 4 ? "four-flush" : "monotone");
  else if (maxSuit === 2) features.push("two-tone");
  else features.push("rainbow");
  const sorted = [...uniqueRanks].sort((left, right) => left - right);
  let closeGaps = 0;
  for (let index = 1; index < sorted.length; index++) {
    if (sorted[index] - sorted[index - 1] <= 2) closeGaps++;
  }
  features.push(closeGaps >= 2 ? "connected" : "disconnected");
  if (ranks.filter((rank) => rank >= 10).length >= 2) features.push("broadway-heavy");
  return features;
}

function heroFeatures(
  holeCards: readonly string[],
  board: readonly string[],
): string[] {
  const features: string[] = [];
  const holeRanks = holeCards.map((card) => rankValue(card[0]));
  if (board.length === 0) {
    const holePair = holeRanks[0] === holeRanks[1];
    if (holePair) features.push("pocket-pair");
    if (holeCards[0][1] === holeCards[1][1]) features.push("suited");
    if (Math.abs(holeRanks[0] - holeRanks[1]) === 1) features.push("connected");
    if (Math.max(...holeRanks) >= 13) features.push("high-card");
    return features.length > 0 ? features : ["unpaired"];
  }
  const score = evaluateHoleAndBoard(holeCards, board);
  const category = score?.[0] ?? 0;
  if (category >= 8) features.push("straight-flush");
  else if (category === 7) features.push("quads");
  else if (category === 6) features.push("full-house");
  else if (category === 5) features.push("flush");
  else if (category === 4) features.push("straight");
  else if (category === 3) features.push("trips-or-better");
  else if (category === 2) features.push("two-pair");
  else if (category === 1) features.push("one-pair");
  else features.push("high-card");
  const suitCounts = frequency([...holeCards, ...board].map((card) => card[1]));
  const heroSuits = new Set(holeCards.map((card) => card[1]));
  if ([...heroSuits].some((suit) => (suitCounts.get(suit) ?? 0) === 4)) {
    features.push("flush-draw");
  }
  if (category < 4) {
    const draw = straightDrawLabel(holeCards, board);
    if (draw) features.push(draw);
  }
  return features;
}

/** Open-ender or gutshot using at least one hole card on the current board. */
function straightDrawLabel(
  holeCards: readonly string[],
  board: readonly string[],
): string | null {
  const holeRanks = new Set(holeCards.map((card) => rankValue(card[0])));
  const allRanks = [...holeCards, ...board].map((card) => rankValue(card[0]));
  const unique = new Set(allRanks);
  if (unique.has(14)) unique.add(1);
  let openEnders = 0;
  let gutshots = 0;
  for (let high = 5; high <= 14; high++) {
    const window = [high - 4, high - 3, high - 2, high - 1, high];
    const missing = window.filter((rank) => !unique.has(rank));
    if (missing.length !== 1) continue;
    const usesHole = window.some((rank) => {
      const normalized = rank === 1 ? 14 : rank;
      return holeRanks.has(normalized);
    });
    if (!usesHole) continue;
    const miss = missing[0];
    if (miss === high - 4 || miss === high) openEnders += 1;
    else gutshots += 1;
  }
  if (openEnders > 0) return "oesd";
  if (gutshots > 0) return "gutshot";
  return null;
}

function frequency<T>(values: readonly T[]): Map<T, number> {
  const counts = new Map<T, number>();
  for (const value of values) counts.set(value, (counts.get(value) ?? 0) + 1);
  return counts;
}

function rankValue(rank: string): number {
  return "23456789TJQKA".indexOf(rank.toUpperCase()) + 2;
}

function roundOne(value: number): number {
  return Math.round(value * 10) / 10;
}

/** Keep tiny SPRs visible. 26/789 is 0.03, not a one-decimal 0. */
function roundSpr(value: number): number {
  if (value <= 0) return 0;
  const one = roundOne(value);
  return one === 0 ? Math.round(value * 100) / 100 : one;
}
