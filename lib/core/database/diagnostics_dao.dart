/// Diagnostics DAO: app sessions, AI request log, settings changes, caught
/// errors, retention pruning, and read helpers for Stats / debug screens.
///
/// Implements [AiRequestLogger] (fed by `GeminiService`) and [DiagnosticsSink]
/// (fed by `DiagnosticsLog`). Every write is a single insert or update and is
/// meant to be awaited off the UI hot path (`unawaited(...)`).
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/core/diagnostics/retention_policy.dart';
import 'package:live_poker_trainer/services/ai_request_log.dart';

/// Build / platform facts recorded with each app session.
class AppSessionInfo {
  /// Creates session info.
  const AppSessionInfo({
    this.appVersion = '',
    this.buildNumber = '',
    this.platform = '',
    this.osVersion = '',
    this.isDebugBuild = false,
  });

  final String appVersion;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final bool isDebugBuild;
}

/// Row counts per logging table (for a debug screen / export header).
class DiagnosticsSummary {
  /// Creates a summary.
  const DiagnosticsSummary({
    required this.sessions,
    required this.aiRequests,
    required this.aiFailures,
    required this.voiceClips,
    required this.hands,
    required this.coachDecisions,
    required this.settingsChanges,
    required this.diagnosticEvents,
  });

  final int sessions;
  final int aiRequests;
  final int aiFailures;
  final int voiceClips;
  final int hands;
  final int coachDecisions;
  final int settingsChanges;
  final int diagnosticEvents;
}

/// Data-access helpers for the diagnostics tables.
class DiagnosticsDao implements AiRequestLogger, DiagnosticsSink {
  /// Creates a DAO bound to [db] with [retention] bounds.
  DiagnosticsDao(this.db, {this.retention = RetentionPolicy.standard});

  final AppDatabase db;
  final RetentionPolicy retention;

  /// `app_sessions.id` for the running process; null until [startSession].
  int? currentSessionId;

  static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  // --- Sessions ---------------------------------------------------------

  /// Opens a session row and makes it current. Returns the row id.
  Future<int> startSession({
    required String sessionUuid,
    AppSessionInfo info = const AppSessionInfo(),
    int? now,
  }) async {
    final ts = now ?? _now();
    final id = await db.into(db.appSessions).insert(
          AppSessionsCompanion.insert(
            sessionUuid: sessionUuid,
            startedAtMs: ts,
            lastSeenAtMs: ts,
            appVersion: Value(info.appVersion),
            buildNumber: Value(info.buildNumber),
            platform: Value(info.platform),
            osVersion: Value(info.osVersion),
            isDebugBuild: Value(info.isDebugBuild),
            schemaVersion: Value(db.schemaVersion),
            createdAtMs: ts,
            updatedAtMs: ts,
          ),
        );
    currentSessionId = id;
    return id;
  }

  /// Records a lifecycle heartbeat; [ended] also stamps `ended_at_ms`.
  Future<void> touchSession({bool ended = false, int? now}) async {
    final id = currentSessionId;
    if (id == null) return;
    final ts = now ?? _now();
    await (db.update(db.appSessions)..where((t) => t.id.equals(id))).write(
      AppSessionsCompanion(
        lastSeenAtMs: Value(ts),
        endedAtMs: ended ? Value(ts) : const Value.absent(),
        updatedAtMs: Value(ts),
      ),
    );
  }

  /// Clears `ended_at_ms` after a resume so the session reads as alive.
  Future<void> resumeSession({int? now}) async {
    final id = currentSessionId;
    if (id == null) return;
    final ts = now ?? _now();
    await (db.update(db.appSessions)..where((t) => t.id.equals(id))).write(
      AppSessionsCompanion(
        lastSeenAtMs: Value(ts),
        endedAtMs: const Value(null),
        updatedAtMs: Value(ts),
      ),
    );
  }

