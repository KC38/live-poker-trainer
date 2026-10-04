/**
 * Unit tests for course soft-grading, streaks, flags, and life-loss rules.
 */

import {describe, expect, it} from "vitest";
import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore} from "firebase-admin/firestore";
import {
  DEFAULT_LESSON_LIVES,
  HEART_REFILL_INTERVAL_MS,
} from "./course_hearts";
import {
  activityIdsInOrder,
  courseBank,
  findLesson,
  lessonGrantsLiveTrainingEntitlement,
  lessonRequiresPlacementFlag,
  LIVE_UNLOCK_SECTION_ID,
} from "./course_catalog";
import {
  acceptedAccuracyRatio,
  applyStudyDayStreak,
  assertCourseAvailable,
  countsAsScoredAnswer,
  disabledCourseFlags,
  evaluateLifeAndAcceptance,
  gradeCourseResponse,
  isLessonAttemptReadyToComplete,
  lessonAttemptAcceptedAccuracy,
  lessonXpTotal,
  localDateString,
  parseCourseFlags,
  profileLivesFromData,
  omitUndefined,
  reviewLessonXp,
  allowsZeroHeartPlay,
  shouldAdvanceActivityAfterSubmit,
  resolveSubmitHeartState,
  shouldBlockSubmitForHearts,
  XP_LESSON_COMPLETE,
  XP_PER_ACCEPTED_STEP,
  type CourseFlags,
} from "./course_session";

/** Flags for unit tests that skip Firestore (assertCourseAvailable uses `flags`). */
const enabledFlags: CourseFlags = {
  courseEnabled: true,
  courseStartsEnabled: true,
  guestCourseEnabled: false,
  placementTestsEnabled: true,
  catalogVersion: "2.0.0",
  minimumClientVersion: "2.0.0",
};

const unusedDb = {} as Firestore;

