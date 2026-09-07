/// DiagnosticsDao: sessions, AI request log, settings audit, diagnostic
/// events, retention pruning, summary, and export against in-memory Drift.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/diagnostics_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/core/diagnostics/retention_policy.dart';
import 'package:live_poker_trainer/services/ai_request_log.dart';

AiRequestLogEntry _entry({
  AiRequestKind kind = AiRequestKind.coach,
  String model = 'gemini-test',
  bool success = true,
  int attempt = 1,
  String prompt = 'Hero raised the river vs a Nit.',
  String? error,
  int? handId,
}) {
  final now = DateTime.now().toUtc();
  return AiRequestLogEntry(
    kind: kind,
    modelId: model,
    prompt: prompt,
    systemInstruction: 'coach system',
    requestedAt: now.subtract(const Duration(milliseconds: 120)),
    respondedAt: now,
    success: success,
    httpStatus: success ? 200 : 500,
    errorMessage: error,
    usage: success
        ? const AiTokenUsage(prompt: 40, response: 12, total: 52)
        : null,
    responseText: success ? 'Fold the river against a Nit.' : null,
    attempt: attempt,
    handId: handId,
  );
}

void main() {
  late AppDatabase db;
  late DiagnosticsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = DiagnosticsDao(db);
  });

  tearDown(() async {
    DiagnosticsLog.install(null);
    await db.close();
  });

  group('sessions', () {
    test('start, heartbeat, end, resume', () async {
      final id = await dao.startSession(
        sessionUuid: 'abc',
        info: const AppSessionInfo(
          appVersion: '1.0.0',
          platform: 'ios',
          isDebugBuild: true,
        ),
        now: 1000,
      );
      expect(dao.currentSessionId, id);

      await dao.touchSession(now: 2000);
      await dao.touchSession(ended: true, now: 3000);
      var row = (await dao.recentSessions()).single;
      expect(row.sessionUuid, 'abc');
      expect(row.startedAtMs, 1000);
      expect(row.lastSeenAtMs, 3000);
      expect(row.endedAtMs, 3000);
      expect(row.platform, 'ios');
      expect(row.schemaVersion, AppDatabase.currentSchemaVersion);

      await dao.resumeSession(now: 4000);
      row = (await dao.recentSessions()).single;
      expect(row.endedAtMs, isNull);
      expect(row.lastSeenAtMs, 4000);
    });
  });

  group('ai requests', () {
    test('logRequest stores hashes, tokens, session and hand links', () async {
      await dao.startSession(sessionUuid: 's1');
      final id = await dao.logRequest(_entry(handId: 7));
      expect(id, isNotNull);

      final rows = await dao.recentAiRequests();
      final r = rows.single;
      expect(r.requestKind, 'coach');
      expect(r.modelId, 'gemini-test');
      expect(r.promptHash, hasLength(64));
      expect(r.systemInstructionHash, hasLength(64));
      expect(r.promptText, contains('Nit'));
      expect(r.promptFull, isNull, reason: 'short prompts are inline only');
      expect(r.success, isTrue);
      expect(r.httpStatus, 200);
      expect(r.promptTokens, 40);
      expect(r.responseTokens, 12);
      expect(r.totalTokens, 52);
      expect(r.latencyMs, greaterThanOrEqualTo(100));
      expect(r.sessionId, dao.currentSessionId);
      expect(r.handId, 7);
      expect(r.attempt, 1);
    });

    test('long prompts keep full text in the blob column', () async {
      final tight = DiagnosticsDao(
        db,
        retention: const RetentionPolicy(maxInlineTextChars: 20),
      );
      await tight.logRequest(_entry(prompt: 'x' * 100));
      final r = (await tight.recentAiRequests()).single;
      expect(r.promptText.length, lessThanOrEqualTo(21));
      expect(r.promptFull, isNotNull);
      expect(r.promptFull!.length, 100);
    });

    test('filters and per-model token totals', () async {
      await dao.logRequest(_entry(model: 'a'));
      await dao.logRequest(_entry(model: 'a', attempt: 2));
      await dao.logRequest(
        _entry(model: 'b', kind: AiRequestKind.tts, success: false, error: 'x'),
      );

      expect(await dao.recentAiRequests(modelId: 'a'), hasLength(2));
      expect(await dao.recentAiRequests(kind: 'tts'), hasLength(1));

      final usage = await dao.tokenUsageByModel();
      expect(usage['a']!.requests, 2);
      expect(usage['a']!.promptTokens, 80);
      expect(usage['a']!.responseTokens, 24);
      expect(usage['b']!.requests, 1);
      expect(usage['b']!.promptTokens, 0);
    });
  });

  group('settings changes', () {
    test('logSettingsDiff records only changed keys', () async {
      final n = await dao.logSettingsDiff(
        {'sfxEnabled': true, 'seatCount': 6, 'bigBlind': 2.0},
        {'sfxEnabled': false, 'seatCount': 6, 'bigBlind': 5.0, 'new': 'x'},
        now: 500,
      );
      expect(n, 3);
      final rows = await dao.recentSettingsChanges();
      final byKey = {for (final r in rows) r.settingKey: r};
      expect(byKey.keys, containsAll(['sfxEnabled', 'bigBlind', 'new']));
      expect(byKey['sfxEnabled']!.oldValue, 'true');
      expect(byKey['sfxEnabled']!.newValue, 'false');
      expect(byKey['new']!.oldValue, isNull);
      expect(byKey['new']!.changedAtMs, 500);
    });

    test('identical maps write nothing', () async {
      expect(await dao.logSettingsDiff({'a': 1}, {'a': 1}), 0);
      expect(await dao.recentSettingsChanges(), isEmpty);
    });
  });

  group('diagnostic events', () {
    test('DiagnosticsLog facade routes into the table', () async {
      DiagnosticsLog.install(dao);
      DiagnosticsLog.redactor = (t) => t.replaceAll('SECRET', '***');
      DiagnosticsLog.error(
        'GeminiService',
        'boom key=SECRET',
        StackTrace.current,
        {'attempt': 2},
        9,
      );
      DiagnosticsLog.warning('VoiceCache', 'evicted');
      // The facade is fire-and-forget; let the inserts land.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final errors = await dao.recentEvents(level: DiagnosticLevel.error);
      expect(errors, hasLength(1));
      expect(errors.single.context, 'GeminiService');
      expect(errors.single.message, contains('***'));
      expect(errors.single.message, isNot(contains('SECRET')));
      expect(errors.single.stackTrace, isNotNull);
      expect(errors.single.extraJson, contains('"attempt":2'));
      expect(errors.single.handId, 9);
      expect(await dao.recentEvents(), hasLength(2));
      DiagnosticsLog.redactor = (t) => t;
    });

    test('stack traces are truncated to the retention bound', () async {
      final tight = DiagnosticsDao(
        db,
        retention: const RetentionPolicy(maxStackTraceChars: 32),
      );
      await tight.logEvent(
        level: DiagnosticLevel.error,
        context: 'c',
        message: 'm',
        stackTrace: 'frame\n' * 50,
      );
      final row = (await tight.recentEvents()).single;
      expect(row.stackTrace!.length, lessThanOrEqualTo(40));
    });
  });

  group('prune', () {
    test('keeps newest rows and drops old ones; protects live session',
        () async {
      final tight = DiagnosticsDao(
        db,
        retention: const RetentionPolicy(
          maxAiRequests: 3,
          maxDiagnosticEvents: 2,
          maxSettingsChanges: 2,
          maxSessions: 1,
          maxDiagnosticEventAge: Duration(days: 1),
        ),
      );
      // Two old sessions, then the live one.
      await tight.startSession(sessionUuid: 'old1', now: 1);
      await tight.startSession(sessionUuid: 'old2', now: 2);
      final live = await tight.startSession(sessionUuid: 'live', now: 3);

      for (var i = 0; i < 6; i++) {
        await tight.logRequest(_entry(prompt: 'p$i'));
      }
      for (var i = 0; i < 5; i++) {
        await tight.logEvent(
          level: DiagnosticLevel.info,
          context: 'c',
          message: 'm$i',
        );
      }
      // One ancient event that survives the count cap but not the age cap.
      await tight.logEvent(
        level: DiagnosticLevel.info,
        context: 'c',
        message: 'ancient',
        now: 0,
      );
      await tight.logSettingsDiff({'a': 1, 'b': 1, 'c': 1}, {'a': 2, 'b': 2, 'c': 2});

      final deleted = await tight.prune();
      expect(deleted['ai_requests'], 3);
      expect(deleted['diagnostic_events'], greaterThanOrEqualTo(4));
      expect(deleted['settings_changes'], 1);
      expect(deleted['app_sessions'], 2);

      final requests = await tight.recentAiRequests();
      expect(requests.map((r) => r.promptText), ['p5', 'p4', 'p3']);
      expect(await tight.recentEvents(), hasLength(lessThanOrEqualTo(2)));
      expect(
        (await tight.recentEvents()).map((e) => e.message),
        isNot(contains('ancient')),
      );
      final sessions = await tight.recentSessions();
      expect(sessions.single.id, live);
    });
  });

  group('summary and export', () {
    test('counts rows and exports JSON-safe maps', () async {
      await dao.startSession(sessionUuid: 's');
      await dao.logRequest(_entry());
      await dao.logRequest(_entry(success: false, error: 'bad'));
      await dao.logEvent(
          level: DiagnosticLevel.error, context: 'x', message: 'y');

      final s = await dao.summary();
      expect(s.sessions, 1);
      expect(s.aiRequests, 2);
      expect(s.aiFailures, 1);
      expect(s.diagnosticEvents, 1);
      expect(s.hands, 0);

      final export = await dao.exportDebugLog();
      expect(export['schemaVersion'], AppDatabase.currentSchemaVersion);
      expect(export['currentSessionId'], dao.currentSessionId);
      expect((export['aiRequests'] as List), hasLength(2));
      expect((export['sessions'] as List), hasLength(1));
    });
  });
}
