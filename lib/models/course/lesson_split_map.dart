import 'package:live_poker_trainer/models/course/course_catalog.dart';

/// Expands [completed] with successors from [CourseCatalog.lessonSplitMap].
///
/// When a retired multi-concept lesson id is present, every successor lesson
/// id counts as completed so unlocks and Home nodes do not strand learners
/// after a curriculum split (LPT-83+).
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
