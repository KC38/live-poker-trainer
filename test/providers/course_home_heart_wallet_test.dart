/// Home heart-wallet patches must not reload or corrupt the course path.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_hearts.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final intervalMs = kHeartRefillInterval.inMilliseconds;

  group('CourseHomeController heart wallet', () {
    test('a graded step clamps the wallet and keeps the path', () async {
      final futureTimer = DateTime.now().millisecondsSinceEpoch + intervalMs;
      final harness = await _mountWallet(
        _readyWallet(hearts: 3, livesNextRefillAtMs: futureTimer),
      );
      addTearDown(harness.dispose);

      harness.home.applyStepHeartWallet(
        livesRemaining: 12,
        livesMax: 5,
        livesNextRefillAtMs: futureTimer,
      );
      var snap = harness.snapshot;
      expect(snap.hearts, 5);
      expect(snap.livesMax, 5);
      expect(snap.livesNextRefillAtMs, futureTimer);
      expect(snap.gems, 40);
      expect(snap.nextLessonId, 'lesson-b');
      expect(identical(snap.nodes, harness.initial.nodes), isTrue);
      expect(harness.home.refreshes, 0);

      harness.home.applyStepHeartWallet(
        livesRemaining: -4,
        livesMax: 0,
        livesNextRefillAtMs: futureTimer,
      );
      snap = harness.snapshot;
      expect(snap.hearts, 0);
      expect(snap.livesMax, 5);
      expect(snap.livesNextRefillAtMs, futureTimer);
      expect(snap.gems, 40);
      expect(snap.adClaimsRemainingToday, 4);
      expect(harness.home.refreshes, 0);
    });

    test('a step wallet is ignored unless Home is ready', () async {
      final futureTimer = DateTime.now().millisecondsSinceEpoch + intervalMs;
      final harness = await _mountWallet(
        _readyWallet(
          hearts: 3,
          livesNextRefillAtMs: futureTimer,
          status: CourseHomeLoadStatus.error,
        ),
      );
      addTearDown(harness.dispose);

      harness.home.applyStepHeartWallet(
        livesRemaining: 1,
        livesMax: 5,
        livesNextRefillAtMs: futureTimer + 1,
      );
      expect(harness.snapshot.hearts, 3);
      expect(harness.snapshot.livesNextRefillAtMs, futureTimer);
      expect(harness.home.refreshes, 0);
    });

    test('a gem refill replaces hearts, gems, and the ad window', () async {
      final harness = await _mountWallet(
        _readyWallet(hearts: 1, livesNextRefillAtMs: 50),
      );
      addTearDown(harness.dispose);

      harness.home.applyHeartRefill(
        const RefillCourseHeartsResult(
          method: 'gems',
          livesRemaining: 5,
          livesMax: 5,
          heartsRestored: 4,
          gems: 0,
          gemsSpent: 650,
          duplicate: false,
          adClaimsRemainingToday: 3,
          nextAdClaimAtMs: 80_000,
        ),
      );

      final snap = harness.snapshot;
      expect(snap.hearts, 5);
      expect(snap.gems, 0);
      expect(snap.livesNextRefillAtMs, isNull);
      expect(snap.adClaimsRemainingToday, 3);
      expect(snap.nextAdClaimAtMs, 80_000);
      expect(snap.nextLessonId, 'lesson-b');
      expect(identical(snap.nodes, harness.initial.nodes), isTrue);
      expect(harness.home.refreshes, 0);

      harness.home.applyDuePassiveRefill(nowMs: 50);
      expect(harness.snapshot.hearts, 5);
      expect(harness.home.refreshes, 0);
    });

    test('a due passive refill grants elapsed hearts once', () async {
      const nextAt = 5_000;
      final harness = await _mountWallet(
        _readyWallet(hearts: 1, livesNextRefillAtMs: nextAt),
      );
      addTearDown(harness.dispose);

      // Two intervals have elapsed, so the next timer is a full interval ahead.
      harness.home.applyDuePassiveRefill(nowMs: nextAt + intervalMs);
      final snap = harness.snapshot;
      expect(snap.hearts, 3);
      expect(snap.livesNextRefillAtMs, nextAt + intervalMs * 2);
      expect(snap.gems, 40);
      expect(snap.nextLessonId, 'lesson-b');
      expect(identical(snap.nodes, harness.initial.nodes), isTrue);
      expect(harness.home.refreshes, 1);

      harness.home.applyDuePassiveRefill(nowMs: nextAt);
      expect(harness.snapshot.hearts, 3);
      expect(harness.home.refreshes, 1);
    });

    test(
      'the refill instant grants one heart and keeps the next timer',
      () async {
        const nextAt = 5_000;
        final harness = await _mountWallet(
          _readyWallet(hearts: 2, livesNextRefillAtMs: nextAt),
        );
        addTearDown(harness.dispose);

        harness.home.applyDuePassiveRefill(nowMs: nextAt);
        expect(harness.snapshot.hearts, 3);
        expect(
          harness.snapshot.livesNextRefillAtMs,
          nextAt + kHeartRefillInterval.inMilliseconds,
        );
        expect(harness.home.refreshes, 1);
      },
    );

    test('a timer that is not due does not grant or refresh', () async {
      final nextAt = 5_000 + intervalMs;
      final harness = await _mountWallet(
        _readyWallet(hearts: 2, livesNextRefillAtMs: nextAt),
      );
      addTearDown(harness.dispose);

      harness.home.applyDuePassiveRefill(nowMs: 5_000);
      expect(harness.snapshot.hearts, 2);
      expect(harness.snapshot.livesNextRefillAtMs, nextAt);
      expect(identical(harness.snapshot, harness.initial), isTrue);
      expect(harness.home.refreshes, 0);
    });

    test('a full wallet does not accrue or refresh', () async {
      final harness = await _mountWallet(
        _readyWallet(hearts: 5, livesNextRefillAtMs: 10),
      );
      addTearDown(harness.dispose);

      harness.home.applyDuePassiveRefill(nowMs: 10_000);
      expect(harness.snapshot.hearts, 5);
      expect(identical(harness.snapshot, harness.initial), isTrue);
      expect(harness.home.refreshes, 0);
    });
  });

  group('snapshotFromCourseState', () {
    test('review rows do not steal the frontier from the next lesson', () {
      final snap = snapshotFromCourseState(
        catalog: _catalog(),
        raw: <String, dynamic>{
          'available': true,
          'flags': _flagsJson(),
          'profile': <String, dynamic>{
            'lifetimeXp': 25,
            'gems': 10,
            'currentStreak': 1,
            'acceptedAccuracy': 1,
            'completedLessonIds': <String>['lesson-a'],
            'masteryByLessonId': <String, double>{'lesson-a': 1},
            'catalogVersion': '2.0.0',
            'livesRemaining': 9,
            'livesMax': 5,
            'recommendedLessonId': 'lesson-a',
          },
          'reviewsDue': <Object?>[
            <String, dynamic>{'lessonId': 'lesson-a'},
            <String, dynamic>{'lessonId': ''},
            <String, dynamic>{'title': 'missing id'},
            'lesson-b',
            null,
          ],
          'openAttempt': 'not-a-map',
        },
      );

      expect(snap.status, CourseHomeLoadStatus.ready);
      expect(snap.hearts, 5);
      expect(snap.livesMax, 5);
      expect(snap.nextLessonId, 'lesson-b');
      expect(snap.resume, isNull);
      expect(snap.nodes.map((node) => node.state), <CourseNodeState>[
        CourseNodeState.reviewDue,
        CourseNodeState.available,
      ]);
      expect(snap.nodes.first.isNext, isFalse);
      expect(snap.nodes.last.isNext, isTrue);
    });

    test('an open first-run attempt owns the pointer', () {
      final snap = snapshotFromCourseState(
        catalog: _catalog(),
        raw: <String, dynamic>{
          'available': true,
          'flags': _flagsJson(),
          'profile': <String, dynamic>{
            'lifetimeXp': 0,
            'gems': 0,
            'currentStreak': 0,
            'acceptedAccuracy': 0,
            'completedLessonIds': <String>['lesson-a'],
            'masteryByLessonId': <String, dynamic>{},
            'catalogVersion': '2.0.0',
            'livesRemaining': -2,
            'livesMax': 0,
          },
          'openAttempt': <String, dynamic>{
            'attemptId': 'att-b',
            'lessonId': 'lesson-b',
            'catalogVersion': '2.0.0',
            'status': 'in_progress',
            'activityIndex': 0,
            'currentActivityId': 'act-b',
            'livesRemaining': 4,
            'livesMax': 5,
            'acceptedCount': 0,
            'scoredCount': 0,
            'stepCount': 0,
          },
        },
      );

      expect(snap.hearts, 0);
      expect(snap.livesMax, 5);
      expect(snap.nextLessonId, 'lesson-b');
      expect(snap.resume?.attemptId, 'att-b');
      expect(snap.resume?.lessonId, 'lesson-b');
      expect(snap.nodes.last.state, CourseNodeState.active);
      expect(snap.nodes.last.hasCompleted, isFalse);
    });

    test('missing or non-boolean availability fails closed', () {
      final missingFlags = snapshotFromCourseState(
        catalog: _catalog(),
        raw: <String, dynamic>{'available': true},
      );
      expect(missingFlags.status, CourseHomeLoadStatus.disabled);
      expect(missingFlags.nodes, isEmpty);

      final stringAvailable = snapshotFromCourseState(
        catalog: _catalog(),
        raw: <String, dynamic>{'available': 'true', 'flags': _flagsJson()},
      );
      expect(stringAvailable.status, CourseHomeLoadStatus.disabled);
      expect(stringAvailable.nodes, isEmpty);
    });
  });
}

