/// Unit tests for client-side passive heart accrual.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_hearts.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';

void main() {
  group('applyPassiveHeartRefill', () {
    test('restores multiple elapsed intervals and clears timer when full', () {
      final result = applyPassiveHeartRefill(
        livesRemaining: 3,
        livesMax: 5,
        livesNextRefillAtMs: 1_000,
        nowMs: 1_000 + kHeartRefillInterval.inMilliseconds * 2 + 1,
      );
      expect(result.livesRemaining, 5);
      expect(result.livesNextRefillAtMs, isNull);
      expect(result.heartsRestored, 2);
      expect(result.changed, isTrue);
    });

    test('starts a timer when below max with no next refill', () {
      final result = applyPassiveHeartRefill(
        livesRemaining: 4,
        livesMax: 5,
        livesNextRefillAtMs: null,
        nowMs: 5_000,
      );
      expect(result.livesRemaining, 4);
      expect(
        result.livesNextRefillAtMs,
        5_000 + kHeartRefillInterval.inMilliseconds,
      );
      expect(result.heartsRestored, 0);
      expect(result.changed, isTrue);
    });

    test('clears timer when already full', () {
      final result = applyPassiveHeartRefill(
        livesRemaining: 5,
        livesMax: 5,
        livesNextRefillAtMs: 99,
        nowMs: 0,
      );
      expect(result.livesRemaining, 5);
      expect(result.livesNextRefillAtMs, isNull);
      expect(result.heartsRestored, 0);
      expect(result.changed, isTrue);
    });

    test('does not restore before the scheduled instant', () {
      final result = applyPassiveHeartRefill(
        livesRemaining: 3,
        livesMax: 5,
        livesNextRefillAtMs: 1000,
        nowMs: 999,
      );
      expect(result.livesRemaining, 3);
      expect(result.heartsRestored, 0);
      expect(result.livesNextRefillAtMs, 1000);
      expect(result.changed, isFalse);
    });

    test(
      'restores one heart per crossed interval and keeps the next timer ahead',
      () {
        final interval = kHeartRefillInterval.inMilliseconds;
        final result = applyPassiveHeartRefill(
          livesRemaining: 0,
          livesMax: 5,
          livesNextRefillAtMs: 1000,
          nowMs: 1000 + interval * 2 - 1,
        );
        expect(result.heartsRestored, 2);
        expect(result.livesRemaining, 2);
        expect(result.livesNextRefillAtMs, 1000 + interval * 2);
        expect(result.changed, isTrue);
      },
    );

    test('replaces a non-positive ceiling and clamps a negative count', () {
      for (final max in <int>[0, -1]) {
        final result = applyPassiveHeartRefill(
          livesRemaining: -2,
          livesMax: max,
          livesNextRefillAtMs: null,
          nowMs: 20,
        );
        expect(result.livesMax, kDefaultLessonLives);
        expect(result.livesRemaining, 0);
        expect(
          result.livesNextRefillAtMs,
          20 + kHeartRefillInterval.inMilliseconds,
        );
        expect(result.heartsRestored, 0);
        expect(result.changed, isTrue);
      }
    });

    test('clamps a count above the ceiling and clears the timer', () {
      final result = applyPassiveHeartRefill(
        livesRemaining: 9,
        livesMax: 5,
        livesNextRefillAtMs: 40,
        nowMs: 0,
      );
      expect(result.livesRemaining, 5);
      expect(result.livesNextRefillAtMs, isNull);
      expect(result.heartsRestored, 0);
      expect(result.changed, isTrue);
    });

    test('reports unchanged when already full with no timer', () {
      final result = applyPassiveHeartRefill(
        livesRemaining: 5,
        livesMax: 5,
        livesNextRefillAtMs: null,
        nowMs: 0,
      );
      expect(result.changed, isFalse);
      expect(result.heartsRestored, 0);
      expect(result.livesNextRefillAtMs, isNull);
    });
  });

  group('CourseHomeSnapshot.withHeartState', () {
    test('updates hearts without touching the course path', () {
      const base = CourseHomeSnapshot(
        status: CourseHomeLoadStatus.ready,
        nodes: [],
        sections: [],
        hearts: 2,
        livesMax: 5,
        gems: 100,
        nextLessonId: 'lesson-a',
      );
      final next = base.withHeartState(
        hearts: 5,
        livesMax: 5,
        gems: 0,
        livesNextRefillAtMs: null,
        adClaimsRemainingToday: 4,
      );
      expect(next.hearts, 5);
      expect(next.gems, 0);
      expect(next.nextLessonId, 'lesson-a');
      expect(next.status, CourseHomeLoadStatus.ready);
      expect(identical(next.nodes, base.nodes), isTrue);
    });
  });
}
