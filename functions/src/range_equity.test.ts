/**
 * Tests for deterministic fair-information range equity estimates.
 */

import {describe, expect, test} from "vitest";
import {estimateProfileEquity} from "./range_equity";
import {generateTendencyProfile} from "./tendency_profiles";

describe("profile range equity", () => {
  test("is deterministic and bounded", () => {
    const options = {
      heroCards: ["Ah", "Qd"] as [string, string],
      board: ["As", "8c", "3d"],
      opponents: [{
        seat: 1,
        profile: generateTendencyProfile("TAG", "tag"),
      }],
      publicHistory: [],
    };
    const first = estimateProfileEquity(options);
    const second = estimateProfileEquity(options);
    expect(first).toBe(second);
    expect(first).toBeGreaterThanOrEqual(0);
    expect(first).toBeLessThanOrEqual(100);
  });

  test("a locked royal flush has full equity against every modeled range", () => {
    const equity = estimateProfileEquity({
      heroCards: ["Ah", "Kh"],
      board: ["Qh", "Jh", "Th", "2c", "3d"],
      opponents: [
        {seat: 1, profile: generateTendencyProfile("NIT", "nit")},
        {seat: 2, profile: generateTendencyProfile("MANIAC", "maniac")},
      ],
      publicHistory: [],
    });
    expect(equity).toBe(100);
  });

  test("uses visible action history to condition a tighter aggressive range", () => {
    const profile = generateTendencyProfile("TAG", "history");
    const passive = estimateProfileEquity({
      heroCards: ["9h", "9d"],
      board: [],
      opponents: [{seat: 1, profile}],
      publicHistory: [],
    });
    const aggressive = estimateProfileEquity({
      heroCards: ["9h", "9d"],
      board: [],
      opponents: [{seat: 1, profile}],
      publicHistory: [
        {
          sequence: 0,
          seat: 0,
          street: "preflop",
          actionId: "OPEN_3_BB:600",
          kind: "RAISE",
          bucket: "OPEN_3_BB",
          amountTo: 6,
        },
        {
          sequence: 1,
          seat: 1,
          street: "preflop",
          actionId: "RERAISE_3X:1800",
          kind: "RAISE",
          bucket: "RERAISE_3X",
          amountTo: 18,
        },
      ],
    });
    expect(aggressive).toBeLessThan(passive);
  });
});
