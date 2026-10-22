import 'package:live_poker_trainer/models/course/course_catalog.dart';

/// Expands [completed] with successors from [CourseCatalog.lessonSplitMap].
///
/// When a retired multi-concept lesson id is present, every listed successor
/// counts as completed so unlocks and Home nodes do not strand learners
/// after a curriculum split (LPT-83+). One pass over the map: a successor is
/// expanded further only if that id is already completed when its key is
/// visited. The published map has no such chains.
Set<String> expandCompletedLessonIds(
  Iterable<String> completed, {
  required Map<String, List<String>> lessonSplitMap,
}) {
  final out = Set<String>.from(completed);
  for (final entry in lessonSplitMap.entries) {
    if (out.contains(entry.key)) {
      out.addAll(entry.value);
    }
  }
  return out;
}

/// Resolves a possibly-retired [lessonId] to a live catalog lesson id.
///
/// Prefer the first successor that is not yet in [completed]; otherwise the
/// last successor. Returns null when unknown and not in the split map.
String? resolveSplitLessonId(
  String lessonId, {
  required Map<String, List<String>> lessonSplitMap,
  required Set<String> completed,
  required bool Function(String id) lessonExists,
}) {
  if (lessonExists(lessonId)) return lessonId;
  final successors = lessonSplitMap[lessonId];
  if (successors == null || successors.isEmpty) return null;
  for (final id in successors) {
    if (lessonExists(id) && !completed.contains(id)) return id;
  }
  final last = successors.last;
  return lessonExists(last) ? last : null;
}

/// Completed lesson ids that count for unlocks and progress.
///
/// Expands [completed] through the split map, then drops any jump test whose
/// own prerequisites are not all completed and that no completed lesson
/// builds on. Jump tests sit at the end of their section and the next
/// section's first lesson requires them, so a jump test passed as a placement
/// (Section N, before Section N's lessons) must not unlock Section N+1
/// (LPT-1032). Repeats until stable. Mirrors `effectiveCompletedLessonIds` in
/// Cloud Functions.
Set<String> placementAwareCompletedLessonIds(
  Iterable<String> completed, {
  required CourseCatalog catalog,
}) {
  final out = expandCompletedLessonIds(
    completed,
    lessonSplitMap: catalog.lessonSplitMap,
  );
  final jumpPrereqs = <String, List<String>>{};
  final dependents = <String, List<String>>{};
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        for (final prereq in lesson.prerequisites) {
          (dependents[prereq] ??= <String>[]).add(lesson.id);
        }
        if (lesson.activities.any(
          (a) => a.assessmentRole == AssessmentRole.jumpTest,
        )) {
          jumpPrereqs[lesson.id] = lesson.prerequisites;
        }
      }
    }
  }
  bool placementOnly(String id) {
    final prereqs = jumpPrereqs[id];
    if (prereqs == null) return false;
    if (prereqs.every(out.contains)) return false;
    return !(dependents[id] ?? const <String>[]).any(out.contains);
  }

  for (;;) {
    final drop = [
      for (final id in out)
        if (placementOnly(id)) id,
    ];
    if (drop.isEmpty) return out;
    out.removeAll(drop);
  }
}
