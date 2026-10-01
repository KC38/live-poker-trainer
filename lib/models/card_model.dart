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
///
/// Teaching distractors may set [rankLabelOverride] (fake rank letter) or
/// [suitSymbolOverride] (e.g. a star fifth suit). Those cards are display-only
/// and must not enter the evaluator or a live deck.
@immutable
class CardModel {
  /// Creates a card with [rank] (2–14) and [suit].
  const CardModel({
    required this.rank,
    required this.suit,
    this.rankLabelOverride,
    this.suitSymbolOverride,
    this.suitColorOverride,
  });

  final int rank;
  final Suit suit;

  /// Fake rank glyph for teaching distractors (e.g. `H`).
  final String? rankLabelOverride;

  /// Fake suit glyph for teaching distractors (e.g. `★`).
  final String? suitSymbolOverride;

  /// Color for [suitSymbolOverride], else [suit.color].
  final Color? suitColorOverride;

  /// Whether this card is a lesson-only distractor, not a real deck card.
  bool get isTeachingDistractor =>
      rankLabelOverride != null || suitSymbolOverride != null;

  /// Short code like `As`, `Td`, `5*`, or `Hs`.
  String get code {
    final rankPart = rankLabelOverride ??
        (PokerConstants.rankLabels[rank] ?? '$rank');
    final suitPart = suitSymbolOverride != null ? '*' : suit.code;
    return '$rankPart$suitPart';
  }

  String get rankLabel =>
      rankLabelOverride ?? PokerConstants.rankLabels[rank] ?? '$rank';

  /// Suit glyph drawn on the face.
  String get suitSymbol => suitSymbolOverride ?? suit.symbol;

  /// Ink color for rank and suit on the face.
  Color get displayColor => suitColorOverride ?? suit.color;

  String get display => '$rankLabel$suitSymbol';

  factory CardModel.fromCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length < 2) {
      throw FormatException('Invalid card code: $raw');
    }
    final suitCode = trimmed.substring(trimmed.length - 1).toLowerCase();
    final rankRaw = trimmed.substring(0, trimmed.length - 1).toUpperCase();

    // Star fifth-suit distractor: e.g. `5*`.
    if (suitCode == '*') {
      final rank = _parseRank(rankRaw);
      return CardModel(
        rank: rank,
        suit: Suit.spades,
        suitSymbolOverride: '★',
        suitColorOverride: AppColors.goldMuted,
      );
    }

    // Fake rank letter distractor: e.g. `Hs` (H of spades).
    if (rankRaw == 'H') {
      return CardModel(
        rank: 0,
        suit: Suit.fromCode(suitCode),
        rankLabelOverride: 'H',
      );
    }

    return CardModel(rank: _parseRank(rankRaw), suit: Suit.fromCode(suitCode));
  }

  static int _parseRank(String rankRaw) {
    return switch (rankRaw) {
      'A' => 14,
      'K' => 13,
      'Q' => 12,
      'J' => 11,
      'T' || '10' => 10,
      _ => int.parse(rankRaw),
    };
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
      other is CardModel &&
      other.rank == rank &&
      other.suit == suit &&
      other.rankLabelOverride == rankLabelOverride &&
      other.suitSymbolOverride == suitSymbolOverride &&
      other.suitColorOverride == suitColorOverride;

  @override
  int get hashCode => Object.hash(
        rank,
        suit,
        rankLabelOverride,
        suitSymbolOverride,
        suitColorOverride,
      );

  @override
  String toString() => code;
}
