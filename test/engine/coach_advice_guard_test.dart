/// Tests for [CoachAdviceGuard] contradiction detection and rewrite.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_advice_guard.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
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
}
