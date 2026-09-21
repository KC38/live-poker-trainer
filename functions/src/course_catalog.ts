/**
 * Course catalog v2 contracts shared by Cloud Functions.
 *
 * Private grading and hand-lab specs live in
 * `functions/src/generated/course_bank.json`. The Flutter client loads the
 * sanitized twin at `assets/course/v2/catalog.json`.
 */

import courseBankJson from "./generated/course_bank.json";

/** Soft grades reused from live coaching. */
export type SoftGrade =
  | "recommended"
  | "strong"
  | "reasonable"
  | "questionable"
  | "clear_mistake";

export type ActivityStage =
  | "explain"
  | "guided"
  | "scaffolded"
  | "unguided"
  | "checkpoint"
  | "jump_test";

export type ActivityRenderer =
  | "coach_dialogue"
  | "select_identify"
  | "order_sequence"
  | "compare_rank"
  | "numeric_pot_price"
  | "poker_action_sizing"
  | "player_read_classify"
  | "authored_multi_step_hand"
  | "full_table_hand_lab";

export type CoursePlayerTypeId =
  | "calling_station"
  | "nit"
  | "maniac"
  | "tag"
  | "lag";

export interface CoursePlayerType {
  id: CoursePlayerTypeId;
  label: string;
  introducedByLessonId: string;
  summary?: string;
}

export interface CourseChoice {
  id: string;
  label: string;
  accessibilityText?: string;
  action?: string;
  amountBb?: number;
  grading?: {
    grade: SoftGrade;
    feedback: string;
    reversalRead?: string;
    betterChoiceId?: string;
  };
}

export interface CourseActivity {
  id: string;
  order: number;
  stage: ActivityStage;
  renderer: ActivityRenderer;
  estimatedSeconds: number;
  accessibilityText: string;
  acceptedGrades: readonly SoftGrade[];
  lifeLossEligible: boolean;
  objectives?: readonly string[];
  playerTypeRefs?: readonly CoursePlayerTypeId[];
  prompt?: string;
  choices?: readonly CourseChoice[];
  handSteps?: readonly Array<{
    id: string;
    street?: string;
    prompt?: string;
    choices?: readonly CourseChoice[];
  }>;
  handLabSpecId?: string;
  handLabSpec?: Record<string, unknown>;
}

export interface CourseLesson {
  id: string;
  order: number;
  title: string;
  summary: string;
  objectives: readonly string[];
  prerequisites: readonly string[];
  remediationLessonIds: readonly string[];
  estimatedMinutes: number;
  difficultyBand: number;
  playerTypeRefs: readonly CoursePlayerTypeId[];
  introducesPlayerTypes?: readonly CoursePlayerTypeId[];
  activities: readonly CourseActivity[];
}

export interface CourseUnit {
  id: string;
  order: number;
  title: string;
  summary: string;
  lessons: readonly CourseLesson[];
}

export interface CourseSection {
  id: string;
  order: number;
  title: string;
  summary: string;
  experienceBand: string;
  units: readonly CourseUnit[];
}

export interface CourseBank {
  catalogVersion: string;
  minClientVersion: string;
  scope: "live_cash_nlh";
  coachId: "rex";
  contentChecksum: string;
  playerTypes: readonly CoursePlayerType[];
  sections: readonly CourseSection[];
  gradingByActivityId: Record<string, unknown>;
  handLabsById: Record<string, unknown>;
}

/** Parsed private course bank bundled with Functions. */
export const courseBank = courseBankJson as CourseBank;

/** Depth-first lesson ids in bank order. */
export function lessonIdsInOrder(bank: CourseBank = courseBank): string[] {
  const ids: string[] = [];
  for (const section of bank.sections) {
    for (const unit of section.units) {
      for (const lesson of unit.lessons) {
        ids.push(lesson.id);
      }
    }
  }
  return ids;
}

/** Depth-first activity ids in bank order. */
export function activityIdsInOrder(bank: CourseBank = courseBank): string[] {
  const ids: string[] = [];
  for (const section of bank.sections) {
    for (const unit of section.units) {
      for (const lesson of unit.lessons) {
        for (const activity of lesson.activities) {
          ids.push(activity.id);
        }
      }
    }
  }
  return ids;
}

/** Lesson located with its section/unit parents. */
export interface LocatedLesson {
  section: CourseSection;
  unit: CourseUnit;
  lesson: CourseLesson;
}

/** Finds a lesson by id in the private bank. */
export function findLesson(
  lessonId: string,
  bank: CourseBank = courseBank,
): LocatedLesson | null {
  for (const section of bank.sections) {
    for (const unit of section.units) {
      for (const lesson of unit.lessons) {
        if (lesson.id === lessonId) {
          return {section, unit, lesson};
        }
      }
    }
  }
  return null;
}

/** Finds an activity inside a lesson. */
export function findActivity(
  lesson: CourseLesson,
  activityId: string,
): CourseActivity | null {
  return lesson.activities.find((activity) => activity.id === activityId) ??
    null;
}

/** True when the lesson contains a jump-test or placement-style activity. */
export function lessonRequiresPlacementFlag(lesson: CourseLesson): boolean {
  return lesson.activities.some((activity) => activity.stage === "jump_test");
}

/**
 * Section whose validated jump-test completion grants unrestricted Live
 * Training. Content waves publish the actual jump node; Plan 10 enforces the
 * entitlement at Live callables.
 */
export const LIVE_UNLOCK_SECTION_ID = "sec-04-regular-live";

/** True when completing this lesson's jump test may grant Live entitlement. */
export function lessonGrantsLiveTrainingEntitlement(
  located: LocatedLesson,
): boolean {
  return located.section.id === LIVE_UNLOCK_SECTION_ID &&
    lessonRequiresPlacementFlag(located.lesson);
}
