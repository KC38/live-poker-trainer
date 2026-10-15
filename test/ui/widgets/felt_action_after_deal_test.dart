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

Finder _streetBetChips() {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith('bet-');
  });
}

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
    // Blinds / street bets stay off until holes finish (Live Training class).
    expect(_streetBetChips(), findsNothing);

    // Six seats × two hole cards; the first card already landed.
    // Eleven more pumps finish the deal; keep bets hidden until then.
    for (var i = 0; i < 10; i++) {
      await tester.pump(CardDealPace.dealCard);
      expect(
        _streetBetChips(),
        findsNothing,
        reason: 'street bets must wait for the deal (pump $i)',
      );
    }
    await tester.pump(CardDealPace.dealCard); // 12th hole card → holes done
    expect(find.byType(TableCardBack), findsNWidgets(12));
    expect(find.text('FOLD'), findsNothing);
    // Holes done → blinds may post; folds still wait one beat.
    expect(_streetBetChips(), findsWidgets);

    await tester.pump(CardDealPace.dealCard);
    expect(find.text('FOLD'), findsOneWidget);

    await tester.pump(CardDealPace.dealCard);
    expect(find.text('FOLD'), findsNWidgets(2));
  });
}
