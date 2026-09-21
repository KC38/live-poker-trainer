/**
 * Unit tests for static lesson scoring, XP, streak, and mastery placeholders.
 */

import {describe, expect, it} from "vitest";
import {getLessonById} from "./curriculum_catalog";
import {
  applyLessonCompletion,
  BASE_LESSON_XP,
  calendarDayInTimeZone,
  COACHING_SCORE_WEIGHTS,
  emptyLearningProgress,
  scoreFromCoachingRating,
  scoreStaticAnswers,
} from "./curriculum_progress";

const LESSON_ID = "lesson-00-01-01-cash-vs-tournaments";

function guestLesson() {
  const lesson = getLessonById(LESSON_ID);
  expect(lesson).toBeDefined();
  return lesson!;
}

function allCorrectAnswers() {
  return {
    "q1-chip-value": "a",
    "q2-leaving": "b",
    "q3-blinds": "c",
    "q4-bust": "b",
    "q5-depth": "b",
  };
}

describe("curriculum_progress", () => {
  it("exposes coaching-style score weights", () => {
    expect(COACHING_SCORE_WEIGHTS.recommended).toBe(1);
    expect(COACHING_SCORE_WEIGHTS.strong).toBe(0.85);
    expect(COACHING_SCORE_WEIGHTS.reasonable).toBe(0.55);
    expect(COACHING_SCORE_WEIGHTS.questionable).toBe(0.2);
    expect(COACHING_SCORE_WEIGHTS.clear_mistake).toBe(0);
    expect(scoreFromCoachingRating("strong")).toBe(0.85);
  });

  it("scores static answers by correct/incorrect ratio", () => {
    const lesson = guestLesson();
    const perfect = scoreStaticAnswers(lesson, allCorrectAnswers());
    expect(perfect.totalCount).toBe(5);
    expect(perfect.correctCount).toBe(5);
    expect(perfect.score).toBe(1);
    expect(perfect.ratio).toBe(1);

    const partial = scoreStaticAnswers(lesson, {
      "q1-chip-value": "a",
      "q2-leaving": "a",
      "q3-blinds": "c",
      "q4-bust": "a",
      "q5-depth": "b",
    });
    expect(partial.correctCount).toBe(3);
    expect(partial.score).toBeCloseTo(0.6);

    const fromArray = scoreStaticAnswers(lesson, [
      {questionId: "q1-chip-value", choiceId: "a"},
      {questionId: "q2-leaving", choiceId: "b"},
    ]);
    expect(fromArray.correctCount).toBe(2);
    expect(fromArray.totalCount).toBe(5);
  });

  it("rejects non-object answers", () => {
    expect(() => scoreStaticAnswers(guestLesson(), "nope")).toThrow(/answers/);
  });

  it("computes IANA timezone calendar days", () => {
    // 2024-01-01 06:00 UTC is still 2023-12-31 evening in America/Los_Angeles.
    const instant = new Date("2024-01-01T06:00:00.000Z");
    expect(calendarDayInTimeZone(instant, "UTC")).toBe("2024-01-01");
    expect(calendarDayInTimeZone(instant, "America/Los_Angeles")).toBe(
      "2023-12-31",
    );
  });

  it("awards XP, streak, and mastery placeholders on completion", () => {
    const lesson = guestLesson();
    const day1 = applyLessonCompletion({
      progress: emptyLearningProgress(),
      lesson,
      score: 1,
      now: new Date("2024-06-01T18:00:00.000Z"),
      timezone: "America/Chicago",
    });
    expect(day1.xp).toBe(BASE_LESSON_XP);
    expect(day1.streak).toBe(1);
    expect(day1.lastStudyDay).toBe("2024-06-01");
    expect(day1.masteryByObjectiveId["obj-cash-vs-tournament"]).toBe(1);
    expect(day1.completedLessonIds).toContain(LESSON_ID);

    const sameDay = applyLessonCompletion({
      progress: day1,
      lesson,
      score: 0.6,
      now: new Date("2024-06-02T03:00:00.000Z"), // still June 1 in Chicago
      timezone: "America/Chicago",
    });
    expect(sameDay.streak).toBe(1);
    expect(sameDay.xp).toBe(BASE_LESSON_XP + Math.round(BASE_LESSON_XP * 0.6));
    expect(sameDay.masteryByObjectiveId["obj-cash-vs-tournament"]).toBe(1);

    const nextDay = applyLessonCompletion({
      progress: sameDay,
      lesson,
      score: 0.4,
      now: new Date("2024-06-02T18:00:00.000Z"),
      timezone: "America/Chicago",
    });
    expect(nextDay.streak).toBe(2);
    expect(nextDay.lastStudyDay).toBe("2024-06-02");

    const broken = applyLessonCompletion({
      progress: nextDay,
      lesson,
      score: 1,
      now: new Date("2024-06-05T18:00:00.000Z"),
      timezone: "America/Chicago",
    });
    expect(broken.streak).toBe(1);
  });
});