class _WalletHarness {
  _WalletHarness({
    required this.container,
    required this.home,
    required this.initial,
  });

  final ProviderContainer container;
  final _WalletHome home;
  final CourseHomeSnapshot initial;

  CourseHomeSnapshot get snapshot =>
      container.read(courseHomeProvider).requireValue;

  void dispose() => container.dispose();
}

class _WalletHome extends CourseHomeController {
  _WalletHome(this.initial);

  final CourseHomeSnapshot initial;
  int refreshes = 0;

  @override
  Future<CourseHomeSnapshot> build() async => initial;

  @override
  Future<void> refresh() async {
    refreshes += 1;
  }
}

Future<_WalletHarness> _mountWallet(CourseHomeSnapshot initial) async {
  final home = _WalletHome(initial);
  final container = ProviderContainer(
    overrides: [courseHomeProvider.overrideWith(() => home)],
  );
  await container.read(courseHomeProvider.future);
  return _WalletHarness(container: container, home: home, initial: initial);
}

CourseHomeSnapshot _readyWallet({
  required int hearts,
  int? livesNextRefillAtMs,
  CourseHomeLoadStatus status = CourseHomeLoadStatus.ready,
}) {
  return CourseHomeSnapshot(
    status: status,
    nodes: <CourseMapNode>[
      const CourseMapNode(
        lessonId: 'lesson-b',
        title: 'Lesson B',
        summary: 'Next',
        kind: CourseNodeKind.lesson,
        state: CourseNodeState.available,
        sectionId: 'sec-1',
        sectionTitle: 'Section',
        unitId: 'unit-1',
        unitTitle: 'Unit',
        isNext: true,
      ),
    ],
    sections: const <CourseSection>[],
    gems: 40,
    hearts: hearts,
    livesMax: 5,
    livesNextRefillAtMs: livesNextRefillAtMs,
    adClaimsRemainingToday: 4,
    nextLessonId: 'lesson-b',
  );
}

