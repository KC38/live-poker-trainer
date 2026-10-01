/// CHECK paints on the street-bet home, not under the seat box.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

GameState _checkGame() {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'You',
        archetype: PlayerArchetype.hero,
        stack: 200,
        isHero: true,
        holeCards: [
          CardModel.fromCode('Ah'),
          CardModel.fromCode('Kd'),
        ],
      ),
      PlayerModel(
        id: 1,
        name: 'Max',
        archetype: PlayerArchetype.tag,
        stack: 200,
        lastActionLabel: 'CHECK',
        holeCards: [
          CardModel.fromCode('2c'),
          CardModel.fromCode('7d'),
        ],
      ),
      PlayerModel(
        id: 2,
        name: 'Kai',
        archetype: PlayerArchetype.lag,
        stack: 194,
        currentBet: 6,
        lastActionLabel: 'BET',
        holeCards: [
          CardModel.fromCode('3c'),
          CardModel.fromCode('3d'),
        ],
      ),
    ],
    mode: GameMode.training,
    community: [
      CardModel.fromCode('Ac'),
      CardModel.fromCode('Jc'),
      CardModel.fromCode('Kd'),
    ],
    street: Street.flop,
    mainPot: 6,
    highestBet: 6,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    dealerIndex: 0,
    sbIndex: 1,
    bbIndex: 2,
    waitingForHero: true,
  );
}

void main() {
  testWidgets('CHECK badge sits on the felt bet home for that seat', (
    tester,
  ) async {
    const size = Size(393, 520);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final game = _checkGame();
    final laid = TableLayout.resolve(
      size: size,
      game: game,
      features: TableFeatures.full,
      includeHero: true,
      review: false,
      awarding: false,
      chipDisplayMode: ChipDisplayMode.dollars,
    );
    final checkSeat = laid.seats.firstWhere((s) => s.index == 1);
    expect(checkSeat.feltAction, isNotNull);
    expect(checkSeat.feltAction!.label, 'CHECK');
    expect(laid.seats.firstWhere((s) => s.index == 2).bet, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: FeltTableView(
              game: game,
              chipDisplayMode: ChipDisplayMode.dollars,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final badge = find.byKey(const ValueKey<String>('act-1-CHECK'));
    expect(badge, findsOneWidget);
    final badgeRect = tester.getRect(badge);
    expect(
      (badgeRect.center - checkSeat.feltAction!.rect.center).distance,
      lessThan(8),
    );
    // Not hanging under the seat box.
    expect(badgeRect.center.dy, lessThan(checkSeat.pod.bottom - 4));
  });
}
