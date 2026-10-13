/// Leak-repair guided felt names the hand TPWK, not TPTK (LPT-401).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

void main() {
  test('guided streetLabel says weak top pair for Ah4d on As9c7d', () {
    final activity = CourseActivity(
      id: 'act-03-08-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 50,
      accessibilityText: 'Fold top pair weak kicker to heat.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Multiway raise-reraise pot. You have top pair weak kicker. Action?',
    );
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['Ah', '4d']);
    expect(spot.boardCodes, ['As', '9c', '7d']);
    expect(spot.streetLabel, 'Flop · Weak top pair · Heat');
    expect(spot.streetLabel, isNot(contains('TPTK')));
    expect(
      HandClassifier.classify(_enc('Ah'), _enc('4d'), [
        for (final c in spot.boardCodes) _enc(c),
      ]),
      HandClass.topPair,
    );
    // Kicker 4 loses to every unpaired board card (9, 7): weak kicker.
    final kicker = CardModel.fromCode('4d').rank;
    for (final c in ['9c', '7d']) {
      expect(kicker, lessThan(CardModel.fromCode(c).rank));
    }
  });
}
