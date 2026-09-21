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

  test("questionable answers never lose lives; clear_mistake does when eligible", async () => {
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
    const questionable = await submitCourseStepForUser({
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
    expect(questionable.lifeLost).toBe(false);
    expect(questionable.livesRemaining).toBe(3);

    // Accept guided, then questionable scaffolded (still no life loss).
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
    expect(scaffoldedQuestionable.lifeLost).toBe(false);
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
});
