/// Path unlock and practice selection.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/models/curriculum/learning_snapshot.dart';
import 'package:live_poker_trainer/models/curriculum/path_progress.dart';

CurriculumLesson _lesson(
  String id,
  int order, {
  List<String> objectives = const [],
}) {
  return CurriculumLesson(
    id: id,
    order: order,
    title: id,
    format: LessonFormat.concept,
    objectiveIds: objectives,
    estimatedMinutes: 5,
    mediaIds: const [],
    exerciseRefs: const [],
    simulationClaims: SimulationClaim.conceptualOnly,
    prerequisites: const [],
    remediationLessonIds: const [],
  );
}

CurriculumCatalog _catalog() {
  return CurriculumCatalog(
    catalogVersion: '1.0.0',
    minClientVersion: '1.0.0',
    sections: [
      CurriculumSection(
        id: 'early',
        order: 0,
        title: 'Early',
        summary: '',
        units: [
          CurriculumUnit(
            id: 'u0',
            order: 1,
            title: 'Unit',
            summary: '',
            objectiveIds: const ['obj-a'],
            lessons: [
              _lesson('a', 1, objectives: const ['obj-a']),
            ],
          ),
        ],
      ),
      CurriculumSection(
        id: 'pre',
        order: 3,
        title: 'Preflop',
        summary: '',
        units: [
          CurriculumUnit(
            id: 'u3',
            order: 1,
            title: 'Opens',
            summary: '',
            objectiveIds: const ['obj-b'],
            lessons: [
              _lesson('b', 1, objectives: const ['obj-b']),
            ],
          ),
        ],
      ),
    ],
    objectives: const [],
    milestoneGates: const [],
  );
}

LearningSnapshot _snapshot({
  Set<String> completed = const {},
  bool tableReadyPassed = false,
  Map<String, double> mastery = const {},
}) {
  return LearningSnapshot(
    xp: 0,
    streak: 0,
    completedLessonIds: completed,
    tableReadyCompleted: completed.contains('a') ? 1 : 0,
    tableReadyTotal: 1,
    tableReadyPassed: tableReadyPassed,
    preflopCompleted: 0,
    preflopTotal: 1,
    preflopPassed: false,
    masteryByObjectiveId: mastery,
  );
}

void main() {
  test('locks preflop until table ready, then continues in order', () {
    final catalog = _catalog();
    final fresh = _snapshot();
    expect(
      isPathLessonUnlocked(catalog: catalog, snapshot: fresh, lessonId: 'a'),
      isTrue,
    );
    expect(
      isPathLessonUnlocked(catalog: catalog, snapshot: fresh, lessonId: 'b'),
      isFalse,
    );

    final doneWithoutGate = _snapshot(completed: {'a'});
    expect(
      isPathLessonUnlocked(
        catalog: catalog,
        snapshot: doneWithoutGate,
        lessonId: 'b',
      ),
      isFalse,
    );

    final ready = _snapshot(completed: {'a'}, tableReadyPassed: true);
    expect(
      isPathLessonUnlocked(catalog: catalog, snapshot: ready, lessonId: 'b'),
      isTrue,
    );
    expect(nextPracticeLesson(catalog: catalog, snapshot: ready)?.id, 'b');
  });

  test('reviews the weakest objective after the visible path is complete', () {
    final catalog = _catalog();
    final done = _snapshot(
      completed: {'a', 'b'},
      tableReadyPassed: true,
      mastery: {'obj-a': 1, 'obj-b': 0.4},
    );
    expect(nextPracticeLesson(catalog: catalog, snapshot: done)?.id, 'b');
  });
}
