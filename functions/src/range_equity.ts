/**
 * Deterministic profile-conditioned equity approximation.
 *
 * This is not a GTO solver and never uses authored villain cards. It samples
 * private hands from bounded archetype preflop ranges, conditioned by visible
 * action history, then completes the public board. The result is a factual
 * range estimate for coaching—not claimed exact EV.
 */

import {createHash} from "node:crypto";
import {compareHandScores, evaluateSevenCards} from "./holdem_evaluator";
import type {
  LiveActionEvent,
  TendencyProfile,
} from "./live_types";

export const RANGE_EQUITY_VERSION = "profile-range-mc-v2";
const ITERATIONS = 400;

export interface EquityOpponent {
  seat: number;
  profile: TendencyProfile;
}

/** Estimates Hero's showdown equity versus visible profile-conditioned ranges. */
export function estimateProfileEquity(options: {
  heroCards: [string, string];
  board: string[];
  opponents: EquityOpponent[];
  publicHistory: LiveActionEvent[];
  iterations?: number;
}): number {
  if (options.opponents.length === 0) return 100;
  const dead = new Set([...options.heroCards, ...options.board]);
  const baseDeck = deck().filter((card) => !dead.has(card));
  const random = seededRandom(JSON.stringify({
    heroCards: options.heroCards,
    board: options.board,
    opponents: options.opponents,
    history: options.publicHistory.map((event) => ({
      seat: event.seat,
      street: event.street,
      bucket: event.bucket,
      kind: event.kind,
    })),
  }));
  let equity = 0;
  const iterations = options.iterations ?? ITERATIONS;
  for (let iteration = 0; iteration < iterations; iteration++) {
    const available = [...baseDeck];
    const opponentCards: Array<[string, string]> = [];
    for (const opponent of options.opponents) {
      const rangePct = visibleRangePercent(
        opponent,
        options.publicHistory,
      );
      opponentCards.push(drawRangeHand({
        available,
        rangePercent: rangePct,
        random,
        profile: opponent.profile,
        board: options.board,
        publicHistory: options.publicHistory,
        seat: opponent.seat,
      }));
    }
    const completedBoard = [...options.board];
    while (completedBoard.length < 5) {
      completedBoard.push(removeRandom(available, random));
    }
    const heroScore = evaluateSevenCards([
      ...options.heroCards,
      ...completedBoard,
    ]);
    const scores = opponentCards.map((cards) =>
      evaluateSevenCards([...cards, ...completedBoard]),
    );
    const bestOpponent = scores.reduce((best, score) =>
      compareHandScores(score, best) > 0 ? score : best,
    );
    const comparison = compareHandScores(heroScore, bestOpponent);
    if (comparison > 0) {
      equity += 1;
    } else if (comparison === 0) {
      const tiedOpponents = scores.filter(
        (score) => compareHandScores(score, heroScore) === 0,
      ).length;
      equity += 1 / (tiedOpponents + 1);
    }
  }
  return Math.round((equity / iterations) * 1000) / 10;
}

function visibleRangePercent(
  opponent: EquityOpponent,
  history: LiveActionEvent[],
): number {
  const actions = history.filter((event) => event.seat === opponent.seat);
  const preflop = actions.filter((event) => event.street === "preflop");
  const aggressive = preflop.filter((event) =>
    event.kind === "BET" ||
    event.kind === "RAISE" ||
    event.kind === "ALL_IN",
  );
  const threeBet = aggressive.some((event) => {
    if (
      event.bucket === "RERAISE_3X" ||
      event.bucket === "RERAISE_4X" ||
      event.bucket === "RERAISE_5X" ||
      event.bucket === "RAISE_MIN"
    ) {
      return true;
    }
    const eventIndex = history.indexOf(event);
    return history.slice(0, eventIndex).some(
      (prior) =>
        prior.street === "preflop" &&
        prior.seat !== opponent.seat &&
        (prior.kind === "BET" ||
          prior.kind === "RAISE" ||
          prior.kind === "ALL_IN"),
    );
  });
  if (threeBet) {
    return clamp(opponent.profile.threeBet, 2, 35);
  }
  if (aggressive.length === 1) {
    return clamp(opponent.profile.pfr, 4, 55);
  }
  if (preflop.some((event) => event.kind === "CALL")) {
    return clamp(
      opponent.profile.vpip - opponent.profile.pfr * 0.25,
      6,
      70,
    );
  }
  return clamp(opponent.profile.vpip, 8, 75);
}

