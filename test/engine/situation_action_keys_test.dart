/// Exact authored-action resolution tests.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/situation_action_keys.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

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

HeroDecisionNode _node(List<HeroActionEdge> actions) {
  return HeroDecisionNode(
    id: 'hero',
    street: Street.flop,
    pot: 60,
    stacks: const [190, 170],
    streetBets: const [10, 30],
    board: const [],
    foldedSeats: const [],
    toAct: 0,
    callAmount: 20,
    minRaiseTo: 50,
    actions: actions,
  );
}

GameState _state() {
  return GameState(
    players: const [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 190,
        currentBet: 10,
        isHero: true,
      ),
      PlayerModel(
        id: 1,
        name: 'Villain',
        archetype: PlayerArchetype.tag,
        stack: 170,
        currentBet: 30,
      ),
    ],
    mode: GameMode.training,
    street: Street.flop,
    highestBet: 30,
    minRaise: 20,
    smallBlind: 1,
    bigBlind: 2,
    waitingForHero: true,
  );
}

void main() {
  test('never falls back across action kinds', () {
    final node = _node([
      _edge('RAISE_40', SituationActionKind.raise, amountTo: 40),
    ]);

    final resolved = SituationActionKeys.resolveEdge(
      node: node,
      state: _state(),
      action: const PokerAction(type: PokerActionType.bet, amount: 40),
    );

    expect(resolved, isNull);
  });

  test('rejects arbitrary unauthored sizing instead of choosing nearest', () {
    final node = _node([
      _edge('BET_40', SituationActionKind.bet, amountTo: 40),
      _edge('BET_60', SituationActionKind.bet, amountTo: 60),
    ]);

    final resolved = SituationActionKeys.resolveEdge(
      node: node,
      state: _state(),
      action: const PokerAction(type: PokerActionType.bet, amount: 55),
    );

    expect(resolved, isNull);
  });

  test('matches action amounts that round to the authored cent', () {
    final edge = _edge('BET_40', SituationActionKind.bet, amountTo: 40);

    final within = SituationActionKeys.resolveEdge(
      node: _node([edge]),
      state: _state(),
      action: const PokerAction(type: PokerActionType.bet, amount: 40.004),
    );
    final nextCent = SituationActionKeys.resolveEdge(
      node: _node([edge]),
      state: _state(),
      action: const PokerAction(type: PokerActionType.bet, amount: 40.006),
    );

    expect(within, same(edge));
    expect(nextCent, isNull);
  });

  test('rejects non-cent authored model amounts', () {
    final malformed = _edge(
      'BET_BAD',
      SituationActionKind.bet,
      amountTo: 40.004,
    );

    final resolved = SituationActionKeys.resolveEdge(
      node: _node([malformed]),
      state: _state(),
      action: const PokerAction(type: PokerActionType.bet, amount: 40),
    );

    expect(resolved, isNull);
  });

  test('call matches authored total commitment', () {
    final call = _edge('CALL_TO_30', SituationActionKind.call, amountTo: 30);

    final resolved = SituationActionKeys.resolveEdge(
      node: _node([call]),
      state: _state(),
      action: const PokerAction(type: PokerActionType.call, amount: 20),
    );

    expect(resolved, same(call));
  });
}
