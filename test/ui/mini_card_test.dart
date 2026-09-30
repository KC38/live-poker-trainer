/// MiniCard is a size-preset wrapper around the shared TableCard face.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

void main() {
  testWidgets('MiniCard draws the shared TableCard face', (tester) async {
    final card = CardModel.fromCode('Ac');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MiniCard(card: card, size: MiniCardSize.small),
          ),
        ),
      ),
    );

    expect(find.byType(TableCard), findsOneWidget);
    expect(find.text(card.rankLabel), findsOneWidget);
    expect(find.text(card.suit.symbol), findsOneWidget);
    // Old inline "A♣" compact face must not appear.
    expect(find.text(card.display), findsNothing);
  });

  testWidgets('MiniCardSize footprints match TableCard aspect', (tester) async {
    for (final size in MiniCardSize.values) {
      expect(
        size.dimensions.height,
        moreOrLessEquals(size.dimensions.width * tableCardAspect),
      );
    }
  });

  testWidgets('CardBack draws the shared TableCardBack', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CardBack(size: MiniCardSize.tiny)),
        ),
      ),
    );

    expect(find.byType(TableCardBack), findsOneWidget);
  });
}
