/**
 * Authenticated learning: complete a lesson with idempotent grading.
 */

import {
  FieldValue,
  getFirestore,
  type DocumentData,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {getCurriculumCatalog, getLessonById} from "./curriculum_catalog";
import {
  applyLessonCompletion,
  emptyLearningProgress,
  scoreStaticAnswers,
  type StaticAnswerScore,
} from "./curriculum_progress";
import type {FeatureFlagsDocReader} from "./feature_flags";
import type {LearningProgressSnapshot} from "./curriculum_types";
import {
  assertLearningPlatformEnabled,
  firestoreFlagReader,
  learningAttemptRef,
  learningMainRef,
  nonEmpty,
  record,
  safeIdempotencyKey,
} from "./learning_common";

export interface CompleteLessonResult {
  attemptId: string;
  lessonId: string;
  alreadyCompleted: boolean;
  score: StaticAnswerScore;
  progress: LearningProgressSnapshot;
}

/** Grades answers, updates XP/streak/mastery, and stores an attempt receipt. */
export async function completeLessonForUser(options: {
  uid: string;
  raw: unknown;
  db?: Firestore;
  readFlags?: FeatureFlagsDocReader;
  now?: Date;
}): Promise<CompleteLessonResult> {
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

  const idempotencyKey = safeIdempotencyKey(
    input.idempotencyKey,
    "idempotencyKey",
  );
  const timezone = nonEmpty(input.timezone, "timezone");
  const now = options.now ?? new Date();
  const catalog = getCurriculumCatalog();

  let score: StaticAnswerScore;
  try {
    score = scoreStaticAnswers(lesson, input.answers);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new HttpsError("invalid-argument", message);
  }

  const db = options.db ?? getFirestore();
  const attemptRef = learningAttemptRef(db, options.uid, idempotencyKey);
  const mainRef = learningMainRef(db, options.uid);

  return db.runTransaction(async (tx) => {
    const [attemptSnap, mainSnap] = await Promise.all([
      tx.get(attemptRef),
      tx.get(mainRef),
    ]);

    const existing = attemptSnap.data();
    if (
      attemptSnap.exists &&
      existing?.status === "completed" &&
      existing.lessonId === lesson.id
    ) {
      return {
        attemptId: idempotencyKey,
        lessonId: lesson.id,
        alreadyCompleted: true,
        score: existing.score as StaticAnswerScore,
        progress: progressFromDoc(mainSnap.data()),
      };
    }
    if (
      attemptSnap.exists &&
      existing?.status === "completed" &&
      existing.lessonId !== lesson.id
    ) {
      throw new HttpsError(
        "already-exists",
        "idempotencyKey was reused for another lesson.",
      );
    }

    const prior = progressFromDoc(mainSnap.data());
    let next: LearningProgressSnapshot;
    try {
      next = applyLessonCompletion({
        progress: {
          ...prior,
          catalogVersion: catalog.catalogVersion,
        },
        lesson,
        score: score.score,
        now,
        timezone,
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new HttpsError("invalid-argument", message);
    }

    tx.set(
      mainRef,
      {
        xp: next.xp,
        streak: next.streak,
        lastStudyDay: next.lastStudyDay ?? null,
        masteryByObjectiveId: next.masteryByObjectiveId,
        completedLessonIds: next.completedLessonIds ?? [],
        reviewDueByLessonId: next.reviewDueByLessonId ?? {},
        catalogVersion: catalog.catalogVersion,
        activeAttemptId: FieldValue.delete(),
        activeLessonId: FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
        updatedAtMs: next.updatedAtMs ?? now.getTime(),
      },
      {merge: true},
    );
    tx.set(attemptRef, {
      attemptId: idempotencyKey,
      lessonId: lesson.id,
      status: "completed",
      catalogVersion: catalog.catalogVersion,
      timezone,
      score,
      xpAwarded: next.xp - prior.xp,
      startedAttemptId:
        typeof input.attemptId === "string" ? input.attemptId : null,
      completedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {
      attemptId: idempotencyKey,
      lessonId: lesson.id,
      alreadyCompleted: false,
      score,
      progress: {
        ...next,
        catalogVersion: catalog.catalogVersion,
      },
    };
  });
}

function progressFromDoc(
  data: DocumentData | undefined,
): LearningProgressSnapshot {
  if (!data) return emptyLearningProgress();
  const masteryRaw = data.masteryByObjectiveId;
  const masteryByObjectiveId: Record<string, number> = {};
  if (masteryRaw && typeof masteryRaw === "object" && !Array.isArray(masteryRaw)) {
    for (const [key, value] of Object.entries(
      masteryRaw as Record<string, unknown>,
    )) {
      if (typeof value === "number" && Number.isFinite(value)) {
        masteryByObjectiveId[key] = value;
      }
    }
  }
  const completedLessonIds = Array.isArray(data.completedLessonIds) ?
    data.completedLessonIds.filter(
      (id): id is string => typeof id === "string",
    ) :
    [];
  return {
    xp: typeof data.xp === "number" ? data.xp : 0,
    streak: typeof data.streak === "number" ? data.streak : 0,
    lastStudyDay:
      typeof data.lastStudyDay === "string" ? data.lastStudyDay : undefined,
    masteryByObjectiveId,
    completedLessonIds,
    catalogVersion:
      typeof data.catalogVersion === "string" ? data.catalogVersion : undefined,
    updatedAtMs:
      typeof data.updatedAtMs === "number" ? data.updatedAtMs : undefined,
  };
}
