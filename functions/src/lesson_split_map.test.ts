import {describe, expect, it} from "vitest";
import {hasCompletedLessonId} from "./lesson_split_map";

const split = {
  "lesson-01-01-02-suits-and-ranks": [
    "lesson-01-01-02-01-suits",
    "lesson-01-01-02-02-ranks",
    "lesson-01-01-02-03-pairs-and-suited",
  ],
};

describe("hasCompletedLessonId", () => {
  it("counts successors of a retired lesson as completed", () => {
    const completed = ["lesson-01-01-02-suits-and-ranks"];
    expect(hasCompletedLessonId(
      completed,
      "lesson-01-01-02-01-suits",
      split,
    )).toBe(true);
    expect(hasCompletedLessonId(
      completed,
      "lesson-01-01-02-suits-and-ranks",
      split,
    )).toBe(true);
  });

  it("does not treat an unfinished successor as completed", () => {
    expect(hasCompletedLessonId(
      ["lesson-01-01-01-your-two-cards"],
      "lesson-01-01-02-01-suits",
      split,
    )).toBe(false);
  });

  it("keeps a directly stored successor id completed", () => {
    expect(hasCompletedLessonId(
      ["lesson-01-01-02-02-ranks"],
      "lesson-01-01-02-02-ranks",
      split,
    )).toBe(true);
    expect(hasCompletedLessonId(
      ["lesson-01-01-02-02-ranks"],
      "lesson-01-01-02-01-suits",
      split,
    )).toBe(false);
  });
});
