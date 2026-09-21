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
    required this.preflopCompleted,
    required this.preflopTotal,
    required this.preflopPassed,
    required this.postflopCompleted,
    required this.postflopTotal,
    required this.postflopPassed,
    required this.dueLessonIds,
    required this.masteryByObjectiveId,
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

  /// Completed lessons in Sections 3–4.
  final int preflopCompleted;

  /// Lessons required for the preflop gate.
  final int preflopTotal;

  /// Whether Table Ready and the preflop gate are both passed.
  final bool preflopPassed;

  /// Completed lessons in Sections 5–7.
  final int postflopCompleted;

  /// Lessons required for the postflop gate.
  final int postflopTotal;

  /// Whether the Preflop gate and Postflop Core are both passed.
  final bool postflopPassed;

  /// Lessons due for spaced review or immediate remediation.
  final List<String> dueLessonIds;

  /// Best mastery by objective id, from 0 to 1.
  final Map<String, double> masteryByObjectiveId;

  /// Empty progress when the callable is unavailable.
  static const empty = LearningSnapshot(
    xp: 0,
    streak: 0,
    completedLessonIds: {},
    tableReadyCompleted: 0,
    tableReadyTotal: 39,
    tableReadyPassed: false,
    preflopCompleted: 0,
    preflopTotal: 27,
    preflopPassed: false,
    postflopCompleted: 0,
    postflopTotal: 45,
    postflopPassed: false,
    dueLessonIds: [],
    masteryByObjectiveId: {},
  );

  /// Parses a `getLearningState` response.
  factory LearningSnapshot.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'];
    final tableReady = json['tableReady'];
    final preflop = json['preflop'];
    final postflop = json['postflop'];
    final completed = <String>{};
    if (progress is Map && progress['completedLessonIds'] is List) {
      for (final id in progress['completedLessonIds'] as List) {
        completed.add(id.toString());
      }
    }
    final mastery = <String, double>{};
    if (progress is Map && progress['masteryByObjectiveId'] is Map) {
      for (final entry in (progress['masteryByObjectiveId'] as Map).entries) {
        final value = entry.value;
        if (value is num) mastery[entry.key.toString()] = value.toDouble();
      }
    }
    final due = <String>[];
    final rawDue = json['dueLessonIds'];
    if (rawDue is List) {
      for (final id in rawDue) {
        due.add(id.toString());
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
      preflopCompleted: preflop is Map ? asInt(preflop['completedCount']) : 0,
      preflopTotal: preflop is Map ? asInt(preflop['totalCount']) : 27,
      preflopPassed: preflop is Map && preflop['passed'] == true,
      postflopCompleted:
          postflop is Map ? asInt(postflop['completedCount']) : 0,
      postflopTotal: postflop is Map ? asInt(postflop['totalCount']) : 45,
      postflopPassed: postflop is Map && postflop['passed'] == true,
      dueLessonIds: List.unmodifiable(due),
      masteryByObjectiveId: Map.unmodifiable(mastery),
    );
  }
}
