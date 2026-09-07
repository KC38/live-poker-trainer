/// User stats DAO wrapping [AppDatabase] helpers.
library;

import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

/// Data-access helpers for lifetime EV and accuracy metrics.
class UserStatsDao {
  /// Creates a DAO bound to [db].
  UserStatsDao(this.db);

  final AppDatabase db;

  /// Loads aggregate stats for [userId].
  Future<UserStatsModel> getStats({String userId = Config.defaultUserId}) =>
      db.getUserStats(userId: userId);

  /// Records a practice grading outcome.
  Future<UserStatsModel> recordPracticeResult({
    String userId = Config.defaultUserId,
    required bool wasCorrect,
    required double evDeltaBb,
    required String street,
    required String archetype,
  }) =>
      db.recordPracticeResult(
        userId: userId,
        wasCorrect: wasCorrect,
        evDeltaBb: evDeltaBb,
        street: street,
        archetype: archetype,
      );
}
