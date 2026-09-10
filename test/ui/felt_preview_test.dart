import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';

GameState _game({required int seats, required Street street}) {
  const archetypes = [
    PlayerArchetype.callingStation,
    PlayerArchetype.maniac,
    PlayerArchetype.lag,
    PlayerArchetype.nit,
    PlayerArchetype.tag,
    PlayerArchetype.lag,
    PlayerArchetype.nit,
    PlayerArchetype.tag,
  ];
  final community = street == Street.preflop
      ? <CardModel>[]
      : [
          CardModel.fromCode('Ac'),
          CardModel.fromCode('Jc'),
          CardModel.fromCode('Kd'),
          CardModel.fromCode('3h'),
          CardModel.fromCode('9s'),
        ];
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Kushal',
        archetype: PlayerArchetype.hero,
        stack: 400,
        isHero: true,
        holeCards: [CardModel.fromCode('9h'), CardModel.fromCode('7h')],
      ),
      for (var i = 0; i < seats - 1; i++)
        PlayerModel(
          id: i + 1,
          name: ['Fred', 'Viktor', 'Sammy', 'Stan', 'Alex', 'Ned', 'Paul',
              'Rex'][i],
          archetype: archetypes[i],
          stack: 349 + i * 13,
          currentBet: i.isEven ? 2.0 + i * 3 : 0,
          lastActionLabel: i.isEven ? (i == 0 ? 'BLIND' : 'RAISE') : null,
          holeCards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
        ),
    ],
    mode: GameMode.training,
    community: community,
    mainPot: 137.5,
    street: street,
    highestBet: 8,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    dealerIndex: 3,
    sbIndex: 4,
    bbIndex: 5,
    waitingForHero: true,
  );
}

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required Size size,
  required GameState game,
}) async {
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
  testWidgets('felt 7 handed preflop', (tester) async {
    await _shoot(
      tester,
      name: 'felt_7_preflop',
      size: const Size(393, 560),
      game: _game(seats: 7, street: Street.preflop),
    );
  });

  testWidgets('felt 9 handed river', (tester) async {
    await _shoot(
      tester,
      name: 'felt_9_river',
      size: const Size(393, 560),
      game: _game(seats: 9, street: Street.river),
    );
  });
}
