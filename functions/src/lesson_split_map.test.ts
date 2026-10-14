/**
 * Unit tests for retired-lesson progress: prereq expansion and start remap.
 */

import {describe, expect, it} from "vitest";

import {
  expandCompletedLessonIds,
  resolveLiveLessonId,
} from "./lesson_split_map";

const suitsSplit = {
  "lesson-01-01-02-suits-and-ranks": [
    "lesson-01-01-02-01-suits",
    "lesson-01-01-02-02-ranks",
    "lesson-01-01-02-03-pairs-and-suited",
  ],
  "lesson-retired-other": ["lesson-other-a"],
};

describe("expandCompletedLessonIds", () => {
  it("adds every successor of a completed retired lesson and keeps originals", () => {
    const completed = [
      "lesson-01-01-01-your-two-cards",
      "lesson-01-01-02-suits-and-ranks",
    ];
    const expanded = expandCompletedLessonIds(completed, suitsSplit);
    expect(expanded).toEqual([
      "lesson-01-01-01-your-two-cards",
      "lesson-01-01-02-suits-and-ranks",
      "lesson-01-01-02-01-suits",
      "lesson-01-01-02-02-ranks",
      "lesson-01-01-02-03-pairs-and-suited",
    ]);
    expect(completed).toEqual([
      "lesson-01-01-01-your-two-cards",
      "lesson-01-01-02-suits-and-ranks",
    ]);
  });

  it("does not unlock successors when the retired id is absent", () => {
    expect(expandCompletedLessonIds(["lesson-01-01-01-your-two-cards"], suitsSplit))
      .toEqual(["lesson-01-01-01-your-two-cards"]);
  });

  it("expands only the retired ids the learner actually finished", () => {
    expect(expandCompletedLessonIds(["lesson-retired-other"], suitsSplit)).toEqual([
      "lesson-retired-other",
      "lesson-other-a",
    ]);
  });

  it("returns a string copy when the map is missing or empty", () => {
    expect(expandCompletedLessonIds(["lesson-a", 2 as unknown as string], null))
      .toEqual(["lesson-a", "2"]);
    expect(expandCompletedLessonIds(["lesson-a"], undefined)).toEqual(["lesson-a"]);
    expect(expandCompletedLessonIds(["lesson-a"], {})).toEqual(["lesson-a"]);
  });

  it("ignores a non-array successor list instead of throwing", () => {
    const map = {
      "lesson-retired": "lesson-a",
    } as unknown as Record<string, readonly string[]>;
    expect(expandCompletedLessonIds(["lesson-retired"], map)).toEqual([
      "lesson-retired",
    ]);
  });

  it("stringifies successor ids so a numeric bank entry still counts", () => {
    const map = {
      "lesson-retired": [1],
    } as unknown as Record<string, readonly string[]>;
    expect(expandCompletedLessonIds(["lesson-retired"], map)).toEqual([
      "lesson-retired",
      "1",
    ]);
  });
});

describe("resolveLiveLessonId", () => {
  const live = new Set([
    "lesson-01-01-02-01-suits",
    "lesson-01-01-02-02-ranks",
    "lesson-01-01-02-03-pairs-and-suited",
  ]);

  it("keeps a published lesson id and does not jump to a successor", () => {
    expect(resolveLiveLessonId(
      "lesson-01-01-02-01-suits",
      (id) => live.has(id),
      suitsSplit,
    )).toBe("lesson-01-01-02-01-suits");
  });

  it("opens the first successor that is still in the catalog", () => {
    expect(resolveLiveLessonId(
      "lesson-01-01-02-suits-and-ranks",
      (id) => live.has(id),
      suitsSplit,
    )).toBe("lesson-01-01-02-01-suits");
  });

  it("skips successors that were removed and rejects an unknown id", () => {
    const withoutFirst = new Set(live);
    withoutFirst.delete("lesson-01-01-02-01-suits");
    expect(resolveLiveLessonId(
      "lesson-01-01-02-suits-and-ranks",
      (id) => withoutFirst.has(id),
      suitsSplit,
    )).toBe("lesson-01-01-02-02-ranks");

    expect(resolveLiveLessonId(
      "lesson-01-01-02-suits-and-ranks",
      () => false,
      suitsSplit,
    )).toBeNull();
    expect(resolveLiveLessonId("lesson-missing", (id) => live.has(id), suitsSplit))
      .toBeNull();
    expect(resolveLiveLessonId("lesson-missing", (id) => live.has(id), null))
      .toBeNull();
    expect(resolveLiveLessonId(
      "lesson-01-01-02-suits-and-ranks",
      (id) => live.has(id),
      {},
    )).toBeNull();
  });
});
