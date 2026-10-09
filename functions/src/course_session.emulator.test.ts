/**
 * Firestore-emulator integration for course idempotency, gates, and isolation.
 */

import {deleteApp, getApp, getApps, initializeApp} from "firebase-admin/app";
import {getFirestore, type Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {afterAll, afterEach, beforeAll, describe, expect, test} from "vitest";
import {
  completeCourseLessonForUser,
  getCourseStateForUser,
  HEART_REFILL_INTERVAL_MS,
  initializeCourseProfileForUser,
  startCourseLessonForUser,
  submitCourseStepForUser,
} from "./course_session";

const PROJECT_ID = "live-poker-trainer-rules-test";
const APP_NAME = "course-session-emulator-tests";
let db: Firestore;

async function seedFlags(overrides: Record<string, unknown> = {}): Promise<void> {
  await db.doc("appConfig/courseFlags").set({
    courseEnabled: true,
    courseStartsEnabled: true,
    guestCourseEnabled: true,
    placementTestsEnabled: true,
    catalogVersion: "2.0.0",
    minimumClientVersion: "2.0.0",
    ...overrides,
  });
}

beforeAll(() => {
  const existing = getApps().find((app) => app.name === APP_NAME);
  const app = existing ?? initializeApp({projectId: PROJECT_ID}, APP_NAME);
  db = getFirestore(app);
});

afterEach(async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  if (!host) throw new Error("FIRESTORE_EMULATOR_HOST is required");
  await fetch(
    `http://${host}/emulator/v1/projects/${PROJECT_ID}` +
      "/databases/(default)/documents",
    {method: "DELETE"},
  );
});

afterAll(async () => {
  if (getApps().some((app) => app.name === APP_NAME)) {
    await deleteApp(getApp(APP_NAME));
  }
});

