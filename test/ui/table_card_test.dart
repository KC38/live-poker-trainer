/// TableCard face: corner rank, one centered suit, no duplicates.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

void main() {
  testWidgets('draws rank and suit once without a second overlapping suit', (
    tester,
  ) async {
    final card = CardModel.fromCode('Ah');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TableCard(card: card, width: 52),
          ),
        ),
      ),
    );

    expect(find.text(card.rankLabel), findsOneWidget);
    expect(find.text(card.suitSymbol), findsOneWidget);
  });

  testWidgets('each suit board code shows a single suit glyph', (tester) async {
    const codes = ['Ah', 'Kd', '7c', '2s'];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final code in codes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TableCard(
                    card: CardModel.fromCode(code),
                    width: 52,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    for (final code in codes) {
      final card = CardModel.fromCode(code);
      expect(
        find.text(card.suitSymbol),
        findsOneWidget,
        reason: '$code should draw ${card.suitSymbol} once',
      );
      final suitText = tester.widget<Text>(find.text(card.suitSymbol));
      expect(
        suitText.style?.color,
        card.displayColor,
        reason: '$code suit ink should match ${card.suit.name}',
      );
    }
  });

  testWidgets('suit sits below the corner rank and near horizontal center', (
    tester,
  ) async {
    const width = 52.0;
    final card = CardModel.fromCode('Qs');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TableCard(card: card, width: width),
          ),
        ),
      ),
    );

    final rank = tester.getRect(find.text(card.rankLabel));
    final suit = tester.getRect(find.text(card.suitSymbol));
    final cardBox = tester.getRect(find.byType(TableCard));

    expect(suit.top, greaterThan(rank.bottom));
    expect(
      (suit.center.dx - cardBox.center.dx).abs(),
      lessThan(width * 0.08),
    );
  });

  testWidgets('star distractor draws a gold star suit', (tester) async {
    final card = CardModel.fromCode('5*');
    expect(card.isTeachingDistractor, isTrue);
    expect(card.suitSymbol, '★');
    expect(card.rankLabel, '5');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: TableCard(card: card, width: 52)),
        ),
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.text('★'), findsOneWidget);
  });

  testWidgets('H of spades distractor draws fake rank H', (tester) async {
    final card = CardModel.fromCode('Hs');
    expect(card.isTeachingDistractor, isTrue);
    expect(card.rankLabel, 'H');
    expect(card.suitSymbol, '♠');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: TableCard(card: card, width: 52)),
        ),
      ),
    );

    expect(find.text('H'), findsOneWidget);
    expect(find.text('♠'), findsOneWidget);
  });
}
