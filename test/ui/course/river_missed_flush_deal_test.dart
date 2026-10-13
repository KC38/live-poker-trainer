/// Close-the-river scaffolded bluff is a real missed flush draw (LPT-402).
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

void _expectMissedFlushDraw(List<String> hero, List<String> board, String why) {
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
    id: 'act-03-06-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Represent the flush as a bluff when the story fits.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt:
        'You missed a flush draw after betting twice. River completes the '
        'flush. Action?',
  );

  test('template flops a flush draw, misses, river completes hearts', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['9s', '8s']);
    expect(spot.boardCodes, ['Ks', '7s', '2h', '3h', 'Ah']);
    expect(spot.streetLabel, 'River · flush completes');
    _expectMissedFlushDraw(spot.heroCodes, spot.boardCodes, 'template');
    final hearts = spot.boardCodes.where((c) => c.endsWith('h')).length;
    expect(hearts, 3, reason: 'a board flush completes on the river');
  });

  test('remapped deals keep the missed-draw story (LPT-402)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      _expectMissedFlushDraw(
        spot.heroCodes,
        spot.boardCodes,
        'generation $generation',
      );
    }
  });
}
