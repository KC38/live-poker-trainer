/// Felt cards must match the hand the lesson names.
///
/// Dock tests tap Fold/Check and read the cue, so they still pass if the
/// holes are a different hand. #391 was that bug: Kh9d on K72 was labeled
/// second pair while it was top pair. These cases classify the authored
/// spots with [HandClassifier].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

int _code(String raw) => FastEvaluator.encode(CardModel.fromCode(raw));

HandClass _classOf(List<String> holes, List<String> board) {
  return HandClassifier.classify(
    _code(holes[0]),
    _code(holes[1]),
    board.map(_code).toList(growable: false),
  );
}

CourseActivity _activity(String id, ActivityRenderer renderer) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: ActivityStage.guided,
    renderer: renderer,
    estimatedSeconds: 30,
    accessibilityText: id,
    acceptedGrades: const [SoftGrade.recommended],
  );
}

void main() {
  test('multiway guided felt is second pair, not the top-pair regression', () {
    final activity = _activity(
      'act-03-07-01-guided',
      ActivityRenderer.pokerActionSizing,
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.heroCodes, ['7h', '9d']);
    expect(spot.boardCodes, ['Kc', '7s', '2d']);
    expect(spot.streetLabel, contains('Second pair'));
    expect(spot.openPot, isTrue);
    expect(spot.facingBet, isFalse);
    expect(_classOf(spot.heroCodes, spot.boardCodes), HandClass.weakPair);

    // Kh9d on this king flop pairs the king. That is the bug #391 fixed.
    expect(_classOf(const ['Kh', '9d'], spot.boardCodes), HandClass.topPair);
  });

  test('labeled action docks classify as the street name', () {
    const expected = <String, (HandClass, String)>{
      'act-03-04-01-guided': (HandClass.topPair, 'Heads-up'),
      'act-03-04-01-scaffolded': (HandClass.air, 'BTN aggressor'),
      'act-03-04-01-unguided': (HandClass.strongMade, 'Multiway'),
      'act-03-04-01-checkpoint': (HandClass.weakPair, 'Multiway'),
      'act-03-05-01-scaffolded': (HandClass.topPair, 'your holes'),
      'act-03-05-01-unguided': (HandClass.monster, 'hearts'),
      'act-03-06-01-guided': (HandClass.strongMade, 'brick'),
      'act-03-06-01-unguided': (HandClass.topPair, 'quiet line'),
      'act-03-08-01-guided': (HandClass.topPair, 'Weak TPTK'),
      'act-03-08-01-unguided': (HandClass.air, 'Air'),
      'act-03-08-02-jump-river': (HandClass.strongMade, 'brick'),
    };

    for (final entry in expected.entries) {
      final spot = resolveLessonActionSpot(
        _activity(entry.key, ActivityRenderer.pokerActionSizing),
      );
      expect(spot, isNotNull, reason: entry.key);
      expect(
        spot!.boardCodes.length,
        greaterThanOrEqualTo(3),
        reason: entry.key,
      );
      expect(spot.streetLabel, contains(entry.value.$2), reason: entry.key);
      expect(
        _classOf(spot.heroCodes, spot.boardCodes),
        entry.value.$1,
        reason: entry.key,
      );
    }
  });

  test('weak top pair and crowd air stay the hands the leak lesson names', () {
    final weak = resolveLessonActionSpot(
      _activity('act-03-08-01-guided', ActivityRenderer.pokerActionSizing),
    )!;
    expect(weak.heroCodes, ['Ah', '4d']);
    expect(weak.facingBet, isTrue);
    expect(_classOf(weak.heroCodes, weak.boardCodes), HandClass.topPair);
    // AK on this ace flop is still top pair, but it is not a weak kicker.
    expect(_classOf(const ['Ah', 'Kd'], weak.boardCodes), HandClass.topPair);
    expect(weak.heroCodes, isNot(contains('Kd')));

    final air = resolveLessonActionSpot(
      _activity('act-03-08-01-unguided', ActivityRenderer.pokerActionSizing),
    )!;
    expect(air.heroCodes, ['9h', '8d']);
    expect(air.boardCodes, ['Kc', '7s', '2d']);
    expect(_classOf(air.heroCodes, air.boardCodes), HandClass.air);
    expect(
      HandClassifier.drawOuts(
        _code(air.heroCodes[0]),
        _code(air.heroCodes[1]),
        air.boardCodes.map(_code).toList(growable: false),
      ),
      0,
    );
  });

  test('flop-class and river one-pair felts match their captions', () {
    const expected = <String, (HandClass, String)>{
      'act-03-02-01-guided': (HandClass.topPair, 'your holes'),
      'act-03-02-01-scaffolded': (HandClass.strongDraw, 'nut flush draw'),
      'act-03-02-01-checkpoint': (HandClass.strongDraw, 'open-ender'),
      'act-03-06-01-checkpoint': (HandClass.topPair, 'Medium one pair'),
      'act-03-08-02-jump-class': (HandClass.strongDraw, 'class?'),
    };

    for (final entry in expected.entries) {
      final scene = resolveLessonTableScene(
        _activity(entry.key, ActivityRenderer.selectIdentify),
      );
      expect(scene, isNotNull, reason: entry.key);
      expect(scene!.caption, contains(entry.value.$2), reason: entry.key);
      expect(scene.heroCodes, hasLength(2), reason: entry.key);
      expect(
        _classOf(scene.heroCodes, scene.boardCodes),
        entry.value.$1,
        reason: entry.key,
      );
    }

    final draw = resolveLessonTableScene(
      _activity('act-03-02-01-scaffolded', ActivityRenderer.selectIdentify),
    )!;
    expect(
      HandClassifier.drawOuts(
        _code(draw.heroCodes[0]),
        _code(draw.heroCodes[1]),
        draw.boardCodes.map(_code).toList(growable: false),
      ),
      DrawOuts.flushDraw,
    );
    final openEnder = resolveLessonTableScene(
      _activity('act-03-02-01-checkpoint', ActivityRenderer.selectIdentify),
    )!;
    expect(
      HandClassifier.drawOuts(
        _code(openEnder.heroCodes[0]),
        _code(openEnder.heroCodes[1]),
        openEnder.boardCodes.map(_code).toList(growable: false),
      ),
      DrawOuts.strong,
    );
    final combo = resolveLessonTableScene(
      _activity('act-03-08-02-jump-class', ActivityRenderer.selectIdentify),
    )!;
    expect(combo.heroCodes, ['Jd', 'Td']);
    expect(combo.boardCodes, ['Qd', '9d', '3c']);
    expect(
      HandClassifier.drawOuts(
        _code(combo.heroCodes[0]),
        _code(combo.heroCodes[1]),
        combo.boardCodes.map(_code).toList(growable: false),
      ),
      DrawOuts.combo,
    );
  });
}
