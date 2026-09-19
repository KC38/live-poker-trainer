/// Widget tests guarding the action dock against illegal range math.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/situation_action_keys.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
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

HeroActionEdge _edge(String key, SituationActionKind kind, {double? amountTo}) {
  return HeroActionEdge(
    actionKey: key,
    kind: kind,
    amountTo: amountTo,
    coaching: 'Test coaching',
    verdict: HeroActionVerdict.correct,
    evDeltaBb: 0,
    optimalActionKey: key,
    nextNodeId: 'terminal',
  );
}

Future<void> _pump(
  WidgetTester tester,
  GameState state, {
  List<HeroActionEdge>? authoredEdges,
  ValueChanged<PokerAction>? onAction,
  List<LiveLegalActionModel>? liveActions,
  ValueChanged<LiveLegalActionModel>? onLiveAction,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ActionDockWidget(
                game: state,
                authoredEdges: authoredEdges,
                liveActions: liveActions,
                onLiveAction: onLiveAction,
                onAction: onAction ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('live mode renders only exact server actions and no free fold', (
    tester,
  ) async {
    LiveLegalActionModel? chosen;
    const actions = [
      LiveLegalActionModel(
        actionId: 'CHECK',
        kind: 'CHECK',
        bucket: 'CHECK',
        label: 'Check',
      ),
      LiveLegalActionModel(
        actionId: 'BET_67:1200',
        kind: 'BET',
        bucket: 'BET_67',
        label: r'Bet $12',
        amountTo: 12,
      ),
    ];
    await _pump(
      tester,
      _state(heroStack: 400, highestBet: 0, mainPot: 18),
      liveActions: actions,
      onLiveAction: (action) => chosen = action,
    );

    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text(r'BET $12'), findsOneWidget);
    expect(find.text('FOLD'), findsNothing);
    expect(find.byType(Slider), findsNothing);

    await tester.tap(find.text(r'BET $12'));
    expect(chosen?.actionId, 'BET_67:1200');
  });

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

  testWidgets('renders when the hero is covered and cannot raise', (
    tester,
  ) async {
    await _pump(tester, _state(heroStack: 10, highestBet: 449, mainPot: 900));
    expect(tester.takeException(), isNull);
    expect(find.text('No raise available at this price'), findsOneWidget);
  });

  testWidgets('renders for every hero stack against a large bet', (
    tester,
  ) async {
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

  testWidgets('shows currency only on the dock, never dual amounts', (
    tester,
  ) async {
    await _pump(tester, _state(heroStack: 400, highestBet: 20, mainPot: 40));
    expect(tester.takeException(), isNull);
    final texts =
        tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .toList();
    expect(texts.any((t) => t.contains('BB')), isFalse);
    expect(texts.any((t) => t.startsWith('Call \$')), isTrue);
  });

  testWidgets('authored mode shows only server actions and exact amounts', (
    tester,
  ) async {
    final state = _state(heroStack: 400, highestBet: 20, mainPot: 40);
    final edges = [
      _edge('FOLD', SituationActionKind.fold),
      _edge('CALL_20', SituationActionKind.call, amountTo: 20),
      _edge('RAISE_70', SituationActionKind.raise, amountTo: 70),
    ];

    await _pump(tester, state, authoredEdges: edges);

    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('CALL \$20'), findsOneWidget);
    expect(find.text('RAISE \$70'), findsOneWidget);
    expect(find.text('CHECK'), findsNothing);
    expect(find.text('BET'), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.text('⅓'), findsNothing);
    expect(find.text('½'), findsNothing);
    expect(find.text('¾'), findsNothing);
    expect(find.text('Pot'), findsNothing);
  });

  testWidgets('authored tap resolves and records the exact edge and path', (
    tester,
  ) async {
    final state = _state(heroStack: 400, highestBet: 20, mainPot: 40);
    final raise = _edge('RAISE_70', SituationActionKind.raise, amountTo: 70);
    final node = HeroDecisionNode(
      id: 'hero_flop',
      street: Street.preflop,
      pot: 40,
      stacks: const [400, 480],
      streetBets: const [0, 20],
      board: const [],
      foldedSeats: const [],
      toAct: 0,
      callAmount: 20,
      minRaiseTo: 40,
      actions: [raise],
    );
    final pathNodeIds = <String>[];
    final chosenActionKeys = <String>[];

    await _pump(
      tester,
      state,
      authoredEdges: [raise],
      onAction: (action) {
        final resolved = SituationActionKeys.resolveEdge(
          node: node,
          state: state,
          action: action,
        );
        if (resolved != null) {
          pathNodeIds.add(node.id);
          chosenActionKeys.add(resolved.actionKey);
        }
      },
    );
    await tester.tap(find.text('RAISE \$70'));

    expect(pathNodeIds, ['hero_flop']);
    expect(chosenActionKeys, ['RAISE_70']);
  });
}
