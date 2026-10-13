/// Type×board guided call is a real second pair on a wet turn (LPT-396).
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

int _outs(List<String> hero, List<String> board) => HandClassifier.drawOuts(
  _enc(hero[0]),
  _enc(hero[1]),
  [for (final c in board) _enc(c)],
);

void main() {
  final activity = CourseActivity(
    id: 'act-07-08-01-guided',
    order: 2,
    stage: ActivityStage.guided,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Call second pair versus a Maniac overbet.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Wet board. Maniac overbets turn. Second pair. Action?',
  );

  test('template is second pair with no draw, not top pair (LPT-396)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['Jh', 'Td']);
    expect(spot.boardCodes, ['Kh', 'Ts', '8h', '2d']);
    expect(spot.streetLabel, 'Turn · second pair · wet');
    expect(_class(spot.heroCodes, spot.boardCodes), HandClass.weakPair);
    expect(_outs(spot.heroCodes, spot.boardCodes), lessThan(DrawOuts.weak));
    final ranks = {
      for (final c in spot.boardCodes) CardModel.fromCode(c).rank,
    }.toList()..sort((a, b) => b.compareTo(a));
    expect(CardModel.fromCode('Td').rank, ranks[1], reason: 'second-high rank');
  });

  test('remapped deals keep a non-top pair (LPT-396)', () {
    for (var generation = 0; generation < 64; generation++) {
      final spot = dealtLessonActionSpot(activity, generation: generation)!;
      expect(
        _class(spot.heroCodes, spot.boardCodes),
        HandClass.weakPair,
        reason: 'gen $generation: ${spot.heroCodes} on ${spot.boardCodes}',
      );
    }
  });
}
