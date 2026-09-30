/// Posted blinds stay beside their seats, not deep on the felt.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('posted blinds sit beside their seats on a phone felt', () {
    final game = lessonBandGame(
      villainSeatCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
    );
    final features = TableFeatures.forLesson(TableFeatures.blindsLesson);
    const size = Size(393, 520);
    final layout = TableLayout.resolve(
      size: size,
      game: game,
      features: features,
      includeHero: true,
      review: false,
      awarding: false,
      chipDisplayMode: ChipDisplayMode.dollars,
      collecting: false,
    );

    final sb = layout.seats.firstWhere(
      (s) => s.index == lessonBlindsSmallBlindIndex,
    );
    final bb = layout.seats.firstWhere(
      (s) => s.index == lessonBlindsBigBlindIndex,
    );
    expect(sb.bet, isNotNull);
    expect(bb.bet, isNotNull);
    expect(sb.pucks, isNotEmpty);
    expect(bb.pucks, isNotEmpty);

    // Same vertical band as the seat box — beside the hole cards, not past
    // them toward the pot (the old radial walk parked the BB near the hero).
    expect(
      (bb.bet!.rect.center.dy - bb.pod.center.dy).abs(),
      lessThan(20),
      reason: 'BB bet should sit at pod height, not past the hole cards',
    );
    expect(
      (sb.bet!.rect.center.dy - sb.pod.center.dy).abs(),
      lessThan(20),
      reason: 'SB bet should sit at pod height, not past the hole cards',
    );

    // Just inward of the position puck, not floating mid-felt.
    final bbPuck = bb.pucks.first.rect;
    final sbPuck = sb.pucks.first.rect;
    expect(
      (bb.bet!.rect.center - bbPuck.center).distance,
      lessThan(56),
      reason: 'BB bet should sit next to its BB puck',
    );
    expect(
      (sb.bet!.rect.center - sbPuck.center).distance,
      lessThan(56),
      reason: 'SB bet should sit next to its SB puck',
    );

    // Still on Kai's side of the felt, not drifting past the board midline
    // toward the hero.
    expect(bb.bet!.rect.center.dx, greaterThan(layout.size.width * 0.5));
    expect(sb.bet!.rect.center.dx, greaterThan(layout.size.width * 0.5));
  });
}
