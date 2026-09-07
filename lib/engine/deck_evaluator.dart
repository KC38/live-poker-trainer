/// Seven-card Texas Hold'em hand evaluator with kicker tie-breakers.
library;

import 'dart:math';

import 'package:live_poker_trainer/models/card_model.dart';

/// Result of evaluating a 5–7 card Hold'em hand.
class HandRank {
  /// Creates a hand rank result.
  const HandRank({required this.score, required this.rankName});

  /// Comparable score (higher wins). Encodes category + kickers.
  final int score;

  /// Human-readable category name.
  final String rankName;

  @override
  String toString() => '$rankName ($score)';
}

/// Evaluates the best 5-card Hold'em hand from up to 7 cards.
class DeckEvaluator {
  DeckEvaluator._();

  /// Evaluates [cards] (typically hole + board). Requires at least 5 cards.
  static HandRank evaluate7Cards(List<CardModel> cards) {
    if (cards.length < 5) {
      return const HandRank(score: 0, rankName: 'High Card');
    }
    final sorted = [...cards]..sort((a, b) => b.rank.compareTo(a.rank));

    final suitsCount = <Suit, List<CardModel>>{
      Suit.spades: [],
      Suit.hearts: [],
      Suit.diamonds: [],
      Suit.clubs: [],
    };
    for (final c in sorted) {
      suitsCount[c.suit]!.add(c);
    }

    Suit? flushSuit;
    for (final entry in suitsCount.entries) {
      if (entry.value.length >= 5) {
        flushSuit = entry.key;
        break;
      }
    }

    if (flushSuit != null) {
      final sf = checkStraight(suitsCount[flushSuit]!);
      if (sf > 0) {
        return HandRank(
          score: 8000000 + sf,
          rankName: sf == 14 ? 'Royal Flush' : 'Straight Flush',
        );
      }
    }

    final counts = <int, int>{};
    for (final c in sorted) {
      counts[c.rank] = (counts[c.rank] ?? 0) + 1;
    }

    final pairs = <int>[];
    final trips = <int>[];
    var quads = 0;

    for (final entry in counts.entries) {
      if (entry.value == 4) {
        quads = entry.key;
      } else if (entry.value == 3) {
        trips.add(entry.key);
      } else if (entry.value == 2) {
        pairs.add(entry.key);
      }
    }
    trips.sort((a, b) => b.compareTo(a));
    pairs.sort((a, b) => b.compareTo(a));

    if (quads != 0) {
      final kicker = sorted
          .firstWhere((c) => c.rank != quads, orElse: () => sorted.first)
          .rank;
      return HandRank(
        score: 7000000 + quads * 100 + kicker,
        rankName: 'Four of a Kind',
      );
    }

    if (trips.length >= 2) {
      return HandRank(
        score: 6000000 + trips[0] * 100 + trips[1],
        rankName: 'Full House',
      );
    }
    if (trips.length == 1 && pairs.isNotEmpty) {
      return HandRank(
        score: 6000000 + trips[0] * 100 + pairs[0],
        rankName: 'Full House',
      );
    }

    if (flushSuit != null) {
      final top5 = suitsCount[flushSuit]!.take(5).toList();
      var tieBreaker = 0;
      for (var i = 0; i < top5.length; i++) {
        tieBreaker += top5[i].rank * _pow15(4 - i);
      }
      return HandRank(score: 5000000 + tieBreaker, rankName: 'Flush');
    }

    final straightHigh = checkStraight(sorted);
    if (straightHigh > 0) {
      return HandRank(score: 4000000 + straightHigh, rankName: 'Straight');
    }

    if (trips.length == 1) {
      final kickers =
          sorted.where((c) => c.rank != trips[0]).take(2).toList();
      return HandRank(
        score: 3000000 +
            trips[0] * 1000 +
            (kickers.isNotEmpty ? kickers[0].rank : 0) * 15 +
            (kickers.length > 1 ? kickers[1].rank : 0),
        rankName: 'Three of a Kind',
      );
    }

    if (pairs.length >= 2) {
      final kicker = sorted
          .firstWhere(
            (c) => c.rank != pairs[0] && c.rank != pairs[1],
            orElse: () => sorted.first,
          )
          .rank;
      return HandRank(
        score: 2000000 + pairs[0] * 1000 + pairs[1] * 50 + kicker,
        rankName: 'Two Pair',
      );
    }

    if (pairs.length == 1) {
      final kickers =
          sorted.where((c) => c.rank != pairs[0]).take(3).toList();
      var kickerScore = 0;
      for (var i = 0; i < kickers.length; i++) {
        kickerScore += kickers[i].rank * _pow15(2 - i);
      }
      return HandRank(
        score: 1000000 + pairs[0] * 5000 + kickerScore,
        rankName: 'One Pair',
      );
    }

    final top5 = sorted.take(5).toList();
    var tieBreaker = 0;
    for (var i = 0; i < top5.length; i++) {
      tieBreaker += top5[i].rank * _pow15(4 - i);
    }
    return HandRank(score: tieBreaker, rankName: 'High Card');
  }

  /// Returns the high card of a straight, or 0 if none.
  static int checkStraight(List<CardModel> cardList) {
    final distinct = cardList.map((c) => c.rank).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (distinct.contains(14)) {
      distinct.add(1);
    }
    for (var i = 0; i <= distinct.length - 5; i++) {
      if (distinct[i] - 1 == distinct[i + 1] &&
          distinct[i] - 2 == distinct[i + 2] &&
          distinct[i] - 3 == distinct[i + 3] &&
          distinct[i] - 4 == distinct[i + 4]) {
        return distinct[i];
      }
    }
    return 0;
  }

  static int _pow15(int exp) {
    var result = 1;
    for (var i = 0; i < exp; i++) {
      result *= 15;
    }
    return result;
  }

  /// Builds a shuffled 52-card deck.
  static List<CardModel> buildShuffledDeck([Random? random]) {
    final rng = random ?? Random();
    final deck = <CardModel>[
      for (final suit in Suit.values)
        for (var rank = 2; rank <= 14; rank++)
          CardModel(rank: rank, suit: suit),
    ];
    for (var i = deck.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = deck[i];
      deck[i] = deck[j];
      deck[j] = tmp;
    }
    return deck;
  }
}
