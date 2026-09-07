/// Scenario cache DAO wrapping [AppDatabase] helpers.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Data-access helpers for scenario caching and played history.
class ScenarioDao {
  /// Creates a DAO bound to [db].
  ScenarioDao(this.db);

  final AppDatabase db;

  /// JSON shape version written into `scenarios.payload_version`.
  static const int payloadVersion = 1;

  /// Inserts or returns existing scenario id by content hash.
  ///
  /// [source] is `gemini` or `offline`; [modelId] names the generator. A
  /// duplicate hash only bumps `last_updated_at_ms` on the existing row.
  Future<int> upsert(
    ScenarioModel scenario, {
    String source = 'gemini',
    String modelId = '',
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final existing = await (db.select(db.scenarios)
          ..where((t) => t.contentHash.equals(scenario.contentHash)))
        .getSingleOrNull();
    if (existing != null) {
      await (db.update(db.scenarios)..where((t) => t.id.equals(existing.id)))
          .write(ScenariosCompanion(lastUpdatedAtMs: Value(now)));
      return existing.id;
    }
    return db.into(db.scenarios).insert(
          ScenariosCompanion.insert(
            contentHash: scenario.contentHash,
            payloadJson: jsonEncode(scenario.toJson()),
            source: Value(source),
            modelId: Value(modelId),
            generatedAtMs: Value(now),
            lastUpdatedAtMs: Value(now),
            payloadVersion: const Value(payloadVersion),
          ),
        );
  }

  /// Records that scenario [scenarioId] was handed to the table.
  Future<void> markServed(int scenarioId) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db.customUpdate(
      'UPDATE scenarios SET times_served = times_served + 1, '
      'last_served_at_ms = ? WHERE id = ?',
      variables: [Variable.withInt(now), Variable.withInt(scenarioId)],
      updates: {db.scenarios},
    );
  }

  /// Cache metadata rows, newest first (for Stats / debug screens).
  Future<List<Scenario>> cacheRows({int limit = 200}) =>
      (db.select(db.scenarios)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(limit))
          .get();

  /// Played history for [scenarioId], newest first.
  Future<List<PlayedScenario>> playedHistory(int scenarioId) =>
      (db.select(db.playedScenarios)
            ..where((t) => t.scenarioId.equals(scenarioId))
            ..orderBy([(t) => OrderingTerm.desc(t.playedAt)]))
          .get();

  /// Unplayed scenarios for the local user.
  Future<List<ScenarioModel>> unplayed({
    String userId = Config.defaultUserId,
    int limit = 20,
  }) =>
      db.getUnplayedScenarios(userId: userId, limit: limit);

  /// Count remaining unplayed scenarios (prefetch trigger).
  Future<int> unplayedCount({String userId = Config.defaultUserId}) =>
      db.countUnplayed(userId: userId);

  /// Records that a scenario was played.
  Future<void> markPlayed({
    required int scenarioId,
    String userId = Config.defaultUserId,
    required bool wasCorrect,
    required double evDeltaBb,
    required String street,
    required String archetype,
  }) =>
      db.markScenarioPlayed(
        scenarioId: scenarioId,
        userId: userId,
        wasCorrect: wasCorrect,
        evDeltaBb: evDeltaBb,
        street: street,
        archetype: archetype,
      );
}
