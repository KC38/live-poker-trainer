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

  /// Firestore `stats` map mirroring the Drift user_stats_rows shape.
  Map<String, Object?> toFirestoreMap() => {
        'totalSpots': totalSpots,
        'correctSpots': correctSpots,
        'netEvBb': netEvBb,
        'archetypeAccuracy': {
          for (final e in archetypeAccuracy.entries)
            e.key: {
              'played': e.value.played,
              'correct': e.value.correct,
              'evBb': e.value.evBb,
            },
        },
        'streetAccuracy': {
          for (final e in streetAccuracy.entries)
            e.key: {
              'played': e.value.played,
              'correct': e.value.correct,
            },
        },
        'recentEvDeltas': recentEvDeltas,
      };

  /// Parses Firestore `stats` (tolerates missing keys).
  factory UserStatsModel.fromFirestoreMap(Map<String, dynamic> data) {
    final archRaw = data['archetypeAccuracy'];
    final streetRaw = data['streetAccuracy'];
    final recentRaw = data['recentEvDeltas'];
    return UserStatsModel(
      totalSpots: (data['totalSpots'] as num?)?.toInt() ?? 0,
      correctSpots: (data['correctSpots'] as num?)?.toInt() ?? 0,
      netEvBb: (data['netEvBb'] as num?)?.toDouble() ?? 0,
      archetypeAccuracy: archRaw is Map
          ? archRaw.map((k, v) {
              final m = Map<String, dynamic>.from(v as Map);
              return MapEntry(
                k.toString(),
                ArchetypeStat(
                  archetype: k.toString(),
                  played: (m['played'] as num?)?.toInt() ?? 0,
                  correct: (m['correct'] as num?)?.toInt() ?? 0,
                  evBb: (m['evBb'] as num?)?.toDouble() ?? 0,
                ),
              );
            })
          : const {},
      streetAccuracy: streetRaw is Map
          ? streetRaw.map((k, v) {
              final m = Map<String, dynamic>.from(v as Map);
              return MapEntry(
                k.toString(),
                StreetStat(
                  street: k.toString(),
                  played: (m['played'] as num?)?.toInt() ?? 0,
                  correct: (m['correct'] as num?)?.toInt() ?? 0,
                ),
              );
            })
          : const {},
      recentEvDeltas: recentRaw is List
          ? recentRaw.map((e) => (e as num).toDouble()).toList()
          : const [],
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
