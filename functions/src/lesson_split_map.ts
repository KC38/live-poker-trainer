/**
 * Expands completed lesson ids using catalog lessonSplitMap so retired
 * multi-concept lessons unlock their successor lessons (LPT-83+).
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
