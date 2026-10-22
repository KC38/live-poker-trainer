import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/core/deal/felt_deal_controller.dart';
import 'package:live_poker_trainer/core/deal/felt_deal_ledger.dart';
import 'package:live_poker_trainer/ui/widgets/dealt_card_reveal.dart';
import 'package:live_poker_trainer/ui/widgets/felt_deal_ledger_scope.dart';

void main() {
  tearDown(() => CardDealPace.debugInstant = null);

  test('ledger never moves a deal backwards and clears per step', () {
    final ledger = FeltDealLedger();
    ledger.record('h', const FeltDealProgress(holes: {0: 2, 1: 1}, board: 3));
    ledger.record('h', const FeltDealProgress(holes: {0: 1, 1: 2}, board: 0));
    final p = ledger.progressFor('h')!;
    expect(p.holes, {0: 2, 1: 2});
    expect(p.board, 3);
    ledger.record('', const FeltDealProgress(holes: {0: 2}, board: 0));
    ledger.record('x', const FeltDealProgress(holes: {}, board: 0));
    expect(ledger.length, 1);
    ledger.clear();
    expect(ledger.progressFor('h'), isNull);
  });

  test('a fresh controller resumes a recorded deal instead of replaying', () {
    CardDealPace.debugInstant = false;
    final dealt = <int>[];
    final c = FeltDealController(onDealt: () => dealt.add(1));
    c.bind(
      epoch: 'lesson-AhKd',
      seatCount: 6,
      dealerIndex: 0,
      boardTarget: 3,
      dealHoles: true,
      resume: FeltDealProgress(
        holes: {for (var s = 0; s < 6; s++) s: 2},
        board: 3,
      ),
    );
    expect(c.resumed, isTrue);
    expect(c.isComplete, isTrue);
    for (var s = 0; s < 6; s++) {
      expect(c.holeVisibleAt(s), 2);
    }
    expect(c.boardVisible, 3);
    expect(dealt, isEmpty, reason: 'no card dealt (and no SFX) twice');
    c.dispose();
  });

  test('a partial resume deals only what is still missing', () async {
    CardDealPace.debugInstant = false;
    final c = FeltDealController();
    c.bind(
      epoch: 'e',
      seatCount: 2,
      dealerIndex: 0,
      boardTarget: 0,
      dealHoles: true,
      resume: const FeltDealProgress(holes: {1: 1}, board: 0),
    );
    expect(c.holeVisibleAt(1), 1);
    expect(c.holeVisibleAt(0), 0);
    await Future<void>.delayed(Duration.zero);
    // First pending card lands immediately; seat 1's first card stays.
    expect(c.holeVisibleAt(1), greaterThanOrEqualTo(1));
    c.dispose();
  });

  testWidgets('a card key that already landed does not fade in again', (
    tester,
  ) async {
    CardDealPace.debugInstant = false;
    final landed = <Key>{};
    Widget card(Key key) => Directionality(
      textDirection: TextDirection.ltr,
      child: DealtCardRevealSettledScope(
        settled: false,
        landed: landed,
        child: DealtCardReveal(
          key: key,
          playSound: false,
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );
    await tester.pumpWidget(card(const ValueKey('dealt-hole-0-0')));
    await tester.pump();
    expect(landed, contains(const ValueKey('dealt-hole-0-0')));
    // Remount the same card (e.g. its seat row changed shape on lock).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(card(const ValueKey('dealt-hole-0-0')));
    final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacity.opacity, 1, reason: 'remounted card must not fade in');
    // A card that never landed still deals in.
    await tester.pumpWidget(card(const ValueKey('dealt-board-0')));
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      0,
    );
    await tester.pump(const Duration(milliseconds: 300));
  });
}
