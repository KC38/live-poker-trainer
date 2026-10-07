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
        gems: 0,
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
    expect(snap.nodes[0].previewXp, previewLessonXp(1));
    expect(snap.nodes[0].previewXp, 35);
    expect(snap.nodes[1].state, CourseNodeState.locked);
    expect(snap.nodes[1].lockReason, contains('Lesson A'));
    expect(snap.nodes[1].kind, CourseNodeKind.jumpTest);
    expect(snap.nodes[1].previewXp, 35);
    expect(snap.nodes[2].kind, CourseNodeKind.handLab);
  });

  test('active attempt wins over suggesting a new available node', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        gems: 0,
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
    expect(snap.nodes[0].hasCompleted, isTrue);
    expect(snap.nodes[1].hasCompleted, isFalse);
    expect(snap.resume?.attemptId, 'att-1');
  });

  test('open attempt on an earned lesson does not move the progress pointer', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.9,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.9, 'lesson-b': 0.6},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-replay',
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
    // Reviewing lesson-b must not steal isNext from the frontier (lesson-c).
    expect(snap.nodes[1].state, CourseNodeState.completed);
    expect(snap.nodes[1].hasCompleted, isTrue);
    expect(snap.nodes[1].isNext, isFalse);
    expect(snap.nodes[0].hasCompleted, isTrue);
    expect(snap.nextLessonId, 'lesson-c');
    expect(snap.nodes[2].isNext, isTrue);
    expect(snap.resume, isNull);
  });

  test('review of an early lesson keeps next on the furthest available', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.9,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.9, 'lesson-b': 0.9},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-review-early',
        lessonId: 'lesson-a',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: 'act-a1',
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: 0,
      ),
    );
    expect(snap.nextLessonId, 'lesson-c');
    expect(snap.nodes[0].state, CourseNodeState.mastered);
    expect(snap.nodes[0].isNext, isFalse);
    expect(snap.resume, isNull);
  });

  test('review-due does not steal next from the course frontier', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.7,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.7, 'lesson-b': 0.6},
        catalogVersion: '2.0.0',
      ),
      reviewLessonIds: const ['lesson-a'],
    );
    expect(snap.nodes[0].state, CourseNodeState.reviewDue);
    // Spaced review stays openable, but pulse stays on lesson-c.
    expect(snap.nextLessonId, 'lesson-c');
    expect(snap.nodes[2].isNext, isTrue);
    expect(snap.nodes[0].isNext, isFalse);
  });

  test('review-due alone does not become next when the path is finished', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 60,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.9,
        completedLessonIds: ['lesson-a', 'lesson-b', 'lesson-c'],
        masteryByLessonId: {
          'lesson-a': 0.9,
          'lesson-b': 0.9,
          'lesson-c': 0.9,
        },
        catalogVersion: '2.0.0',
      ),
      reviewLessonIds: const ['lesson-a'],
    );
    expect(snap.nodes[0].state, CourseNodeState.reviewDue);
    expect(snap.nextLessonId, isNull);
    expect(snap.nodes.every((n) => !n.isNext), isTrue);
  });

  test('dangling profile.resume without openAttempt is not shown', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
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
        gems: 0,
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

    final nextLesson = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 0,
        gems: 0,
        currentStreak: 0,
        acceptedAccuracy: 0,
        completedLessonIds: [],
        masteryByLessonId: {},
        catalogVersion: '2.0.0',
      ),
    );
    expect(
      nextLesson.rexLine,
      'Next lesson on the path. One short lesson, then move.',
    );
    expect(nextLesson.rexLine, isNot(contains('next to act')));

    final resumed = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: paused,
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        gems: 0,
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

  test('heart restore practice never opens an unplayed next lesson', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.95,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.95, 'lesson-b': 0.9},
        catalogVersion: '2.0.0',
      ),
    );
    expect(snap.nextLessonId, 'lesson-c');
    expect(heartRestorePracticeLessonId(snap), 'lesson-b');
  });

  test('heart restore practice picks the lowest-mastery completed lesson', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.6,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.4, 'lesson-b': 0.7},
        catalogVersion: '2.0.0',
      ),
    );
    expect(snap.nextLessonId, 'lesson-c');
    expect(heartRestorePracticeLessonId(snap), 'lesson-a');
  });

  test('heart restore practice uses first-run resume when nothing is weak', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        gems: 0,
        currentStreak: 2,
        acceptedAccuracy: 0.9,
        completedLessonIds: ['lesson-a'],
        masteryByLessonId: {'lesson-a': 0.9},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-bleed',
        lessonId: 'lesson-b',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 1,
        currentActivityId: 'act-b1',
        livesRemaining: 0,
        livesMax: 5,
        acceptedCount: 0,
        scoredCount: 2,
        stepCount: 2,
      ),
    );
    expect(snap.nextLessonId, 'lesson-b');
    expect(heartRestorePracticeLessonId(snap), 'lesson-b');
  });

  test('heart restore practice prefers a weak lesson over a first-run resume', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        gems: 0,
        currentStreak: 2,
        acceptedAccuracy: 0.5,
        completedLessonIds: ['lesson-a'],
        masteryByLessonId: {'lesson-a': 0.5},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-new',
        lessonId: 'lesson-b',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: 'act-b1',
        livesRemaining: 0,
        livesMax: 5,
        acceptedCount: 0,
        scoredCount: 1,
        stepCount: 1,
      ),
    );
    expect(heartRestorePracticeLessonId(snap), 'lesson-a');
  });

  test('heart restore practice is null when accuracy is none', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 0,
        gems: 0,
        currentStreak: 0,
        acceptedAccuracy: 0,
        completedLessonIds: [],
        masteryByLessonId: {},
        catalogVersion: '2.0.0',
      ),
    );
    expect(snap.nextLessonId, 'lesson-a');
    expect(heartRestorePracticeLessonId(snap), isNull);
  });

  test('heart restore treats mastery at the threshold as strong', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: CourseProfileView(
        lifetimeXp: 20,
        gems: 0,
        currentStreak: 2,
        acceptedAccuracy: 0.9,
        completedLessonIds: const ['lesson-a'],
        masteryByLessonId: {'lesson-a': kCourseMasteryThreshold},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-bleed',
        lessonId: 'lesson-b',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 1,
        currentActivityId: 'act-b1',
        livesRemaining: 0,
        livesMax: 5,
        acceptedCount: 0,
        scoredCount: 2,
        stepCount: 2,
      ),
    );
    expect(heartRestorePracticeLessonId(snap), 'lesson-b');
  });

  test('heart restore breaks equal mastery toward the later lesson', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.4,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.4, 'lesson-b': 0.4},
        catalogVersion: '2.0.0',
      ),
    );
    expect(heartRestorePracticeLessonId(snap), 'lesson-b');
  });

  test('heart restore ignores a resume that is not on the map', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 20,
        gems: 0,
        currentStreak: 2,
        acceptedAccuracy: 0.9,
        completedLessonIds: ['lesson-a'],
        masteryByLessonId: {'lesson-a': 0.9},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-missing',
        lessonId: 'lesson-missing',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: 'act-x',
        livesRemaining: 0,
        livesMax: 5,
        acceptedCount: 0,
        scoredCount: 1,
        stepCount: 1,
      ),
    );
    expect(heartRestorePracticeLessonId(snap), 'lesson-a');
  });

  test('heart restore ignores a resume of an already completed lesson', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: _enabledFlags(),
      available: true,
      profile: const CourseProfileView(
        lifetimeXp: 40,
        gems: 0,
        currentStreak: 3,
        acceptedAccuracy: 0.95,
        completedLessonIds: ['lesson-a', 'lesson-b'],
        masteryByLessonId: {'lesson-a': 0.95, 'lesson-b': 0.9},
        catalogVersion: '2.0.0',
      ),
      openAttempt: const CourseAttemptSnapshot(
        attemptId: 'att-done',
        lessonId: 'lesson-a',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 2,
        currentActivityId: 'act-a1',
        livesRemaining: 0,
        livesMax: 5,
        acceptedCount: 1,
        scoredCount: 2,
        stepCount: 2,
      ),
    );
    expect(heartRestorePracticeLessonId(snap), 'lesson-b');
  });

  test('course profile hearts clamp and a partial resume is dropped', () {
    final empty = CourseProfileView.fromJson(<String, dynamic>{});
    expect(empty.livesRemaining, 5);
    expect(empty.livesMax, 5);
    expect(empty.gems, 0);
    expect(empty.lifetimeXp, 0);
    expect(empty.currentStreak, 0);
    expect(empty.acceptedAccuracy, 0);
    expect(empty.completedLessonIds, isEmpty);
    expect(empty.masteryByLessonId, isEmpty);
    expect(empty.resume, isNull);
    expect(empty.livesNextRefillAtMs, isNull);
    expect(empty.nextAdClaimAtMs, isNull);
    expect(empty.adClaimsRemainingToday, 5);
    expect(empty.recommendedLessonId, isNull);
    expect(empty.catalogVersion, '');

    final clamped = CourseProfileView.fromJson(<String, dynamic>{
      'livesMax': 5.8,
      'livesRemaining': 9.2,
      'gems': 12.9,
      'lifetimeXp': 40.2,
      'currentStreak': 3.4,
      'acceptedAccuracy': 0.84,
      'livesNextRefillAtMs': 1200.9,
      'nextAdClaimAtMs': 400.4,
      'adClaimsRemainingToday': 2.7,
      'catalogVersion': '2.0.0',
      'recommendedLessonId': 'lesson-c',
      'completedLessonIds': ['lesson-a', 2],
      'masteryByLessonId': <String, dynamic>{
        'lesson-a': 0.4,
        'lesson-b': null,
      },
      'resume': <String, dynamic>{
        'attemptId': 'att-1',
        'lessonId': '',
        'activityId': 'act',
        'activityIndex': 2,
      },
    });
    expect(clamped.livesMax, 5);
    expect(clamped.livesRemaining, 5);
    expect(clamped.gems, 12);
    expect(clamped.lifetimeXp, 40);
    expect(clamped.currentStreak, 3);
    expect(clamped.acceptedAccuracy, 0.84);
    expect(clamped.livesNextRefillAtMs, 1200);
    expect(clamped.nextAdClaimAtMs, 400);
    expect(clamped.adClaimsRemainingToday, 2);
    expect(clamped.recommendedLessonId, 'lesson-c');
    expect(clamped.catalogVersion, '2.0.0');
    expect(clamped.completedLessonIds, ['lesson-a', '2']);
    expect(clamped.masteryByLessonId['lesson-a'], 0.4);
    expect(clamped.masteryByLessonId['lesson-b'], 0);
    expect(clamped.resume, isNull);

    final negative = CourseProfileView.fromJson(<String, dynamic>{
      'livesMax': 8,
      'livesRemaining': -3,
    });
    expect(negative.livesMax, 8);
    expect(negative.livesRemaining, 0);

    final invalidCeiling = CourseProfileView.fromJson(<String, dynamic>{
      'livesMax': 0,
      'livesRemaining': 4,
    });
    expect(invalidCeiling.livesMax, 5);
    expect(invalidCeiling.livesRemaining, 4);

    final brokenCeiling = CourseProfileView.fromJson(<String, dynamic>{
      'livesMax': -2,
      'livesRemaining': 3.9,
    });
    expect(brokenCeiling.livesMax, 5);
    expect(brokenCeiling.livesRemaining, 3);

    final resume = CourseProfileView.fromJson(<String, dynamic>{
      'resume': <String, dynamic>{
        'attemptId': 'att-9',
        'lessonId': 'lesson-b',
        'activityIndex': 1.8,
      },
    });
    expect(resume.resume?.attemptId, 'att-9');
    expect(resume.resume?.lessonId, 'lesson-b');
    expect(resume.resume?.activityId, '');
    expect(resume.resume?.activityIndex, 1);

    final missingAttempt = CourseProfileView.fromJson(<String, dynamic>{
      'resume': <String, dynamic>{'lessonId': 'lesson-b'},
    });
    expect(missingAttempt.resume, isNull);

    final notAMap = CourseProfileView.fromJson(<String, dynamic>{
      'resume': 'att-1',
      'completedLessonIds': 'lesson-a',
      'masteryByLessonId': ['lesson-a'],
    });
    expect(notAMap.resume, isNull);
    expect(notAMap.completedLessonIds, isEmpty);
    expect(notAMap.masteryByLessonId, isEmpty);
  });
}
