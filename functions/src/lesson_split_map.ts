/**
 * Expands completed lesson ids using catalog lessonSplitMap so retired
 * multi-concept lessons unlock their successor lessons (LPT-83+).
 *
 * One level only: a successor that is itself retired is not expanded again.
 * Callers that decide "already finished" (prereqs, review XP, resume, zero
 * hearts) must use [hasCompletedLessonId], not a raw includes() on the
 * stored array — successors are not written back onto the profile.
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
 * True when [lessonId] is stored as completed, or a retired parent in
 * [completed] lists it as a successor.
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
