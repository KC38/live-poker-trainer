/// Pure Home map derivation: locks, next node, resume priority.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

CourseCatalog _miniCatalog() {
  return CourseCatalog.fromJson({
    'catalogVersion': '2.0.0',
    'minClientVersion': '2.0.0',
    'scope': 'live_cash_nlh',
    'coachId': 'rex',
    'contentChecksum': 'test',
    'playerTypes': <Map<String, dynamic>>[],
    'sections': [
      {
        'id': 'sec-1',
        'order': 1,
        'title': 'Section One',
        'summary': 'Basics',
        'experienceBand': 'never_played',
        'units': [
          {
            'id': 'unit-1',
            'order': 1,
            'title': 'Unit One',
            'summary': 'Start',
            'lessons': [
              {
                'id': 'lesson-a',
                'order': 1,
                'title': 'Lesson A',
                'summary': 'First',
                'objectives': <String>['a'],
                'prerequisites': <String>[],
                'remediationLessonIds': <String>[],
                'estimatedMinutes': 5,
                'difficultyBand': 1,
                'playerTypeRefs': <String>[],
                'introducesPlayerTypes': <String>[],
                'activities': [
                  {
                    'id': 'act-a1',
                    'order': 1,
                    'stage': 'explain',
                    'renderer': 'coach_dialogue',
                    'estimatedSeconds': 30,
                    'accessibilityText': 'Explain',
                    'acceptedGrades': ['recommended'],
                    'objectives': <String>['a'],
                    'coachMedia': [
                      {'id': 'm1', 'kind': 'dialogue', 'text': 'Hello'},
                    ],
                  },
                ],
              },
              {
                'id': 'lesson-b',
                'order': 2,
                'title': 'Lesson B',
                'summary': 'Second',
                'objectives': <String>['b'],
                'prerequisites': <String>['lesson-a'],
                'remediationLessonIds': <String>[],
                'estimatedMinutes': 5,
                'difficultyBand': 1,
                'playerTypeRefs': <String>[],
                'introducesPlayerTypes': <String>[],
                'activities': [
                  {
                    'id': 'act-b1',
                    'order': 1,
                    'stage': 'jump_test',
                    'renderer': 'select_identify',
                    'estimatedSeconds': 30,
                    'accessibilityText': 'Jump',
                    'acceptedGrades': ['recommended'],
                    'objectives': <String>['b'],
                    'choices': [
                      {'id': 'c1', 'label': 'One'},
                    ],
                  },
                ],
              },
              {
                'id': 'lesson-c',
                'order': 3,
                'title': 'Hand lab C',
                'summary': 'Lab',
                'objectives': <String>['c'],
                'prerequisites': <String>['lesson-b'],
                'remediationLessonIds': <String>[],
                'estimatedMinutes': 8,
                'difficultyBand': 2,
                'playerTypeRefs': <String>[],
                'introducesPlayerTypes': <String>[],
                'activities': [
                  {
                    'id': 'act-c1',
                    'order': 1,
                    'stage': 'unguided',
                    'renderer': 'full_table_hand_lab',
                    'estimatedSeconds': 60,
                    'accessibilityText': 'Lab',
                    'acceptedGrades': ['recommended'],
                    'objectives': <String>['c'],
                    'handLabSpecId': 'lab-c',
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  });
}

CourseFlags _enabledFlags() => const CourseFlags(
  courseEnabled: true,
  courseStartsEnabled: true,
  guestCourseEnabled: true,
  placementTestsEnabled: true,
  catalogVersion: '2.0.0',
  minimumClientVersion: '2.0.0',
);

void main() {
  final catalog = _miniCatalog();

  test('fresh profile unlocks only the first lesson as next', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 0,
        currentStreak: 0,
        acceptedAccuracy: 0,
        completedLessonIds: [],
        masteryByLessonId: {},
        catalogVersion: '2.0.0',
      ),
    );
    expect(snap.status, CourseHomeLoadStatus.ready);
    expect(snap.nextLessonId, 'lesson-a');
    expect(snap.nodes[0].state, CourseNodeState.available);
    expect(snap.nodes[0].isNext, isTrue);
    expect(snap.nodes[1].state, CourseNodeState.locked);
    expect(snap.nodes[1].lockReason, contains('Lesson A'));
    expect(snap.nodes[1].kind, CourseNodeKind.jumpTest);
    expect(snap.nodes[2].kind, CourseNodeKind.handLab);
  });

  test('active attempt wins over suggesting a new available node', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        currentStreak: 2,
        acceptedAccuracy: 0.8,
        completedLessonIds: ['lesson-a'],
        masteryByLessonId: {'lesson-a': 0.9},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-1',
        lessonId: 'lesson-b',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: 'act-b1',
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: 0,
      ),
    );
    expect(snap.nextLessonId, 'lesson-b');
    expect(snap.nodes[1].state, CourseNodeState.active);
    expect(snap.nodes[1].isNext, isTrue);
    expect(snap.nodes[0].state, CourseNodeState.mastered);
    expect(snap.resume?.attemptId, 'att-1');
  });

  test('review-due nodes are preferred next after active clears', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        currentStreak: 3,
        acceptedAccuracy: 0.7,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.7, 'lesson-b': 0.6},
        catalogVersion: '2.0.0',
      ),
      reviewLessonIds: const ['lesson-a'],
    );
    expect(snap.nodes[0].state, CourseNodeState.reviewDue);
    expect(snap.nextLessonId, 'lesson-a');
  });

  test('dangling profile.resume without openAttempt is not shown', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        currentStreak: 3,
        acceptedAccuracy: 0.9,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.9, 'lesson-b': 0.9},
        catalogVersion: '2.0.0',
        resume: CourseResumePointer(
          attemptId: 'stale-att',
          lessonId: 'lesson-b',
          activityId: 'act-b-last',
          activityIndex: 4,
        ),
        recommendedLessonId: 'lesson-c',
      ),
    );
    expect(snap.resume, isNull);
    expect(snap.nodes[1].state, isNot(CourseNodeState.active));
    expect(snap.nextLessonId, 'lesson-c');
  });

  test('disabled and stale catalog statuses are recoverable messages', () {
    final disabled = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: CourseFlags.disabled(catalogVersion: '2.0.0'),
      available: false,
    );
    expect(disabled.status, CourseHomeLoadStatus.disabled);

    final stale = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: const CourseFlags(
        courseEnabled: true,
        courseStartsEnabled: true,
        guestCourseEnabled: true,
        placementTestsEnabled: true,
        catalogVersion: '9.9.9',
        minimumClientVersion: '2.0.0',
      ),
      available: true,
    );
    expect(stale.status, CourseHomeLoadStatus.staleCatalog);
  });

  test('paused starts are not a startable path but keep an open attempt', () {
    const paused = CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: false,
      guestCourseEnabled: true,
      placementTestsEnabled: true,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    final fresh = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: paused,
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 0,
        currentStreak: 0,
        acceptedAccuracy: 0,
        completedLessonIds: [],
        masteryByLessonId: {},
        catalogVersion: '2.0.0',
      ),
    );
    expect(fresh.status, CourseHomeLoadStatus.ready);
    expect(fresh.startsEnabled, isFalse);
    expect(fresh.nextLessonId, isNull);
    expect(fresh.nodes[0].state, CourseNodeState.locked);
    expect(fresh.nodes[0].lockReason, contains('paused'));
    expect(fresh.rexLine, contains('paused'));

    final resumed = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: paused,
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        currentStreak: 2,
        acceptedAccuracy: 0.8,
        completedLessonIds: ['lesson-a'],
        masteryByLessonId: {'lesson-a': 0.9},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-1',
        lessonId: 'lesson-b',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: 'act-b1',
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: 0,
      ),
    );
    expect(resumed.startsEnabled, isFalse);
    expect(resumed.nextLessonId, 'lesson-b');
    expect(resumed.nodes[0].state, CourseNodeState.mastered);
    expect(resumed.nodes[1].state, CourseNodeState.active);
    expect(resumed.resume?.attemptId, 'att-1');
    expect(resumed.nodes[2].state, CourseNodeState.locked);
    expect(resumed.nodes[2].lockReason, contains('paused'));
  });
}
