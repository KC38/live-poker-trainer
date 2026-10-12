/// Adjust versus Calling Station scaffolded river is a real missed draw (LPT-399).
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
}

void main() {
  final activity = CourseActivity(
    id: 'act-04-06-03-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Give up a missed draw versus a sticky seat.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Missed draw versus the same sticky seat. River brick. Action?',
  );

  test('template is a flopped flush draw that misses (LPT-399)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['8h', '7h']);
    expect(spot.boardCodes, ['Kh', '9h', '2c', '3d', '5s']);
    expect(spot.streetLabel, 'River · missed draw');
    _expectMissedDraw(spot.heroCodes, spot.boardCodes, 'template');
  });

  test('remapped deals keep the missed-draw story (LPT-399)', () {
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
