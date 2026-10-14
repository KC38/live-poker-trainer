/**
 * Retired multi-concept lesson ids (LPT-83+).
 *
 * Completing a retired id counts as completing each listed successor, so
 * Home, startLesson prerequisites, review XP, zero-heart replay, and resume
 * protection do not strand learners after a split. Successors are not written
 * back onto the profile. Callers that decide "already finished" must use
 * `hasCompletedLessonId`, not a raw includes() on the stored array.
 *
 * A start request for a retired id opens the first successor still in the
 * catalog (`resolveLiveLessonId`).
 *
 * Expansion is one Object.entries pass. A successor is expanded further only
 * when that id is already in the set at the moment its key is visited, so
 * key order matters if a successor is itself a retired id. The published map
 * has no such chains; do not add a second pass without a product decision.
 */
export function expandCompletedLessonIds(
  completed: readonly string[],
  lessonSplitMap: Record<string, readonly string[]> | undefined | null,
): string[] {
  const out = new Set(completed.map(String));
  if (lessonSplitMap && typeof lessonSplitMap === "object") {
    for (const [retired, successors] of Object.entries(lessonSplitMap)) {
      if (out.has(retired) && Array.isArray(successors)) {
        for (const id of successors) out.add(String(id));
      }
    }
  }
  return [...out];
}

/**
 * True when `lessonId` is stored as completed, or a retired parent in
 * `completed` lists it as a successor.
 *
 * Home and startLesson already expand. Submit, complete, and getCourseState
 * must use this too: a raw includes() treats the successor as a first run,
 * overwrites the frontier resume, grants full XP, and blocks zero-heart
 * replay.
 */
export function hasCompletedLessonId(
  completed: readonly string[],
  lessonId: string,
  lessonSplitMap: Record<string, readonly string[]> | undefined | null,
): boolean {
  return expandCompletedLessonIds(completed, lessonSplitMap).includes(lessonId);
}

/**
 * Maps a start request onto a published lesson id.
 *
 * A live id is returned unchanged. A retired id opens the first successor
 * for which `lessonExists` is true, skipping successors that were removed.
 * Returns null when nothing in the catalog matches, so the caller can
 * reject the start.
 */
export function resolveLiveLessonId(
  requestedLessonId: string,
  lessonExists: (id: string) => boolean,
  lessonSplitMap: Record<string, readonly string[]> | undefined | null,
): string | null {
  if (lessonExists(requestedLessonId)) return requestedLessonId;
  const successors = lessonSplitMap?.[requestedLessonId];
  if (!Array.isArray(successors)) return null;
  for (const successor of successors) {
    if (lessonExists(successor)) return successor;
  }
  return null;
}
