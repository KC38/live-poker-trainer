/// Unit tests for sequential dealer pacing.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.testScale = 1;
    CardDealPace.debugInstant = null;
  });

  test('holeDelay deals clockwise from the left of the button', () {
    CardDealPace.debugInstant = false;
    const seats = 6;
    const dealer = 3;

    Duration delay(int seat, int card) => CardDealPace.holeDelay(
      seatIndex: seat,
      cardIndex: card,
      seatCount: seats,
      dealerIndex: dealer,
    );

    // Left of the button (seat 4) is first; the button is last in the round.
    expect(delay(4, 0), Duration.zero);
    expect(delay(5, 0), CardDealPace.dealCard);
    expect(delay(0, 0), CardDealPace.dealCard * 2);
    expect(delay(1, 0), CardDealPace.dealCard * 3);
    expect(delay(2, 0), CardDealPace.dealCard * 4);
    expect(delay(3, 0), CardDealPace.dealCard * 5);
    // Second hole card starts after a full clockwise round.
    expect(delay(4, 1), CardDealPace.dealCard * seats);
    expect(delay(3, 1), CardDealPace.dealCard * (seats + 5));
  });

  test('holeDelay clamps the dealer and ignores an empty ring', () {
    CardDealPace.debugInstant = false;
    expect(
      CardDealPace.holeDelay(
        seatIndex: 0,
        cardIndex: 0,
        seatCount: 0,
        dealerIndex: 0,
      ),
      Duration.zero,
    );
    // Dealer past the last seat clamps to seat 5, so seat 0 is first.
    expect(
      CardDealPace.holeDelay(
        seatIndex: 0,
        cardIndex: 0,
        seatCount: 6,
        dealerIndex: 99,
      ),
      Duration.zero,
    );
    expect(
      CardDealPace.holeDelay(
        seatIndex: 5,
        cardIndex: 0,
        seatCount: 6,
        dealerIndex: 99,
      ),
      CardDealPace.dealCard * 5,
    );
  });

  test('boardDelay is zero under the test binding', () {
    expect(CardDealPace.boardDelay(index: 2, alreadyVisible: 0), Duration.zero);
    expect(CardDealPace.boardDelay(index: 3, alreadyVisible: 3), Duration.zero);
  });

  test('dealCard leaves a beat between cards', () {
    CardDealPace.debugInstant = false;
    expect(CardDealPace.dealCardMs, greaterThanOrEqualTo(400));
    expect(CardDealPace.dealCard, const Duration(milliseconds: 420));
  });

  test('dealCard respects testScale when not under widget tests', () {
    // Instant is forced by TestWidgetsFlutterBinding; scale alone stays zero.
    expect(CardDealPace.instant, isTrue);
    CardDealPace.testScale = 0;
    expect(CardDealPace.dealCard, Duration.zero);
  });

  test('boardDelay skips cards already up and scales the rest', () {
    CardDealPace.debugInstant = false;
    CardDealPace.testScale = 2;
    expect(CardDealPace.boardDelay(index: 1, alreadyVisible: 3), Duration.zero);
    expect(CardDealPace.boardDelay(index: 3, alreadyVisible: 3), Duration.zero);
    expect(
      CardDealPace.boardDelay(index: 4, alreadyVisible: 3),
      CardDealPace.dealCard,
    );
    expect(
      CardDealPace.boardDelay(index: 5, alreadyVisible: 3),
      CardDealPace.dealCard * 2,
    );
  });
}
