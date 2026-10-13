/// Nut flush draw templates stay nut after remap (LPT-408).
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

/// 1 = nut flush draw, 0 = non-nut flush draw, -1 = no flush draw.
int _fd(List<String> hero, List<String> board) {
  final h = [for (final c in hero) CardModel.fromCode(c)];
  final b = [for (final c in board) CardModel.fromCode(c)];
  for (final suit in {for (final c in h) c.suit}) {
    final inHand = h.where((c) => c.suit == suit).toList();
    final onBoard = b.where((c) => c.suit == suit).toList();
    if (inHand.length + onBoard.length != 4) continue;
    final boardRanks = {for (final c in onBoard) c.rank};
    var nut = 14;
    while (boardRanks.contains(nut)) {
      nut--;
    }
    return inHand.any((c) => c.rank == nut) ? 1 : 0;
  }
  return -1;
}

void main() {
  test('A9hh on Jh8h3c remaps only to nut flush draws (LPT-408)', () {
    expect(_fd(['Ah', '9h'], ['Jh', '8h', '3c']), 1);
    for (var seed = 0; seed < 160; seed++) {
      final g = isomorphicLessonCardGroups([
        ['Ah', '9h'],
        ['Jh', '8h', '3c'],
      ], Random(seed));
      expect(_fd(g[0], g[1]), 1, reason: 'seed $seed: ${g[0]} on ${g[1]}');
    }
  });

  test('non-nut 76hh on Kh9h2c never becomes nut (LPT-408)', () {
    expect(_fd(['7h', '6h'], ['Kh', '9h', '2c']), 0);
    for (var seed = 0; seed < 160; seed++) {
      final g = isomorphicLessonCardGroups([
        ['7h', '6h'],
        ['Kh', '9h', '2c'],
      ], Random(seed));
      expect(_fd(g[0], g[1]), 0, reason: 'seed $seed: ${g[0]} on ${g[1]}');
    }
  });

  test('flop-class scaffolded scene keeps the nut flush draw (LPT-408)', () {
    final activity = CourseActivity(
      id: 'act-03-02-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Name the strong draw.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name your flop class.',
    );
    for (var generation = 0; generation < 64; generation++) {
      final scene = dealtLessonTableScene(activity, generation: generation)!;
      expect(
        _fd(scene.heroCodes, scene.boardCodes),
        1,
        reason: 'gen $generation: ${scene.heroCodes} on ${scene.boardCodes}',
      );
    }
  });

  test('capstone multiway-deep flop keeps AhQh nut draw (LPT-408)', () {
    for (var generation = 0; generation < 32; generation++) {
      final spot = dealtToyHandStepSpot(
        activityId: 'act-07-10-03-hand',
        stepId: 'step-mw-flop',
        generation: generation,
      )!;
      expect(
        _fd(spot.heroCodes, spot.boardCodes),
        1,
        reason: 'gen $generation',
      );
    }
  });
}