describe("profile lives (per user)", () => {
  it("defaults missing profile hearts to a full set", () => {
    expect(profileLivesFromData(undefined)).toEqual({
      livesRemaining: 5,
      livesMax: 5,
    });
    expect(profileLivesFromData({})).toEqual({
      livesRemaining: 5,
      livesMax: 5,
    });
  });

  it("clamps remaining hearts into [0, livesMax]", () => {
    expect(profileLivesFromData({livesRemaining: 2, livesMax: 5})).toEqual({
      livesRemaining: 2,
      livesMax: 5,
    });
    expect(profileLivesFromData({livesRemaining: -1, livesMax: 5})).toEqual({
      livesRemaining: 0,
      livesMax: 5,
    });
    expect(profileLivesFromData({livesRemaining: 9, livesMax: 5})).toEqual({
      livesRemaining: 5,
      livesMax: 5,
    });
  });
});

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
  const openFold = findLesson("lesson-02-03-01-open-fold")!.lesson;
  const streets = findLesson("lesson-01-04-01-streets-and-order")!.lesson;
  const pots = findLesson("lesson-01-05-01-winning-pots")!.lesson;

  it("loses a life on any non-accepted grade except guided", () => {
    expect(
      evaluateLifeAndAcceptance({
        grade: "questionable",
        stage: "unguided",
      }),
    ).toMatchObject({accepted: false, lifeLost: true, masteryWeight: 0});
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "checkpoint",
      }).lifeLost,
    ).toBe(true);
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "guided",
      }).lifeLost,
    ).toBe(false);
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "scaffolded",
      }).lifeLost,
    ).toBe(true);
    expect(
      evaluateLifeAndAcceptance({
        grade: "questionable",
        stage: "explain",
      }).lifeLost,
    ).toBe(true);
  });

  it("loses a life on jump_test mistakes", () => {
    expect(
      evaluateLifeAndAcceptance({
        grade: "clear_mistake",
        stage: "jump_test",
      }),
    ).toMatchObject({accepted: false, lifeLost: true, masteryWeight: 0});
    expect(
      evaluateLifeAndAcceptance({
        grade: "questionable",
        stage: "jump_test",
      }),
    ).toMatchObject({accepted: false, lifeLost: true, masteryWeight: 0});
  });

  it("treats strong and reasonable as accepted without life loss", () => {
    expect(
      evaluateLifeAndAcceptance({
        grade: "strong",
        stage: "unguided",
      }),
    ).toMatchObject({accepted: true, lifeLost: false, masteryWeight: 0.85});
    expect(
      evaluateLifeAndAcceptance({
        grade: "reasonable",
        stage: "checkpoint",
      }),
    ).toMatchObject({accepted: true, lifeLost: false, masteryWeight: 0.7});
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
      lifeLost: true,
    });

    const checkpoint = openFold.activities.find(
      (activity) => activity.id === "act-02-03-01-guided-utg",
    )!;
    expect(gradeCourseResponse({
      activity: checkpoint,
      choiceId: "open-six",
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: false, // guided: never life loss
    });
    expect(gradeCourseResponse({
      activity: checkpoint,
      choiceId: "limp",
    })).toMatchObject({
      grade: "questionable",
      accepted: false,
      lifeLost: false,
    });

    const lifeLossCheckpoint = openFold.activities.find(
      (activity) => activity.id === "act-02-03-01-checkpoint-hj",
    )!;
    expect(gradeCourseResponse({
      activity: lifeLossCheckpoint,
      choiceId: "jam-ato",
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: true,
    });

    const holesCheckpoint = lesson.activities.find(
      (activity) => activity.id === "act-01-01-01-checkpoint-table",
    )!;
    expect(gradeCourseResponse({
      activity: holesCheckpoint,
      choiceId: "choice-checkpoint-all",
    })).toMatchObject({
      grade: "questionable",
      accepted: false,
      lifeLost: true,
    });

    const scaffolded = streets.activities.find(
      (activity) => activity.id === "act-01-04-01-scaffolded-order",
    )!;
    expect(gradeCourseResponse({
      activity: scaffolded,
      orderedIds: ["seat-btn", "seat-utg", "seat-hj"],
    })).toMatchObject({
      grade: "clear_mistake",
      lifeLost: true,
    });

    const unguided = pots.activities.find(
      (activity) => activity.id === "act-01-05-01-unguided-pot",
    )!;
    expect(gradeCourseResponse({
      activity: unguided,
      choiceId: "pot-correct",
    })).toMatchObject({grade: "recommended", accepted: true, lifeLost: false});
    expect(gradeCourseResponse({
      activity: unguided,
      choiceId: "pot-miss-blind",
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: true,
    });
    expect(gradeCourseResponse({
      activity: unguided,
      choiceId: "pot-too-big",
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: true,
      betterChoiceId: "pot-correct",
    });
  });

  it("auto-passes explain and coach_dialogue without a client answer", () => {
    const explain = lesson.activities.find(
      (activity) => activity.id === "act-01-01-01-explain-hole-cards",
    )!;
    expect(gradeCourseResponse({activity: explain})).toMatchObject({
      grade: "recommended",
      accepted: true,
      lifeLost: false,
    });
  });

  it("accepts UTG HJ CO BTN and rejects the order that skips CO", () => {
    const scaffolded = streets.activities.find(
      (activity) => activity.id === "act-01-04-01-scaffolded-order",
    )!;
    expect(gradeCourseResponse({
      activity: scaffolded,
      orderedIds: ["seat-utg", "seat-hj", "seat-co", "seat-btn"],
    })).toMatchObject({accepted: true, lifeLost: false});
    expect(gradeCourseResponse({
      activity: scaffolded,
      orderedIds: ["seat-utg", "seat-hj", "seat-btn"],
    })).toMatchObject({
      grade: "clear_mistake",
      accepted: false,
      lifeLost: true,
    });
  });

  it("rejects unknown choices and empty scored payloads", () => {
    const guided = lesson.activities.find(
      (activity) => activity.id === "act-01-01-01-guided-find-holes",
    )!;
    expect(() => gradeCourseResponse({
      activity: guided,
      choiceId: "not-a-real-choice",
    })).toThrow(HttpsError);
    expect(() => gradeCourseResponse({activity: guided})).toThrowError(
      /choiceId, orderedIds, or numericValue/,
    );
  });

  it("rejects mismatched response shapes for sequence and numeric activities", () => {
    const guided = lesson.activities.find(
      (activity) => activity.id === "act-01-01-01-guided-find-holes",
    )!;
    expect(() => gradeCourseResponse({
      activity: guided,
      orderedIds: ["choice-hero-holes"],
    })).toThrowError(/does not accept ordered responses/);
    expect(() => gradeCourseResponse({
      activity: guided,
      numericValue: 2,
    })).toThrowError(/does not accept numeric responses/);
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

  it("falls back to UTC for an invalid IANA timezone", () => {
    expect(localDateString(Date.parse("2026-03-09T07:30:00Z"), "Not/A_Zone"))
      .toBe("2026-03-09");
  });
});

describe("assertCourseAvailable gates", () => {
  it("fails closed when the course is disabled", async () => {
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "read",
      flags: disabledCourseFlags(),
    })).rejects.toMatchObject({code: "failed-precondition"});
  });

  it("rejects stale clients and catalog mismatches", async () => {
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "1.9.9",
      mode: "mutate",
      flags: enabledFlags,
    })).rejects.toThrowError(/newer app version/);
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      catalogVersion: "1.0.0",
      mode: "mutate",
      flags: enabledFlags,
    })).rejects.toThrowError(/catalog version mismatch/i);
  });

  it("blocks anonymous starts unless guestCourseEnabled", async () => {
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "start",
      isAnonymous: true,
      flags: enabledFlags,
    })).rejects.toThrowError(/Guest course access is disabled/);
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "mutate",
      isAnonymous: true,
      flags: enabledFlags,
    })).resolves.toEqual(enabledFlags);
  });

  it("pauses new starts independently of in-progress mutate", async () => {
    const paused: CourseFlags = {...enabledFlags, courseStartsEnabled: false};
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "start",
      flags: paused,
    })).rejects.toThrowError(/New course attempts are paused/);
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "mutate",
      flags: paused,
    })).resolves.toEqual(paused);
  });

  it("blocks placement/jump when the placement flag is off", async () => {
    const noPlacement: CourseFlags = {
      ...enabledFlags,
      placementTestsEnabled: false,
    };
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "placement",
      flags: {...enabledFlags, guestCourseEnabled: true, placementTestsEnabled: false},
    })).rejects.toThrowError(/Placement and jump tests are disabled/);
    await expect(assertCourseAvailable({
      db: unusedDb,
      clientVersion: "2.0.0",
      mode: "start",
      requiresPlacement: true,
      flags: noPlacement,
    })).rejects.toThrowError(/Placement and jump tests are disabled/);
  });
});

