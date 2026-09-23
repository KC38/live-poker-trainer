/**
 * Unit tests for anonymous progress transfer merge + TTL helpers.
 */

import {describe, expect, it} from "vitest";
import {
  inProgressAttemptForDestination,
  mergeCourseProfiles,
  mergeLiveEntitlement,
  TRANSFER_RECEIPT_TTL_MS,
  TOMBSTONE_RECOVERY_MS,
} from "./course_transfer";

describe("mergeCourseProfiles", () => {
  it("unions lessons and transfers XP only for new lessons", () => {
    const merged = mergeCourseProfiles(
      {
        lifetimeXp: 40,
        completedLessonIds: ["lesson-a", "lesson-b"],
        masteryByLessonId: {"lesson-a": 0.8, "lesson-b": 0.5},
        currentStreak: 2,
        longestStreak: 3,
        acceptedAnswers: 4,
        totalScoredAnswers: 5,
        experienceBand: "never_played",
        dailyGoalMinutes: 10,
      },
      {
        lifetimeXp: 25,
        completedLessonIds: ["lesson-a"],
        masteryByLessonId: {"lesson-a": 0.9},
        currentStreak: 1,
        longestStreak: 4,
        acceptedAnswers: 2,
        totalScoredAnswers: 2,
      },
      "2.0.0",
    );
    expect(merged.mergedLessonCount).toBe(1);
    expect(merged.transferredXp).toBe(40);
    expect(merged.profile.lifetimeXp).toBe(65);
    expect(merged.profile.completedLessonIds).toEqual(
      expect.arrayContaining(["lesson-a", "lesson-b"]),
    );
    expect(merged.profile.masteryByLessonId["lesson-a"]).toBe(0.9);
    expect(merged.profile.masteryByLessonId["lesson-b"]).toBe(0.5);
    expect(merged.profile.longestStreak).toBe(4);
    expect(merged.profile.experienceBand).toBe("never_played");
  });

  it("does not transfer XP when destination already has all lessons", () => {
    const merged = mergeCourseProfiles(
      {
        lifetimeXp: 40,
        completedLessonIds: ["lesson-a"],
        masteryByLessonId: {"lesson-a": 0.5},
      },
      {
        lifetimeXp: 100,
        completedLessonIds: ["lesson-a"],
        masteryByLessonId: {"lesson-a": 0.9},
      },
      "2.0.0",
    );
    expect(merged.mergedLessonCount).toBe(0);
    expect(merged.transferredXp).toBe(0);
    expect(merged.profile.lifetimeXp).toBe(100);
  });
});

describe("inProgressAttemptForDestination", () => {
  const sourceAttempt = {
    attemptId: "attempt-1",
    uid: "anon-1",
    lessonId: "lesson-b",
    status: "in_progress",
    activityIndex: 3,
    currentActivityId: "act-b-4",
    livesRemaining: 2,
  };

  it("copies an open guest attempt onto the destination uid", () => {
    const copied = inProgressAttemptForDestination({
      destinationResume: null,
      sourceResume: {
        attemptId: "attempt-1",
        lessonId: "lesson-b",
        activityId: "act-b-4",
        activityIndex: 3,
      },
      sourceAttempt,
      sourceUid: "anon-1",
      destinationUid: "dest-1",
    });
    expect(copied).toMatchObject({
      attemptId: "attempt-1",
      uid: "dest-1",
      lessonId: "lesson-b",
      status: "in_progress",
      activityIndex: 3,
      currentActivityId: "act-b-4",
      livesRemaining: 2,
    });
  });

  it("copies a remediation attempt so lives stay exhausted", () => {
    const copied = inProgressAttemptForDestination({
      destinationResume: null,
      sourceResume: {attemptId: "attempt-1", lessonId: "lesson-b"},
      sourceAttempt: {...sourceAttempt, status: "remediation", livesRemaining: 0},
      sourceUid: "anon-1",
      destinationUid: "dest-1",
    });
    expect(copied?.status).toBe("remediation");
    expect(copied?.livesRemaining).toBe(0);
    expect(copied?.uid).toBe("dest-1");
  });

  it("leaves a destination resume in place", () => {
    const copied = inProgressAttemptForDestination({
      destinationResume: {attemptId: "dest-attempt", lessonId: "lesson-a"},
      sourceResume: {attemptId: "attempt-1", lessonId: "lesson-b"},
      sourceAttempt,
      sourceUid: "anon-1",
      destinationUid: "dest-1",
    });
    expect(copied).toBeNull();
  });

  it("does not revive a completed attempt", () => {
    const copied = inProgressAttemptForDestination({
      destinationResume: null,
      sourceResume: {attemptId: "attempt-1", lessonId: "lesson-b"},
      sourceAttempt: {...sourceAttempt, status: "completed"},
      sourceUid: "anon-1",
      destinationUid: "dest-1",
    });
    expect(copied).toBeNull();
  });

  it("rejects an attempt that belongs to another uid or lesson", () => {
    expect(inProgressAttemptForDestination({
      destinationResume: null,
      sourceResume: {attemptId: "attempt-1", lessonId: "lesson-b"},
      sourceAttempt: {...sourceAttempt, uid: "someone-else"},
      sourceUid: "anon-1",
      destinationUid: "dest-1",
    })).toBeNull();
    expect(inProgressAttemptForDestination({
      destinationResume: null,
      sourceResume: {attemptId: "attempt-1", lessonId: "lesson-b"},
      sourceAttempt: {...sourceAttempt, lessonId: "lesson-other"},
      sourceUid: "anon-1",
      destinationUid: "dest-1",
    })).toBeNull();
  });
});

describe("mergeLiveEntitlement", () => {
  it("copies source grant when destination lacks one", () => {
    const result = mergeLiveEntitlement({
      source: {
        unrestrictedAccess: true,
        source: "section4_jump",
        grantedAtMs: 10,
      },
      destination: undefined,
      nowMs: 100,
      sourceUid: "anon-1",
    });
    expect(result.transferred).toBe(true);
    expect(result.writeDestination).toBe(true);
    expect(result.destinationDoc.unrestrictedAccess).toBe(true);
    expect(result.destinationDoc.originalEntitlementSource).toBe("section4_jump");
    expect(result.destinationDoc.transferredFromUid).toBe("anon-1");
  });

  it("preserves stronger destination grant and still clears source", () => {
    const result = mergeLiveEntitlement({
      source: {unrestrictedAccess: true, source: "section4_jump"},
      destination: {unrestrictedAccess: true, source: "admin"},
      nowMs: 100,
      sourceUid: "anon-1",
    });
    expect(result.transferred).toBe(false);
    expect(result.writeDestination).toBe(true);
    expect(result.clearSource).toBe(true);
    expect(result.destinationDoc.source).toBe("admin");
  });

  it("ignores absent source grant", () => {
    const result = mergeLiveEntitlement({
      source: undefined,
      destination: undefined,
      nowMs: 100,
      sourceUid: "anon-1",
    });
    expect(result.transferred).toBe(false);
    expect(result.writeDestination).toBe(false);
  });
});

describe("transfer TTL constants", () => {
  it("uses short receipt TTL and multi-day recovery window", () => {
    expect(TRANSFER_RECEIPT_TTL_MS).toBe(15 * 60 * 1000);
    expect(TOMBSTONE_RECOVERY_MS).toBe(30 * 24 * 60 * 60 * 1000);
  });
});
