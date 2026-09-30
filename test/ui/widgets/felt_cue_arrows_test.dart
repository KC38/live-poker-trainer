/// Hero/board cue arrows bounce and glow so the tap target is obvious.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
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

Offset _arrowTranslate(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byKey(const ValueKey<String>('felt-cue-arrows')),
          matching: find.byType(Transform),
        )
        .first,
  );
  return Offset(transform.transform.storage[12], transform.transform.storage[13]);
}

void main() {
  testWidgets('hero cue shows two gold bouncing arrows', (tester) async {
    await _pumpFelt(tester, highlightHero: true, highlightBoard: false);

    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNWidgets(2));

    final icons = tester.widgetList<Icon>(
      find.byIcon(Icons.arrow_downward_rounded),
    );
    for (final icon in icons) {
      expect(icon.color, AppColors.goldBright);
      expect(icon.size, 22);
    }

    final start = _arrowTranslate(tester);
    await tester.pump(const Duration(milliseconds: 450));
    final mid = _arrowTranslate(tester);
    expect(mid.dy, isNot(closeTo(start.dy, 0.5)));
  });

  testWidgets('board cue shows one arrow above community cards', (tester) async {
    await _pumpFelt(tester, highlightHero: false, highlightBoard: true);

    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
  });

  testWidgets('no cue arrows when highlights are off', (tester) async {
    await _pumpFelt(tester, highlightHero: false, highlightBoard: false);

    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsNothing);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
  });

  testWidgets('highlightHeroIndexes puts one arrow on that hole card', (
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

    expect(find.byKey(const ValueKey<String>('hero-cue-arrow-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('hero-cue-arrow-1')), findsNothing);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);

    final arrow = tester.getCenter(
      find.byKey(const ValueKey<String>('hero-cue-arrow-0')),
    );
    final leftCard = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-0')),
    );
    final rightCard = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-1')),
    );
    expect(arrow.dx, closeTo(leftCard.dx, 1));
    expect((arrow.dx - rightCard.dx).abs(), greaterThan(20));
  });
}
