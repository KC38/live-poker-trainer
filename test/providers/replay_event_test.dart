/// Client replay must clear stale CHECK pills when a bet reopens seats.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';

PlayerModel _seat({
  required int id,
  required double stack,
  double currentBet = 0,
  String? lastActionLabel,
  bool hasActedThisRound = false,
  bool folded = false,
  bool allIn = false,
}) {
  return PlayerModel(
    id: id,
    name: 'Seat $id',
    archetype: PlayerArchetype.tag,
    stack: stack,
    currentBet: currentBet,
    lastActionLabel: lastActionLabel,
    hasActedThisRound: hasActedThisRound,
    folded: folded,
    allIn: allIn,
  );
}

void main() {
  test('bet clears CHECK labels on seats that now owe chips', () {
    final game = GameState(
      mode: GameMode.training,
      players: [
        _seat(
          id: 0,
          stack: 200,
          currentBet: 0,
          lastActionLabel: 'CHECK',
          hasActedThisRound: true,
        ),
        _seat(
          id: 1,
          stack: 200,
          currentBet: 0,
          lastActionLabel: 'CHECK',
          hasActedThisRound: true,
        ),
        _seat(id: 2, stack: 200, currentBet: 0),
      ],
      street: Street.flop,
      highestBet: 0,
      activePlayerIndex: 2,
      handCount: 1,
    );

    final next = applyLiveReplayEvent(
      game,
      const LiveActionEventModel(
        sequence: 1,
        seat: 2,
        street: 'flop',
        actionId: 'BET_50:600',
        kind: 'BET',
        bucket: 'BET_50',
        amountTo: 6,
      ),
    );

    expect(next.players[2].lastActionLabel, 'BET');
    expect(next.players[2].currentBet, 6);
    expect(next.highestBet, 6);
    expect(next.players[0].lastActionLabel, isNull);
    expect(next.players[1].lastActionLabel, isNull);
    expect(next.players[0].hasActedThisRound, isFalse);
    expect(next.players[1].hasActedThisRound, isFalse);
  });

  test('call does not clear CHECK labels behind an unmatched bet', () {
    final game = GameState(
      mode: GameMode.training,
      players: [
        _seat(
          id: 0,
          stack: 194,
          currentBet: 6,
          lastActionLabel: 'BET',
          hasActedThisRound: true,
        ),
        _seat(
          id: 1,
          stack: 200,
          currentBet: 0,
          lastActionLabel: 'CHECK',
          hasActedThisRound: true,
        ),
        _seat(id: 2, stack: 200, currentBet: 0),
      ],
      street: Street.flop,
      highestBet: 6,
      activePlayerIndex: 2,
      handCount: 1,
    );

    final next = applyLiveReplayEvent(
      game,
      const LiveActionEventModel(
        sequence: 2,
        seat: 2,
        street: 'flop',
        actionId: 'CALL:600',
        kind: 'CALL',
        bucket: 'CALL',
        amountTo: 6,
      ),
    );

    expect(next.players[2].lastActionLabel, 'CALL');
    // Seat 1 still shows CHECK until a raise reopens; CALL does not reopen.
    expect(next.players[1].lastActionLabel, 'CHECK');
  });

  test('all-in raise clears CHECK labels on seats that now owe chips', () {
    final game = GameState(
      mode: GameMode.training,
      players: [
        _seat(
          id: 0,
          stack: 200,
          currentBet: 0,
          lastActionLabel: 'CHECK',
          hasActedThisRound: true,
        ),
        _seat(
          id: 1,
          stack: 194,
          currentBet: 6,
          lastActionLabel: 'BET',
          hasActedThisRound: true,
        ),
        _seat(id: 2, stack: 50, currentBet: 0),
      ],
      street: Street.flop,
      highestBet: 6,
      activePlayerIndex: 2,
      handCount: 1,
    );

    final next = applyLiveReplayEvent(
      game,
      const LiveActionEventModel(
        sequence: 3,
        seat: 2,
        street: 'flop',
        actionId: 'ALL_IN:5000',
        kind: 'ALL_IN',
        bucket: 'ALL_IN',
        amountTo: 50,
      ),
    );

    expect(next.players[2].lastActionLabel, 'ALL-IN');
    expect(next.highestBet, 50);
    expect(next.players[0].lastActionLabel, isNull);
    expect(next.players[1].lastActionLabel, isNull);
    expect(next.players[0].hasActedThisRound, isFalse);
    expect(next.players[1].hasActedThisRound, isFalse);
  });
}
