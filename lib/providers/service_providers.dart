/// Shared service providers (DB, Gemini, audio).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/mistake_dao.dart';
import 'package:live_poker_trainer/core/database/scenario_dao.dart';
import 'package:live_poker_trainer/core/database/user_stats_dao.dart';
import 'package:live_poker_trainer/engine/scenario_manager.dart';
import 'package:live_poker_trainer/services/gemini_service.dart';
import 'package:live_poker_trainer/services/mistake_tracker.dart';

/// Drift database singleton.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final scenarioDaoProvider = Provider<ScenarioDao>(
  (ref) => ScenarioDao(ref.watch(appDatabaseProvider)),
);

final userStatsDaoProvider = Provider<UserStatsDao>(
  (ref) => UserStatsDao(ref.watch(appDatabaseProvider)),
);

final mistakeDaoProvider = Provider<MistakeDao>(
  (ref) => MistakeDao(ref.watch(appDatabaseProvider)),
);

/// Leak tracker: persists mistakes, detects repeats, credits improvements.
final mistakeTrackerProvider = Provider<MistakeTracker>(
  (ref) => MistakeTracker(ref.watch(mistakeDaoProvider)),
);

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();
  ref.onDispose(service.dispose);
  return service;
});

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(gemini: ref.watch(geminiServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});

final scenarioManagerProvider = Provider<ScenarioManager>(
  (ref) => ScenarioManager(
    scenarioDao: ref.watch(scenarioDaoProvider),
    statsDao: ref.watch(userStatsDaoProvider),
    gemini: ref.watch(geminiServiceProvider),
  ),
);
