/// Ranked list of the 169 starting-hand classes, and top-N% selection over it.
///
/// This is the one hand-authored table in the coach. Everything else about an
/// opponent is derived: an archetype's VPIP and PFR are read as "top N% of all
/// combos", and this ordering decides which hands those percentages actually
/// name. Ordering is by playability against a raising range rather than raw
/// all-in equity, which is why suited connectors sit above the offsuit junk
/// they lose to heads-up.
///
/// The list is exhaustive and duplicate-free by test, so `topPercent` can be
/// trusted to be a real percentage of the 1326 combos rather than a percentage
/// of whatever happened to be listed.
library;

/// Rank characters, weakest to strongest, matching the `2..A` card ranks.
const String _rankChars = '23456789TJQKA';

/// Starting-hand classes and combo-count arithmetic over them.
class PreflopChart {
  PreflopChart._();

  /// Every distinct two-card combination in a deck.
  static const int totalCombos = 1326;

  /// The 169 starting-hand classes, strongest first.
  static const List<String> ranking = [
    'AA', 'KK', 'QQ', 'JJ', 'AKs', 'AQs', 'TT', 'AKo',
    'AJs', 'KQs', '99', 'ATs', 'AQo', 'KJs', '88', 'QJs',
    'KTs', 'A9s', 'AJo', 'QTs', 'KQo', '77', 'JTs', 'A8s',
    'K9s', 'A7s', 'ATo', 'Q9s', 'J9s', 'KJo', 'A5s', '66',
    'T9s', 'A6s', 'A4s', 'QJo', 'Q8s', 'K8s', 'A3s', 'JTo',
    'KTo', 'QTo', '98s', 'T8s', 'A2s', '55', 'J8s', 'Q7s',
    'K7s', '87s', 'Q6s', 'A9o', 'K6s', '97s', 'Q5s', 'T7s',
    '76s', '44', 'K5s', 'J7s', 'A8o', 'Q4s', '86s', 'K4s',
    'Q3s', '65s', 'J6s', '96s', 'T6s', 'Q2s', 'K3s', '54s',
    'A7o', 'J9o', 'K2s', '75s', 'J5s', 'T9o', '33', 'A5o',
    '85s', 'Q9o', 'J4s', '64s', 'A6o', 'T5s', '95s', 'J3s',
    '43s', '22', 'A4o', '74s', 'K9o', 'J2s', 'T4s', '53s',
    '84s', '63s', 'T8o', '98o', 'T3s', '94s', 'A3o', 'Q8o',
    'J8o', '52s', '73s', 'T2s', '42s', '87o', '93s', 'A2o',
    'K8o', '62s', '32s', '83s', '76o', '92s', 'Q7o', '97o',
    'J7o', 'K7o', 'T7o', '82s', '65o', '72s', 'Q6o', '86o',
    'K6o', '54o', 'Q5o', 'J6o', '75o', 'T6o', 'K5o', '96o',
    'Q4o', '64o', 'J5o', 'K4o', '85o', '53o', 'T5o', 'Q3o',
    '43o', 'J4o', 'K3o', '95o', 'Q2o', '74o', 'J3o', '63o',
    'K2o', 'T4o', '84o', '52o', 'J2o', 'T3o', '42o', '94o',
    '32o', '73o', 'T2o', '62o', '83o', '93o', '92o', '72o',
    '82o',
  ];

  /// How many concrete card combinations [label] stands for.
  ///
  /// Six for a pair, four suited, twelve offsuit.
  static int combosFor(String label) {
    if (label.length == 2) return 6;
    return label.endsWith('s') ? 4 : 12;
  }

  /// The strongest classes making up [percent] of all [totalCombos].
  ///
  /// Whole classes only: a range never contains three of the four combos of
  /// KQs, so the returned share lands near [percent] rather than exactly on
  /// it. Values at or below zero give an empty range; values at or above 100
  /// give every hand.
  static List<String> topPercent(double percent) {
    if (percent <= 0) return const [];
    if (percent >= 100) return ranking;
    final target = totalCombos * percent / 100.0;
    final selected = <String>[];
    var accumulated = 0;
    for (final label in ranking) {
      if (accumulated >= target) break;
      selected.add(label);
      accumulated += combosFor(label);
    }
    return selected;
  }

  /// Share of all combos covered by [labels], as a percentage.
  static double percentOf(Iterable<String> labels) {
    var combos = 0;
    for (final label in labels) {
      combos += combosFor(label);
    }
    return combos / totalCombos * 100.0;
  }

  /// Zero-based index of [label] in [ranking], or [ranking].length when the
  /// label is unknown (which sorts it below every real hand).
  static int rankOf(String label) {
    final index = _rankIndex[label];
    return index ?? ranking.length;
  }

  static final Map<String, int> _rankIndex = {
    for (var i = 0; i < ranking.length; i++) ranking[i]: i,
  };

  /// Expands [label] into concrete card-code pairs in [FastEvaluator] coding.
  ///
  /// Codes are `(rank - 2) * 4 + suitIndex`; this file deliberately repeats
  /// that arithmetic rather than importing the evaluator so the chart stays a
  /// pure data table.
  static List<List<int>> expand(String label) {
    final highRank = _rankOfChar(label[0]);
    final lowRank = _rankOfChar(label[1]);
    final out = <List<int>>[];

    if (label.length == 2) {
      for (var s1 = 0; s1 < 4; s1++) {
        for (var s2 = s1 + 1; s2 < 4; s2++) {
          out.add([_code(highRank, s1), _code(lowRank, s2)]);
        }
      }
      return out;
    }

    if (label.endsWith('s')) {
      for (var s = 0; s < 4; s++) {
        out.add([_code(highRank, s), _code(lowRank, s)]);
      }
      return out;
    }

    for (var s1 = 0; s1 < 4; s1++) {
      for (var s2 = 0; s2 < 4; s2++) {
        if (s1 == s2) continue;
        out.add([_code(highRank, s1), _code(lowRank, s2)]);
      }
    }
    return out;
  }

  /// The chart label for a concrete pair of card codes.
  static String labelFor(int cardA, int cardB) {
    final rankA = (cardA >> 2) + 2;
    final rankB = (cardB >> 2) + 2;
    final high = rankA >= rankB ? rankA : rankB;
    final low = rankA >= rankB ? rankB : rankA;
    final highChar = _rankChars[high - 2];
    final lowChar = _rankChars[low - 2];
    if (high == low) return '$highChar$lowChar';
    final suited = (cardA & 3) == (cardB & 3);
    return '$highChar$lowChar${suited ? 's' : 'o'}';
  }

  static int _rankOfChar(String char) => _rankChars.indexOf(char) + 2;

  static int _code(int rank, int suit) => (rank - 2) * 4 + suit;
}
