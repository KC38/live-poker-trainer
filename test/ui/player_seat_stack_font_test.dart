/// Seat stack amounts stay on the data type.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

void main() {
  testWidgets('seat stack uses JetBrains Mono', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayerSeatWidget(
            player: PlayerModel(
              id: 1,
              name: 'Villain',
              archetype: PlayerArchetype.nit,
              stack: 100,
            ),
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
            isActive: false,
            isDealer: true,
          ),
        ),
      ),
    );

    final stack = tester.widget<Text>(find.text(r'$100'));
    expect(stack.style?.fontFamily, contains('JetBrains'));
  });
}
