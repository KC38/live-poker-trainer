/// Mistake key / coarse tag derivation and LiveCoachGrade.pattern.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

void main() {
  group('MistakePattern.derive', () {
    test('builds the fine key, context keys, and archetype-specific tag', () {
      final p = MistakePattern.derive(
        street: Street.river,
        archetype: PlayerArchetype.nit,
        taken: ExploitAction.raise,
        best: ExploitAction.call,
        mismatch: CoachMismatch.tooAggressive,
      );
      expect(p.key, 'river:nit:raise->call');
      expect(p.contextKey, 'river:nit:call');
      expect(p.coarseContextKey, 'nit:call');
      expect(p.primaryTag, MistakeTag.raisingIntoNits);
      expect(p.tags, contains(MistakeTag.raiseWhenCallBest));
    });

    test('tags the classic station / maniac leaks by name', () {
      final bluff = MistakePattern.deriveTags(
        archetype: PlayerArchetype.callingStation,
        taken: ExploitAction.raise,
        best: ExploitAction.call,
        mismatch: CoachMismatch.tooAggressive,
      );
      expect(bluff.first, MistakeTag.overbluffingStations);

      final value = MistakePattern.deriveTags(
        archetype: PlayerArchetype.callingStation,
        taken: ExploitAction.check,
        best: ExploitAction.raise,
        mismatch: CoachMismatch.tooPassive,
      );
      expect(value, [
        MistakeTag.notValueBettingStations,
        MistakeTag.checkWhenBetBest,
      ]);

      final fold = MistakePattern.deriveTags(
        archetype: PlayerArchetype.maniac,
        taken: ExploitAction.fold,
        best: ExploitAction.call,
        mismatch: CoachMismatch.tooTight,
      );
      expect(fold, [
        MistakeTag.foldingTooMuchVsAggro,
        MistakeTag.foldWhenCallBest,
      ]);

      final payoff = MistakePattern.deriveTags(
        archetype: PlayerArchetype.nit,
        taken: ExploitAction.call,
        best: ExploitAction.fold,
        mismatch: CoachMismatch.tooLoose,
      );
      expect(payoff.first, MistakeTag.payingOffNits);
    });

    test('falls back to a generic action-shape tag for TAGs', () {
      final tags = MistakePattern.deriveTags(
        archetype: PlayerArchetype.tag,
        taken: ExploitAction.call,
        best: ExploitAction.fold,
        mismatch: CoachMismatch.tooLoose,
      );
      expect(tags, [MistakeTag.callWhenFoldBest]);
    });

    test('sizing misses carry direction in the key and tag', () {
      final small = MistakePattern.derive(
        street: Street.turn,
        archetype: PlayerArchetype.callingStation,
        taken: ExploitAction.raise,
        best: ExploitAction.raise,
        mismatch: CoachMismatch.sizing,
        heroSizingBb: 3,
        bestSizingBb: 9,
      );
      expect(small.key, 'turn:station:raise->raise:small');
      expect(small.primaryTag, MistakeTag.underSizingVsStations);
      expect(small.tags.last, MistakeTag.sizingTooSmall);

      final large = MistakePattern.derive(
        street: Street.flop,
        archetype: PlayerArchetype.tag,
        taken: ExploitAction.raise,
        best: ExploitAction.raise,
        mismatch: CoachMismatch.sizing,
        heroSizingBb: 20,
        bestSizingBb: 6,
      );
      expect(large.key, 'flop:tag:raise->raise:large');
      expect(large.tags, [MistakeTag.sizingTooLarge]);
    });

    test('correct decisions still expose a context key', () {
      final p = MistakePattern.derive(
        street: Street.river,
        archetype: PlayerArchetype.nit,
        taken: ExploitAction.call,
        best: ExploitAction.call,
        mismatch: CoachMismatch.none,
      );
      expect(p.contextKey, 'river:nit:call');
      expect(p.tags, [MistakeTag.other]);
    });

    test('tag ids round-trip and unknown ids map to other', () {
      for (final tag in MistakeTag.values) {
        expect(MistakeTag.fromId(tag.id), tag);
      }
      expect(MistakeTag.fromId('nope'), MistakeTag.other);
    });
  });

  group('LiveCoachGrade.pattern', () {
    test('is null for ungraded spots and populated for graded ones', () {
      const ungraded = LiveCoachGrade(
        verdict: CoachVerdict.none,
        message: '',
        villainArchetype: PlayerArchetype.tag,
        villainName: 'V',
        street: Street.flop,
        heroActionLabel: 'CHECK',
        mismatch: CoachMismatch.none,
      );
      expect(ungraded.pattern, isNull);

      const graded = LiveCoachGrade(
        verdict: CoachVerdict.incorrect,
        message: '',
        villainArchetype: PlayerArchetype.nit,
        villainName: 'Stan',
        street: Street.river,
        heroActionLabel: 'RAISE',
        mismatch: CoachMismatch.tooAggressive,
        optimalAction: ExploitAction.call,
        heroAction: ExploitAction.raise,
      );
      expect(graded.pattern?.key, 'river:nit:raise->call');
    });
  });

  group('RepeatInfo', () {
    MistakePattern pattern() => MistakePattern.derive(
          street: Street.river,
          archetype: PlayerArchetype.nit,
          taken: ExploitAction.raise,
          best: ExploitAction.call,
          mismatch: CoachMismatch.tooAggressive,
        );

    test('first occurrence is not a repeat', () {
      final r = RepeatInfo(
        pattern: pattern(),
        totalCount: 1,
        sessionCount: 1,
        tagTotalCount: 1,
      );
      expect(r.isRepeat, isFalse);
    });

    test('exact repeats quote the exact count, coarse repeats the tag count',
        () {
      final exact = RepeatInfo(
        pattern: pattern(),
        totalCount: 3,
        sessionCount: 2,
        tagTotalCount: 5,
      );
      expect(exact.isRepeat, isTrue);
      expect(exact.isExactRepeat, isTrue);
      expect(exact.displayCount, 3);

      final coarse = RepeatInfo(
        pattern: pattern(),
        totalCount: 1,
        sessionCount: 1,
        tagTotalCount: 4,
      );
      expect(coarse.isRepeat, isTrue);
      expect(coarse.isExactRepeat, isFalse);
      expect(coarse.displayCount, 4);
    });
  });
}
