/// Firestore document shape for `users/{uid}/playedScenarios/{scenarioId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One played-scenario receipt for a user.
@immutable
class PlayedScenarioDoc {
  /// Creates a played-scenario document.
  const PlayedScenarioDoc({
    required this.scenarioId,
    required this.playedAt,
    required this.wasCorrect,
    required this.evDeltaBb,
    required this.street,
    required this.archetype,
  });

  /// Scenario pool doc id (`contentHash`).
  final String scenarioId;

  final DateTime playedAt;
  final bool wasCorrect;
  final double evDeltaBb;
  final String street;
  final String archetype;

  /// Parses a Firestore snapshot, or null if missing/malformed.
  static PlayedScenarioDoc? fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    return fromMap(snap.id, data);
  }

  /// Parses a map with [scenarioId] as the document id.
  static PlayedScenarioDoc? fromMap(
    String scenarioId,
    Map<String, dynamic> data,
  ) {
    return PlayedScenarioDoc(
      scenarioId: scenarioId,
      playedAt: _asDateTime(data['playedAt']) ?? DateTime.now().toUtc(),
      wasCorrect: data['wasCorrect'] == true,
      evDeltaBb: _asDouble(data['evDeltaBb'], 0),
      street: '${data['street'] ?? ''}',
      archetype: '${data['archetype'] ?? ''}',
    );
  }

  /// Fields written by [PlayedScenariosRepo.markPlayed].
  Map<String, dynamic> toFirestoreMap({bool useServerTimestamp = true}) {
    return {
      'playedAt': useServerTimestamp
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(playedAt.toUtc()),
      'wasCorrect': wasCorrect,
      'evDeltaBb': evDeltaBb,
      'street': street,
      'archetype': archetype,
    };
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return null;
  }

  static double _asDouble(dynamic value, double fallback) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }
}
