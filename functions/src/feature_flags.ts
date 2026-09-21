/**
 * Learning feature flags loaded from Firestore `appConfig/featureFlags`.
 *
 * Pure helpers with an injectable document reader so tests never touch Admin
 * SDK. This module must not call Firestore at import time.
 */

import type {LearningFeatureFlags} from "./curriculum_types";

/** Firestore document path for app-wide feature flags. */
export const FEATURE_FLAGS_DOC_PATH = "appConfig/featureFlags";

/** All learning flags default to false (production unchanged). */
export const DEFAULT_LEARNING_FEATURE_FLAGS: LearningFeatureFlags = {
  learningPlatformEnabled: false,
  guestBootstrapEnabled: false,
  curriculumPathEnabled: false,
  adaptivePracticeEnabled: false,
  mediaNarrationEnabled: false,
};

const FLAG_KEYS = Object.keys(
  DEFAULT_LEARNING_FEATURE_FLAGS,
) as (keyof LearningFeatureFlags)[];

/**
 * Reads a Firestore document by slash path and returns its data, or null when
 * missing. Injected by callers that own Admin/Firestore access.
 */
export type FeatureFlagsDocReader = (
  path: string,
) => Promise<Record<string, unknown> | null | undefined>;

function asBoolean(value: unknown, fallback: boolean): boolean {
  if (typeof value === "boolean") return value;
  return fallback;
}

/** Merge raw flag fields onto defaults; unknown keys are ignored. */
export function parseLearningFeatureFlags(
  raw: unknown,
): LearningFeatureFlags {
  const source =
    raw && typeof raw === "object" && !Array.isArray(raw) ?
      (raw as Record<string, unknown>) :
      {};

  const parsed = {...DEFAULT_LEARNING_FEATURE_FLAGS};
  for (const key of FLAG_KEYS) {
    parsed[key] = asBoolean(source[key], DEFAULT_LEARNING_FEATURE_FLAGS[key]);
  }
  return parsed;
}

/** Load learning flags via an injectable doc reader (defaults when missing). */
export async function readLearningFeatureFlags(
  readDoc: FeatureFlagsDocReader,
): Promise<LearningFeatureFlags> {
  const doc = await readDoc(FEATURE_FLAGS_DOC_PATH);
  return parseLearningFeatureFlags(doc ?? undefined);
}
