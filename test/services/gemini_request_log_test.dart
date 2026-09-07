/// GeminiService request logging: every HTTP attempt is recorded with model,
/// status, token usage, and a redacted error; retries are numbered; the API
/// key never reaches the log.
library;

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/services/gemini_service.dart';

const _key = 'AIzaTESTSECRETKEY0000';

class _MemoryLogger implements AiRequestLogger {
  final List<AiRequestLogEntry> entries = [];

  @override
  Future<int?> logRequest(AiRequestLogEntry entry) async {
    entries.add(entry);
    return entries.length;
  }
}

String _coachBody(String text) => jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': text},
            ],
          },
        },
      ],
      'usageMetadata': {
        'promptTokenCount': 33,
        'candidatesTokenCount': 9,
        'totalTokenCount': 42,
      },
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => dotenv.loadFromString(envString: 'GEMINI_API_KEY=$_key'));
  tearDown(dotenv.clean);

  test('successful coach call logs one entry with tokens and text', () async {
    final logger = _MemoryLogger();
    final client = MockClient((req) async {
      expect(req.url.queryParameters['key'], _key);
      return http.Response(_coachBody('Fold the river vs a Nit.'), 200);
    });
    final service = GeminiService(client: client, logger: logger);

    final result = await service.coach(prompt: 'hero raised river', handId: 5);
    expect(result.text, 'Fold the river vs a Nit.');
    expect(result.aiRequestId, 1);

    final e = logger.entries.single;
    expect(e.kind, AiRequestKind.coach);
    expect(e.modelId, Config.geminiModel);
    expect(e.success, isTrue);
    expect(e.httpStatus, 200);
    expect(e.attempt, 1);
    expect(e.handId, 5);
    expect(e.usage?.prompt, 33);
    expect(e.usage?.response, 9);
    expect(e.usage?.total, 42);
    expect(e.responseText, contains('Nit'));
    expect(e.promptHash, hasLength(64));
    expect(e.latencyMs, greaterThanOrEqualTo(0));
  });

  test('retryable failure then success logs two attempts', () async {
    final logger = _MemoryLogger();
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      if (calls == 1) {
        return http.Response('{"error":"overloaded key=$_key"}', 503);
      }
      return http.Response(_coachBody('ok'), 200);
    });
    final service = GeminiService(
      client: client,
      logger: logger,
      retryDelay: Duration.zero,
    );

    final result = await service.coach(prompt: 'p');
    expect(result.text, 'ok');
    expect(calls, 2);
    expect(logger.entries, hasLength(2));

    final failed = logger.entries.first;
    expect(failed.success, isFalse);
    expect(failed.httpStatus, 503);
    expect(failed.attempt, 1);
    expect(failed.errorMessage, isNotNull);
    expect(failed.errorMessage, isNot(contains(_key)));
    expect(failed.usage, isNull);

    expect(logger.entries.last.attempt, 2);
    expect(logger.entries.last.success, isTrue);
  });

  test('non-retryable failure logs once and coach falls back to empty text',
      () async {
    final logger = _MemoryLogger();
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      return http.Response('{"error":"bad request"}', 400);
    });
    final service = GeminiService(
      client: client,
      logger: logger,
      retryDelay: Duration.zero,
    );

    final result = await service.coach(prompt: 'p');
    expect(result.text, isEmpty);
    expect(calls, 1);
    expect(logger.entries.single.httpStatus, 400);
    expect(logger.entries.single.success, isFalse);
  });

  test('redact strips the key from URLs and free text', () {
    final text = 'POST https://x/y?key=$_key failed; token $_key';
    final redacted = GeminiService.redact(text);
    expect(redacted, isNot(contains(_key)));
    expect(redacted, contains('key='));
  });

  test('logger failures never break the request', () async {
    final client = MockClient((_) async => http.Response(_coachBody('ok'), 200));
    final service = GeminiService(client: client, logger: _ThrowingLogger());
    final result = await service.coach(prompt: 'p');
    expect(result.text, 'ok');
    expect(result.aiRequestId, isNull);
  });
}

class _ThrowingLogger implements AiRequestLogger {
  @override
  Future<int?> logRequest(AiRequestLogEntry entry) async => throw StateError('db');
}