describe("course session integration", () => {
  test("initialize, start, submit, and complete are idempotent", async () => {
    await seedFlags();
    const init = await initializeCourseProfileForUser({
      uid: "course-user",
      raw: {clientVersion: "2.0.0", timezone: "UTC"},
      db,
    });
    const initAgain = await initializeCourseProfileForUser({
      uid: "course-user",
      raw: {clientVersion: "2.0.0", timezone: "UTC"},
      db,
    });
    expect(init.created).toBe(true);
    expect(initAgain.created).toBe(false);

    const startRaw = {
      clientVersion: "2.0.0",
      lessonId: "lesson-01-01-01-your-two-cards",
      startRequestId: "start_req_01",
      catalogVersion: "2.0.0",
      timezone: "UTC",
    };
    const first = await startCourseLessonForUser({
      uid: "course-user",
      raw: startRaw,
      db,
    });
    const second = await startCourseLessonForUser({
      uid: "course-user",
      raw: startRaw,
      db,
    });
    expect(second.attempt.attemptId).toBe(first.attempt.attemptId);
    expect(second.duplicate).toBe(true);

    const explain = await submitCourseStepForUser({
      uid: "course-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: first.attempt.attemptId,
        activityId: "act-01-01-01-explain-hole-cards",
        idempotencyKey: "step_explain_01",
      },
      db,
    });
    const explainRetry = await submitCourseStepForUser({
      uid: "course-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: first.attempt.attemptId,
        activityId: "act-01-01-01-explain-hole-cards",
        idempotencyKey: "step_explain_01",
      },
      db,
    });
    expect(explainRetry.duplicate).toBe(true);
    expect(explainRetry.xpAwarded).toBe(explain.xpAwarded);

    const ledger = await db
      .collection("users/course-user/courseXpLedger")
      .get();
    expect(ledger.size).toBe(1);
  });

  test("non-accepted grades lose a heart on guided, scaffolded, and unguided", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "life-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const started = await startCourseLessonForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-01-01-01-your-two-cards",
        startRequestId: "start_life_01",
      },
      db,
    });
    // Advance through explain.
    await submitCourseStepForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-01-01-01-explain-hole-cards",
        idempotencyKey: "life_explain",
      },
      db,
    });
    const guidedMiss = await submitCourseStepForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-01-01-01-guided-find-holes",
        choiceId: "choice-board",
        idempotencyKey: "life_guided_miss",
      },
      db,
    });
    expect(guidedMiss.grade).toBe("clear_mistake");
    expect(guidedMiss.lifeLost).toBe(true);
    expect(guidedMiss.livesRemaining).toBe(4);

    // Accept guided, then questionable scaffolded (costs another heart).
    await submitCourseStepForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-01-01-01-guided-find-holes",
        choiceId: "choice-hero-holes",
        idempotencyKey: "life_guided_ok",
      },
      db,
    });
    const scaffoldedQuestionable = await submitCourseStepForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-01-01-01-scaffolded-private",
        choiceId: "choice-dealer-only",
        idempotencyKey: "life_questionable",
      },
      db,
    });
    expect(scaffoldedQuestionable.grade).toBe("questionable");
    expect(scaffoldedQuestionable.lifeLost).toBe(true);
    expect(scaffoldedQuestionable.livesRemaining).toBe(3);
    await submitCourseStepForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-01-01-01-scaffolded-private",
        choiceId: "choice-only-you",
        idempotencyKey: "life_scaffold_ok",
      },
      db,
    });
    const clearMistake = await submitCourseStepForUser({
      uid: "life-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-01-01-01-unguided-mix",
        choiceId: "choice-hero-again",
        idempotencyKey: "life_clear_mistake",
      },
      db,
    });
    expect(clearMistake.grade).toBe("clear_mistake");
    expect(clearMistake.lifeLost).toBe(true);
    expect(clearMistake.livesRemaining).toBe(2);

    const profileAfterLoss = await db.doc("users/life-user/course/main").get();
    expect(profileAfterLoss.data()?.livesRemaining).toBe(2);
  });

  test("new lesson starts carry profile hearts (not a fresh set)", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "hearts-user",
      raw: {clientVersion: "2.0.0", timezone: "UTC"},
      db,
    });
    await db.doc("users/hearts-user/course/main").set({
      livesRemaining: 1,
      livesMax: 5,
    }, {merge: true});

    const started = await startCourseLessonForUser({
      uid: "hearts-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-01-01-01-your-two-cards",
        startRequestId: "start_hearts_carry",
      },
      db,
    });
    expect(started.attempt.livesRemaining).toBe(1);
    expect(started.attempt.livesMax).toBe(5);

    const profile = await db.doc("users/hearts-user/course/main").get();
    expect(profile.data()?.livesRemaining).toBe(1);
  });

  test("rejects client-submitted grades and disabled course starts", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "gate-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const started = await startCourseLessonForUser({
      uid: "gate-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-01-01-01-your-two-cards",
        startRequestId: "start_gate_01",
      },
      db,
    });
    await expect(
      submitCourseStepForUser({
        uid: "gate-user",
        raw: {
          clientVersion: "2.0.0",
          attemptId: started.attempt.attemptId,
          activityId: "act-01-01-01-explain-hole-cards",
          idempotencyKey: "grade_reject_01",
          grade: "recommended",
        },
        db,
      }),
    ).rejects.toBeInstanceOf(HttpsError);

    await seedFlags({courseStartsEnabled: false});
    await expect(
      startCourseLessonForUser({
        uid: "gate-user",
        raw: {
          clientVersion: "2.0.0",
          lessonId: "lesson-02-01-01-position-labels",
          startRequestId: "start_gate_02",
        },
        db,
      }),
    ).rejects.toMatchObject({code: "failed-precondition"});

    await seedFlags({placementTestsEnabled: false});
    await expect(
      startCourseLessonForUser({
        uid: "gate-user",
        raw: {
          clientVersion: "2.0.0",
          lessonId: "lesson-01-06-02-section-one-jump",
          startRequestId: "start_gate_03",
        },
        db,
      }),
    ).rejects.toMatchObject({code: "failed-precondition"});
  });

  test("course writes leave Live Training documents untouched", async () => {
    await seedFlags();
    await db.doc("users/iso-user/liveProgress/main").set({handsPlayed: 9});
    await db.doc("users/iso-user/liveHandHistory/hand-1").set({result: 4});
    await db.doc("users/iso-user/liveHandReceipts/hand-1").set({
      status: "allocated",
    });
    await initializeCourseProfileForUser({
      uid: "iso-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    // Seed the direct prerequisite so this isolation test can start mid-path
    // without authoring the entire Section 1 completion chain.
    await db.doc("users/iso-user/course/main").set({
      completedLessonIds: ["lesson-01-06-02-section-one-jump"],
    }, {merge: true});
    const started = await startCourseLessonForUser({
      uid: "iso-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-02-01-01-position-labels",
        startRequestId: "start_iso_01",
      },
      db,
    });
    await submitCourseStepForUser({
      uid: "iso-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-02-01-01-explain-pos",
        idempotencyKey: "iso_step_01",
      },
      db,
    });
    await completeCourseLessonForUser({
      uid: "iso-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        idempotencyKey: "iso_complete_01",
      },
      db,
    });
    expect((await db.doc("users/iso-user/liveProgress/main").get()).data())
      .toEqual({handsPlayed: 9});
    expect((await db.doc("users/iso-user/liveHandHistory/hand-1").get()).data())
      .toEqual({result: 4});
    expect((await db.doc("users/iso-user/liveHandReceipts/hand-1").get()).data())
      .toEqual({status: "allocated"});

    const state = await getCourseStateForUser({
      uid: "iso-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    expect(state.profile?.completedLessonIds).toContain(
      "lesson-02-01-01-position-labels",
    );
    expect(state.profile?.lifetimeXp).toBeGreaterThan(0);
  });


  test("locked lessons cannot start until prerequisites complete", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "lock-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    await expect(
      startCourseLessonForUser({
        uid: "lock-user",
        raw: {
          clientVersion: "2.0.0",
          lessonId: "lesson-01-01-02-suits-and-ranks",
          startRequestId: "start_lock_01",
        },
        db,
      }),
    ).rejects.toMatchObject({code: "failed-precondition"});

    await db.doc("users/lock-user/course/main").set({
      completedLessonIds: ["lesson-01-01-01-your-two-cards"],
    }, {merge: true});
    const started = await startCourseLessonForUser({
      uid: "lock-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-01-01-02-suits-and-ranks",
        startRequestId: "start_lock_02",
      },
      db,
    });
    expect(started.attempt.lessonId).toBe("lesson-01-01-02-suits-and-ranks");
  });

  test("anonymous starts require guestCourseEnabled", async () => {
    await seedFlags({guestCourseEnabled: false});
    await expect(
      initializeCourseProfileForUser({
        uid: "anon-user",
        raw: {clientVersion: "2.0.0"},
        isAnonymous: true,
        db,
      }),
    ).rejects.toMatchObject({code: "failed-precondition"});
  });

  test("complete is idempotent and does not double XP", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "complete-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const started = await startCourseLessonForUser({
      uid: "complete-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-02-01-01-position-labels",
        startRequestId: "start_complete_01",
      },
      db,
    });
    await submitCourseStepForUser({
      uid: "complete-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        activityId: "act-02-01-01-explain-pos",
        idempotencyKey: "complete_step_01",
      },
      db,
    });
    const first = await completeCourseLessonForUser({
      uid: "complete-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        idempotencyKey: "complete_once_01",
      },
      db,
    });
    const second = await completeCourseLessonForUser({
      uid: "complete-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        idempotencyKey: "complete_once_01",
      },
      db,
    });
    expect(second.duplicate).toBe(true);
    expect(second.xpAwarded).toBe(first.xpAwarded);
    const ledger = await db
      .collection("users/complete-user/courseXpLedger")
      .get();
    expect(ledger.size).toBe(2); // step + one complete
  });

  test("section 4 jump grants liveTraining entitlement", async () => {
    await seedFlags({placementTestsEnabled: true});
    await initializeCourseProfileForUser({
      uid: "unlock-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const lessonId = "lesson-04-10-02-section-four-jump-test";
    const started = await startCourseLessonForUser({
      uid: "unlock-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId,
        startRequestId: "start_unlock_01",
      },
      db,
    });
    const steps: Array<Record<string, unknown>> = [
      {activityId: "act-04-10-02-jump-range", choiceId: "j4-range"},
      {activityId: "act-04-10-02-jump-3bet", choiceId: "j4-3bet"},
      {activityId: "act-04-10-02-jump-spr", numericValue: 4},
      {activityId: "act-04-10-02-jump-size", choiceId: "j4-10"},
      {activityId: "act-04-10-02-jump-station", choiceId: "j4-cs"},
      {activityId: "act-04-10-02-jump-nit", choiceId: "j4-nit"},
      {activityId: "act-04-10-02-jump-maniac", choiceId: "j4-man"},
    ];
    for (const [i, step] of steps.entries()) {
      await submitCourseStepForUser({
        uid: "unlock-user",
        raw: {
          clientVersion: "2.0.0",
          attemptId: started.attempt.attemptId,
          activityId: step.activityId,
          idempotencyKey: `unlock_step_${i}`,
          ...("choiceId" in step ? {choiceId: step.choiceId} : {}),
          ...("numericValue" in step ? {numericValue: step.numericValue} : {}),
        },
        db,
      });
    }
    const completed = await completeCourseLessonForUser({
      uid: "unlock-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: started.attempt.attemptId,
        idempotencyKey: "unlock_complete_01",
      },
      db,
    });
    expect(completed.liveTrainingGranted).toBe(true);
    const entitlement = await db
      .doc("users/unlock-user/entitlements/liveTraining")
      .get();
    expect(entitlement.exists).toBe(true);
    expect(entitlement.data()?.unrestrictedAccess).toBe(true);
    expect(entitlement.data()?.source).toBe("section4_jump");
    expect(entitlement.data()?.grantedByLessonId).toBe(lessonId);
  });

  test("voluntary review does not restore a heart; Practice flag does", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "heart-practice-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const lessonId = "lesson-02-01-01-position-labels";
    await db.doc("users/heart-practice-user/course/main").set({
      completedLessonIds: [
        "lesson-01-06-02-section-one-jump",
        lessonId,
      ],
      livesRemaining: 2,
      livesMax: 5,
      livesNextRefillAtMs: Date.now() + 6 * 60 * 60 * 1000,
    }, {merge: true});

    const review = await startCourseLessonForUser({
      uid: "heart-practice-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId,
        startRequestId: "start_vol_review_01",
      },
      db,
    });
    expect(review.attempt.restoreHeartOnComplete).toBeUndefined();
    await submitCourseStepForUser({
      uid: "heart-practice-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: review.attempt.attemptId,
        activityId: "act-02-01-01-explain-pos",
        idempotencyKey: "vol_review_step_01",
      },
      db,
    });
    const voluntaryComplete = await completeCourseLessonForUser({
      uid: "heart-practice-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: review.attempt.attemptId,
        idempotencyKey: "vol_review_complete_01",
      },
      db,
    });
    expect(voluntaryComplete.heartsRestored).toBe(0);
    expect(voluntaryComplete.livesRemaining).toBe(2);

    const practice = await startCourseLessonForUser({
      uid: "heart-practice-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId,
        startRequestId: "start_practice_heart_01",
        restoreHeartOnComplete: true,
      },
      db,
    });
    expect(practice.attempt.restoreHeartOnComplete).toBe(true);
    await submitCourseStepForUser({
      uid: "heart-practice-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: practice.attempt.attemptId,
        activityId: "act-02-01-01-explain-pos",
        idempotencyKey: "practice_heart_step_01",
      },
      db,
    });
    const practiceComplete = await completeCourseLessonForUser({
      uid: "heart-practice-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: practice.attempt.attemptId,
        idempotencyKey: "practice_heart_complete_01",
      },
      db,
    });
    expect(practiceComplete.heartsRestored).toBe(1);
    expect(practiceComplete.livesRemaining).toBe(3);

    const profile = (
      await db.doc("users/heart-practice-user/course/main").get()
    ).data();
    expect(profile?.livesRemaining).toBe(3);
  });

  test("Practice on an open zero-heart lesson stamps the grant and can submit", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "heart-resume-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const lessonId = "lesson-01-01-01-your-two-cards";
    const started = await startCourseLessonForUser({
      uid: "heart-resume-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId,
        startRequestId: "start_first_run_01",
      },
      db,
    });
    expect(started.attempt.restoreHeartOnComplete).toBeUndefined();
    const nextHeartAt = Date.now() + 6 * 60 * 60 * 1000;
    await db.doc("users/heart-resume-user/course/main").set({
      livesRemaining: 0,
      livesMax: 5,
      livesNextRefillAtMs: nextHeartAt,
    }, {merge: true});

    const resumed = await startCourseLessonForUser({
      uid: "heart-resume-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId,
        startRequestId: "start_blocked_retry_01",
      },
      db,
    });
    expect(resumed.duplicate).toBe(true);
    expect(resumed.attempt.attemptId).toBe(started.attempt.attemptId);
    expect(resumed.attempt.restoreHeartOnComplete).toBeUndefined();
    await expect(submitCourseStepForUser({
      uid: "heart-resume-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: resumed.attempt.attemptId,
        activityId: "act-01-01-01-explain-hole-cards",
        idempotencyKey: "blocked_resume_step_01",
      },
      db,
    })).rejects.toMatchObject({
      code: "failed-precondition",
      message: expect.stringContaining("Out of hearts"),
    });

    const practice = await startCourseLessonForUser({
      uid: "heart-resume-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId,
        startRequestId: "start_practice_resume_01",
        restoreHeartOnComplete: true,
      },
      db,
    });
    expect(practice.duplicate).toBe(true);
    expect(practice.attempt.attemptId).toBe(started.attempt.attemptId);
    expect(practice.attempt.restoreHeartOnComplete).toBe(true);
    expect(practice.attempt.livesRemaining).toBe(0);

    const submitted = await submitCourseStepForUser({
      uid: "heart-resume-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: practice.attempt.attemptId,
        activityId: "act-01-01-01-explain-hole-cards",
        idempotencyKey: "practice_resume_step_01",
      },
      db,
    });
    expect(submitted.accepted).toBe(true);
    expect(submitted.livesRemaining).toBe(0);

    const stored = (
      await db.doc(
        `users/heart-resume-user/courseAttempts/${practice.attempt.attemptId}`,
      ).get()
    ).data();
    expect(stored?.restoreHeartOnComplete).toBe(true);
  });

  test("daily quest gems persist after the step submit credited the streak", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "gem-quest-user",
      raw: {clientVersion: "2.0.0", timezone: "UTC"},
      db,
    });
    const nowMs = Date.UTC(2026, 9, 9, 15, 0, 0);
    const lessonId = "lesson-01-01-01-your-two-cards";
    await db.doc("users/gem-quest-user/course/main").set({
      lastStudyLocalDate: "2026-10-09",
      currentStreak: 1,
      longestStreak: 1,
      gems: 0,
      timezone: "UTC",
    }, {merge: true});
    const attempt = {
      uid: "gem-quest-user",
      lessonId,
      catalogVersion: "2.0.0",
      status: "in_progress",
      activityIndex: 99,
      currentActivityId: "act-01-01-01-explain-hole-cards",
      livesRemaining: 5,
      livesMax: 5,
      acceptedCount: 99,
      scoredCount: 1,
      acceptedScoredCount: 1,
      masteryPoints: 1,
      masteryWeight: 1,
      jumpTestPassed: false,
      stepCount: 1,
      xpEarned: 10,
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
    };
    await db.doc("users/gem-quest-user/courseAttempts/gem-att-1").set({
      ...attempt,
      attemptId: "gem-att-1",
      startRequestId: "start_gem_01",
    });

    const completed = await completeCourseLessonForUser({
      uid: "gem-quest-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: "gem-att-1",
        idempotencyKey: "gem_complete_01",
      },
      db,
      nowMs,
    });
    expect(completed.gemsAwarded).toBe(5);
    expect(completed.gems).toBe(5);
    const profile = (
      await db.doc("users/gem-quest-user/course/main").get()
    ).data();
    expect(profile?.gems).toBe(5);
    expect(profile?.lastDailyGemLocalDate).toBe("2026-10-09");
    expect(profile?.lastStudyLocalDate).toBe("2026-10-09");

    await db.doc("users/gem-quest-user/courseAttempts/gem-att-2").set({
      ...attempt,
      attemptId: "gem-att-2",
      startRequestId: "start_gem_02",
    });
    const second = await completeCourseLessonForUser({
      uid: "gem-quest-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: "gem-att-2",
        idempotencyKey: "gem_complete_02",
      },
      db,
      nowMs,
    });
    expect(second.gemsAwarded).toBe(0);
    expect(second.gems).toBe(5);
    const after = (
      await db.doc("users/gem-quest-user/course/main").get()
    ).data();
    expect(after?.gems).toBe(5);
    expect(after?.lastDailyGemLocalDate).toBe("2026-10-09");
  });

  test("a fresh Practice start is allowed at zero hearts", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "heart-fresh-practice-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    await db.doc("users/heart-fresh-practice-user/course/main").set({
      livesRemaining: 0,
      livesMax: 5,
      livesNextRefillAtMs: Date.now() + 6 * 60 * 60 * 1000,
      resume: null,
    }, {merge: true});

    await expect(startCourseLessonForUser({
      uid: "heart-fresh-practice-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-01-01-01-your-two-cards",
        startRequestId: "start_zero_blocked_01",
      },
      db,
    })).rejects.toMatchObject({
      code: "failed-precondition",
      message: expect.stringContaining("Out of hearts"),
    });

    const practice = await startCourseLessonForUser({
      uid: "heart-fresh-practice-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: "lesson-01-01-01-your-two-cards",
        startRequestId: "start_zero_practice_01",
        restoreHeartOnComplete: true,
      },
      db,
    });
    expect(practice.duplicate).toBe(false);
    expect(practice.attempt.restoreHeartOnComplete).toBe(true);
    expect(practice.attempt.livesRemaining).toBe(0);
  });

  test("reviewing an earlier lesson does not move the progress pointer", async () => {
    await seedFlags();
    await initializeCourseProfileForUser({
      uid: "review-pointer-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    const frontierLessonId = "lesson-02-01-01-position-labels";
    const reviewLessonId = "lesson-01-01-01-your-two-cards";
    await db.doc("users/review-pointer-user/course/main").set({
      completedLessonIds: [
        "lesson-01-01-01-your-two-cards",
        "lesson-01-06-02-section-one-jump",
      ],
      currentLessonId: frontierLessonId,
      resume: {
        attemptId: "frontier-att",
        lessonId: frontierLessonId,
        activityId: "act-02-01-01-explain-pos",
        activityIndex: 0,
      },
    }, {merge: true});
    await db.doc("users/review-pointer-user/courseAttempts/frontier-att").set({
      attemptId: "frontier-att",
      uid: "review-pointer-user",
      lessonId: frontierLessonId,
      catalogVersion: "2.0.0",
      status: "in_progress",
      activityIndex: 0,
      currentActivityId: "act-02-01-01-explain-pos",
      livesRemaining: 5,
      livesMax: 5,
      startRequestId: "start_frontier_seed",
      acceptedCount: 0,
      scoredCount: 0,
      acceptedScoredCount: 0,
      masteryPoints: 0,
      masteryWeight: 0,
      jumpTestPassed: false,
      stepCount: 0,
      xpEarned: 0,
      createdAtMs: Date.now(),
      updatedAtMs: Date.now(),
      completedAtMs: null,
    });

    const reviewed = await startCourseLessonForUser({
      uid: "review-pointer-user",
      raw: {
        clientVersion: "2.0.0",
        lessonId: reviewLessonId,
        startRequestId: "start_review_pointer_01",
      },
      db,
    });
    expect(reviewed.attempt.lessonId).toBe(reviewLessonId);

    const profileAfterStart = (
      await db.doc("users/review-pointer-user/course/main").get()
    ).data();
    expect(profileAfterStart?.currentLessonId).toBe(frontierLessonId);
    expect(profileAfterStart?.resume?.attemptId).toBe("frontier-att");
    expect(profileAfterStart?.resume?.lessonId).toBe(frontierLessonId);

    await submitCourseStepForUser({
      uid: "review-pointer-user",
      raw: {
        clientVersion: "2.0.0",
        attemptId: reviewed.attempt.attemptId,
        activityId: "act-01-01-01-explain-hole-cards",
        idempotencyKey: "review_pointer_step_01",
      },
      db,
    });
    const profileAfterSubmit = (
      await db.doc("users/review-pointer-user/course/main").get()
    ).data();
    expect(profileAfterSubmit?.currentLessonId).toBe(frontierLessonId);
    expect(profileAfterSubmit?.resume?.attemptId).toBe("frontier-att");

    const state = await getCourseStateForUser({
      uid: "review-pointer-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });
    expect(state.openAttempt?.lessonId).toBe(frontierLessonId);
    expect(state.openAttempt?.attemptId).toBe("frontier-att");
  });

  test("getCourseState persists one due passive heart", async () => {
    await seedFlags();
    const now = Date.now();
    await db.doc("users/heart-accrual-user/course/main").set({
      livesRemaining: 2,
      livesMax: 5,
      livesNextRefillAtMs: now - 1000,
      gems: 10,
      timezone: "UTC",
      completedLessonIds: [],
    });

    const state = await getCourseStateForUser({
      uid: "heart-accrual-user",
      raw: {clientVersion: "2.0.0"},
      db,
    });

    const saved = (
      await db.doc("users/heart-accrual-user/course/main").get()
    ).data();
    expect(saved?.livesRemaining).toBe(3);
    expect(saved?.gems).toBe(10);
    expect(saved?.livesNextRefillAtMs).toBeGreaterThan(now);
    expect(state.profile?.livesRemaining).toBe(3);
  });

  test("getCourseState does not clobber a heart spent during accrual", async () => {
    await seedFlags();
    const now = Date.now();
    const pushedTimer = now + HEART_REFILL_INTERVAL_MS;
    await db.doc("users/heart-race-user/course/main").set({
      livesRemaining: 3,
      livesMax: 5,
      livesNextRefillAtMs: now - 1000,
      gems: 650,
      timezone: "UTC",
      completedLessonIds: [],
      heartsAdClaimsToday: 0,
    });

    const state = await getCourseStateForUser({
      uid: "heart-race-user",
      raw: {clientVersion: "2.0.0"},
      db,
      beforePassiveHeartPersist: async () => {
        // A lesson miss (or gem/ad refill) commits after the stale read
        // and before the persist. Net hearts stay 3; the ad counter advances.
        await db.doc("users/heart-race-user/course/main").set({
          livesRemaining: 3,
          livesMax: 5,
          livesNextRefillAtMs: pushedTimer,
          gems: 0,
          heartsAdClaimsToday: 1,
          heartsAdClaimsLocalDate: "2026-10-03",
          lastHeartAdClaimAtMs: now,
        }, {merge: true});
      },
    });

    const saved = (
      await db.doc("users/heart-race-user/course/main").get()
    ).data();
    expect(saved?.livesRemaining).toBe(3);
    expect(saved?.gems).toBe(0);
    expect(saved?.heartsAdClaimsToday).toBe(1);
    expect(saved?.heartsAdClaimsLocalDate).toBe("2026-10-03");
    expect(saved?.lastHeartAdClaimAtMs).toBe(now);
    expect(saved?.livesNextRefillAtMs).toBe(pushedTimer);
    expect(state.profile?.livesRemaining).toBe(3);
    expect(state.profile?.heartsAdClaimsToday).toBe(1);
  });

});
