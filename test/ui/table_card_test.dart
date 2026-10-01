/// TableCard face: one rank and one suit glyph, no duplicates.
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
    }
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
