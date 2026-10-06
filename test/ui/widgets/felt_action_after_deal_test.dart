/// Felt holds FOLD until hole cards land, then plays UTG before HJ.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/action_badge.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets('guided preflop deals holes before UTG then HJ fold', (
    tester,
  ) async {
    CardDealPace.debugInstant = false;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final game = lessonTableStageGame(
      heroCodes: const ['Ah', 'Kd'],
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      seatNames: lessonActionOrderSeatNames,
      foldedSeatIndexes: lessonSeatOrderFoldedIndexes(
        'act-02-01-02-guided-pre',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 560,
            child: FeltTableView(
              game: game,
              chipDisplayMode: ChipDisplayMode.dollars,
              showHoleCardBacks: true,
              dealKey: 'guided-pre-deal-then-fold',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ActionBadge), findsNothing);
    expect(find.text('FOLD'), findsNothing);

    // Six seats × two hole cards; the first card already landed.
    for (var i = 0; i < 11; i++) {
      await tester.pump(CardDealPace.dealCard);
    }
    expect(find.byType(TableCardBack), findsNWidgets(12));
    expect(find.text('FOLD'), findsNothing);

    await tester.pump(CardDealPace.dealCard);
    expect(find.text('FOLD'), findsOneWidget);

    await tester.pump(CardDealPace.dealCard);
    expect(find.text('FOLD'), findsNWidgets(2));
  });
}