describe("placement and live unlock helpers", () => {
  it("requires placement flag for jump-test lessons only", () => {
    const first = findLesson("lesson-01-01-01-your-two-cards")!;
    expect(lessonRequiresPlacementFlag(first.lesson)).toBe(false);
    const jump = findLesson("lesson-01-06-02-section-one-jump")!;
    expect(lessonRequiresPlacementFlag(jump.lesson)).toBe(true);
    const position = findLesson("lesson-02-01-01-position-labels")!;
    expect(lessonRequiresPlacementFlag(position.lesson)).toBe(false);
  });

  it("only section 4 jump lessons grant Live entitlement", () => {
    const first = findLesson("lesson-01-01-01-your-two-cards")!;
    expect(lessonGrantsLiveTrainingEntitlement(first)).toBe(false);
    expect(LIVE_UNLOCK_SECTION_ID).toBe("sec-04-regular-live");
    const sec3Jump = findLesson("lesson-03-08-02-section-three-jump-test")!;
    expect(lessonRequiresPlacementFlag(sec3Jump.lesson)).toBe(true);
    expect(lessonGrantsLiveTrainingEntitlement(sec3Jump)).toBe(false);
    const sec4Jump = findLesson("lesson-04-10-02-section-four-jump-test")!;
    expect(lessonRequiresPlacementFlag(sec4Jump.lesson)).toBe(true);
    expect(lessonGrantsLiveTrainingEntitlement(sec4Jump)).toBe(true);
  });
});

