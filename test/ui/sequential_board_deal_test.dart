/// Sequential board deal reveals one card at a time via visibleCount.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/core/deal/felt_deal_controller.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets('flop cards appear one at a time from the deal controller', (
    tester,
  ) async {
    CardDealPace.debugInstant = false;
    CardDealPace.testScale = 1;
    final deal = FeltDealController();
    final community = [
      CardModel.fromCode('Ah'),
      CardModel.fromCode('Kd'),
      CardModel.fromCode('Qc'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: deal,
          builder: (context, _) {
            return CommunityCardsView(
              community: community,
              pot: 6,
              street: Street.flop,
              bigBlind: 2,
              chipDisplayMode: ChipDisplayMode.dollars,
              visibleCount: deal.boardVisible,
            );
          },
        ),
      ),
    );

    deal.bind(
      epoch: 'flop-1',
      seatCount: 0,
      dealerIndex: 0,
      boardTarget: 3,
      dealHoles: false,
    );
    await tester.pump();
    expect(find.byType(TableCard), findsOneWidget);

    await tester.pump(CardDealPace.dealCard);
    expect(find.byType(TableCard), findsNWidgets(2));

    await tester.pump(CardDealPace.dealCard);
    expect(find.byType(TableCard), findsNWidgets(3));

    deal.dispose();
  });
}
