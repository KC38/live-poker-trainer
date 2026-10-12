/// Plan beyond the flop scaffolded turn is a true four-heart board (LPT-400).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

HandClass _class(List<String> hero, List<String> board) =>
    HandClassifier.classify(_enc(hero[0]), _enc(hero[1]), [
      for (final c in board) _enc(c),
    ]);

void _expectFourFlushAir(List<String> hero, List<String> board, String why) {
  final counts = <Object, int>{};
  for (final c in board) {
    final suit = CardModel.fromCode(c).suit;
    counts[suit] = (counts[suit] ?? 0) + 1;
  }
  final flushSuit = counts.entries.firstWhere(
    (e) => e.value == 4,
    orElse: () => fail('$why: board $board is not four of one suit'),
  );
  for (final c in hero) {
    expect(
      CardModel.fromCode(c).suit,
      isNot(flushSuit.key),
      reason: '$why: hero $hero must hold no card of the flush suit',
    );
  }
  expect(_class(hero, board), HandClass.air, reason: '$why: $hero on $board');
}

void main() {
  final activity = CourseActivity(
    id: 'act-04-03-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Abort the bluff on a four-flush turn.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt:
        'You bluffed flop. Turn puts four to a flush; you have no heart. '
        'Action?',
  );

  test('template turn is four hearts with hero air (LPT-400)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['Qd', '9c']);
    expect(spot.boardCodes, ['Kh', '7h', '2h', '3h']);
    expect(spot.streetLabel, 'Turn · four hearts · air');
    _expectFourFlushAir(spot.heroCodes, spot.boardCodes, 'template');
  });

  test('remapped deals keep a four-flush turn over air (LPT-400)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      _expectFourFlushAir(
        spot.heroCodes,
        spot.boardCodes,
        'generation $generation',
      );
    }
  });
}
