/// Size with a message scaffolded river is a real missed draw (LPT-398).
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

void _expectMissedDraw(List<String> hero, List<String> board, String why) {
  expect(board, hasLength(5), reason: why);
  expect(
    _class(hero, board.sublist(0, 3)),
    HandClass.strongDraw,
    reason: '$why: $hero must flop a real draw on ${board.sublist(0, 3)}',
  );
  expect(
    _class(hero, board),
    HandClass.air,
    reason: '$why: $hero must miss by the river on $board',
  );
  final river = CardModel.fromCode(board[4]);
  expect(river.rank, CardModel.fromCode('As').rank, reason: '$why: scare Ace');
}

void main() {
  final activity = CourseActivity(
    id: 'act-04-04-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Polar pressure size with a missed draw.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt:
        'Missed draw, credible river scare card. Choose pressure size into 40.',
  );

  test('template is a flopped flush draw that misses (LPT-398)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['9h', '8h']);
    expect(spot.boardCodes, ['Kh', '7h', '2c', '3d', 'As']);
    expect(spot.streetLabel, 'River · scare Ace · missed draw');
    _expectMissedDraw(spot.heroCodes, spot.boardCodes, 'template');
  });

  test('remapped deals keep the missed-draw story (LPT-398)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      _expectMissedDraw(
        spot.heroCodes,
        spot.boardCodes,
        'generation $generation',
      );
    }
  });
}