CourseCatalog _catalog() {
  const activity = CourseActivity(
    id: 'act-a',
    order: 1,
    stage: ActivityStage.explain,
    renderer: ActivityRenderer.coachDialogue,
    estimatedSeconds: 30,
    accessibilityText: 'Explain',
    acceptedGrades: <SoftGrade>[SoftGrade.recommended],
  );
  return CourseCatalog(
    catalogVersion: '2.0.0',
    minClientVersion: '2.0.0',
    scope: 'live_cash_nlh',
    coachId: 'rex',
    contentChecksum: 'test',
    playerTypes: const <CoursePlayerType>[],
    sections: <CourseSection>[
      CourseSection(
        id: 'sec-1',
        order: 1,
        title: 'Section',
        summary: 'Basics',
        experienceBand: 'never_played',
        units: <CourseUnit>[
          CourseUnit(
            id: 'unit-1',
            order: 1,
            title: 'Unit',
            summary: 'Start',
            lessons: <CourseLesson>[
              CourseLesson(
                id: 'lesson-a',
                order: 1,
                title: 'Lesson A',
                summary: 'First',
                objectives: const <String>['a'],
                prerequisites: const <String>[],
                remediationLessonIds: const <String>[],
                estimatedMinutes: 5,
                difficultyBand: 1,
                playerTypeRefs: const <CoursePlayerTypeId>[],
                introducesPlayerTypes: const <CoursePlayerTypeId>[],
                activities: const <CourseActivity>[activity],
              ),
              CourseLesson(
                id: 'lesson-b',
                order: 2,
                title: 'Lesson B',
                summary: 'Second',
                objectives: const <String>['b'],
                prerequisites: const <String>['lesson-a'],
                remediationLessonIds: const <String>[],
                estimatedMinutes: 5,
                difficultyBand: 1,
                playerTypeRefs: const <CoursePlayerTypeId>[],
                introducesPlayerTypes: const <CoursePlayerTypeId>[],
                activities: const <CourseActivity>[
                  CourseActivity(
                    id: 'act-b',
                    order: 1,
                    stage: ActivityStage.explain,
                    renderer: ActivityRenderer.coachDialogue,
                    estimatedSeconds: 30,
                    accessibilityText: 'Explain',
                    acceptedGrades: <SoftGrade>[SoftGrade.recommended],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Map<String, dynamic> _flagsJson() {
  return <String, dynamic>{
    'courseEnabled': true,
    'courseStartsEnabled': true,
    'guestCourseEnabled': true,
    'placementTestsEnabled': true,
    'catalogVersion': '2.0.0',
    'minimumClientVersion': '2.0.0',
  };
}
