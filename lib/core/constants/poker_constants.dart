/// Poker gameplay constants and default table configuration.
library;

/// Default blinds, stack depths, and related gameplay constants.
class PokerConstants {
  PokerConstants._();

  static const double defaultSmallBlind = 1;
  static const double defaultBigBlind = 2;
  static const int defaultSeatCount = 9;
  static const int minSeats = 2;
  static const int maxSeats = 9;
  static const int defaultStackBb = 200;
  static const int defaultRebuyThresholdBb = 50;
  static const bool defaultAutoRebuy = true;
  static const bool defaultSfxEnabled = true;
  static const bool defaultTtsEnabled = true;

  /// Preset stake options as (SB, BB).
  static const List<(double, double)> stakePresets = [
    (0.5, 1),
    (1, 2),
    (2, 5),
    (5, 10),
  ];

  /// Preset stack depths in big blinds.
  static const List<int> stackDepthPresets = [50, 100, 200, 300];

  /// Rank labels for display (2–14 → '2'…'A').
  static const Map<int, String> rankLabels = {
    2: '2',
    3: '3',
    4: '4',
    5: '5',
    6: '6',
    7: '7',
    8: '8',
    9: '9',
    10: 'T',
    11: 'J',
    12: 'Q',
    13: 'K',
    14: 'A',
  };

  static const Map<String, String> suitSymbols = {
    's': '♠',
    'h': '♥',
    'd': '♦',
    'c': '♣',
  };
}
