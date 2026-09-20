/// Live coach shelf mapping for assessment ratings and BEST sizing.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';

void main() {
  const call = LiveLegalActionModel(
    actionId: 'CALL:600',
    kind: 'CALL',
    bucket: 'CALL',
    label: 'Call \$6',
    amountTo: 6,
  );
  const raise = LiveLegalActionModel(
    actionId: 'RAISE_3X:1800',
    kind: 'RAISE',
    bucket: 'RAISE_3X',
    label: 'Raise to \$18',
    amountTo: 18,
  );

  test('strong grades as CLOSE and keeps BEST sizing from betterActionId', () {
    final feedback = buildLiveCoachFeedback(
      assessment: const LiveCoachingAssessment(
        actionId: 'CALL:600',
        rating: 'strong',
        confidence: 'high',
        summary: 'Calling is strong but raising is better.',
        playerTypeReason: 'Villain folds too often.',
        sizingNote: 'A small raise extracts more.',
        tendencyKeys: ['aggression'],
        betterActionId: 'RAISE_3X:1800',
      ),
      action: call,
      legalActions: const [call, raise],
      street: Street.preflop,
      bigBlind: 2,
    );

    expect(feedback.verdict, CoachVerdict.close);
    expect(feedback.optimalActionLabel, 'RAISE TO \$18');
    expect(feedback.optimalSizingBb, 9);
    expect(feedback.heroAction, 'Call \$6');
    expect(feedback.heroSizingBb, 3);
  });

  test('recommended grades as CORRECT and uses played sizing for BEST', () {
    final feedback = buildLiveCoachFeedback(
      assessment: const LiveCoachingAssessment(
        actionId: 'RAISE_3X:1800',
        rating: 'recommended',
        confidence: 'high',
        summary: 'Raise.',
        playerTypeReason: 'Wide folds.',
        sizingNote: '3x is enough.',
        tendencyKeys: ['vpip'],
      ),
      action: raise,
      legalActions: const [call, raise],
      street: Street.preflop,
      bigBlind: 2,
    );

    expect(feedback.verdict, CoachVerdict.correct);
    expect(feedback.optimalActionLabel, 'RAISE TO \$18');
    expect(feedback.optimalSizingBb, 9);
  });

  test('reasonable grades as CLOSE like strong', () {
    final feedback = buildLiveCoachFeedback(
      assessment: const LiveCoachingAssessment(
        actionId: 'CALL:600',
        rating: 'reasonable',
        confidence: 'medium',
        summary: 'Calling is fine.',
        playerTypeReason: 'Villain is linear.',
        sizingNote: '',
        tendencyKeys: ['showdownCall'],
        betterActionId: 'RAISE_3X:1800',
      ),
      action: call,
      legalActions: const [call, raise],
      street: Street.preflop,
      bigBlind: 2,
    );

    expect(feedback.verdict, CoachVerdict.close);
    expect(feedback.optimalActionLabel, 'RAISE TO \$18');
    expect(feedback.optimalSizingBb, 9);
  });

  test('mistake grades as INCORRECT', () {
    final feedback = buildLiveCoachFeedback(
      assessment: const LiveCoachingAssessment(
        actionId: 'CALL:600',
        rating: 'mistake',
        confidence: 'high',
        summary: 'Folding is better.',
        playerTypeReason: 'Villain never bluffs.',
        sizingNote: '',
        tendencyKeys: ['bluffRiver'],
      ),
      action: call,
      legalActions: const [call, raise],
      street: Street.preflop,
      bigBlind: 2,
    );

    expect(feedback.verdict, CoachVerdict.incorrect);
    expect(feedback.optimalActionLabel, isNull);
    expect(feedback.optimalSizingBb, 0);
  });
}
