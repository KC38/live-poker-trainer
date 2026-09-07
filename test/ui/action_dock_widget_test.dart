/// Widget tests guarding the action dock against illegal range math.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';

GameState _state({
  required double heroStack,
  required double highestBet,
  double minRaise = 2,
  double mainPot = 0,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: heroStack,
        isHero: true,
      ),
      PlayerModel(
        id: 1,
        name: 'Stan',
        archetype: PlayerArchetype.nit,
        stack: 500,
        currentBet: highestBet,
      ),
    ],
    mode: GameMode.training,
    mainPot: mainPot,
    highestBet: highestBet,
    minRaise: minRaise,
    smallBlind: 1,
    bigBlind: 2,
    waitingForHero: true,
  );
}

Future<void> _pump(WidgetTester tester, GameState state) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ActionDockWidget(game: state, onAction: (_) {}),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders a sizing slider for a deep hero', (tester) async {
    await _pump(tester, _state(heroStack: 400, highestBet: 20, mainPot: 40));
    expect(tester.takeException(), isNull);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets(
    'renders without ArgumentError when a min-raise is unaffordable',
    (tester) async {
      // The reported crash: min-raise-to of 451 against a 450 effective stack.
      await _pump(
        tester,
        _state(heroStack: 450, highestBet: 449, mainPot: 900),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Slider), findsNothing);
      expect(find.text('All-in'), findsWidgets);
    },
  );

  testWidgets('renders when the hero is covered and cannot raise',
      (tester) async {
    await _pump(tester, _state(heroStack: 10, highestBet: 449, mainPot: 900));
    expect(tester.takeException(), isNull);
    expect(find.text('No raise available at this price'), findsOneWidget);
  });

  testWidgets('renders for every hero stack against a large bet',
      (tester) async {
    for (var stack = 0; stack <= 500; stack += 7) {
      await _pump(
        tester,
        _state(heroStack: stack.toDouble(), highestBet: 449, mainPot: 900),
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'action dock threw for hero stack $stack',
      );
    }
  });

  testWidgets('shows currency only on the dock, never dual amounts',
      (tester) async {
    await _pump(tester, _state(heroStack: 400, highestBet: 20, mainPot: 40));
    expect(tester.takeException(), isNull);
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .toList();
    expect(texts.any((t) => t.contains('BB')), isFalse);
    expect(texts.any((t) => t.startsWith('Call \$')), isTrue);
  });
}
