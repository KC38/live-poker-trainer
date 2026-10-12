/// Polar/merged scaffolded thin value is a real second pair (LPT-395).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

void _expectSecondPair(List<String> hero, List<String> board, String why) {
  final h = [for (final c in hero) _enc(c)];
  final b = [for (final c in board) _enc(c)];
  expect(
    HandClassifier.classify(h[0], h[1], b),
    HandClass.weakPair,
    reason: '$why: $hero on $board must be a pair below top',
  );
  final boardRanks = [for (final c in board) CardModel.fromCode(c).rank]
    ..sort((x, y) => y.compareTo(x));
  final heroRanks = [for (final c in hero) CardModel.fromCode(c).rank];
  expect(
    heroRanks,
    contains(boardRanks[1]),
    reason: '$why: $hero must pair the second board rank of $board',
  );
}

void main() {
  final activity = CourseActivity(
    id: 'act-06-04-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Merged thin value with second pair.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Thin value vs station on river. Size shape?',
  );

  test('template is second pair on the river (LPT-395)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['Jh', 'Td']);
    expect(spot.boardCodes, ['Qc', 'Ts', '3h', '2d', '7c']);
    expect(spot.streetLabel, 'River · second pair');
    _expectSecondPair(spot.heroCodes, spot.boardCodes, 'template');
  });

  test('remapped deals stay second pair (LPT-395)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      _expectSecondPair(spot.heroCodes, spot.boardCodes, 'gen $generation');
    }
  });
}
