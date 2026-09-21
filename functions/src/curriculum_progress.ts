/**
 * Pure learning progress helpers: static exercise grading, XP, streaks, mastery.
 *
 * Static lessons use correct/incorrect ratios. Hand-lab paths can map coaching
 * ratings onto the same 0–1 score scale via COACHING_SCORE_WEIGHTS.
 */

import type {
  CoachingRating,
} from "./live_types";
import type {
  CurriculumLesson,
  LearningProgressSnapshot,
} from "./curriculum_types";
import {getExercisesForLesson} from "./curriculum_exercises";

/** XP awarded for a perfect static lesson completion. */
export const BASE_LESSON_XP = 100;

/**
 * Coaching rubric → 0–1 quality weights (same scale as static ratios).
 * Static MC lessons use correct/incorrect instead of these labels.
 */
export const COACHING_SCORE_WEIGHTS: Readonly<Record<CoachingRating, number>> = {
  recommended: 1,
  strong: 0.85,
  reasonable: 0.55,
  questionable: 0.2,
  clear_mistake: 0,
};

export interface StaticQuestionResult {
  questionId: string;
  selectedChoiceId: string | null;
  correctChoiceId: string;
  correct: boolean;
}

export interface StaticAnswerScore {
  correctCount: number;
  totalCount: number;
  /** Correct / total in [0, 1]. */
  ratio: number;
  /** Alias of ratio for static lessons (coaching weights unused). */
  score: number;
  perQuestion: StaticQuestionResult[];
}

export interface ApplyLessonCompletionInput {
  progress: LearningProgressSnapshot;
  lesson: CurriculumLesson;
  /** Quality score in [0, 1]. */
  score: number;
  now: Date | number;
  /** IANA timezone for streak calendar-day boundaries. */
  timezone: string;
}

/** Empty server progress snapshot. */
export function emptyLearningProgress(): LearningProgressSnapshot {
  return {
    xp: 0,
    streak: 0,
    masteryByObjectiveId: {},
    completedLessonIds: [],
  };
}

/** Map a coaching rating onto the shared 0–1 score scale. */
export function scoreFromCoachingRating(rating: CoachingRating): number {
  return COACHING_SCORE_WEIGHTS[rating];
}

/**
 * Grade multiple-choice answers against the lesson's curated exercise bank.
 * Score is the correct/incorrect ratio (not coaching weights).
 */
export function scoreStaticAnswers(
  lesson: CurriculumLesson,
  answers: unknown,
): StaticAnswerScore {
  const exercises = getExercisesForLesson(lesson);
  if (exercises.length === 0) {
    throw new Error(
      `Lesson "${lesson.id}" has no static exercises to score.`,
    );
  }

  const answerMap = normalizeAnswers(answers);
  const perQuestion: StaticQuestionResult[] = [];
  let correctCount = 0;
  let totalCount = 0;

  for (const exercise of exercises) {
    for (const question of exercise.questions) {
      totalCount += 1;
      const selected = answerMap.get(question.id) ?? null;
      const correct = selected !== null && selected === question.correctChoiceId;
      if (correct) correctCount += 1;
      perQuestion.push({
        questionId: question.id,
        selectedChoiceId: selected,
        correctChoiceId: question.correctChoiceId,
        correct,
      });
    }
  }

  const ratio = totalCount === 0 ? 0 : correctCount / totalCount;
  return {
    correctCount,
    totalCount,
    ratio,
    score: ratio,
    perQuestion,
  };
}

/**
 * Apply one lesson completion: XP, IANA-timezone streak, mastery placeholders.
 */
export function applyLessonCompletion(
  input: ApplyLessonCompletionInput,
): LearningProgressSnapshot {
  const score = clamp01(input.score);
  const now =
    input.now instanceof Date ? input.now : new Date(Number(input.now));
  if (Number.isNaN(now.getTime())) {
    throw new Error("applyLessonCompletion requires a valid now timestamp.");
  }
  const timezone = input.timezone.trim();
  if (!timezone) {
    throw new Error("applyLessonCompletion requires a timezone.");
  }

  const today = calendarDayInTimeZone(now, timezone);
  const prev = input.progress;
  const streak = nextStreak(prev.streak, prev.lastStudyDay, today);
  const xpGain = Math.round(BASE_LESSON_XP * score);

  const masteryByObjectiveId = {...(prev.masteryByObjectiveId ?? {})};
  for (const objectiveId of input.lesson.objectiveIds) {
    const prior = masteryByObjectiveId[objectiveId] ?? 0;
    masteryByObjectiveId[objectiveId] = Math.max(prior, score);
  }

  const completed = new Set(prev.completedLessonIds ?? []);
  completed.add(input.lesson.id);

  return {
    xp: (prev.xp ?? 0) + xpGain,
    streak,
    lastStudyDay: today,
    masteryByObjectiveId,
    completedLessonIds: [...completed],
    catalogVersion: prev.catalogVersion,
    updatedAtMs: now.getTime(),
  };
}

/** YYYY-MM-DD civil date in an IANA timezone. */
export function calendarDayInTimeZone(now: Date, timeZone: string): string {
  try {
    const parts = new Intl.DateTimeFormat("en-US", {
      timeZone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).formatToParts(now);
    const year = parts.find((part) => part.type === "year")?.value;
    const month = parts.find((part) => part.type === "month")?.value;
    const day = parts.find((part) => part.type === "day")?.value;
    if (!year || !month || !day) {
      throw new Error("incomplete date parts");
    }
    return `${year}-${month}-${day}`;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Invalid IANA timezone "${timeZone}": ${message}`);
  }
}

function nextStreak(
  currentStreak: number,
  lastStudyDay: string | undefined,
  today: string,
): number {
  if (lastStudyDay === today) {
    return Math.max(1, currentStreak || 1);
  }
  if (lastStudyDay && civilDayDelta(today, lastStudyDay) === 1) {
    return Math.max(1, currentStreak || 0) + 1;
  }
  return 1;
}

/** Difference in civil days (left − right) for YYYY-MM-DD strings. */
function civilDayDelta(left: string, right: string): number {
  return civilDayIndex(left) - civilDayIndex(right);
}

function civilDayIndex(day: string): number {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(day);
  if (!match) {
    throw new Error(`Invalid calendar day "${day}"`);
  }
  const year = Number(match[1]);
  const month = Number(match[2]);
  const date = Number(match[3]);
  return Math.floor(Date.UTC(year, month - 1, date) / 86_400_000);
}

function normalizeAnswers(answers: unknown): Map<string, string> {
  const map = new Map<string, string>();
  if (answers && typeof answers === "object" && !Array.isArray(answers)) {
    for (const [questionId, choiceId] of Object.entries(
      answers as Record<string, unknown>,
    )) {
      if (typeof choiceId === "string" && choiceId.trim()) {
        map.set(questionId, choiceId.trim());
      }
    }
    return map;
  }
  if (Array.isArray(answers)) {
    for (const entry of answers) {
      if (!entry || typeof entry !== "object") continue;
      const row = entry as Record<string, unknown>;
      const questionId =
        typeof row.questionId === "string" ? row.questionId.trim() : "";
      const choiceId =
        typeof row.choiceId === "string" ? row.choiceId.trim() :
          typeof row.selectedChoiceId === "string" ?
            row.selectedChoiceId.trim() :
            "";
      if (questionId && choiceId) map.set(questionId, choiceId);
    }
    return map;
  }
  throw new Error("answers must be an object or array");
}

function clamp01(value: number): number {
  if (!Number.isFinite(value)) return 0;
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}
