/**
 * Smoke tests for learning callable validation (flags + lesson id).
 * Does not require Firestore when failing before persistence.
 */

import {describe, expect, it} from "vitest";
import {HttpsError} from "firebase-functions/v2/https";
import {completeLessonForUser} from "./complete_lesson";
import {DEFAULT_LEARNING_FEATURE_FLAGS} from "./feature_flags";
import {getLearningStateForUser} from "./get_learning_state";
import {startLessonForUser} from "./start_lesson";

const UID = "learning-smoke-user";

describe("learning callables smoke", () => {
  it("rejects when learningPlatformEnabled is false", async () => {
    const readFlags = async () => DEFAULT_LEARNING_FEATURE_FLAGS;

    await expect(
      startLessonForUser({
        uid: UID,
        raw: {lessonId: "lesson-00-01-01-cash-vs-tournaments"},
        readFlags,
      }),
    ).rejects.toMatchObject({
      code: "failed-precondition",
    });

    await expect(
      completeLessonForUser({
        uid: UID,
        raw: {
          lessonId: "lesson-00-01-01-cash-vs-tournaments",
          idempotencyKey: "idempotency-key-01",
          timezone: "UTC",
          answers: {},
        },
        readFlags,
      }),
    ).rejects.toBeInstanceOf(HttpsError);

    await expect(
      getLearningStateForUser({uid: UID, readFlags}),
    ).rejects.toMatchObject({code: "failed-precondition"});
  });

  it("rejects unknown lesson ids when the platform flag is on", async () => {
    const readFlags = async () => ({
      ...DEFAULT_LEARNING_FEATURE_FLAGS,
      learningPlatformEnabled: true,
    });

    await expect(
      startLessonForUser({
        uid: UID,
        raw: {lessonId: "lesson-does-not-exist"},
        readFlags,
      }),
    ).rejects.toMatchObject({
      code: "not-found",
    });

    await expect(
      completeLessonForUser({
        uid: UID,
        raw: {
          lessonId: "missing-lesson-xyz",
          idempotencyKey: "idempotency-key-02",
          timezone: "UTC",
          answers: {},
        },
        readFlags,
      }),
    ).rejects.toMatchObject({
      code: "not-found",
    });
  });
});
