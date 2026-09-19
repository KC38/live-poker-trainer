/// Client projection tests for authoritative live side-pot payouts.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';

Map<String, dynamic> _terminalView({
  required List<Map<String, dynamic>> pots,
  required List<int> winnerSeats,
}) {
  return {
    'sessionId': 'session',
    'handId': 'hand',
    'setupKey': 'setup',
    'decisionId': 'terminal',
    'stateVersion': 2,
    'smallBlind': 1,
    'bigBlind': 2,
    'street': 'river',
    'board': ['2c', '3d', '4h', '8s', 'Kd'],
    'pot': 500,
    'buttonSeat': 0,
    'heroSeat': 0,
    'actorSeat': null,
    'status': 'complete',
    'terminalReason': 'showdown',
    'seats': [
      for (var seat = 0; seat < 3; seat++)
        {
          'seat': seat,
          'name': seat == 0 ? 'Hero' : 'Villain $seat',
          'archetype': seat == 0 ? 'HERO' : 'TAG',
          'stack': 0,
          'streetBet': 0,
          'folded': false,
          'allIn': true,
          'holeCards':
              [
                ['Ah', 'Ad'],
                ['Kh', 'Kd'],
                ['Qh', 'Qd'],
              ][seat],
        },
    ],
    'legalActions': <Map<String, dynamic>>[],
    'winnerSeats': winnerSeats,
    'pots': pots,
  };
}

void main() {
  test('keeps distinct main and side-pot winners separate', () {
    final view = LiveHandViewModel.fromJson(
      _terminalView(
        winnerSeats: [0, 1],
        pots: [
          {
            'amount': 300,
            'eligibleSeats': [0, 1, 2],
            'winnerSeats': [0],
          },
          {
            'amount': 200,
            'eligibleSeats': [1, 2],
            'winnerSeats': [1],
          },
        ],
      ),
    );
    final game = view.toGameState(handCount: 1);

    expect(game.awardShareFor(0), 300);
    expect(game.awardShareFor(1), 200);
    expect(game.isSplitPot, isFalse);
  });

  test('marks an actual tied pot as split', () {
    final view = LiveHandViewModel.fromJson(
      _terminalView(
        winnerSeats: [0, 1],
        pots: [
          {
            'amount': 500,
            'eligibleSeats': [0, 1, 2],
            'winnerSeats': [0, 1],
          },
        ],
      ),
    );
    final game = view.toGameState(handCount: 1);

    expect(game.awardShareFor(0), 250);
    expect(game.awardShareFor(1), 250);
    expect(game.isSplitPot, isTrue);
  });
}
