/**
 * Authenticated learning: start a curated curriculum lesson attempt.
 */

import {randomUUID} from "node:crypto";
import {
  FieldValue,
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {getCurriculumCatalog, getLessonById} from "./curriculum_catalog";
import {publicQuestionsForLesson} from "./curriculum_exercises";
import type {FeatureFlagsDocReader} from "./feature_flags";
import {
  assertLearningPlatformEnabled,
  firestoreFlagReader,
  learningAttemptRef,
  learningMainRef,
  nonEmpty,
  record,
} from "./learning_common";
import type {
  CurriculumLesson,
  PublicExerciseQuestion,
} from "./curriculum_types";

export interface StartLessonResult {
  attemptId: string;
  lessonId: string;
  title: string;
  format: CurriculumLesson["format"];
  catalogVersion: string;
  questions: PublicExerciseQuestion[];
}

/** Opens a lesson attempt and returns client-safe exercise questions. */
export async function startLessonForUser(options: {
  uid: string;
  raw: unknown;
  db?: Firestore;
  readFlags?: FeatureFlagsDocReader;
}): Promise<StartLessonResult> {
  const readFlags =
    options.readFlags ??
    firestoreFlagReader(options.db ?? getFirestore());
  await assertLearningPlatformEnabled(readFlags);

  const input = record(options.raw, "request");
  const lessonId = nonEmpty(input.lessonId, "lessonId");
  const lesson = getLessonById(lessonId);
  if (!lesson) {
    throw new HttpsError("not-found", `Unknown lessonId "${lessonId}".`);
  }

  const catalog = getCurriculumCatalog();
  const questions = publicQuestionsForLesson(lesson);
  if (questions.length === 0) {
    throw new HttpsError(
      "failed-precondition",
      `Lesson "${lessonId}" has no static exercises yet.`,
    );
  }

  const db = options.db ?? getFirestore();
  const attemptId = randomUUID();
  const timezone =
    typeof input.timezone === "string" && input.timezone.trim() ?
      input.timezone.trim() :
      undefined;

  const attemptRef = learningAttemptRef(db, options.uid, attemptId);
  const mainRef = learningMainRef(db, options.uid);

  await db.runTransaction(async (tx) => {
    tx.set(attemptRef, {
      attemptId,
      lessonId: lesson.id,
      status: "started",
      catalogVersion: catalog.catalogVersion,
      format: lesson.format,
      timezone: timezone ?? null,
      startedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      mainRef,
      {
        activeAttemptId: attemptId,
        activeLessonId: lesson.id,
        catalogVersion: catalog.catalogVersion,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
  });

  return {
    attemptId,
    lessonId: lesson.id,
    title: lesson.title,
    format: lesson.format,
    catalogVersion: catalog.catalogVersion,
    questions,
  };
}