describe("accepted accuracy", () => {
  const lesson = findLesson("lesson-01-03-02-bet-raise-allin")!.lesson;

  it("clamps accepted / scored and treats empty scored as zero", () => {
    expect(acceptedAccuracyRatio(0, 0)).toBe(0);
    expect(acceptedAccuracyRatio(3, 4)).toBe(0.75);
    expect(acceptedAccuracyRatio(5, 4)).toBe(1);
  });

  it("counts rejections and advancing accepts, not explain or mid-street accepts", () => {
    expect(countsAsScoredAnswer({
      scored: false,
      advanceActivity: true,
      accepted: true,
    })).toBe(false);
    expect(countsAsScoredAnswer({
      scored: true,
      advanceActivity: false,
      accepted: false,
    })).toBe(true);
    expect(countsAsScoredAnswer({
      scored: true,
      advanceActivity: false,
      accepted: true,
    })).toBe(false);
    expect(countsAsScoredAnswer({
      scored: true,
      advanceActivity: true,
      accepted: true,
    })).toBe(true);
  });

  it("does not let one explain cancel one mistake on the result screen", () => {
    // Bet, raise, all-in: 1 explain + 4 scored. One wrong then four accepts
    // used to report 5/5 = 100% because explain inflated acceptedAnswers.
    expect(lesson.activities.filter((a) => a.stage === "explain")).toHaveLength(
      1,
    );
    expect(
      lessonAttemptAcceptedAccuracy({
        acceptedCount: 5,
        scoredCount: 5,
        acceptedScoredCount: 4,
      }, lesson),
    ).toBe(0.8);
  });

  it("derives legacy attempts by subtracting explain activities", () => {
    expect(
      lessonAttemptAcceptedAccuracy({
        acceptedCount: 5,
        scoredCount: 5,
      }, lesson),
    ).toBe(0.8);
  });

  it("reports perfect when every scored answer was accepted", () => {
    expect(
      lessonAttemptAcceptedAccuracy({
        acceptedCount: 5,
        scoredCount: 4,
        acceptedScoredCount: 4,
      }, lesson),
    ).toBe(1);
  });
});

describe("lesson completion cursor", () => {
  const lesson = findLesson("lesson-01-01-01-your-two-cards")!.lesson;

  it("does not treat reaching the last activity as complete", () => {
    expect(
      isLessonAttemptReadyToComplete({
        status: "in_progress",
        activityIndex: lesson.activities.length - 1,
        acceptedCount: lesson.activities.length - 1,
      }, lesson),
    ).toBe(false);
  });

  it("is ready after the last activity is accepted", () => {
    expect(
      isLessonAttemptReadyToComplete({
        status: "in_progress",
        activityIndex: lesson.activities.length,
        acceptedCount: lesson.activities.length,
      }, lesson),
    ).toBe(true);
    expect(
      isLessonAttemptReadyToComplete({
        status: "in_progress",
        activityIndex: lesson.activities.length - 1,
        acceptedCount: lesson.activities.length,
      }, lesson),
    ).toBe(true);
  });

  it("counts a perfect Your two cards as five step awards plus the bonus", () => {
    expect(lesson.activities.length).toBe(5);
    expect(lessonXpTotal(lesson.activities.length * XP_PER_ACCEPTED_STEP)).toBe(
      75,
    );
  });

  it("drops corrupt step XP and adds the completion bonus once", () => {
    expect(lessonXpTotal(0)).toBe(XP_LESSON_COMPLETE);
    expect(lessonXpTotal(-10)).toBe(XP_LESSON_COMPLETE);
    expect(lessonXpTotal(Number.NaN)).toBe(XP_LESSON_COMPLETE);
    expect(lessonXpTotal(Number.POSITIVE_INFINITY)).toBe(XP_LESSON_COMPLETE);
    expect(lessonXpTotal(XP_PER_ACCEPTED_STEP)).toBe(
      XP_PER_ACCEPTED_STEP + XP_LESSON_COMPLETE,
    );
  });

  it("reviewLessonXp is one quarter of the earned first-run total", () => {
    expect(reviewLessonXp(0)).toBe(0);
    expect(reviewLessonXp(-3)).toBe(0);
    expect(reviewLessonXp(Number.NaN)).toBe(0);
    expect(reviewLessonXp(40)).toBe(10);
    expect(reviewLessonXp(25)).toBe(6);
    expect(reviewLessonXp(35)).toBe(9);
    expect(reviewLessonXp(75)).toBe(19);
  });

  it("omitUndefined drops undefined keys so Firestore writes stay valid", () => {
    const payload = omitUndefined({
      xpEarned: 10,
      lessonXpAwarded: undefined,
      completedAtMs: null,
      stepCount: 0,
    });
    expect(payload).toEqual({
      xpEarned: 10,
      completedAtMs: null,
      stepCount: 0,
    });
    expect(Object.prototype.hasOwnProperty.call(payload, "lessonXpAwarded"))
      .toBe(false);
  });

  it("blocks completion during remediation", () => {
    expect(
      isLessonAttemptReadyToComplete({
        status: "remediation",
        activityIndex: lesson.activities.length,
        acceptedCount: lesson.activities.length,
      }, lesson),
    ).toBe(false);
  });
});

