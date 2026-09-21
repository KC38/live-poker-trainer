/**
 * Authenticated learning: read the server-owned learning progress snapshot.
 */

import {getFirestore, type DocumentData, type Firestore} from "firebase-admin/firestore";
import type {FeatureFlagsDocReader} from "./feature_flags";
import {getCurriculumCatalog} from "./curriculum_catalog";
import {
  emptyLearningProgress,
  evaluatePreflop,
  evaluateTableReady,
} from "./curriculum_progress";
import type {LearningProgressSnapshot} from "./curriculum_types";
import {
  assertLearningPlatformEnabled,
  firestoreFlagReader,
  learningMainRef,
} from "./learning_common";

export interface GetLearningStateResult {
  progress: LearningProgressSnapshot;
  catalogVersion: string;
  activeLessonId?: string;
  activeAttemptId?: string;
  tableReady: ReturnType<typeof evaluateTableReady>;
  preflop: ReturnType<typeof evaluatePreflop>;
}

/** Returns learning/main for the user (empty defaults when missing). */
export async function getLearningStateForUser(options: {
  uid: string;
  db?: Firestore;
  readFlags?: FeatureFlagsDocReader;
}): Promise<GetLearningStateResult> {
  const readFlags =
    options.readFlags ??
    firestoreFlagReader(options.db ?? getFirestore());
  await assertLearningPlatformEnabled(readFlags);

  const db = options.db ?? getFirestore();
  const catalog = getCurriculumCatalog();
  const snapshot = await learningMainRef(db, options.uid).get();
  const data = snapshot.data();
  const progress = progressFromDoc(data);

  return {
    progress: {
      ...progress,
      catalogVersion: progress.catalogVersion ?? catalog.catalogVersion,
    },
    catalogVersion: catalog.catalogVersion,
    activeLessonId:
      typeof data?.activeLessonId === "string" ? data.activeLessonId : undefined,
    activeAttemptId:
      typeof data?.activeAttemptId === "string" ?
        data.activeAttemptId :
        undefined,
    tableReady: evaluateTableReady(catalog, progress),
    preflop: evaluatePreflop(catalog, progress),
  };
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
