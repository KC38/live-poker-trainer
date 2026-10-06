/// Felt SoftPulse uses shared [GlowHighlight] — no cue arrows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';

GameState _peekGame() {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'You',
        archetype: PlayerArchetype.hero,
        stack: 99.5,
        isHero: true,
        holeCards: [CardModel.fromCode('As'), CardModel.fromCode('Kh')],
      ),
      PlayerModel(
        id: 1,
        name: 'Jo',
        archetype: PlayerArchetype.nit,
        stack: 100,
        holeCards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
      ),
      PlayerModel(
        id: 2,
        name: 'Sam',
        archetype: PlayerArchetype.tag,
        stack: 100,
        holeCards: [CardModel.fromCode('3c'), CardModel.fromCode('8d')],
      ),
      PlayerModel(
        id: 3,
        name: 'Rio',
        archetype: PlayerArchetype.lag,
        stack: 100,
        holeCards: [CardModel.fromCode('4c'), CardModel.fromCode('9d')],
      ),
    ],
    mode: GameMode.training,
    community: const [],
    mainPot: 1.5,
    street: Street.preflop,
    highestBet: 1,
    minRaise: 1,
    smallBlind: 0.5,
    bigBlind: 1,
    dealerIndex: 0,
    sbIndex: 0,
    bbIndex: 2,
    waitingForHero: true,
  );
}

Future<void> _pumpFelt(
  WidgetTester tester, {
  required bool highlightHero,
  required bool highlightBoard,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 560));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SizedBox(
          width: 390,
          height: 560,
          child: FeltTableView(
            game: _peekGame(),
            chipDisplayMode: ChipDisplayMode.dollars,
            includeHero: true,
            showHoleCardBacks: true,
            highlightHero: highlightHero,
            highlightBoard: highlightBoard,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets('hero cue SoftPulses each hole card, not the You seat', (
    tester,
  ) async {
    await _pumpFelt(tester, highlightHero: true, highlightBoard: false);

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
  });

  testWidgets('hero cue waits until hole cards have landed', (tester) async {
    CardDealPace.debugInstant = false;
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SizedBox(
            width: 390,
            height: 560,
            child: FeltTableView(
              game: _peekGame(),
              chipDisplayMode: ChipDisplayMode.dollars,
              includeHero: true,
              showHoleCardBacks: true,
              highlightHero: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);

    await tester.pump(CardDealPace.dealCard * 8);

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNWidgets(2));
  });

  testWidgets('board group cue stays off until community cards land', (
    tester,
  ) async {
    await _pumpFelt(tester, highlightHero: false, highlightBoard: true);

    // Preflop — no board yet, so no empty hint ring.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
  });

  testWidgets('board group cue SoftPulses dealt community as one ring', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final game = _peekGame().copyWith(
      community: [
        CardModel.fromCode('Qs'),
        CardModel.fromCode('Jh'),
        CardModel.fromCode('2c'),
      ],
      street: Street.flop,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SizedBox(
            width: 390,
            height: 560,
            child: FeltTableView(
              game: game,
              chipDisplayMode: ChipDisplayMode.dollars,
              includeHero: true,
              showHoleCardBacks: true,
              highlightBoard: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Group SoftPulse — one GlowHighlight around the board row, no arrows.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
  });

  testWidgets('board group cue waits until the flop has landed', (tester) async {
    CardDealPace.debugInstant = false;
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final game = _peekGame().copyWith(
      community: [
        CardModel.fromCode('Qs'),
        CardModel.fromCode('Jh'),
        CardModel.fromCode('2c'),
      ],
      street: Street.flop,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SizedBox(
            width: 390,
            height: 560,
            child: FeltTableView(
              game: game,
              chipDisplayMode: ChipDisplayMode.dollars,
              includeHero: true,
              showHoleCardBacks: true,
              highlightBoard: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);

    // 4 seats × 2 holes + 3 flop; first card lands on the opening pump.
    await tester.pump(CardDealPace.dealCard * 10);

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
  });

  testWidgets('per-card board SoftPulse uses one GlowHighlight each', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final game = _peekGame().copyWith(
      community: [
        CardModel.fromCode('Qs'),
        CardModel.fromCode('Jh'),
        CardModel.fromCode('2c'),
      ],
      street: Street.flop,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SizedBox(
            width: 390,
            height: 560,
            child: FeltTableView(
              game: game,
              chipDisplayMode: ChipDisplayMode.dollars,
              includeHero: true,
              showHoleCardBacks: true,
              highlightBoardIndexes: const {0, 1, 2},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNWidgets(3));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
  });

  testWidgets('no SoftPulse when highlights are off', (tester) async {
    await _pumpFelt(tester, highlightHero: false, highlightBoard: false);

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
  });

  testWidgets('highlightHeroIndexes SoftPulses that hole card only', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SizedBox(
            width: 390,
            height: 560,
            child: FeltTableView(
              game: _peekGame(),
              chipDisplayMode: ChipDisplayMode.dollars,
              includeHero: true,
              showHoleCardBacks: true,
              heroCardsFaceUp: true,
              highlightHeroIndexes: const {0},
              onHeroCardTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);

    final glow = tester.getCenter(
      find.byKey(const ValueKey<String>('glow-highlight')),
    );
    final leftCard = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-0')),
    );
    final rightCard = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-1')),
    );
    expect(glow.dx, closeTo(leftCard.dx, 8));
    expect((glow.dx - rightCard.dx).abs(), greaterThan(20));
  });
}
