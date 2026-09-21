/**
 * Tests for learning feature-flag defaults and override parsing.
 */

import {describe, expect, it, vi} from "vitest";
import {
  DEFAULT_LEARNING_FEATURE_FLAGS,
  FEATURE_FLAGS_DOC_PATH,
  parseLearningFeatureFlags,
  readLearningFeatureFlags,
} from "./feature_flags";

describe("feature_flags", () => {
  it("defaults every learning flag to false", () => {
    expect(DEFAULT_LEARNING_FEATURE_FLAGS).toEqual({
      learningPlatformEnabled: false,
      guestBootstrapEnabled: false,
      curriculumPathEnabled: false,
      adaptivePracticeEnabled: false,
      mediaNarrationEnabled: false,
    });
    expect(parseLearningFeatureFlags(undefined)).toEqual(
      DEFAULT_LEARNING_FEATURE_FLAGS,
    );
    expect(parseLearningFeatureFlags(null)).toEqual(
      DEFAULT_LEARNING_FEATURE_FLAGS,
    );
    expect(parseLearningFeatureFlags({})).toEqual(
      DEFAULT_LEARNING_FEATURE_FLAGS,
    );
  });

  it("parses boolean overrides and ignores unknown keys", () => {
    expect(
      parseLearningFeatureFlags({
        learningPlatformEnabled: true,
        guestBootstrapEnabled: true,
        curriculumPathEnabled: false,
        adaptivePracticeEnabled: true,
        mediaNarrationEnabled: true,
        unrelatedFlag: true,
        learningPlatformEnabled_typo: true,
      }),
    ).toEqual({
      learningPlatformEnabled: true,
      guestBootstrapEnabled: true,
      curriculumPathEnabled: false,
      adaptivePracticeEnabled: true,
      mediaNarrationEnabled: true,
    });
  });

  it("treats non-boolean values as unset (fallback to default)", () => {
    expect(
      parseLearningFeatureFlags({
        learningPlatformEnabled: "true",
        guestBootstrapEnabled: 1,
        curriculumPathEnabled: null,
      }),
    ).toEqual(DEFAULT_LEARNING_FEATURE_FLAGS);
  });

  it("reads from appConfig/featureFlags via the injectable doc reader", async () => {
    const readDoc = vi.fn(async (path: string) => {
      expect(path).toBe(FEATURE_FLAGS_DOC_PATH);
      return {learningPlatformEnabled: true};
    });
    await expect(readLearningFeatureFlags(readDoc)).resolves.toEqual({
      ...DEFAULT_LEARNING_FEATURE_FLAGS,
      learningPlatformEnabled: true,
    });
    expect(readDoc).toHaveBeenCalledTimes(1);
  });

  it("returns defaults when the injected reader finds no document", async () => {
    const readDoc = vi.fn(async () => null);
    await expect(readLearningFeatureFlags(readDoc)).resolves.toEqual(
      DEFAULT_LEARNING_FEATURE_FLAGS,
    );
  });
});
