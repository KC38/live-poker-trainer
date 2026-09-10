/// Allocation-light 7-card evaluator used by the equity simulator.
///
/// [DeckEvaluator] stays the source of truth for showdown and for anything the
/// player sees named ("Two Pair"). This evaluator exists purely for speed: the
/// Monte Carlo equity engine calls it on the order of a hundred thousand times
/// per graded decision, and the map-and-list allocations in [DeckEvaluator]
/// make that far too slow to run inside a frame.
///
/// The two agree on ordering by construction, and `fast_evaluator_test`
/// asserts it across random deals — if they ever disagree, the coach and the
/// pot would be settling on different hands.
library;

import 'package:live_poker_trainer/models/card_model.dart';

/// Hand categories, ordered so a larger value always beats a smaller one.
class HandCategory {
  HandCategory._();

  static const int highCard = 0;
  static const int pair = 1;
  static const int twoPair = 2;
  static const int trips = 3;
  static const int straight = 4;
  static const int flush = 5;
  static const int fullHouse = 6;
  static const int quads = 7;
  static const int straightFlush = 8;

  /// Display name for a category, matching [DeckEvaluator]'s vocabulary.
  static String label(int category) => switch (category) {
        highCard => 'High Card',
        pair => 'One Pair',
        twoPair => 'Two Pair',
        trips => 'Three of a Kind',
        straight => 'Straight',
        flush => 'Flush',
        fullHouse => 'Full House',
        quads => 'Four of a Kind',
        straightFlush => 'Straight Flush',
        _ => 'High Card',
      };
}

/// Fast integer hand scoring over cards encoded as `0..51`.
///
/// A card code is `(rank - 2) * 4 + suitIndex`, so `code >> 2` is the
/// zero-based rank (`0` = deuce, `12` = ace) and `code & 3` is the suit.
class FastEvaluator {
  FastEvaluator._();

  /// Number of distinct cards in a deck.
  static const int deckSize = 52;

  /// Encodes [card] into the `0..51` space this evaluator works in.
  static int encode(CardModel card) =>
      (card.rank - 2) * 4 + card.suit.index;

  /// Decodes [code] back into a [CardModel].
  static CardModel decode(int code) =>
      CardModel(rank: (code >> 2) + 2, suit: Suit.values[code & 3]);

  /// Encodes every card in [cards].
  static List<int> encodeAll(Iterable<CardModel> cards) =>
      [for (final c in cards) encode(c)];

  /// Scores 5–7 [cards] (encoded). Higher is strictly better, and equal scores
  /// are genuine ties.
  ///
  /// The score packs the category into the high bits and up to five ordered
  /// tie-break ranks into four bits each, so comparison is a plain `>`.
  static int score(List<int> cards) {
    var rankMask = 0;
    var suit0 = 0;
    var suit1 = 0;
    var suit2 = 0;
    var suit3 = 0;
    // Two bits per rank is enough to count up to three of a kind; quads are
    // detected from the overflow into the next rank's field, so the counter is
    // read back with a mask rather than trusted raw.
    final counts = _counts;
    for (var i = 0; i < 13; i++) {
      counts[i] = 0;
    }

    for (var i = 0; i < cards.length; i++) {
      final c = cards[i];
      final r = c >> 2;
      rankMask |= 1 << r;
      counts[r]++;
      switch (c & 3) {
        case 0:
          suit0 |= 1 << r;
        case 1:
          suit1 |= 1 << r;
        case 2:
          suit2 |= 1 << r;
        default:
          suit3 |= 1 << r;
      }
    }

    // A flush rules out a full house or quads at seven cards: the five suited
    // cards all have distinct ranks, leaving too few off-suit cards to fill a
    // boat. So returning here cannot skip a stronger category.
    final flushMask = _flushMask(suit0, suit1, suit2, suit3);
    if (flushMask != 0) {
      final sf = _straightHigh(flushMask);
      if (sf >= 0) return _pack(HandCategory.straightFlush, sf, 0, 0, 0, 0);
      return _packMask(HandCategory.flush, flushMask, 5);
    }

    var quad = -1;
    var trip1 = -1;
    var trip2 = -1;
    var pair1 = -1;
    var pair2 = -1;
    for (var r = 12; r >= 0; r--) {
      switch (counts[r]) {
        case 4:
          if (quad < 0) quad = r;
        case 3:
          if (trip1 < 0) {
            trip1 = r;
          } else if (trip2 < 0) {
            trip2 = r;
          }
        case 2:
          if (pair1 < 0) {
            pair1 = r;
          } else if (pair2 < 0) {
            pair2 = r;
          }
      }
    }

    if (quad >= 0) {
      final kicker = _topExcluding(rankMask, 1 << quad, 1);
      return _pack(HandCategory.quads, quad, kicker[0], 0, 0, 0);
    }

    if (trip1 >= 0 && (trip2 >= 0 || pair1 >= 0)) {
      // The second-best trips play as the pair when a hand holds two sets.
      final pairRank = trip2 > pair1 ? trip2 : pair1;
      return _pack(HandCategory.fullHouse, trip1, pairRank, 0, 0, 0);
    }

    final straight = _straightHigh(rankMask);
    if (straight >= 0) {
      return _pack(HandCategory.straight, straight, 0, 0, 0, 0);
    }

    if (trip1 >= 0) {
      final k = _topExcluding(rankMask, 1 << trip1, 2);
      return _pack(HandCategory.trips, trip1, k[0], k[1], 0, 0);
    }

    if (pair2 >= 0) {
      final k = _topExcluding(rankMask, (1 << pair1) | (1 << pair2), 1);
      return _pack(HandCategory.twoPair, pair1, pair2, k[0], 0, 0);
    }

    if (pair1 >= 0) {
      final k = _topExcluding(rankMask, 1 << pair1, 3);
      return _pack(HandCategory.pair, pair1, k[0], k[1], k[2], 0);
    }

    return _packMask(HandCategory.highCard, rankMask, 5);
  }

