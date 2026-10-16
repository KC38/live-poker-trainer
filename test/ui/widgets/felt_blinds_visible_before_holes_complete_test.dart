/// Posted blinds unmask with SoftPulse teaching-card ready (LPT-1010).
///
/// SoftPulse unlocks on hero holes without waiting for every villain back
/// (LPT-678). While those backs still deal, SB/BB chips and the pot must
/// already match the posted blinds — never SoftPulse over POT $0 with
/// stacks already deducted.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets(
    'posted blinds and pot show once SoftPulse teaching cards ready (LPT-1010)',
    (tester) async {
      CardDealPace.debugInstant = false;
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final game = lessonTableStageGame(
        heroCodes: const ['Ah', 'Kd'],
        villainCount: lessonBlindsVillainCount,
        dealerIndex: lessonBlindsButtonIndex,
        sbIndex: lessonBlindsSmallBlindIndex,
        bbIndex: lessonBlindsBigBlindIndex,
      );
      final expectedPot = game.displayPot;
      expect(expectedPot, greaterThan(Money.epsilon));

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
                dealKey: 'pot-stacks-blinds-before-holes-complete',
                features: const TableFeatures(
                  stacks: true,
                  pot: true,
                  blinds: true,
                  positions: true,
                ),
                onDealReady: (ready) => dealReady = ready,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(dealReady, isFalse);

      for (var i = 0; i < 20 && !dealReady; i++) {
        await tester.pump(CardDealPace.dealCard);
        await tester.pump(CardDealPace.revealSettle);
      }
      expect(dealReady, isTrue);

      // SoftPulse unlocked — pot must already match posted blinds even if
      // villain hole-backs are still mid-deal.
      expect(find.textContaining('POT'), findsWidgets);
      expect(
        find.textContaining(
          ChipFormat.chips(expectedPot, game.bigBlind, ChipDisplayMode.dollars),
        ),
        findsWidgets,
      );
      expect(find.textContaining('POT \$0'), findsNothing);
    },
  );
}
