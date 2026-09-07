/// Lifetime and per-archetype user progress metrics.
library;

import 'package:flutter/foundation.dart';

/// Aggregated user statistics for the Stats screen.
@immutable
class UserStatsModel {
  /// Creates user stats.
  const UserStatsModel({
    this.totalSpots = 0,
    this.correctSpots = 0,
    this.netEvBb = 0,
    this.archetypeAccuracy = const {},
    this.streetAccuracy = const {},
    this.recentEvDeltas = const [],
  });

  final int totalSpots;
  final int correctSpots;
  final double netEvBb;
  final Map<String, ArchetypeStat> archetypeAccuracy;
  final Map<String, StreetStat> streetAccuracy;
  final List<double> recentEvDeltas;

  double get accuracyPct =>
      totalSpots == 0 ? 0 : (correctSpots / totalSpots) * 100;

  UserStatsModel copyWith({
    int? totalSpots,
    int? correctSpots,
    double? netEvBb,
    Map<String, ArchetypeStat>? archetypeAccuracy,
    Map<String, StreetStat>? streetAccuracy,
    List<double>? recentEvDeltas,
  }) {
    return UserStatsModel(
      totalSpots: totalSpots ?? this.totalSpots,
      correctSpots: correctSpots ?? this.correctSpots,
      netEvBb: netEvBb ?? this.netEvBb,
      archetypeAccuracy: archetypeAccuracy ?? this.archetypeAccuracy,
      streetAccuracy: streetAccuracy ?? this.streetAccuracy,
      recentEvDeltas: recentEvDeltas ?? this.recentEvDeltas,
    );
  }
}

/// Accuracy vs a single archetype.
@immutable
class ArchetypeStat {
  const ArchetypeStat({
    required this.archetype,
    this.played = 0,
    this.correct = 0,
    this.evBb = 0,
  });

  final String archetype;
  final int played;
  final int correct;
  final double evBb;

  double get accuracyPct => played == 0 ? 0 : (correct / played) * 100;

  ArchetypeStat copyWith({int? played, int? correct, double? evBb}) {
    return ArchetypeStat(
      archetype: archetype,
      played: played ?? this.played,
      correct: correct ?? this.correct,
      evBb: evBb ?? this.evBb,
    );
  }
}

/// Accuracy on a given street.
@immutable
class StreetStat {
  const StreetStat({
    required this.street,
    this.played = 0,
    this.correct = 0,
  });

  final String street;
  final int played;
  final int correct;

  double get accuracyPct => played == 0 ? 0 : (correct / played) * 100;

  StreetStat copyWith({int? played, int? correct}) {
    return StreetStat(
      street: street,
      played: played ?? this.played,
      correct: correct ?? this.correct,
    );
  }
}
