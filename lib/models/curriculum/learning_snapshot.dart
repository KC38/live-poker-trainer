/// Client view of `getLearningState`.
library;

/// Progress returned by the learning callable, with safe defaults.
class LearningSnapshot {
  /// Creates a snapshot.
  const LearningSnapshot({
    required this.xp,
    required this.streak,
    required this.completedLessonIds,
    required this.tableReadyCompleted,
    required this.tableReadyTotal,
    required this.tableReadyPassed,
  });

  /// Lifetime study XP.
  final int xp;

  /// Current study streak in days.
  final int streak;

  /// Lessons completed at least once.
  final Set<String> completedLessonIds;

  /// Completed lessons inside the Table Ready sections.
  final int tableReadyCompleted;

  /// Lessons required for Table Ready.
  final int tableReadyTotal;

  /// Whether the Table Ready gate is passed.
  final bool tableReadyPassed;

  /// Empty progress when the callable is unavailable.
  static const empty = LearningSnapshot(
    xp: 0,
    streak: 0,
    completedLessonIds: {},
    tableReadyCompleted: 0,
    tableReadyTotal: 39,
    tableReadyPassed: false,
  );

  /// Parses a `getLearningState` response.
  factory LearningSnapshot.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'];
    final tableReady = json['tableReady'];
    final completed = <String>{};
    if (progress is Map && progress['completedLessonIds'] is List) {
      for (final id in progress['completedLessonIds'] as List) {
        completed.add(id.toString());
      }
    }
    int asInt(Object? value) => value is num ? value.toInt() : 0;
    return LearningSnapshot(
      xp: progress is Map ? asInt(progress['xp']) : 0,
      streak: progress is Map ? asInt(progress['streak']) : 0,
      completedLessonIds: completed,
      tableReadyCompleted:
          tableReady is Map ? asInt(tableReady['completedCount']) : 0,
      tableReadyTotal: tableReady is Map ? asInt(tableReady['totalCount']) : 39,
      tableReadyPassed: tableReady is Map && tableReady['passed'] == true,
    );
  }
}
