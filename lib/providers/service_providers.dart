/// Shared service providers (DB, Gemini, audio).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/audio/voice_cache.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/diagnostics_dao.dart';
import 'package:live_poker_trainer/core/database/hand_history_dao.dart';
import 'package:live_poker_trainer/core/database/mistake_dao.dart';
import 'package:live_poker_trainer/core/database/scenario_dao.dart';
import 'package:live_poker_trainer/core/database/user_stats_dao.dart';
import 'package:live_poker_trainer/core/database/voice_clip_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/scenario_manager.dart';
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

/// Hand history + coach decisions.
final handHistoryDaoProvider = Provider<HandHistoryDao>(
  (ref) => HandHistoryDao(ref.watch(appDatabaseProvider)),
);

/// Voice clip cache metadata (and blob fallback on web).
final voiceClipDaoProvider = Provider<VoiceClipDao>(
  (ref) => VoiceClipDao(ref.watch(appDatabaseProvider)),
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
  final service = GeminiService(logger: ref.watch(diagnosticsDaoProvider));
  ref.onDispose(service.dispose);
  return service;
});

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(
    gemini: ref.watch(geminiServiceProvider),
    voiceCache: VoiceCache(
      maxBytes: Config.voiceCacheMaxBytes,
      ttl: Config.voiceCacheTtl,
      store: ref.watch(voiceClipDaoProvider),
    ),
  );
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