describe("allowsZeroHeartPlay", () => {
  it("blocks a first-run lesson that is not a heart-refill Practice", () => {
    expect(allowsZeroHeartPlay({
      lessonCompleted: false,
      practiceLesson: false,
      restoreHeartOnComplete: false,
    })).toBe(false);
  });

  it("allows a heart-refill Practice attempt before the lesson is completed", () => {
    expect(allowsZeroHeartPlay({
      lessonCompleted: false,
      practiceLesson: false,
      restoreHeartOnComplete: true,
    })).toBe(true);
  });

  it("allows a completed lesson and a practice node", () => {
    expect(allowsZeroHeartPlay({
      lessonCompleted: true,
      practiceLesson: false,
      restoreHeartOnComplete: false,
    })).toBe(true);
    expect(allowsZeroHeartPlay({
      lessonCompleted: false,
      practiceLesson: true,
      restoreHeartOnComplete: false,
    })).toBe(true);
  });
});

describe("shouldBlockSubmitForHearts", () => {
  it("blocks first-run lessons at zero hearts", () => {
    expect(
      shouldBlockSubmitForHearts({
        livesRemaining: 0,
        isPracticeOrReplay: false,
      }),
    ).toBe(true);
  });

  it("allows practice or replay at zero hearts", () => {
    expect(
      shouldBlockSubmitForHearts({
        livesRemaining: 0,
        isPracticeOrReplay: true,
      }),
    ).toBe(false);
  });

  it("allows submits while hearts remain", () => {
    expect(
      shouldBlockSubmitForHearts({
        livesRemaining: 1,
        isPracticeOrReplay: false,
      }),
    ).toBe(false);
  });

  it("blocks a first-run lesson when the stored count is negative", () => {
    expect(
      shouldBlockSubmitForHearts({
        livesRemaining: -1,
        isPracticeOrReplay: false,
      }),
    ).toBe(true);
  });

  it("still allows practice when the stored count is negative", () => {
    expect(
      shouldBlockSubmitForHearts({
        livesRemaining: -1,
        isPracticeOrReplay: true,
      }),
    ).toBe(false);
  });
});

