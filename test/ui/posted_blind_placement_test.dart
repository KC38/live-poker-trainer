/// Posted blinds stay on each seat's potward felt home.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('posted blinds sit on the potward home beside their seats', () {
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

    final center = Offset(layout.size.width / 2, layout.size.height / 2);

    for (final seat in [sb, bb]) {
      final toward = center - seat.pod.center;
      final inward = toward / toward.distance;
      final claim = Rect.fromLTRB(
        math.min(seat.footprint.left, seat.pod.left),
        math.min(seat.footprint.top, seat.pod.top),
        math.max(seat.footprint.right, seat.pod.right),
        seat.pod.bottom + kSeatBadgeBelowPod,
      );
      final edge = SeatFeltSpots.exitPoint(claim, seat.pod.center, inward);
      final puck = seat.pucks.first.rect.center;
      final bet = seat.bet!.rect.center;

      expect((puck - edge).distance, lessThan(40));
      expect((bet - edge).distance, lessThan(56));
      expect((bet - puck).distance, lessThan(56));

      final puckAlong =
          (puck - edge).dx * inward.dx + (puck - edge).dy * inward.dy;
      final betAlong =
          (bet - edge).dx * inward.dx + (bet - edge).dy * inward.dy;
      expect(betAlong, greaterThan(puckAlong));
    }

    // Still on the right half for Max/Kai in the blinds lesson lineup.
    expect(bb.bet!.rect.center.dx, greaterThan(layout.size.width * 0.5));
    expect(sb.bet!.rect.center.dx, greaterThan(layout.size.width * 0.5));
  });
}
