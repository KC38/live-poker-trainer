/// Player archetype definitions and seat state.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';

/// Villain / hero archetypes with default VPIP/PFR/3-bet frequencies.
enum PlayerArchetype {
  hero('HERO', 'Hero', 'H', 24, 20, 9, AppColors.hero),
  maniac('MANIAC', 'Maniac', 'M', 58, 38, 18, AppColors.maniac),
  nit('NIT', 'Nit', 'N', 13, 10, 3.5, AppColors.nit),
  callingStation(
    'CALLING_STATION',
    'Calling Station',
    'CS',
    46,
    6,
    1.5,
    AppColors.station,
  ),
  tag('TAG', 'TAG', 'T', 23, 19, 8.5, AppColors.tag),
  lag('LAG', 'LAG', 'L', 39, 28, 12, AppColors.lag);

  const PlayerArchetype(
    this.id,
    this.label,
    this.badge,
    this.vpip,
    this.pfr,
    this.threeBet,
    this.color,
  );

  final String id;
  final String label;
  final String badge;
  final double vpip;
  final double pfr;
  final double threeBet;
  final Color color;

  static PlayerArchetype fromLabel(String raw) {
    final key = raw.trim().toLowerCase().replaceAll(' ', '_');
    return switch (key) {
      'hero' => PlayerArchetype.hero,
      'maniac' || 'viktor' => PlayerArchetype.maniac,
      'nit' || 'stan' => PlayerArchetype.nit,
      'calling_station' ||
      'station' ||
      'fred' ||
      'callingstation' =>
        PlayerArchetype.callingStation,
      'tag' || 'alex' => PlayerArchetype.tag,
      'lag' || 'loose' || 'sammy' => PlayerArchetype.lag,
      _ => PlayerArchetype.tag,
    };
  }
}

/// Named villain pool used for default lineups.
class ArchetypeRoster {
  ArchetypeRoster._();

  static const Map<PlayerArchetype, String> defaultNames = {
    PlayerArchetype.maniac: 'Viktor',
    PlayerArchetype.nit: 'Stan',
    PlayerArchetype.callingStation: 'Fred',
    PlayerArchetype.tag: 'Alex',
    PlayerArchetype.lag: 'Sammy',
    PlayerArchetype.hero: 'Hero',
  };

  static const List<PlayerArchetype> villainPool = [
    PlayerArchetype.maniac,
    PlayerArchetype.nit,
    PlayerArchetype.callingStation,
    PlayerArchetype.tag,
    PlayerArchetype.lag,
  ];
}

/// Mutable-ish seat snapshot for a hand.
@immutable
class PlayerModel {
  /// Creates a player seat snapshot.
  const PlayerModel({
    required this.id,
    required this.name,
    required this.archetype,
    required this.stack,
    this.isHero = false,
    this.currentBet = 0,
    this.folded = false,
    this.allIn = false,
    this.holeCards = const [],
    this.hasActedThisRound = false,
    this.lastActionLabel,
  });

  final int id;
  final String name;
  final PlayerArchetype archetype;
  final double stack;
  final bool isHero;
  final double currentBet;
  final bool folded;
  final bool allIn;
  final List<CardModel> holeCards;
  final bool hasActedThisRound;
  final String? lastActionLabel;

  double get vpip => archetype.vpip;
  double get pfr => archetype.pfr;
  double get threeBet => archetype.threeBet;

  PlayerModel copyWith({
    int? id,
    String? name,
    PlayerArchetype? archetype,
    double? stack,
    bool? isHero,
    double? currentBet,
    bool? folded,
    bool? allIn,
    List<CardModel>? holeCards,
    bool? hasActedThisRound,
    String? lastActionLabel,
    bool clearLastAction = false,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      archetype: archetype ?? this.archetype,
      stack: stack ?? this.stack,
      isHero: isHero ?? this.isHero,
      currentBet: currentBet ?? this.currentBet,
      folded: folded ?? this.folded,
      allIn: allIn ?? this.allIn,
      holeCards: holeCards ?? this.holeCards,
      hasActedThisRound: hasActedThisRound ?? this.hasActedThisRound,
      lastActionLabel: clearLastAction
          ? null
          : (lastActionLabel ?? this.lastActionLabel),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'archetype': archetype.id,
        'stack': stack,
        'isHero': isHero,
        'currentBet': currentBet,
        'folded': folded,
        'allIn': allIn,
        'holeCards': holeCards.map((c) => c.toJson()).toList(),
      };
}
