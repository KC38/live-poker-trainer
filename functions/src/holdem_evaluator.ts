/**
 * Pure deterministic No-Limit Hold'em hand evaluator.
 *
 * Scores seven cards by enumerating all five-card combinations. Scores compare
 * lexicographically: category first, then category-specific kickers.
 */

import { normalizeCard } from "./setup_key";

export type HandScore = readonly number[];

const RANKS = "23456789TJQKA";

/** Evaluates exactly seven distinct, valid cards. */
export function evaluateSevenCards(cards: readonly string[]): HandScore {
  if (cards.length !== 7) {
    throw new Error(`expected 7 cards, got ${cards.length}`);
  }
  return bestFiveCardScore(cards);
}

/**
 * Best five-card hold'em score from 5–7 cards (hole + board).
 * Returns null when fewer than five cards are available.
 */
export function evaluateHoleAndBoard(
  holeCards: readonly string[],
  board: readonly string[],
): HandScore | null {
  const cards = [...holeCards, ...board];
  if (cards.length < 5) return null;
  if (cards.length > 7) {
    throw new Error(`expected at most 7 cards, got ${cards.length}`);
  }
  return bestFiveCardScore(cards);
}

function bestFiveCardScore(cards: readonly string[]): HandScore {
  if (cards.length === 5) return evaluateFive(cards);
  let best: HandScore | null = null;
  const n = cards.length;
  for (let a = 0; a < n - 4; a++) {
    for (let b = a + 1; b < n - 3; b++) {
      for (let c = b + 1; c < n - 2; c++) {
        for (let d = c + 1; d < n - 1; d++) {
          for (let e = d + 1; e < n; e++) {
            const score = evaluateFive([
              cards[a],
              cards[b],
              cards[c],
              cards[d],
              cards[e],
            ]);
            if (best === null || compareHandScores(score, best) > 0) {
              best = score;
            }
          }
        }
      }
    }
  }
  return best!;
}

/** Compares two scores, returning negative/zero/positive. */
export function compareHandScores(a: HandScore, b: HandScore): number {
  for (let i = 0; i < Math.max(a.length, b.length); i++) {
    const difference = (a[i] ?? 0) - (b[i] ?? 0);
    if (difference !== 0) return difference;
  }
  return 0;
}

function evaluateFive(rawCards: readonly string[]): HandScore {
  const cards = rawCards.map(normalizeCard);
  const ranks = cards.map((card) => RANKS.indexOf(card[0]) + 2);
  const suits = cards.map((card) => card[1]);
  const counts = new Map<number, number>();
  for (const rank of ranks) counts.set(rank, (counts.get(rank) ?? 0) + 1);
  const groups = [...counts.entries()].sort(
    (a, b) => b[1] - a[1] || b[0] - a[0],
  );
  const flush = suits.every((suit) => suit === suits[0]);
  const straightHigh = findStraightHigh(ranks);

  if (flush && straightHigh > 0) return [8, straightHigh];
  if (groups[0][1] === 4) {
    return [7, groups[0][0], groups.find((group) => group[1] === 1)![0]];
  }
  if (groups[0][1] === 3 && groups[1][1] === 2) {
    return [6, groups[0][0], groups[1][0]];
  }
  if (flush) return [5, ...[...ranks].sort((a, b) => b - a)];
  if (straightHigh > 0) return [4, straightHigh];
  if (groups[0][1] === 3) {
    return [
      3,
      groups[0][0],
      ...groups
        .slice(1)
        .map((g) => g[0])
        .sort((a, b) => b - a),
    ];
  }
  const pairs = groups.filter((group) => group[1] === 2);
  if (pairs.length === 2) {
    const pairRanks = pairs.map((group) => group[0]).sort((a, b) => b - a);
    const kicker = groups.find((group) => group[1] === 1)![0];
    return [2, ...pairRanks, kicker];
  }
  if (pairs.length === 1) {
    return [
      1,
      pairs[0][0],
      ...groups
        .filter((group) => group[1] === 1)
        .map((g) => g[0])
        .sort((a, b) => b - a),
    ];
  }
  return [0, ...[...ranks].sort((a, b) => b - a)];
}

function findStraightHigh(ranks: readonly number[]): number {
  const unique = new Set(ranks);
  if (unique.has(14)) unique.add(1);
  const sorted = [...unique].sort((a, b) => a - b);
  let run = 1;
  let high = 0;
  for (let i = 1; i < sorted.length; i++) {
    if (sorted[i] === sorted[i - 1] + 1) {
      run += 1;
      if (run >= 5) high = sorted[i];
    } else {
      run = 1;
    }
  }
  return high;
}
