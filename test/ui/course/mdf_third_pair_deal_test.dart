/// Minimum-defense scaffolded fold is a real third pair (LPT-397).
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

void main() {
  final activity = CourseActivity(
    id: 'act-06-07-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 55,
    accessibilityText: 'Fold third pair to a river bomb.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Third pair no blockers on scary river. Default?',
  );

  test('template is third pair, not a straight (LPT-397)', () {
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['9h', '7d']);
    expect(spot.boardCodes, ['Kc', 'Qh', '9d', '4c', '8s']);
    expect(spot.streetLabel, 'River · third pair');
    expect(_class(spot.heroCodes, spot.boardCodes), HandClass.weakPair);
    final ranks = {
      for (final c in spot.boardCodes) CardModel.fromCode(c).rank,
    }.toList()..sort((a, b) => b.compareTo(a));
    expect(CardModel.fromCode('9h').rank, ranks[2], reason: 'third-high rank');
  });

  test('remapped deals keep a non-top pair, never a straight (LPT-397)', () {
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
