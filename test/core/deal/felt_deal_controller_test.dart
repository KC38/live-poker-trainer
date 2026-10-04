/// Unit tests for one-pass ordered felt dealing.
library;

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/core/deal/felt_deal_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  test('deals holes clockwise then board, each card once', () {
    CardDealPace.debugInstant = false;
    CardDealPace.testScale = 1;
    fakeAsync((async) {
      final lands = <String>[];
      var prevHoles = <int, int>{};
      var prevBoard = 0;
      late final FeltDealController deal;
      deal = FeltDealController(
        onDealt: () {
          for (var seat = 0; seat < 3; seat++) {
            final n = deal.holeVisibleAt(seat);
            final was = prevHoles[seat] ?? 0;
            for (var card = was; card < n; card++) {
              lands.add('h$seat-$card');
            }
            prevHoles[seat] = n;
          }
          while (prevBoard < deal.boardVisible) {
            lands.add('b$prevBoard');
            prevBoard++;
          }
        },
      );

      deal.bind(
        epoch: 'hand-1',
        seatCount: 3,
        dealerIndex: 0,
        boardTarget: 3,
        dealHoles: true,
      );
      async.flushMicrotasks();

      for (var i = 0; i < 8; i++) {
        async.elapse(CardDealPace.dealCard);
      }

      expect(deal.holeVisibleAt(0), 2);
      expect(deal.holeVisibleAt(1), 2);
      expect(deal.holeVisibleAt(2), 2);
      expect(deal.boardVisible, 3);
      // Left of dealer first: seat 1, 2, 0, then second round, then board.
      expect(lands, [
        'h1-0',
        'h2-0',
        'h0-0',
        'h1-1',
        'h2-1',
        'h0-1',
        'b0',
        'b1',
        'b2',
      ]);

      final before = List<String>.of(lands);
      deal.bind(
        epoch: 'hand-1',
        seatCount: 3,
        dealerIndex: 0,
        boardTarget: 3,
        dealHoles: true,
      );
      async.elapse(CardDealPace.dealCard * 2);
      expect(lands, before);

      deal.dispose();
    });
  });

  test('same epoch only extends the board', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      final deal = FeltDealController();
      deal.bind(
        epoch: 'hand-2',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 0,
        dealHoles: true,
      );
      async.flushMicrotasks();
      for (var i = 0; i < 4; i++) {
        async.elapse(CardDealPace.dealCard);
      }
      expect(deal.holeVisibleAt(0), 2);
      expect(deal.holeVisibleAt(1), 2);
      expect(deal.boardVisible, 0);

      deal.bind(
        epoch: 'hand-2',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 3,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(deal.holeVisibleAt(0), 2);
      expect(deal.boardVisible, 1);
      async.elapse(CardDealPace.dealCard);
      expect(deal.boardVisible, 2);
      async.elapse(CardDealPace.dealCard);
      expect(deal.boardVisible, 3);
      expect(deal.holeVisibleAt(0), 2);
      deal.dispose();
    });
  });

  test('instant snaps the full deal', () {
    CardDealPace.debugInstant = true;
    final deal = FeltDealController();
    deal.bind(
      epoch: 'hand-3',
      seatCount: 2,
      dealerIndex: 1,
      boardTarget: 5,
      dealHoles: true,
    );
    expect(deal.holeVisibleAt(0), 2);
    expect(deal.holeVisibleAt(1), 2);
    expect(deal.boardVisible, 5);
    deal.dispose();
  });

  test('rebuilding the same epoch mid-deal does not replay cards', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      var sounds = 0;
      final deal = FeltDealController(onDealt: () => sounds++);
      deal.bind(
        epoch: 'hand-rebuild',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 1,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(sounds, 1);
      expect(deal.holeVisibleAt(1), 1);
      expect(deal.holeVisibleAt(0), 0);

      deal.bind(
        epoch: 'hand-rebuild',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 1,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(sounds, 1);
      expect(deal.holeVisibleAt(1), 1);

      async.elapse(CardDealPace.dealCard);
      expect(sounds, 2);
      expect(deal.holeVisibleAt(0), 1);
      expect(deal.boardVisible, 0);

      for (var i = 0; i < 4; i++) {
        async.elapse(CardDealPace.dealCard);
      }
      expect(deal.holeVisibleAt(0), 2);
      expect(deal.holeVisibleAt(1), 2);
      expect(deal.boardVisible, 1);
      // Four hole cards plus one board card. A replay would land more.
      expect(sounds, 5);
      deal.dispose();
    });
  });

  test('a new epoch drops the in-progress deal and its timer', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      var sounds = 0;
      final deal = FeltDealController(onDealt: () => sounds++);
      deal.bind(
        epoch: 'hand-a',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 3,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(deal.holeVisibleAt(1), 1);
      expect(sounds, 1);

      deal.bind(
        epoch: 'hand-b',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 1,
        dealHoles: true,
      );
      expect(deal.epoch, 'hand-b');
      expect(deal.holeVisibleAt(0), 0);
      expect(deal.holeVisibleAt(1), 0);
      expect(deal.boardVisible, 0);

      async.flushMicrotasks();
      expect(sounds, 2);
      expect(deal.holeVisibleAt(1), 1);
      expect(deal.holeVisibleAt(0), 0);

      async.elapse(CardDealPace.dealCard);
      expect(sounds, 3);
      expect(deal.holeVisibleAt(0), 1);
      expect(deal.boardVisible, 0);

      for (var i = 0; i < 8; i++) {
        async.elapse(CardDealPace.dealCard);
      }
      expect(deal.holeVisibleAt(0), 2);
      expect(deal.holeVisibleAt(1), 2);
      expect(deal.boardVisible, 1);
      // One card from hand-a, then five from hand-b. The abandoned
      // timer must not keep dealing hand-a's flop.
      expect(sounds, 6);
      deal.dispose();
    });
  });

  test('a smaller board target does not hide or replay cards', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      var sounds = 0;
      final deal = FeltDealController(onDealt: () => sounds++);
      deal.bind(
        epoch: 'hand-shrink',
        seatCount: 0,
        dealerIndex: 0,
        boardTarget: 3,
        dealHoles: true,
      );
      async.flushMicrotasks();
      async.elapse(CardDealPace.dealCard * 2);
      expect(deal.boardVisible, 3);
      expect(sounds, 3);

      deal.bind(
        epoch: 'hand-shrink',
        seatCount: 0,
        dealerIndex: 0,
        boardTarget: 1,
        dealHoles: true,
      );
      async.elapse(CardDealPace.dealCard * 3);
      expect(deal.boardVisible, 3);
      expect(sounds, 3);
      deal.dispose();
    });
  });

  test('dispose cancels the card that has not landed yet', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      var sounds = 0;
      final deal = FeltDealController(onDealt: () => sounds++);
      deal.bind(
        epoch: 'hand-dispose',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 5,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(sounds, 1);
      expect(deal.holeVisibleAt(1), 1);

      deal.dispose();
      async.elapse(CardDealPace.dealCard * 8);
      expect(sounds, 1);
      expect(deal.holeVisibleAt(1), 1);
      expect(deal.holeVisibleAt(0), 0);
      expect(deal.boardVisible, 0);
    });
  });

  test('board target clamps and an empty ring deals no holes', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      var sounds = 0;
      final deal = FeltDealController(onDealt: () => sounds++);
      deal.bind(
        epoch: 'hand-clamp',
        seatCount: 0,
        dealerIndex: -3,
        boardTarget: 9,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(deal.boardVisible, 1);
      expect(deal.holeVisibleAt(0), 0);
      async.elapse(CardDealPace.dealCard * 6);
      expect(deal.boardVisible, 5);
      expect(sounds, 5);

      deal.bind(
        epoch: 'hand-none',
        seatCount: 0,
        dealerIndex: 0,
        boardTarget: -1,
        dealHoles: true,
      );
      async.flushMicrotasks();
      async.elapse(CardDealPace.dealCard * 2);
      expect(deal.boardVisible, 0);
      expect(sounds, 5);
      deal.dispose();
    });
  });

  test('dealer indexes outside the ring still deal clockwise', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      final pastEnd = FeltDealController();
      pastEnd.bind(
        epoch: 'dealer-high',
        seatCount: 4,
        dealerIndex: 99,
        boardTarget: 0,
        dealHoles: true,
      );
      async.flushMicrotasks();
      // Clamped to the last seat, so the first card is seat 0.
      expect(pastEnd.holeVisibleAt(0), 1);
      expect(pastEnd.holeVisibleAt(1), 0);
      expect(pastEnd.holeVisibleAt(3), 0);
      pastEnd.dispose();

      final negative = FeltDealController();
      negative.bind(
        epoch: 'dealer-low',
        seatCount: 3,
        dealerIndex: -4,
        boardTarget: 0,
        dealHoles: true,
      );
      async.flushMicrotasks();
      // Clamped to seat 0, so the first card is the left of the button.
      expect(negative.holeVisibleAt(1), 1);
      expect(negative.holeVisibleAt(0), 0);
      expect(negative.holeVisibleAt(2), 0);
      negative.dispose();
    });
  });

  test('turning holes on later does not reset the board', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      var sounds = 0;
      final deal = FeltDealController(onDealt: () => sounds++);
      deal.bind(
        epoch: 'hand-holes-later',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 2,
        dealHoles: false,
      );
      async.flushMicrotasks();
      async.elapse(CardDealPace.dealCard);
      expect(deal.boardVisible, 2);
      expect(deal.holeVisibleAt(0), 0);
      expect(deal.holeVisibleAt(1), 0);
      expect(sounds, 2);

      deal.bind(
        epoch: 'hand-holes-later',
        seatCount: 2,
        dealerIndex: 0,
        boardTarget: 2,
        dealHoles: true,
      );
      async.flushMicrotasks();
      expect(deal.boardVisible, 2);
      expect(deal.holeVisibleAt(1), 1);
      expect(sounds, 3);

      for (var i = 0; i < 4; i++) {
        async.elapse(CardDealPace.dealCard);
      }
      expect(deal.holeVisibleAt(0), 2);
      expect(deal.holeVisibleAt(1), 2);
      expect(deal.boardVisible, 2);
      expect(sounds, 6);
      deal.dispose();
    });
  });

  test('instant mode snaps a new epoch without keeping the previous board', () {
    CardDealPace.debugInstant = true;
    final deal = FeltDealController();
    deal.bind(
      epoch: 'instant-a',
      seatCount: 2,
      dealerIndex: 1,
      boardTarget: 5,
      dealHoles: true,
    );
    expect(deal.boardVisible, 5);

    deal.bind(
      epoch: 'instant-b',
      seatCount: 2,
      dealerIndex: 1,
      boardTarget: 1,
      dealHoles: true,
    );
    expect(deal.holeVisibleAt(0), 2);
    expect(deal.holeVisibleAt(1), 2);
    expect(deal.boardVisible, 1);

    deal.bind(
      epoch: 'instant-b',
      seatCount: 2,
      dealerIndex: 1,
      boardTarget: 4,
      dealHoles: true,
    );
    expect(deal.holeVisibleAt(0), 2);
    expect(deal.boardVisible, 4);
    deal.dispose();
  });
}
