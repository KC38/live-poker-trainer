/// Visual previews for felt marker lanes across 2–9 seats and actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';

const _names = [
  'Sam',
  'Jo',
  'Rio',
  'Max',
  'Kai',
  'Ned',
  'Paul',
  'Rex',
];

GameState _blindsTable(int seats) {
  final dealer = seats <= 2 ? 0 : (seats ~/ 2);
  return lessonBandGame(
    villainSeatCount: seats - 1,
    dealerIndex: dealer,
    heroCodes: const ['Ah', 'Kd'],
  );
}

GameState _actionTable(int seats) {
  final dealer = seats <= 2 ? 0 : 1;
  final sb = seats <= 2 ? dealer : (dealer + 1) % seats;
  final bb = seats <= 2 ? (dealer + 1) % seats : (dealer + 2) % seats;
  final actions = List<String?>.filled(seats, null);
  final bets = List<double>.filled(seats, 0);
  // Cycle through common street outcomes so every seat shape is exercised.
  for (var i = 0; i < seats; i++) {
    if (i == sb) {
      actions[i] = 'BLIND';
      bets[i] = 1;
    } else if (i == bb) {
      actions[i] = 'BLIND';
      bets[i] = 2;
    } else {
      switch (i % 4) {
        case 0:
          actions[i] = 'CHECK';
        case 1:
          actions[i] = 'CALL';
          bets[i] = 6;
        case 2:
          actions[i] = 'RAISE';
          bets[i] = 14;
        case 3:
          actions[i] = 'FOLD';
      }
    }
  }
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'You',
        archetype: PlayerArchetype.hero,
        stack: 200 - bets[0],
        currentBet: bets[0],
        isHero: true,
        lastActionLabel: actions[0],
        holeCards: [
          CardModel.fromCode('9h'),
          CardModel.fromCode('7h'),
        ],
      ),
      for (var i = 1; i < seats; i++)
        PlayerModel(
          id: i,
          name: _names[i - 1],
          archetype: PlayerArchetype.tag,
          stack: 200 - bets[i],
          currentBet: bets[i],
          lastActionLabel: actions[i],
          holeCards: [
            CardModel.fromCode('2c'),
            CardModel.fromCode('7d'),
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
    mainPot: 40,
    highestBet: bets.fold<double>(0, (a, b) => a > b ? a : b),
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    dealerIndex: dealer,
    sbIndex: sb,
    bbIndex: bb,
    waitingForHero: true,
  );
}

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required GameState game,
}) async {
  const size = Size(393, 560);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0B1017),
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: RepaintBoundary(
              child: FeltTableView(
                game: game,
                chipDisplayMode: ChipDisplayMode.dollars,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('preview/$name.png'),
  );
}

void main() {
  for (var n = 2; n <= 9; n++) {
    testWidgets('felt ${n}h blinds markers', (tester) async {
      await _shoot(
        tester,
        name: 'felt_${n}h_blinds',
        game: _blindsTable(n),
      );
    });
  }

  testWidgets('felt 6h check call raise fold', (tester) async {
    await _shoot(
      tester,
      name: 'felt_6h_actions',
      game: _actionTable(6),
    );
  });

  testWidgets('felt 9h check call raise fold', (tester) async {
    await _shoot(
      tester,
      name: 'felt_9h_actions',
      game: _actionTable(9),
    );
  });
}
