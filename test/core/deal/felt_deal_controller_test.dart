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
}
