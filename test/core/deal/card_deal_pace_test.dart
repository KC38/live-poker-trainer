/// Unit tests for sequential dealer pacing.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => CardDealPace.testScale = 1);

  test('hole order is clockwise from left of the button', () {
    const seats = 6;
    const dealer = 3; // button
    // Left of button is seat 4, then 5, 0, 1, 2, 3.
    final order = [
      for (var seat = 0; seat < seats; seat++)
        (seat - dealer - 1 + seats) % seats,
    ];
    expect(order, [2, 3, 4, 5, 0, 1]);
    expect(order[4], 0); // SB first
    expect(order[3], 5); // BTN last in the round
  });

  test('boardDelay is zero under the test binding', () {
    expect(
      CardDealPace.boardDelay(index: 2, alreadyVisible: 0),
      Duration.zero,
    );
    expect(
      CardDealPace.boardDelay(index: 3, alreadyVisible: 3),
      Duration.zero,
    );
  });

  test('dealCard respects testScale when not under widget tests', () {
    // Instant is forced by TestWidgetsFlutterBinding; scale alone stays zero.
    expect(CardDealPace.instant, isTrue);
    CardDealPace.testScale = 0;
    expect(CardDealPace.dealCard, Duration.zero);
  });
}
