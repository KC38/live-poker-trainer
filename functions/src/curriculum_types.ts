/**
 * Learning-platform curriculum contracts.
 *
 * Mirrors `content/curriculum/v1/schemas/curriculum.schema.json` plus server
 * progress / feature-flag placeholders. Production callables are not wired yet.
 */

/** Five primary lesson formats (+ hand_lab for table-bound assessments). */
export type LessonFormat =
  | "concept"
  | "decision_drill"
  | "worked_review"
  | "scenario"
  | "assessment"
  | "hand_lab";

/**
 * Whether a lesson may be graded against the live engine today.
 * Variant content (straddles, bomb pots, etc.) stays `conceptual_only` until
 * deterministic engine support exists.
 */
export type SimulationClaim = "engine_supported" | "conceptual_only";

/** Opaque tag map used for filtering and mastery aggregation. */
export type ObjectiveTagSelectors = Record<string, readonly string[]>;

export interface CurriculumObjective {
  id: string;
  title: string;
  tagSelectors: ObjectiveTagSelectors;
  /** Integer difficulty band 1–5. */
  difficulty: number;
}

export interface CurriculumLesson {
  id: string;
  order: number;
  title: string;
  format: LessonFormat;
  objectiveIds: readonly string[];
  estimatedMinutes: number;
  mediaIds: readonly string[];
  exerciseRefs: readonly string[];
  simulationClaims: SimulationClaim;
  prerequisites: readonly string[];
  remediationLessonIds: readonly string[];
}

export interface CurriculumUnit {
  id: string;
  order: number;
  title: string;
  summary: string;
  objectiveIds: readonly string[];
  lessons: readonly CurriculumLesson[];
}

export interface CurriculumSection {
  id: string;
  order: number;
  title: string;
  summary: string;
  /** Optional link to a milestone gate that closes this section wave. */
  milestoneGateId?: string;
  units: readonly CurriculumUnit[];
}

export interface MilestoneGate {
  id: string;
  title: string;
  requiredObjectiveIds: readonly string[];
  minDecisionSamples: number;
  masteryThreshold: number;
  criticalMistakeCap: number;
  safetyCritical: boolean;
}

export interface CurriculumCatalog {
  catalogVersion: string;
  minClientVersion: string;
  sections: readonly CurriculumSection[];
  objectives: readonly CurriculumObjective[];
  milestoneGates: readonly MilestoneGate[];
}

/**
 * Independent learning feature flags (Firestore `appConfig/featureFlags`).
 * Defaults are all false so production behavior stays unchanged until rollout.
 */
export interface LearningFeatureFlags {
  learningPlatformEnabled: boolean;
  guestBootstrapEnabled: boolean;
  curriculumPathEnabled: boolean;
  adaptivePracticeEnabled: boolean;
  mediaNarrationEnabled: boolean;
}

/**
 * Server-owned learning progress under `users/{uid}/learning/main`.
 */
export interface LearningProgressSnapshot {
  /** Lifetime learning XP (study / decision quality, never chip results). */
  xp: number;
  /** Current consecutive-day study streak. */
  streak: number;
  /**
   * Last calendar day (YYYY-MM-DD) that counted toward the streak, in the
   * learner's IANA timezone at write time.
   */
  lastStudyDay?: string;
  /** Mastery scores keyed by objective id (0–1 placeholders). */
  masteryByObjectiveId: Record<string, number>;
  /** Lesson ids completed at least once (placeholder unlock tracking). */
  completedLessonIds?: readonly string[];
  /** Catalog version this snapshot was last graded against. */
  catalogVersion?: string;
  /** Epoch ms of last progress write. */
  updatedAtMs?: number;
}

/** Multiple-choice choice inside a static exercise question. */
export interface StaticExerciseChoice {
  id: string;
  text: string;
}

/** Graded multiple-choice question (correct id stays server-side). */
export interface StaticExerciseQuestion {
  id: string;
  prompt: string;
  choices: readonly StaticExerciseChoice[];
  correctChoiceId: string;
  explanation?: string;
}

/** Curated static exercise set referenced by a lesson `exerciseRefs` entry. */
export interface StaticExerciseSet {
  id: string;
  lessonId: string;
  version: string;
  questions: readonly StaticExerciseQuestion[];
}

/** Client-safe question projection (no correct answer). */
export interface PublicExerciseQuestion {
  id: string;
  prompt: string;
  choices: readonly StaticExerciseChoice[];
}

/**
 * Future deterministic tags attached to Hero decision nodes for adaptive
 * practice, assessment coverage, and leak-driven remediation.
 */
export interface HeroDecisionTags {
  street?: "preflop" | "flop" | "turn" | "river";
  seatCount?: number;
  /** Relative Hero position label (e.g. BTN, BB, HJ). */
  position?: string;
  /** Effective stack depth in big blinds at the decision. */
  depthBb?: number;
  /** Stack-to-pot ratio at the decision. */
  spr?: number;
  /** limped | srp | three_bet | four_bet | multiway, etc. */
  potFamily?: string;
  /** True when more than one opponent remains. */
  multiway?: boolean;
  inPosition?: boolean;
  texture?: string;
  handFeature?: string;
  facingAction?: string;
  tendencyEvidence?: string;
  rangeRole?: string;
  objectiveId?: string;
  difficulty?: number;
  assessmentEligible?: boolean;
}
