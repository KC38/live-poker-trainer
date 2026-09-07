/// MistakeDao CRUD, repeat counting, improvement detection, and aggregates
/// against an in-memory Drift database, plus MistakeTracker end to end.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/mistake_dao.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/services/mistake_tracker.dart';

MistakePattern _riverNitRaise() => MistakePattern.derive(
      street: Street.river,
      archetype: PlayerArchetype.nit,
      taken: ExploitAction.raise,
      best: ExploitAction.call,
      mismatch: CoachMismatch.tooAggressive,
    );

MistakePattern _riverNitCall() => MistakePattern.derive(
      street: Street.river,
      archetype: PlayerArchetype.nit,
      taken: ExploitAction.call,
      best: ExploitAction.call,
      mismatch: CoachMismatch.none,
    );

MistakePattern _turnNitCall() => MistakePattern.derive(
      street: Street.turn,
      archetype: PlayerArchetype.nit,
      taken: ExploitAction.call,
      best: ExploitAction.call,
      mismatch: CoachMismatch.none,
    );

void main() {
  late AppDatabase db;
  late MistakeDao dao;
  final t0 = DateTime.utc(2026, 9, 7, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = MistakeDao(db);
  });

  tearDown(() => db.close());

  Future<RepeatInfo> record(
    MistakePattern p, {
    String session = 's1',
    String hand = 'h1',
    Duration at = Duration.zero,
    double ev = -1.5,
  }) async {
    final r = await dao.recordMistake(
      sessionId: session,
      handId: hand,
      pattern: p,
      heroAmount: 40,
      bestSizingBb: 0,
      evDeltaBb: ev,
      evDeltaDollars: ev * 2,
      adviceText: 'local line',
      now: t0.add(at),
    );
    return r.repeat;
  }

  group('recordMistake', () {
    test('persists every column and counts repeats per key and session',
        () async {
      final first = await record(_riverNitRaise());
      expect(first.totalCount, 1);
      expect(first.isRepeat, isFalse);
      expect(first.lastSeen, isNull);

      final second = await record(
        _riverNitRaise(),
        hand: 'h2',
        at: const Duration(minutes: 5),
      );
      expect(second.totalCount, 2);
      expect(second.sessionCount, 2);
      expect(second.tagTotalCount, 2);
      expect(second.isRepeat, isTrue);
      expect(second.lastSeen!.isAtSameMomentAs(t0), isTrue);

      final third = await record(
        _riverNitRaise(),
        session: 's2',
        hand: 'h9',
        at: const Duration(days: 1),
      );
      expect(third.totalCount, 3);
      expect(third.sessionCount, 1);

      final rows = await dao.allMistakes();
      expect(rows, hasLength(3));
      final row = rows.last;
      expect(row.sessionId, 's1');
      expect(row.handId, 'h1');
      expect(row.decisionId, isNull);
      expect(row.street, 'river');
      expect(row.villainArchetype, 'Nit');
      expect(row.heroAction, 'raise');
      expect(row.heroAmount, 40);
      expect(row.bestAction, 'call');
      expect(row.evDeltaBb, -1.5);
      expect(row.evDeltaDollars, -3);
      expect(row.mistakeKey, 'river:nit:raise->call');
      expect(row.contextKey, 'river:nit:call');
      expect(row.primaryTag, 'raising_into_nits');
      expect(row.coarseTagsJson, contains('raise_when_call_best'));
      expect(row.adviceText, 'local line');
    });

    test('coarse tag repeats are detected across different streets', () async {
      await record(_riverNitRaise());
      final flop = MistakePattern.derive(
        street: Street.flop,
        archetype: PlayerArchetype.nit,
        taken: ExploitAction.raise,
        best: ExploitAction.call,
        mismatch: CoachMismatch.tooAggressive,
      );
      final r = await record(flop, hand: 'h2', at: const Duration(minutes: 1));
      expect(r.totalCount, 1);
      expect(r.tagTotalCount, 2);
      expect(r.isRepeat, isTrue);
      expect(r.isExactRepeat, isFalse);
      expect(r.displayCount, 2);
    });

    test('updateAdvice replaces the stored line', () async {
      final r = await dao.recordMistake(
        sessionId: 's1',
        handId: 'h1',
        pattern: _riverNitRaise(),
        heroAmount: 0,
        bestSizingBb: 0,
        evDeltaBb: -1,
        evDeltaDollars: -2,
        adviceText: 'local',
      );
      await dao.updateAdvice(r.id, 'gemini line');
      expect((await dao.allMistakes()).single.adviceText, 'gemini line');
    });
  });

  group('findImprovement', () {
    test('ignores spots without a repeated leak', () async {
      expect(await dao.findImprovement(pattern: _riverNitCall()), isNull);
      await record(_riverNitRaise());
      expect(await dao.findImprovement(pattern: _riverNitCall()), isNull);
    });

    test('matches the exact context after two mistakes and tracks streaks',
        () async {
      await record(_riverNitRaise());
      await record(_riverNitRaise(), hand: 'h2', at: const Duration(minutes: 1));

      final first = await dao.findImprovement(pattern: _riverNitCall());
      expect(first, isNotNull);
      expect(first!.matchedKey, 'river:nit:raise->call');
      expect(first.exactContext, isTrue);
      expect(first.priorMistakes, 2);
      expect(first.lastWrongAction, ExploitAction.raise);
      expect(first.streak, 1);
      await dao.recordImprovement(
        sessionId: 's1',
        handId: 'h3',
        improvement: first,
        pattern: _riverNitCall(),
        now: t0.add(const Duration(minutes: 2)),
      );

      final second = await dao.findImprovement(pattern: _riverNitCall());
      expect(second!.streak, 2);
      await dao.recordImprovement(
        sessionId: 's1',
        handId: 'h4',
        improvement: second,
        pattern: _riverNitCall(),
        now: t0.add(const Duration(minutes: 3)),
      );

      // A fresh mistake resets the streak.
      await record(_riverNitRaise(), hand: 'h5', at: const Duration(minutes: 4));
      final third = await dao.findImprovement(pattern: _riverNitCall());
      expect(third!.streak, 1);
      expect(third.priorMistakes, 3);
    });

    test('falls back to the same archetype + best action on another street',
        () async {
      await record(_riverNitRaise());
      await record(_riverNitRaise(), hand: 'h2', at: const Duration(minutes: 1));
      final info = await dao.findImprovement(pattern: _turnNitCall());
      expect(info, isNotNull);
      expect(info!.exactContext, isFalse);
      expect(info.matchedKey, 'river:nit:raise->call');
    });
  });

  group('loadStats', () {
    test('is empty with no history', () async {
      final stats = await dao.loadStats();
      expect(stats.isEmpty, isTrue);
      expect(stats.topMistakes, isEmpty);
    });

    test('aggregates counts, trend, breakdowns, and EV lost', () async {
      await record(_riverNitRaise(), ev: -2);
      await record(
        _riverNitRaise(),
        hand: 'h2',
        at: const Duration(minutes: 1),
        ev: -1,
      );
      final station = MistakePattern.derive(
        street: Street.turn,
        archetype: PlayerArchetype.callingStation,
        taken: ExploitAction.raise,
        best: ExploitAction.call,
        mismatch: CoachMismatch.tooAggressive,
      );
      await record(station, hand: 'h3', at: const Duration(minutes: 2));

      var stats = await dao.loadStats();
      expect(stats.totalMistakes, 3);
      expect(stats.topMistakes.first.key, 'river:nit:raise->call');
      expect(stats.topMistakes.first.count, 2);
      expect(stats.topMistakes.first.trend, MistakeTrend.recurring);
      expect(stats.topMistakes.first.evLostBb, 3);
      expect(stats.topMistakes.first.title,
          'River vs Nit: raised, call was best');
      expect(stats.topMistakes.last.trend, MistakeTrend.isolated);
      expect(stats.byArchetype, {'Nit': 2, 'Calling Station': 1});
      expect(stats.byStreet, {'river': 2, 'turn': 1});
      expect(stats.byTag[MistakeTag.raisingIntoNits], 2);

      final fix = await dao.findImprovement(pattern: _riverNitCall());
      await dao.recordImprovement(
        sessionId: 's1',
        handId: 'h4',
        improvement: fix!,
        pattern: _riverNitCall(),
        now: t0.add(const Duration(minutes: 5)),
      );
      stats = await dao.loadStats();
      expect(stats.totalImprovements, 1);
      expect(stats.topMistakes.first.trend, MistakeTrend.improving);
      expect(stats.topMistakes.first.currentStreak, 1);
      expect(stats.topMistakes.first.improvements, 1);
    });

    test('clear removes everything', () async {
      await record(_riverNitRaise());
      await dao.clear();
      expect(await dao.allMistakes(), isEmpty);
    });
  });

  group('MistakeTracker', () {
    LiveCoachGrade grade(CoachVerdict verdict, ExploitAction taken) {
      return LiveCoachGrade(
        verdict: verdict,
        message: 'line',
        villainArchetype: PlayerArchetype.nit,
        villainName: 'Stan',
        street: Street.river,
        heroActionLabel: taken.label,
        mismatch: verdict == CoachVerdict.correct
            ? CoachMismatch.none
            : CoachMismatch.tooAggressive,
        optimalAction: ExploitAction.call,
        heroAction: taken,
        evDeltaBb: verdict == CoachVerdict.correct ? 0.3 : -1.2,
      );
    }

    test('records mistakes, then credits the fix once the leak repeated',
        () async {
      final tracker = MistakeTracker(dao);
      Future<LeakCheck> go(CoachVerdict v, ExploitAction a, String hand) =>
          tracker.track(
            grade: grade(v, a),
            sessionId: 's1',
            handId: hand,
            bigBlind: 2,
            heroAmount: 40,
          );

      final one = await go(CoachVerdict.incorrect, ExploitAction.raise, 'h1');
      expect(one.mistakeId, isNotNull);
      expect(one.repeat!.isRepeat, isFalse);

      final two = await go(CoachVerdict.incorrect, ExploitAction.raise, 'h2');
      expect(two.repeat!.isRepeat, isTrue);
      expect(two.repeat!.displayCount, 2);

      final fixed = await go(CoachVerdict.correct, ExploitAction.call, 'h3');
      expect(fixed.improvement, isNotNull);
      expect(fixed.improvement!.streak, 1);
      expect(fixed.mistakeId, isNull);
      expect(await dao.allImprovements(), hasLength(1));

      await tracker.saveAdvice(two.mistakeId, 'AI said so');
      final rows = await dao.allMistakes();
      final updated = rows.singleWhere((r) => r.id == two.mistakeId);
      expect(updated.adviceText, 'AI said so');
      expect(updated.evDeltaDollars, -2.4);
      expect(rows.where((r) => r.adviceText == 'line'), hasLength(1));
    });

    test('ungraded spots are ignored', () async {
      final tracker = MistakeTracker(dao);
      final res = await tracker.track(
        grade: const LiveCoachGrade(
          verdict: CoachVerdict.none,
          message: '',
          villainArchetype: PlayerArchetype.tag,
          villainName: 'V',
          street: Street.flop,
          heroActionLabel: 'CHECK',
          mismatch: CoachMismatch.none,
        ),
        sessionId: 's1',
        handId: 'h1',
        bigBlind: 2,
        heroAmount: 0,
      );
      expect(res.repeat, isNull);
      expect(res.improvement, isNull);
      expect(await dao.allMistakes(), isEmpty);
    });
  });
}