function drawRangeHand(options: {
  available: string[];
  rangePercent: number;
  random: () => number;
  profile: TendencyProfile;
  board: string[];
  publicHistory: LiveActionEvent[];
  seat: number;
}): [string, string] {
  const {available, random} = options;
  let best: [string, string] | null = null;
  let bestScore = -1;
  for (let attempt = 0; attempt < 80; attempt++) {
    const firstIndex = Math.floor(random() * available.length);
    let secondIndex = Math.floor(random() * (available.length - 1));
    if (secondIndex >= firstIndex) secondIndex++;
    const candidate: [string, string] = [
      available[firstIndex],
      available[secondIndex],
    ];
    const preflopScore = startingHandPercentile(candidate);
    const postflopScore = postflopStrength(candidate, options.board);
    const score = preflopScore + postflopScore;
    if (score > bestScore) {
      best = candidate;
      bestScore = score;
    }
    if (
      preflopScore >= 100 - options.rangePercent &&
      fitsVisiblePostflopAction({
        cards: candidate,
        profile: options.profile,
        board: options.board,
        history: options.publicHistory,
        seat: options.seat,
        random,
      })
    ) {
      return removeCards(available, firstIndex, secondIndex);
    }
  }
  const fallback = best ?? [available[0], available[1]];
  const firstIndex = available.indexOf(fallback[0]);
  const secondIndex = available.indexOf(fallback[1]);
  return removeCards(available, firstIndex, secondIndex);
}

function fitsVisiblePostflopAction(options: {
  cards: [string, string];
  profile: TendencyProfile;
  board: string[];
  history: LiveActionEvent[];
  seat: number;
  random: () => number;
}): boolean {
  if (options.board.length === 0) return true;
  const aggressive = [...options.history].reverse().find(
    (event) =>
      event.seat === options.seat &&
      event.street !== "preflop" &&
      (event.kind === "BET" ||
        event.kind === "RAISE" ||
        event.kind === "ALL_IN"),
  );
  if (!aggressive) return true;
  const bluffFrequency = aggressive.street === "river" ?
    options.profile.bluffRiver :
    clamp(options.profile.aggression * 0.5, 5, 55);
  if (options.random() * 100 < bluffFrequency) return true;
  const valueThreshold = 55 + (100 - options.profile.aggression) * 0.2;
  return postflopStrength(options.cards, options.board) >= valueThreshold;
}

function postflopStrength(
  cards: [string, string],
  board: readonly string[],
): number {
  if (board.length === 0) return 0;
  const holeRanks = cards.map(rank);
  const boardRanks = board.map(rank);
  const counts = new Map<number, number>();
  for (const value of [...holeRanks, ...boardRanks]) {
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }
  const groups = [...counts.values()].sort((left, right) => right - left);
  if (groups[0] >= 4) return 100;
  if (groups[0] === 3 && groups[1] >= 2) return 96;
  if (groups[0] === 3) return 90;
  const pairedRanks = [...counts.entries()].filter((entry) => entry[1] >= 2);
  if (pairedRanks.length >= 2) return 82;
  let score = 10;
  if (holeRanks[0] === holeRanks[1]) {
    score = holeRanks[0] > Math.max(...boardRanks) ? 74 : 52;
  }
  for (const holeRank of holeRanks) {
    if (!boardRanks.includes(holeRank)) continue;
    const boardHigh = Math.max(...boardRanks);
    score = Math.max(score, holeRank === boardHigh ? 68 : 46);
  }
  const suits = [...cards, ...board].map((card) => card[1]);
  const heroSuits = new Set(cards.map((card) => card[1]));
  for (const suit of heroSuits) {
    const count = suits.filter((candidate) => candidate === suit).length;
    if (count >= 5) score = Math.max(score, 92);
    else if (count === 4) score = Math.max(score, 58);
  }
  return score;
}

function removeCards(
  available: string[],
  firstIndex: number,
  secondIndex: number,
): [string, string] {
  const high = Math.max(firstIndex, secondIndex);
  const low = Math.min(firstIndex, secondIndex);
  const highCard = available.splice(high, 1)[0];
  const lowCard = available.splice(low, 1)[0];
  return firstIndex < secondIndex ?
    [lowCard, highCard] :
    [highCard, lowCard];
}

function startingHandPercentile(cards: [string, string]): number {
  const first = rank(cards[0]);
  const second = rank(cards[1]);
  const high = Math.max(first, second);
  const low = Math.min(first, second);
  if (first === second) return clamp(64 + high * 2.55, 0, 100);
  const suited = cards[0][1] === cards[1][1];
  const gap = high - low;
  let score = high * 4.2 + low * 1.7;
  if (suited) score += 7;
  if (gap === 1) score += 6;
  else if (gap === 2) score += 3;
  else if (gap >= 5) score -= (gap - 4) * 3;
  if (high === 14) score += 5;
  return clamp(score, 0, 100);
}

function removeRandom(available: string[], random: () => number): string {
  const index = Math.floor(random() * available.length);
  return available.splice(index, 1)[0];
}

function deck(): string[] {
  const cards: string[] = [];
  for (const rank of "23456789TJQKA") {
    for (const suit of "shdc") cards.push(`${rank}${suit}`);
  }
  return cards;
}

function rank(card: string): number {
  return "23456789TJQKA".indexOf(card[0]) + 2;
}

function seededRandom(seed: string): () => number {
  let state = createHash("sha256").update(seed).digest().readUInt32BE(0);
  return () => {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    return state / 0x100000000;
  };
}

function clamp(value: number, minimum: number, maximum: number): number {
  return Math.min(maximum, Math.max(minimum, value));
}