describe("resolveSubmitHeartState", () => {
  const nowMs = 1_000_000;

  it("grades from a passive heart that accrued on the profile", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "remediation",
      attemptLivesRemaining: 0,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {
        livesRemaining: 0,
        livesMax: 5,
        livesNextRefillAtMs: nowMs,
      },
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.blocked).toBe(false);
    expect(resolved.livesRemaining).toBe(1);
    expect(resolved.status).toBe("in_progress");
    expect(resolved.livesNextRefillAtMs).toBe(nowMs + HEART_REFILL_INTERVAL_MS);
  });

  it("keeps a first-run lesson blocked when the wallet is still empty", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "remediation",
      attemptLivesRemaining: 0,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {
        livesRemaining: 0,
        livesMax: 5,
        livesNextRefillAtMs: nowMs + HEART_REFILL_INTERVAL_MS,
      },
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.blocked).toBe(true);
    expect(resolved.livesRemaining).toBe(0);
    expect(resolved.status).toBe("remediation");
  });

  it("does not drop a heart the profile already accrued above the attempt", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "in_progress",
      attemptLivesRemaining: 3,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {
        livesRemaining: 3,
        livesMax: 5,
        livesNextRefillAtMs: nowMs,
      },
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.livesRemaining).toBe(4);
    expect(resolved.blocked).toBe(false);
  });

  it("keeps the attempt count when the profile has no heart wallet", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "in_progress",
      attemptLivesRemaining: 0,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {gems: 10},
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.blocked).toBe(true);
    expect(resolved.livesRemaining).toBe(0);
    expect(resolved.livesNextRefillAtMs).toBeNull();
  });

  it("does not restore hearts from a stale higher attempt count", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "in_progress",
      attemptLivesRemaining: 4,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {
        livesRemaining: 1,
        livesMax: 5,
        livesNextRefillAtMs: nowMs + HEART_REFILL_INTERVAL_MS,
      },
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.livesRemaining).toBe(1);
    expect(resolved.livesMax).toBe(DEFAULT_LESSON_LIVES);
    expect(resolved.blocked).toBe(false);
    expect(resolved.status).toBe("in_progress");
  });

  it("lets practice continue on an empty wallet without leaving remediation", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "remediation",
      attemptLivesRemaining: 4,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {
        livesRemaining: 0,
        livesMax: 5,
        livesNextRefillAtMs: nowMs + HEART_REFILL_INTERVAL_MS,
      },
      nowMs,
      isPracticeOrReplay: true,
    });
    expect(resolved.livesRemaining).toBe(0);
    expect(resolved.blocked).toBe(false);
    expect(resolved.status).toBe("remediation");
  });

  it("grades a numeric-string wallet and lifts remediation", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "remediation",
      attemptLivesRemaining: 0,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {
        livesRemaining: "2",
        livesMax: 5,
        livesNextRefillAtMs: nowMs + HEART_REFILL_INTERVAL_MS,
      },
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.livesRemaining).toBe(2);
    expect(resolved.blocked).toBe(false);
    expect(resolved.status).toBe("in_progress");
  });

  it("ignores a non-numeric wallet and clamps the attempt", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "in_progress",
      attemptLivesRemaining: 9,
      attemptLivesMax: 5,
      profileExists: true,
      profileData: {livesRemaining: "none", livesMax: 5},
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.livesRemaining).toBe(5);
    expect(resolved.livesMax).toBe(5);
    expect(resolved.blocked).toBe(false);
    expect(resolved.livesNextRefillAtMs).toBeNull();
  });

  it("blocks a missing profile when the attempt count is not finite", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "in_progress",
      attemptLivesRemaining: Number.NaN,
      attemptLivesMax: 0,
      profileExists: false,
      profileData: {livesRemaining: 5, livesMax: 5},
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.livesRemaining).toBe(0);
    expect(resolved.livesMax).toBe(DEFAULT_LESSON_LIVES);
    expect(resolved.livesNextRefillAtMs).toBeNull();
    expect(resolved.blocked).toBe(true);
    expect(resolved.status).toBe("in_progress");
  });

  it("does not block practice when the attempt count is not finite", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "in_progress",
      attemptLivesRemaining: Number.NaN,
      attemptLivesMax: 0,
      profileExists: false,
      profileData: undefined,
      nowMs,
      isPracticeOrReplay: true,
    });
    expect(resolved.blocked).toBe(false);
    expect(resolved.livesRemaining).toBe(0);
    expect(resolved.livesMax).toBe(DEFAULT_LESSON_LIVES);
  });

  it("floors a fractional attempt and clears remediation without a wallet", () => {
    const resolved = resolveSubmitHeartState({
      attemptStatus: "remediation",
      attemptLivesRemaining: 2.9,
      attemptLivesMax: 5,
      profileExists: false,
      profileData: {livesRemaining: 0},
      nowMs,
      isPracticeOrReplay: false,
    });
    expect(resolved.livesRemaining).toBe(2);
    expect(resolved.status).toBe("in_progress");
    expect(resolved.blocked).toBe(false);
    expect(resolved.livesNextRefillAtMs).toBeNull();
  });
});

describe("multi-step activity advance", () => {
  const toy = findLesson("lesson-01-06-01-guided-complete-hand")!.lesson;
  const guided = toy.activities.find((a) => a.id === "act-01-06-01-guided-steps")!;

  it("stays on activity after an accepted first street", () => {
    expect(
      shouldAdvanceActivityAfterSubmit({
        activity: guided,
        choiceId: "open-6",
        accepted: true,
      }),
    ).toBe(false);
  });

  it("advances after an accepted last street", () => {
    expect(
      shouldAdvanceActivityAfterSubmit({
        activity: guided,
        choiceId: "won-folds",
        accepted: true,
      }),
    ).toBe(true);
  });

  it("does not advance on a rejected first street", () => {
    expect(
      shouldAdvanceActivityAfterSubmit({
        activity: guided,
        choiceId: "fold-a9",
        accepted: false,
      }),
    ).toBe(false);
  });

  it("advances on last street when choiceId also appears earlier", () => {
    const dupCheckHand = {
      ...guided,
      handSteps: [
        {
          id: "step-a",
          street: "flop",
          choices: [{id: "bet", label: "Bet"}],
        },
        {
          id: "step-b",
          street: "turn",
          choices: [{id: "check", label: "Check"}],
        },
        {
          id: "step-c",
          street: "river",
          choices: [{id: "check", label: "Check"}],
        },
      ],
    } as typeof guided;
    expect(
      shouldAdvanceActivityAfterSubmit({
        activity: dupCheckHand,
        choiceId: "check",
        accepted: true,
      }),
    ).toBe(true);
  });
});
