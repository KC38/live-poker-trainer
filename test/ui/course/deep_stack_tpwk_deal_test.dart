/// Deep-stack scaffolded fold is true top pair weak kicker (LPT-404).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

void _expectTpwkNoDraw(List<String> hero, List<String> board, String why) {
  final h = [for (final c in hero) _enc(c)];
  final b = [for (final c in board) _enc(c)];
  expect(
    HandClassifier.classify(h[0], h[1], b),
    HandClass.topPair,
    reason: '$why: $hero on $board must be top pair',
  );
  expect(
    HandClassifier.drawOuts(h[0], h[1], b),
    lessThan(DrawOuts.weak),
    reason: '$why: $hero on $board must hold no flush or straight draw',
  );
  final boardRanks = [for (final c in board) CardModel.fromCode(c).rank];
  final top = boardRanks.reduce((x, y) => x > y ? x : y);
  final heroRanks = [for (final c in hero) CardModel.fromCode(c).rank];
  expect(heroRanks, contains(top), reason: '$why: pairs the top card');
  final kicker = heroRanks.firstWhere((r) => r != top);
  final unpaired = boardRanks.where((r) => r != top);
  expect(
    unpaired.any((r) => r > kicker),
    isTrue,
    reason: '$why: kicker in $hero must lose to an unpaired card on $board',
  );
}

void main() {
  final activity = CourseActivity(
    id: 'act-05-02-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Fold light top pair deep.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt:
        '250bb. Top pair weak kicker faces a huge check-raise on a wet flop. '
        'Action?',
  );

  test('template is top pair weak kicker without a draw (LPT-404)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['Ad', '9c']);
    expect(spot.boardCodes, ['As', 'Th', '7h']);
    expect(spot.streetLabel, 'Flop · top pair weak · 250bb');
    _expectTpwkNoDraw(spot.heroCodes, spot.boardCodes, 'template');
  });

  test('remapped deals stay TPWK with no draw (LPT-404)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      _expectTpwkNoDraw(spot.heroCodes, spot.boardCodes, 'gen $generation');
    }
  });
}
