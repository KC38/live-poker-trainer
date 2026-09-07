/// Playing card model with 4-color deck support.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';

/// Playing card suit codes.
enum Suit {
  spades('s'),
  hearts('h'),
  diamonds('d'),
  clubs('c');

  const Suit(this.code);
  final String code;

  static Suit fromCode(String code) {
    return Suit.values.firstWhere(
      (s) => s.code == code.toLowerCase(),
      orElse: () => Suit.spades,
    );
  }

  String get symbol => PokerConstants.suitSymbols[code] ?? code;

  Color get color {
    switch (this) {
      case Suit.spades:
        return AppColors.spades;
      case Suit.hearts:
        return AppColors.hearts;
      case Suit.diamonds:
        return AppColors.diamonds;
      case Suit.clubs:
        return AppColors.clubs;
    }
  }
}

/// A single playing card. Rank is 2–14 (Ace high).
@immutable
class CardModel {
  /// Creates a card with [rank] (2–14) and [suit].
  const CardModel({required this.rank, required this.suit});

  final int rank;
  final Suit suit;

  /// Short code like `As`, `Td`.
  String get code =>
      '${PokerConstants.rankLabels[rank] ?? rank}${suit.code}';

  String get rankLabel => PokerConstants.rankLabels[rank] ?? '$rank';

  String get display => '$rankLabel${suit.symbol}';

  factory CardModel.fromCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length < 2) {
      throw FormatException('Invalid card code: $raw');
    }
    final suitCode = trimmed.substring(trimmed.length - 1).toLowerCase();
    final rankRaw = trimmed.substring(0, trimmed.length - 1).toUpperCase();
    final rank = switch (rankRaw) {
      'A' => 14,
      'K' => 13,
      'Q' => 12,
      'J' => 11,
      'T' || '10' => 10,
      _ => int.parse(rankRaw),
    };
    return CardModel(rank: rank, suit: Suit.fromCode(suitCode));
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('code')) {
      return CardModel.fromCode(json['code'] as String);
    }
    final rank = json['rank'];
    final suit = json['suit'] as String;
    return CardModel(
      rank: rank is int ? rank : int.parse('$rank'),
      suit: Suit.fromCode(suit),
    );
  }

  Map<String, dynamic> toJson() => {'rank': rank, 'suit': suit.code};

  @override
  bool operator ==(Object other) =>
      other is CardModel && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => Object.hash(rank, suit);

  @override
  String toString() => code;
}
