/**
 * Frozen static exercise bank for learning callables.
 *
 * Mirrors catalog loading: curated JSON under content/ is copied into
 * `generated/exercises/` for Cloud Functions imports.
 */

import type {
  CurriculumLesson,
  PublicExerciseQuestion,
  StaticExerciseSet,
} from "./curriculum_types";
import rawBank from "./generated/exercise_bank.json";

const BANK = rawBank as Record<string, StaticExerciseSet>;

/** Look up one exercise set by id (matches catalog `exerciseRefs`). */
export function getExerciseById(
  exerciseId: string,
): StaticExerciseSet | undefined {
  const needle = exerciseId.trim();
  if (!needle) return undefined;
  return BANK[needle];
}

/** Resolve all exercise sets referenced by a lesson. Missing refs are skipped. */
export function getExercisesForLesson(
  lesson: CurriculumLesson,
): StaticExerciseSet[] {
  const out: StaticExerciseSet[] = [];
  for (const ref of lesson.exerciseRefs ?? []) {
    const exercise = getExerciseById(ref);
    if (exercise) out.push(exercise);
  }
  return out;
}

/** Client-safe questions (correct answers stripped). */
export function publicQuestionsForLesson(
  lesson: CurriculumLesson,
): PublicExerciseQuestion[] {
  const questions: PublicExerciseQuestion[] = [];
  for (const exercise of getExercisesForLesson(lesson)) {
    for (const question of exercise.questions) {
      questions.push({
        id: question.id,
        prompt: question.prompt,
        choices: question.choices.map((choice) => ({
          id: choice.id,
          text: choice.text,
        })),
      });
    }
  }
  return questions;
}

/** Registered exercise ids (test / diagnostics). */
export function listExerciseIds(): string[] {
  return Object.keys(BANK).sort();
}
