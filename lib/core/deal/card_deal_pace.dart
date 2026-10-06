/// Timing for one-card-at-a-time felt deals (live table and lessons).
library;

import 'package:flutter/widgets.dart';

/// Spacing between consecutive dealt cards, like a real dealer.
class CardDealPace {
  CardDealPace._();

  /// Multiplier for widget / provider tests. `0` makes every deal instant.
  static double testScale = 1;

  /// Gap between one card and the next in a deal sequence.
  ///
  /// Long enough that each deal clip finishes with a beat of silence, like a
  /// live dealer placing cards one at a time.
  static const int dealCardMs = 420;

  /// When set, overrides [instant] (widget tests that assert real pacing).
  @visibleForTesting
  static bool? debugInstant;

  /// True when deals should appear all at once (tests).
  static bool get instant {
    if (debugInstant != null) return debugInstant!;
    if (testScale <= 0) return true;
    try {
      final binding = WidgetsBinding.instance.runtimeType.toString();
      return binding.contains('TestWidgetsFlutterBinding');
    } on Object {
      return false;
    }
  }

  static Duration _scaled(int milliseconds) {
    if (instant) return Duration.zero;
    return Duration(microseconds: (milliseconds * 1000 * testScale).round());
  }

  /// Delay before the next card in a sequential deal.
  static Duration get dealCard => _scaled(dealCardMs);

  /// Delay for board card [index] when [alreadyVisible] cards were already up.
  static Duration boardDelay({
    required int index,
    required int alreadyVisible,
  }) {
    if (index < alreadyVisible) return Duration.zero;
    return dealCard * (index - alreadyVisible);
  }

  /// Delay for hole card [cardIndex] (0 or 1) at [seatIndex].
  ///
  /// Order matches a live dealer: one round clockwise from the left of the
  /// button, then a second round for the second hole card.
  static Duration holeDelay({
    required int seatIndex,
    required int cardIndex,
    required int seatCount,
    required int dealerIndex,
  }) {
    if (seatCount <= 0) return Duration.zero;
    final dealer = dealerIndex.clamp(0, seatCount - 1);
    final fromButton = (seatIndex - dealer - 1 + seatCount) % seatCount;
    final sequence = cardIndex * seatCount + fromButton;
    return dealCard * sequence;
  }
}
