/// Sequential board deal reveals one card at a time.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets('flop cards appear one at a time', (tester) async {
    CardDealPace.debugInstant = false;
    CardDealPace.testScale = 1;
    final sound = SoundService.silent();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [soundServiceProvider.overrideWithValue(sound)],
        child: MaterialApp(
          home: CommunityCardsView(
            community: [
              CardModel.fromCode('Ah'),
              CardModel.fromCode('Kd'),
              CardModel.fromCode('Qc'),
            ],
            pot: 6,
            street: Street.flop,
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(TableCard), findsOneWidget);

    await tester.pump(CardDealPace.dealCard);
    expect(find.byType(TableCard), findsNWidgets(2));

    await tester.pump(CardDealPace.dealCard);
    expect(find.byType(TableCard), findsNWidgets(3));

    // Flush deal-stagger timers from SoundService.
    await tester.pump(const Duration(milliseconds: 300));
    await sound.dispose();
  });
}
