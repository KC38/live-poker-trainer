/**
 * Deterministic NLH evaluator tests.
 */

import {describe, expect, it} from "vitest";
import {
  compareHandScores,
  evaluateHoleAndBoard,
  evaluateSevenCards,
} from "./holdem_evaluator";

describe("evaluateSevenCards", () => {
  it.each([
    ["straight", ["As", "Kd", "Qh", "Jc", "Ts", "2d", "3c"], 4],
    ["flush", ["As", "Js", "8s", "4s", "2s", "Kd", "Qh"], 5],
    ["full house", ["As", "Ah", "Ad", "Kc", "Kd", "2s", "3h"], 6],
    ["wheel", ["As", "2d", "3h", "4c", "5s", "Kd", "Qh"], 4],
  ])("scores %s correctly", (_, cards, category) => {
    const score = evaluateSevenCards(cards);
    expect(score[0]).toBe(category);
    if (_ === "wheel") expect(score[1]).toBe(5);
  });

  it("compares tied hands equally", () => {
    const board = ["2s", "3s", "4s", "5s", "6s"];
    const a = evaluateSevenCards(["As", "Kd", ...board]);
    const b = evaluateSevenCards(["Qc", "Jh", ...board]);
    expect(compareHandScores(a, b)).toBe(0);
  });
});

describe("evaluateHoleAndBoard", () => {
  it("detects the flop nut straight with five cards", () => {
    const score = evaluateHoleAndBoard(["Js", "Ts"], ["Qs", "9s", "8d"]);
    expect(score?.[0]).toBe(4);
  });

  it("returns null preflop", () => {
    expect(evaluateHoleAndBoard(["As", "Kd"], [])).toBeNull();
  });
});
