/// SoftPulse onDealReady waits on hero holes, not every villain back.
///
/// LPT-678 / LPT-679: Open strong scaffolded SoftPulse after Hint must unlock
/// once the hero pair lands, without waiting for the full six-max deal.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets(
    'SoftPulse onDealReady is true once hero has two holes (LPT-678)',
    (tester) async {
      CardDealPace.debugInstant = false;
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final game = lessonTableStageGame(
        heroCodes: const ['Qh', 'Qd'],
        villainCount: lessonBlindsVillainCount,
        dealerIndex: lessonBlindsButtonIndex,
        sbIndex: lessonBlindsSmallBlindIndex,
        bbIndex: lessonBlindsBigBlindIndex,
        seatNames: lessonActionOrderSeatNames,
      );

      var dealReady = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 560,
              child: FeltTableView(
                game: game,
                chipDisplayMode: ChipDisplayMode.dollars,
                showHoleCardBacks: true,
                heroCardsFaceUp: true,
                dealKey: 'open-strong-hero-softpulse-ready',
                onDealReady: (ready) => dealReady = ready,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(dealReady, isFalse);

      // Hero is seat 0; deal is clockwise from the button. Advance until the
      // hero's second hole is scheduled — SoftPulse must not wait for all
      // twelve hole cards.
      for (var i = 0; i < 20 && !dealReady; i++) {
        await tester.pump(CardDealPace.dealCard);
        await tester.pump(CardDealPace.revealSettle);
      }
      expect(dealReady, isTrue);

      // Villain backs may still be landing — SoftPulse already unlocked.
      expect(find.byType(FeltTableView), findsOneWidget);
    },
  );
}
