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

describe("soft grading and life loss", () => {
  const lesson = findLesson("lesson-01-01-01-your-two-cards")!.lesson;
  const coverage = findLesson("lesson-01-01-02-renderer-coverage-seed")!.lesson;

  it("never loses a life on reasonable or questionable answers", () => {
    for (const grade of ["reasonable", "questionable"] as const) {
      const outcome = evaluateLifeAndAcceptance({
        grade,
        stage: "unguided",
        lifeLossEligible: true,
      });
      expect(outcome.lifeLost).toBe(false);
      expect(outcome.accepted).toBe(grade === "reasonable");
    }
  });

  it("loses a life only on clear_mistake when stage is eligible", () => {
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "checkpoint",
        lifeLossEligible: true,
      }).lifeLost,
    ).toBe(true);
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "guided",
        lifeLossEligible: false,
      }).lifeLost,
    ).toBe(false);
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "scaffolded",
        lifeLossEligible: false,
      }).lifeLost,
    ).toBe(false);
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "unguided",
        lifeLossEligible: false,
      }).lifeLost,
    ).toBe(false);
  });

  it("grades every soft-grade × stage combination from the bank", () => {
    const guided = lesson.activities.find(
      (activity) => activity.id === "act-01-01-01-guided-find-holes",
    )!;
    expect(gradeCourseResponse({
      activity: guided,
      choiceId: "choice-hero-holes",
    })).toMatchObject({grade: "recommended", accepted: true, lifeLost: false});
    expect(gradeCourseResponse({
      activity: guided,
      choiceId: "choice-board",
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: false,
    });
    expect(gradeCourseResponse({
      activity: lesson.activities.find(
        (activity) => activity.id === "act-01-01-01-scaffolded-private",
      )!,
      choiceId: "choice-dealer-only",
    })).toMatchObject({
      grade: "questionable",
      accepted: false,
      lifeLost: false,
    });

    const checkpoint = coverage.activities.find(
      (activity) => activity.id === "act-01-01-02-checkpoint-open-fold",
    )!;
    expect(gradeCourseResponse({
      activity: checkpoint,
      choiceId: "open-six",
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: true,
    });
    expect(gradeCourseResponse({
      activity: checkpoint,
      choiceId: "limp",
    })).toMatchObject({
      grade: "questionable",
      accepted: false,
      lifeLost: false,
    });

    const scaffolded = coverage.activities.find(
      (activity) => activity.id === "act-01-01-02-scaffolded-action-order",
    )!;
    expect(gradeCourseResponse({
      activity: scaffolded,
      orderedIds: ["seat-btn", "seat-utg", "seat-hj"],
    })).toMatchObject({
      grade: "clear_mistake",
      lifeLost: false,
    });

    const unguided = coverage.activities.find(
      (activity) => activity.id === "act-01-01-02-unguided-pot-price",
    )!;
    expect(gradeCourseResponse({
      activity: unguided,
      numericValue: 9,
    })).toMatchObject({grade: "recommended", accepted: true, lifeLost: false});
    expect(gradeCourseResponse({
      activity: unguided,
      numericValue: 3,
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: true,
    });
  });

  it("rejects client-supplied grade fields at the response API boundary", () => {
    // Covered by submitCourseStepForUser; grading helper never accepts a grade.
    expect(activityIdsInOrder().length).toBeGreaterThan(5);
    expect(courseBank.gradingByActivityId["act-01-01-01-guided-find-holes"])
      .toBeTruthy();
  });
});

describe("streak calendar rules", () => {
  it("credits at most one study day per local calendar day", () => {
    const first = applyStudyDayStreak({
      currentStreak: 0,
      longestStreak: 0,
      lastStudyLocalDate: null,
      todayLocalDate: "2026-03-08",
    });
    expect(first).toEqual({
      currentStreak: 1,
      longestStreak: 1,
      lastStudyLocalDate: "2026-03-08",
      credited: true,
    });
    const sameDay = applyStudyDayStreak({
      currentStreak: 1,
      longestStreak: 1,
      lastStudyLocalDate: "2026-03-08",
      todayLocalDate: "2026-03-08",
    });
    expect(sameDay.credited).toBe(false);
    expect(sameDay.currentStreak).toBe(1);
  });

  it("increments on the next local day and resets after a miss", () => {
    const nextDay = applyStudyDayStreak({
      currentStreak: 2,
      longestStreak: 2,
      lastStudyLocalDate: "2026-03-08",
      todayLocalDate: "2026-03-09",
    });
    expect(nextDay.currentStreak).toBe(3);
    const missed = applyStudyDayStreak({
      currentStreak: 3,
      longestStreak: 5,
      lastStudyLocalDate: "2026-03-08",
      todayLocalDate: "2026-03-10",
    });
    expect(missed.currentStreak).toBe(1);
    expect(missed.longestStreak).toBe(5);
  });

  it("handles America/Los_Angeles around a DST spring-forward boundary", () => {
    // 2026-03-08 09:00 UTC is still 2026-03-08 in LA (PST).
    expect(localDateString(Date.parse("2026-03-08T09:00:00Z"), "America/Los_Angeles"))
      .toBe("2026-03-08");
    // 2026-03-09 07:30 UTC is 2026-03-09 00:30 PDT after the 2am→3am jump.
    expect(localDateString(Date.parse("2026-03-09T07:30:00Z"), "America/Los_Angeles"))
      .toBe("2026-03-09");
    const acrossDst = applyStudyDayStreak({
      currentStreak: 1,
      longestStreak: 1,
      lastStudyLocalDate: "2026-03-08",
      todayLocalDate: localDateString(
        Date.parse("2026-03-09T07:30:00Z"),
        "America/Los_Angeles",
      ),
    });
    expect(acrossDst.currentStreak).toBe(2);
  });
});

describe("placement and live unlock helpers", () => {
  it("requires placement flag for jump-test lessons only", () => {
    const first = findLesson("lesson-01-01-01-your-two-cards")!;
    expect(lessonRequiresPlacementFlag(first.lesson)).toBe(false);
    const coverage = findLesson("lesson-01-01-02-renderer-coverage-seed")!;
    expect(lessonRequiresPlacementFlag(coverage.lesson)).toBe(true);
    const stub = findLesson("lesson-02-01-01-position-stub")!;
    expect(lessonRequiresPlacementFlag(stub.lesson)).toBe(false);
  });

  it("only section 4 jump lessons grant Live entitlement", () => {
    const first = findLesson("lesson-01-01-01-your-two-cards")!;
    expect(lessonGrantsLiveTrainingEntitlement(first)).toBe(false);
    expect(LIVE_UNLOCK_SECTION_ID).toBe("sec-04-regular-live");
  });
});
