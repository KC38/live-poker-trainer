/// Parsing contract for streamed liveActionFeed snapshots.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/firestore/live_hand_service.dart';

void main() {
  test('reads waitingOnSeat and coaching status from a feed snapshot', () {
    final acting = LiveActionFeedUpdate.fromJson({
      'sessionId': 'session-1',
      'decisionId': 'node-root',
      'street': 'flop',
      'status': 'acting',
      'waitingOnSeat': 3.0,
      'board': ['2c', '7d', 'Kh'],
      'events': [
        {
          'sequence': 1,
          'seat': 3,
          'street': 'flop',
          'actionId': 'CHECK:0',
          'kind': 'CHECK',
          'bucket': 'CHECK',
        },
      ],
    });

    expect(acting.sessionId, 'session-1');
    expect(acting.decisionId, 'node-root');
    expect(acting.street, 'flop');
    expect(acting.status, 'acting');
    expect(acting.isCoaching, isFalse);
    expect(acting.waitingOnSeat, 3);
    expect(acting.board, ['2c', '7d', 'Kh']);
    expect(acting.events.single.kind, 'CHECK');

    final coaching = LiveActionFeedUpdate.fromJson({
      'sessionId': 'session-1',
      'decisionId': 'node-root',
      'status': 'coaching',
      'waitingOnSeat': 3,
    });
    expect(coaching.isCoaching, isTrue);
    expect(coaching.waitingOnSeat, 3);
    expect(coaching.street, 'preflop');
    expect(coaching.events, isEmpty);
  });

  test('ignores non-numeric waitingOnSeat and non-map events', () {
    final update = LiveActionFeedUpdate.fromJson({
      'waitingOnSeat': '1',
      'events': [
        'skip-me',
        {
          'sequence': 2,
          'seat': 1,
          'street': 'turn',
          'actionId': 'BET:400',
          'kind': 'BET',
          'bucket': 'BET_50',
          'amountTo': 4,
        },
      ],
    });

    expect(update.waitingOnSeat, isNull);
    expect(update.status, 'acting');
    expect(update.isCoaching, isFalse);
    expect(update.events, hasLength(1));
    expect(update.events.single.amountTo, 4);
  });
}
