/// Tests for [CoachAdviceGuard] contradiction detection and rewrite.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_advice_guard.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

void main() {
  group('CoachAdviceGuard.reconcile', () {
    test('keeps advice that endorses a fold grade', () {
      const advice =
          'Too loose preflop — folding was cheaper against this nit.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: advice,
          fallback: 'fallback',
          bestAction: ExploitAction.fold,
          verdict: CoachVerdict.incorrect,
        ),
        advice,
      );
    });

    test('rejects call-urging advice when best is fold', () {
      const bad =
          'Versus a LAG you should call most of the time and defend wider.';
      const fallback =
          'Too loose preflop — folding was cheaper against this LAG.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: bad,
          fallback: fallback,
          bestAction: ExploitAction.fold,
          verdict: CoachVerdict.incorrect,
        ),
        fallback,
      );
    });

    test('rejects fold-urging advice when best is call', () {
      const bad =
          'Against a maniac, fold all the time here — they have it.';
      const fallback =
          'Too tight on the flop — calling was better versus a maniac.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: bad,
          fallback: fallback,
          bestAction: ExploitAction.call,
          verdict: CoachVerdict.incorrect,
        ),
        fallback,
      );
    });

    test('rejects internally contradictory advice', () {
      const bad =
          'Call most of the time versus a maniac, and fold all the time.';
      const fallback = 'Call versus a maniac — they bluff too often.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: bad,
          fallback: fallback,
          bestAction: ExploitAction.call,
          verdict: CoachVerdict.correct,
        ),
        fallback,
      );
    });

    test('ungraded spots keep advice unless self-contradictory', () {
      const ok = 'Close spot preflop — no clear exploit against this TAG.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: ok,
          fallback: 'fallback',
          bestAction: null,
          verdict: CoachVerdict.none,
        ),
        ok,
      );

      const bad = 'Call most of the time and fold all the time here.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: bad,
          fallback: 'fallback',
          bestAction: null,
          verdict: CoachVerdict.none,
        ),
        'fallback',
      );
    });

    test('falls back when narration facts disagree with the grade', () {
      const bad =
          'Fold the river vs a nit — you only have 55% and they fired.';
      const fallback =
          'Too loose on the flop vs a nit. Fold when the price is wrong '
          'for your equity.';
      expect(
        CoachAdviceGuard.reconcile(
          advice: bad,
          fallback: fallback,
          bestAction: ExploitAction.fold,
          verdict: CoachVerdict.incorrect,
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
          villainIsAggressor: false,
          reasonCodes: const [CoachReasonCode.foldWhenPriceWrong],
          villainArchetype: PlayerArchetype.nit,
        ),
        fallback,
      );
    });

    test('keeps slot-fill advice that matches grade facts', () {
      final phrase = CoachReasonCode.dontPayOffNits.phrase;
      final advice =
          'Fold on the flop vs this nit — 22% loses to 40%. $phrase';
      expect(
        CoachAdviceGuard.reconcile(
          advice: advice,
          fallback: 'fallback',
          bestAction: ExploitAction.fold,
          verdict: CoachVerdict.incorrect,
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
          villainIsAggressor: true,
          reasonCodes: const [
            CoachReasonCode.foldWhenPriceWrong,
            CoachReasonCode.dontPayOffNits,
          ],
          villainArchetype: PlayerArchetype.nit,
        ),
        advice,
      );
    });
  });

  group('CoachAdviceGuard.contradictsBest', () {
    test('flags never-fold language against a fold grade', () {
      expect(
        CoachAdviceGuard.contradictsBest(
          'Do not fold this — defend more versus a LAG.',
          ExploitAction.fold,
        ),
        isTrue,
      );
    });

    test('allows fold language when best is fold', () {
      expect(
        CoachAdviceGuard.contradictsBest(
          'Folding here saves chips against a nit.',
          ExploitAction.fold,
        ),
        isFalse,
      );
    });
  });

  group('CoachAdviceGuard.contradictsFacts', () {
    test('rejects wrong street and missing graded street', () {
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the river — equity is too thin vs a nit.',
          street: Street.flop,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold here — equity is too thin vs a nit.',
          street: Street.flop,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold on the flop — equity is too thin vs a nit.',
          street: Street.flop,
        ),
        isFalse,
      );
    });

    test('does not treat preflop as a flop mention', () {
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold preflop vs a nit — no price.',
          street: Street.preflop,
        ),
        isFalse,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold preflop vs a nit — no price.',
          street: Street.flop,
        ),
        isTrue,
      );
    });

    test('requires equity% and rejects wrong percents', () {
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the flop vs a nit — price is wrong.',
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the flop vs a nit — 55% is not enough vs 40%.',
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the flop vs a nit — 22% loses to 40%.',
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
        ),
        isFalse,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the flop vs a nit — 22% equity, 48% of their range is air.',
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 0,
          villainAirPercent: 48,
        ),
        isFalse,
      );
    });

    test('rejects invented aggressor language when villain only posted', () {
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold preflop — the nit fired and you are crushed.',
          street: Street.preflop,
          villainIsAggressor: false,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold preflop — facing a price from the nit in the BB.',
          street: Street.preflop,
          villainIsAggressor: false,
        ),
        isFalse,
      );
    });

    test('requires a curriculum phrase or reason id', () {
      final phrase = CoachReasonCode.neverBluffStations.phrase;
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Check back the turn vs a station — keep the pot small.',
          street: Street.turn,
          reasonCodes: const [CoachReasonCode.neverBluffStations],
          villainArchetype: PlayerArchetype.callingStation,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Check back the turn vs a station. $phrase',
          street: Street.turn,
          reasonCodes: const [CoachReasonCode.neverBluffStations],
          villainArchetype: PlayerArchetype.callingStation,
        ),
        isFalse,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Check the turn vs a station — never_bluff_stations applies.',
          street: Street.turn,
          reasonCodes: const [CoachReasonCode.neverBluffStations],
          villainArchetype: PlayerArchetype.callingStation,
        ),
        isFalse,
      );
    });

    test('requires archetype by name when provided', () {
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the flop — 22% loses to 40%. '
          '${CoachReasonCode.foldWhenPriceWrong.phrase}',
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
          reasonCodes: const [CoachReasonCode.foldWhenPriceWrong],
          villainArchetype: PlayerArchetype.nit,
        ),
        isTrue,
      );
      expect(
        CoachAdviceGuard.contradictsFacts(
          'Fold the flop vs this nit — 22% loses to 40%. '
          '${CoachReasonCode.foldWhenPriceWrong.phrase}',
          street: Street.flop,
          equityPercent: 22,
          requiredEquityPercent: 40,
          reasonCodes: const [CoachReasonCode.foldWhenPriceWrong],
          villainArchetype: PlayerArchetype.nit,
        ),
        isFalse,
      );
    });
  });
}
