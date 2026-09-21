/**
 * Unit tests for course soft-grading, streaks, flags, and life-loss rules.
 */

import {describe, expect, it} from "vitest";
import {
  activityIdsInOrder,
  courseBank,
  findLesson,
  lessonGrantsLiveTrainingEntitlement,
  lessonRequiresPlacementFlag,
  LIVE_UNLOCK_SECTION_ID,
} from "./course_catalog";
import {
  applyStudyDayStreak,
  disabledCourseFlags,
  evaluateLifeAndAcceptance,
  gradeCourseResponse,
  isLessonAttemptReadyToComplete,
  localDateString,
  parseCourseFlags,
} from "./course_session";

describe("course flags", () => {
  it("fails closed on missing or invalid documents", () => {
    expect(parseCourseFlags(undefined).courseEnabled).toBe(false);
    expect(parseCourseFlags({}).courseEnabled).toBe(false);
    expect(parseCourseFlags({courseEnabled: true}).courseEnabled).toBe(false);
    expect(disabledCourseFlags().courseStartsEnabled).toBe(false);
  });

  it("parses an enabled flag document", () => {
    const flags = parseCourseFlags({
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: false,
      placementTestsEnabled: true,
      catalogVersion: "2.0.0",
      minimumClientVersion: "2.0.0",
    });
    expect(flags.courseEnabled).toBe(true);
    expect(flags.guestCourseEnabled).toBe(false);
    expect(flags.placementTestsEnabled).toBe(true);
  });
});
