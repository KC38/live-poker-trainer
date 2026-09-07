/// Shared service providers (DB, Gemini, audio).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/diagnostics_dao.dart';
import 'package:live_poker_trainer/core/database/hand_history_dao.dart';
import 'package:live_poker_trainer/core/database/mistake_dao.dart';
import 'package:live_poker_trainer/core/database/scenario_dao.dart';
import 'package:live_poker_trainer/core/database/user_stats_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/scenario_manager.dart';
import 'package:live_poker_trainer/services/app_session_service.dart';
import 'package:live_poker_trainer/services/gemini_service.dart';
import 'package:live_poker_trainer/services/hand_recorder.dart';
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

/// Diagnostics: sessions, AI request log, settings audit, caught errors.
///
/// Also installed as the process-wide [DiagnosticsLog] sink so services
/// without a database handle can report errors.
final diagnosticsDaoProvider = Provider<DiagnosticsDao>((ref) {
  final dao = DiagnosticsDao(ref.watch(appDatabaseProvider));
  DiagnosticsLog.install(dao);
  DiagnosticsLog.redactor = GeminiService.redact;
  ref.onDispose(() => DiagnosticsLog.install(null));
  return dao;
});

/// App session lifecycle (one row per launch) + uncaught-error capture.
final appSessionServiceProvider = Provider<AppSessionService>((ref) {
  final service = AppSessionService(ref.watch(diagnosticsDaoProvider));
  ref.onDispose(() => service.stop());
  return service;
});

/// Hand history + coach decisions.
final handHistoryDaoProvider = Provider<HandHistoryDao>(
  (ref) => HandHistoryDao(ref.watch(appDatabaseProvider)),
);

/// Buffers one hand at a time and writes it through [HandHistoryDao].
final handRecorderProvider = Provider<HandRecorder>((ref) {
  final diagnostics = ref.watch(diagnosticsDaoProvider);
  return HandRecorder(
    ref.watch(handHistoryDaoProvider),
    sessionId: () => diagnostics.currentSessionId,
  );
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  // The logger resolves the DAO on first use so building the Gemini graph
  // (e.g. from a Settings read) never opens the database eagerly.
  final service = GeminiService(
    logger: _LazyRequestLogger(() => ref.read(diagnosticsDaoProvider)),
  );
  ref.onDispose(service.dispose);
  return service;
});

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});

class _LazyRequestLogger implements AiRequestLogger {
  _LazyRequestLogger(this._resolve);
  final AiRequestLogger Function() _resolve;

  @override
  Future<int?> logRequest(AiRequestLogEntry entry) =>
      _resolve().logRequest(entry);
}

final scenarioManagerProvider = Provider<ScenarioManager>(
  (ref) => ScenarioManager(
    scenarioDao: ref.watch(scenarioDaoProvider),
    statsDao: ref.watch(userStatsDaoProvider),
    gemini: ref.watch(geminiServiceProvider),
  ),
);
