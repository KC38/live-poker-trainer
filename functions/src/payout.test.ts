/**
 * Tests for deterministic cent-exact split-pot payouts.
 */

import { describe, expect, it } from "vitest";
import { potShareForSeat, splitPotBySeat } from "./payout";

describe("splitPotBySeat", () => {
  it("splits $10.01 two ways by ascending seat", () => {
    expect(splitPotBySeat(10.01, [4, 1])).toEqual([
      { seat: 1, amount: 5.01 },
      { seat: 4, amount: 5 },
    ]);
  });

  it("splits $10 three ways and conserves every cent", () => {
    const payouts = splitPotBySeat(10, [5, 0, 2]);
    expect(payouts).toEqual([
      { seat: 0, amount: 3.34 },
      { seat: 2, amount: 3.33 },
      { seat: 5, amount: 3.33 },
    ]);
    expect(
      Math.round(
        payouts.reduce((total, payout) => total + payout.amount, 0) * 100,
      ),
    ).toBe(1000);
  });

  it.each([
    [0, 3.34],
    [2, 3.33],
    [5, 3.33],
  ])("returns the assigned share for hero seat %i", (heroSeat, expected) => {
    expect(potShareForSeat(10, [5, 0, 2], heroSeat)).toBe(expected);
  });

  it("awards a single winner the whole pot, including a zero pot", () => {
    expect(splitPotBySeat(10.01, [3])).toEqual([{seat: 3, amount: 10.01}]);
    expect(splitPotBySeat(0, [2])).toEqual([{seat: 2, amount: 0}]);
    expect(potShareForSeat(10.01, [3], 3)).toBe(10.01);
  });

  it("returns nothing for an empty field or a non-finite pot", () => {
    expect(splitPotBySeat(10, [])).toEqual([]);
    expect(splitPotBySeat(-1, [1])).toEqual([]);
    expect(splitPotBySeat(Number.NaN, [1])).toEqual([]);
    expect(splitPotBySeat(Number.POSITIVE_INFINITY, [1])).toEqual([]);
    expect(potShareForSeat(10, [1, 2], 9)).toBe(0);
    expect(potShareForSeat(Number.NaN, [1], 1)).toBe(0);
  });
});
