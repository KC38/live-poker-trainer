/// Hero seat hole cards use the larger hero footprint.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

void main() {
  testWidgets('hero face-up hole cards use MiniCardSize.hero', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerSeatWidget(
            player: PlayerModel(
              id: 0,
              name: 'You',
              archetype: PlayerArchetype.tag,
              stack: 100,
              isHero: true,
              holeCards: [
                CardModel.fromCode('Ah'),
                CardModel.fromCode('Kd'),
              ],
            ),
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
            isActive: false,
            isDealer: true,
            revealHoleCards: true,
          ),
        ),
      ),
    );

    final heroCards = tester
        .widgetList<MiniCard>(find.byType(MiniCard))
        .toList();
    expect(heroCards, hasLength(2));
    expect(heroCards.every((c) => c.size == MiniCardSize.hero), isTrue);

    final cardSize = tester.getSize(find.byType(MiniCard).first);
    // Regular seat fits hero cards near full size; must beat villain tiny.
    expect(cardSize.height, greaterThan(MiniCardSize.tiny.dimensions.height));
    expect(cardSize.height, greaterThanOrEqualTo(40));
  });

  testWidgets('villain face-up hole cards stay MiniCardSize.tiny', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerSeatWidget(
            player: PlayerModel(
              id: 1,
              name: 'Sam',
              archetype: PlayerArchetype.tag,
              stack: 100,
              holeCards: [
                CardModel.fromCode('Qs'),
                CardModel.fromCode('Jh'),
              ],
            ),
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
            isActive: false,
            isDealer: false,
            revealHoleCards: true,
          ),
        ),
      ),
    );

    final villainCards = tester
        .widgetList<MiniCard>(find.byType(MiniCard))
        .toList();
    expect(villainCards, hasLength(2));
    expect(villainCards.every((c) => c.size == MiniCardSize.tiny), isTrue);
  });

  testWidgets('hero hole-card backs use MiniCardSize.hero', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayerSeatWidget(
            player: PlayerModel(
              id: 0,
              name: 'You',
              archetype: PlayerArchetype.tag,
              stack: 100,
              isHero: true,
            ),
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
            isActive: false,
            isDealer: false,
            showHoleBacks: true,
          ),
        ),
      ),
    );

    final backs = tester.widgetList<CardBack>(find.byType(CardBack)).toList();
    expect(backs, hasLength(2));
    expect(backs.every((b) => b.size == MiniCardSize.hero), isTrue);
  });
}
