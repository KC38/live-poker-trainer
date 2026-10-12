/// Implied odds guided spot is a gutshot with two overcards (LPT-393).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

void _expectGutshotOvers(List<String> hero, List<String> board, String why) {
  final h = [for (final c in hero) _enc(c)];
  final b = [for (final c in board) _enc(c)];
  expect(
    HandClassifier.drawOuts(h[0], h[1], b),
    DrawOuts.weak,
    reason: '$why: $hero on $board must be a four-out gutshot',
  );
  expect(
    HandClassifier.classify(h[0], h[1], b),
    HandClass.weakDraw,
    reason: '$why: $hero on $board',
  );
  final boardTop = [for (final c in board) CardModel.fromCode(c).rank]
      .reduce((x, y) => x > y ? x : y);
  for (final c in hero) {
    expect(
      CardModel.fromCode(c).rank,
      greaterThan(boardTop),
      reason: '$why: $c must be an overcard to $board',
    );
  }
}

void main() {
  final activity = CourseActivity(
    id: 'act-05-03-01-guided',
    order: 2,
    stage: ActivityStage.guided,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Call a gutshot with overs for implied odds.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Deep vs a Calling Station. Gutshot with overs. Action?',
  );

  test('template is a gutshot with two overs (LPT-393)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['Jh', '9d']);
    expect(spot.boardCodes, ['8s', '7c', '2d']);
    expect(spot.streetLabel, 'Flop · gutshot + overs · 200bb');
    _expectGutshotOvers(spot.heroCodes, spot.boardCodes, 'template');
  });

  test('remapped deals keep gutshot + overs (LPT-393)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      _expectGutshotOvers(spot.heroCodes, spot.boardCodes, 'gen $generation');
    }
  });
}