  /// Sessions, newest first.
  Future<List<AppSession>> recentSessions({int limit = 50}) =>
      (db.select(db.appSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAtMs)])
            ..limit(limit))
          .get();

  // --- AI requests -----------------------------------------------------

  @override
  Future<int?> logRequest(AiRequestLogEntry entry) async {
    final prompt = entry.prompt;
    final truncated = retention.truncate(prompt);
    final ts = _now();
    return db.into(db.aiRequests).insert(
          AiRequestsCompanion.insert(
            sessionId: Value(currentSessionId),
            handId: Value(entry.handId),
            requestKind: entry.kind.dbValue,
            modelId: entry.modelId,
            systemInstructionHash: Value(entry.systemInstructionHash),
            promptHash: entry.promptHash,
            promptText: truncated,
            promptFull: Value(
              truncated.length == prompt.length
                  ? null
                  : Uint8List.fromList(utf8.encode(prompt)),
            ),
            requestedAtMs: entry.requestedAt.toUtc().millisecondsSinceEpoch,
            respondedAtMs:
                Value(entry.respondedAt.toUtc().millisecondsSinceEpoch),
            latencyMs: Value(entry.latencyMs),
            httpStatus: Value(entry.httpStatus),
            success: entry.success,
            errorMessage: Value(
              entry.errorMessage == null
                  ? null
                  : retention.truncate(entry.errorMessage!),
            ),
            promptTokens: Value(entry.usage?.prompt),
            responseTokens: Value(entry.usage?.response),
            totalTokens: Value(entry.usage?.total),
            responseText: Value(
              entry.responseText == null
                  ? null
                  : retention.truncate(entry.responseText!),
            ),
            responseBytes: Value(entry.responseBytes),
            attempt: Value(entry.attempt),
            fromCache: Value(entry.fromCache),
            createdAtMs: ts,
          ),
        );
  }

  /// AI requests, newest first, optionally filtered by kind / model.
  Future<List<AiRequest>> recentAiRequests({
    int limit = 100,
    String? kind,
    String? modelId,
    int? sessionId,
  }) {
    final q = db.select(db.aiRequests)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(limit);
    if (kind != null) q.where((t) => t.requestKind.equals(kind));
    if (modelId != null) q.where((t) => t.modelId.equals(modelId));
    if (sessionId != null) q.where((t) => t.sessionId.equals(sessionId));
    return q.get();
  }

  /// Total prompt / response tokens per model (for a usage panel).
  Future<Map<String, ({int requests, int promptTokens, int responseTokens})>>
      tokenUsageByModel() async {
    final count = db.aiRequests.id.count();
    final prompt = db.aiRequests.promptTokens.sum();
    final response = db.aiRequests.responseTokens.sum();
    final q = db.selectOnly(db.aiRequests)
      ..addColumns([db.aiRequests.modelId, count, prompt, response])
      ..groupBy([db.aiRequests.modelId]);
    final rows = await q.get();
    return {
      for (final r in rows)
        r.read(db.aiRequests.modelId)!: (
          requests: r.read(count) ?? 0,
          promptTokens: r.read(prompt) ?? 0,
          responseTokens: r.read(response) ?? 0,
        ),
    };
  }

  // --- Settings changes -------------------------------------------------

  /// Records one changed key. Values are stringified; nulls allowed.
  Future<void> logSettingChange({
    required String key,
    Object? oldValue,
    Object? newValue,
    int? now,
  }) {
    return db.into(db.settingsChanges).insert(
          SettingsChangesCompanion.insert(
            sessionId: Value(currentSessionId),
            settingKey: key,
            oldValue: Value(oldValue?.toString()),
            newValue: Value(newValue?.toString()),
            changedAtMs: now ?? _now(),
          ),
        );
  }

  /// Diffs two settings maps and records every changed key in one batch.
  Future<int> logSettingsDiff(
    Map<String, Object?> before,
    Map<String, Object?> after, {
    int? now,
  }) async {
    final ts = now ?? _now();
    final keys = {...before.keys, ...after.keys};
    final changed = [
      for (final k in keys)
        if (before[k] != after[k]) k,
    ];
    if (changed.isEmpty) return 0;
    await db.batch((b) {
      for (final k in changed) {
        b.insert(
          db.settingsChanges,
          SettingsChangesCompanion.insert(
            sessionId: Value(currentSessionId),
            settingKey: k,
            oldValue: Value(before[k]?.toString()),
            newValue: Value(after[k]?.toString()),
            changedAtMs: ts,
          ),
        );
      }
    });
    return changed.length;
  }

  /// Settings changes, newest first.
  Future<List<SettingsChange>> recentSettingsChanges({int limit = 100}) =>
      (db.select(db.settingsChanges)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(limit))
          .get();

  // --- Diagnostic events -----------------------------------------------

  @override
  Future<void> record(DiagnosticRecord event) => logEvent(
        level: event.level,
        context: event.context,
        message: event.message,
        stackTrace: event.stackTrace,
        extra: event.extra,
        handId: event.handId,
      );

  /// Inserts one diagnostic row.
  Future<int> logEvent({
    required DiagnosticLevel level,
    required String context,
    required String message,
    String? stackTrace,
    Map<String, Object?>? extra,
    int? handId,
    int? now,
  }) {
    return db.into(db.diagnosticEvents).insert(
          DiagnosticEventsCompanion.insert(
            sessionId: Value(currentSessionId),
            handId: Value(handId),
            level: Value(level.name),
            context: context,
            message: retention.truncate(message),
            stackTrace: Value(
              stackTrace == null ? null : retention.truncateStack(stackTrace),
            ),
            extraJson: Value(extra == null ? null : _safeJson(extra)),
            createdAtMs: now ?? _now(),
          ),
        );
  }

  /// Diagnostic events, newest first, optionally filtered by level.
  Future<List<DiagnosticEvent>> recentEvents({
    int limit = 100,
    DiagnosticLevel? level,
    String? context,
  }) {
    final q = db.select(db.diagnosticEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(limit);
    if (level != null) q.where((t) => t.level.equals(level.name));
    if (context != null) q.where((t) => t.context.equals(context));
    return q.get();
  }

  // --- Pruning ----------------------------------------------------------

  /// Applies [retention]: keeps the newest N rows per table and drops rows
  /// older than the configured ages. Returns rows deleted per table.
  Future<Map<String, int>> prune({int? now}) async {
    final ts = now ?? _now();
    final deleted = <String, int>{};

    deleted['ai_requests'] = await _keepNewest(
          db.aiRequests,
          db.aiRequests.id,
          retention.maxAiRequests,
        ) +
        await (db.delete(db.aiRequests)
              ..where(
                (t) => t.createdAtMs
                    .isSmallerThanValue(ts - retention.maxAiRequestAge.inMilliseconds),
              ))
            .go();

    deleted['diagnostic_events'] = await _keepNewest(
          db.diagnosticEvents,
          db.diagnosticEvents.id,
          retention.maxDiagnosticEvents,
        ) +
        await (db.delete(db.diagnosticEvents)
              ..where(
                (t) => t.createdAtMs.isSmallerThanValue(
                  ts - retention.maxDiagnosticEventAge.inMilliseconds,
                ),
              ))
            .go();

    deleted['settings_changes'] = await _keepNewest(
      db.settingsChanges,
      db.settingsChanges.id,
      retention.maxSettingsChanges,
    );

    deleted['coach_decisions'] = await _keepNewest(
      db.coachDecisions,
      db.coachDecisions.id,
      retention.maxCoachDecisions,
    );

    // Hands take their actions with them.
    final handsDeleted = await _keepNewest(
      db.hands,
      db.hands.id,
      retention.maxHands,
    );
    deleted['hands'] = handsDeleted;
    if (handsDeleted > 0) {
      final liveIds = db.selectOnly(db.hands)..addColumns([db.hands.id]);
      deleted['hand_actions'] = await (db.delete(db.handActions)
            ..where((t) => t.handId.isNotInQuery(liveIds)))
          .go();
    } else {
      deleted['hand_actions'] = 0;
    }

    // Sessions: keep the newest N but never the live one.
    deleted['app_sessions'] = await _keepNewest(
      db.appSessions,
      db.appSessions.id,
      retention.maxSessions,
      protectId: currentSessionId,
    );

    deleted['voice_clips'] = await (db.delete(db.voiceClips)
          ..where(
            (t) => t.evictedAtMs.isNotNull() &
                t.evictedAtMs.isSmallerThanValue(
                  ts - retention.evictedVoiceClipAge.inMilliseconds,
                ),
          ))
        .go();

    return deleted;
  }

  /// One-time-ish purge of Gemini-sourced coach artifacts so they cannot be
  /// replayed as live shelf copy.
  ///
  /// Deletes Gemini coach/TTS `ai_requests`, all `voice_clips`, blanks Gemini
  /// `coach_decisions.advice_text`, and clears cached `mistakes.advice_text`.
  /// Safe to call on every launch (idempotent once emptied).
  Future<Map<String, int>> purgeGeminiCoachArtifacts() async {
    final out = <String, int>{};

    out['ai_requests_coach_tts'] = await (db.delete(db.aiRequests)
          ..where(
            (t) =>
                t.requestKind.isIn(['coach', 'tts']) &
                t.modelId.like('%gemini%'),
          ))
        .go();

    // Also drop legacy Gemini coach rows (empty model or spoken-aloud prompt).
    out['ai_requests_coach_legacy'] = await (db.delete(db.aiRequests)
          ..where(
            (t) =>
                t.requestKind.equals('coach') &
                (t.modelId.equals('') |
                    t.promptText.like('%spoken aloud%') |
                    t.modelId.like('%flash%')),
          ))
        .go();

    out['voice_clips'] = await db.delete(db.voiceClips).go();

    final geminiDecisions = await (db.select(db.coachDecisions)
          ..where((t) => t.adviceSource.equals('gemini')))
        .get();
    if (geminiDecisions.isNotEmpty) {
      await (db.update(db.coachDecisions)
            ..where((t) => t.adviceSource.equals('gemini')))
          .write(
        const CoachDecisionsCompanion(
          adviceText: Value(''),
          adviceSource: Value('purged'),
        ),
      );
    }
    out['coach_decisions_gemini'] = geminiDecisions.length;

    // Mistake advice may still hold old Gemini lines shown in Leak Finder.
    final mistakesCleared = await db.customUpdate(
      'UPDATE mistakes SET advice_text = \'\' WHERE length(advice_text) > 0',
      updates: {db.mistakes},
    );
    out['mistakes_advice'] = mistakesCleared;

    return out;
  }

  Future<int> _keepNewest<T extends Table, R>(
    TableInfo<T, R> table,
    GeneratedColumn<int> id,
    int keep, {
    int? protectId,
  }) async {
    if (keep <= 0) return 0;
    final newest = db.selectOnly(table)
      ..addColumns([id])
      ..orderBy([OrderingTerm.desc(id)])
      ..limit(keep);
    final stmt = db.delete(table)
      ..where((_) {
        var pred = id.isNotInQuery(newest);
        if (protectId != null) pred = pred & id.equals(protectId).not();
        return pred;
      });
    return stmt.go();
  }

  // --- Summary / export -------------------------------------------------

  /// Row counts for every logging table.
  Future<DiagnosticsSummary> summary() async {
    Future<int> count(TableInfo table) async {
      final c = countAll();
      final row =
          await (db.selectOnly(table)..addColumns([c])).getSingle();
      return row.read(c) ?? 0;
    }

    final failures = countAll();
    final failRow = await (db.selectOnly(db.aiRequests)
          ..addColumns([failures])
          ..where(db.aiRequests.success.equals(false)))
        .getSingle();

    return DiagnosticsSummary(
      sessions: await count(db.appSessions),
      aiRequests: await count(db.aiRequests),
      aiFailures: failRow.read(failures) ?? 0,
      voiceClips: await count(db.voiceClips),
      hands: await count(db.hands),
      coachDecisions: await count(db.coachDecisions),
      settingsChanges: await count(db.settingsChanges),
      diagnosticEvents: await count(db.diagnosticEvents),
    );
  }

  /// JSON-encodable snapshot of the most recent rows in every logging table
  /// (blobs omitted), ready for an "Export debug log" action.
  Future<Map<String, Object?>> exportDebugLog({int limitPerTable = 200}) async {
    List<Map<String, Object?>> rows(List<DataClass> list) =>
        list.map((r) => _stripBlobs(r.toJson())).toList();

    return {
      'exportedAtMs': _now(),
      'schemaVersion': db.schemaVersion,
      'currentSessionId': currentSessionId,
      'sessions': rows(await recentSessions(limit: limitPerTable)),
      'aiRequests': rows(await recentAiRequests(limit: limitPerTable)),
      'settingsChanges':
          rows(await recentSettingsChanges(limit: limitPerTable)),
      'diagnosticEvents': rows(await recentEvents(limit: limitPerTable)),
      'voiceClips': rows(
        await (db.select(db.voiceClips)
              ..orderBy([(t) => OrderingTerm.desc(t.lastAccessedAtMs)])
              ..limit(limitPerTable))
            .get(),
      ),
      'hands': rows(
        await (db.select(db.hands)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(limitPerTable))
            .get(),
      ),
      'coachDecisions': rows(
        await (db.select(db.coachDecisions)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(limitPerTable))
            .get(),
      ),
    };
  }

  static Map<String, Object?> _stripBlobs(Map<String, dynamic> json) => {
        for (final e in json.entries)
          if (e.value is! Uint8List && e.value is! List<int>)
            e.key: e.value
          else
            e.key: '<${(e.value as List).length} bytes>',
      };

  static String _safeJson(Map<String, Object?> extra) {
    try {
      return jsonEncode(extra);
    } catch (_) {
      return jsonEncode({for (final e in extra.entries) e.key: '${e.value}'});
    }
  }
}