  /// Scores [cards] given as models. Convenience for tests and one-off calls;
  /// hot loops should encode once and use [score].
  static int scoreCards(List<CardModel> cards) => score(encodeAll(cards));

  /// Category component of a [score] result.
  static int categoryOf(int score) => score >> 20;

  /// Primary tie-break rank of a [score] result — the pair's rank for a pair,
  /// the trips rank for a boat, the top card for a straight.
  static int primaryRankOf(int score) => (score >> 16) & 0xF;

  /// Top rank of a straight present in [rankMask], or `-1`.
  ///
  /// Exposed so draw detection can ask "does adding this rank make a straight"
  /// without rebuilding a card list per candidate.
  static int straightHigh(int rankMask) => _straightHigh(rankMask);

  /// Rank bitmask for [cards], where bit `n` is the rank `n + 2`.
  static int rankMaskOf(List<int> cards) {
    var mask = 0;
    for (var i = 0; i < cards.length; i++) {
      mask |= 1 << (cards[i] >> 2);
    }
    return mask;
  }

  // --- internals ---

  static final List<int> _counts = List<int>.filled(13, 0);
  static final List<int> _kickers = List<int>.filled(5, 0);

  /// Rank mask of the flushed suit, or `0` when no suit has five cards.
  static int _flushMask(int s0, int s1, int s2, int s3) {
    if (_popCount(s0) >= 5) return s0;
    if (_popCount(s1) >= 5) return s1;
    if (_popCount(s2) >= 5) return s2;
    if (_popCount(s3) >= 5) return s3;
    return 0;
  }

  /// Top rank of a straight inside [mask], or `-1`.
  ///
  /// The mask is shifted up one bit so the wheel's ace can occupy position
  /// zero, which makes A-2-3-4-5 fall out of the same consecutive-run scan as
  /// every other straight instead of needing a special case.
  static int _straightHigh(int mask) {
    final extended = (mask << 1) | ((mask >> 12) & 1);
    for (var high = 13; high >= 4; high--) {
      if ((extended >> (high - 4)) & 0x1F == 0x1F) return high - 1;
    }
    return -1;
  }

  /// The [count] highest ranks in [mask] that are not in [excludeMask].
  static List<int> _topExcluding(int mask, int excludeMask, int count) {
    final remaining = mask & ~excludeMask;
    for (var i = 0; i < 5; i++) {
      _kickers[i] = 0;
    }
    var found = 0;
    for (var r = 12; r >= 0 && found < count; r--) {
      if ((remaining >> r) & 1 == 1) {
        _kickers[found++] = r;
      }
    }
    return _kickers;
  }

  static int _packMask(int category, int mask, int count) {
    final top = _topExcluding(mask, 0, count);
    return _pack(category, top[0], top[1], top[2], top[3], top[4]);
  }

  static int _pack(int category, int a, int b, int c, int d, int e) {
    return (category << 20) | (a << 16) | (b << 12) | (c << 8) | (d << 4) | e;
  }

  static int _popCount(int mask) {
    var m = mask;
    var n = 0;
    while (m != 0) {
      m &= m - 1;
      n++;
    }
    return n;
  }
}
