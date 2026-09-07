/// Scenario cache DAO wrapping [AppDatabase] helpers.
library;

import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Data-access helpers for scenario caching and played history.
class ScenarioDao {
  /// Creates a DAO bound to [db].
  ScenarioDao(this.db);

  final AppDatabase db;

  /// Inserts or returns existing scenario id by content hash.
  Future<int> upsert(ScenarioModel scenario) => db.upsertScenario(scenario);

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
