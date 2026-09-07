/// GeminiService request logging for scenario generation (not coaching).
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

String _jsonBody(Map<String, dynamic> payload) => jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': jsonEncode(payload)},
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

Map<String, dynamic> get _scenarioPayload => {
      'table_size': 6,
      'hero_position': 'BTN',
      'hero_hand': ['As', 'Kd'],
      'board_cards': ['Ah', '7c', '2d'],
      'pot_size': 40,
      'villain_seat': 1,
      'villain_archetype': 'Nit',
      'previous_action_narrative': 'opens',
      'villain_action': 'RAISE',
      'call_amount': 20,
      'min_raise': 40,
      'max_raise': 400,
      'optimal_exploit_action': 'FOLD',
      'optimal_sizing_bb': 0,
      'theoretical_ev_explanation': 'fold',
      'exploit_reasoning': 'nits mean it',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => dotenv.loadFromString(
        envString: 'GEMINI_API_KEY=$_key\nANTHROPIC_API_KEY=',
      ));
  tearDown(dotenv.clean);

  test('successful scenario call logs one entry with tokens', () async {
    final logger = _MemoryLogger();
    final client = MockClient((req) async {
      expect(req.url.queryParameters['key'], _key);
      return http.Response(_jsonBody(_scenarioPayload), 200);
    });
    final service = GeminiService(client: client, logger: logger);

    final scenarios = await service.generateScenarios(count: 1);
    expect(scenarios, hasLength(1));

    final e = logger.entries.single;
    expect(e.kind, AiRequestKind.scenario);
    expect(e.modelId, Config.geminiModel);
    expect(e.success, isTrue);
    expect(e.httpStatus, 200);
    expect(e.usage?.prompt, 33);
    expect(e.promptHash, hasLength(64));
  });

  test('retryable failure then success logs two attempts', () async {
    final logger = _MemoryLogger();
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      if (calls == 1) {
        return http.Response('{"error":"overloaded key=$_key"}', 503);
      }
      return http.Response(_jsonBody(_scenarioPayload), 200);
    });
    final service = GeminiService(
      client: client,
      logger: logger,
      retryDelay: Duration.zero,
    );

    final scenarios = await service.generateScenarios(count: 1);
    expect(scenarios, hasLength(1));
    expect(calls, 2);
    expect(logger.entries, hasLength(2));
    expect(logger.entries.first.success, isFalse);
    expect(logger.entries.first.errorMessage, isNot(contains(_key)));
    expect(logger.entries.last.success, isTrue);
  });

  test('redact strips the key from URLs and free text', () {
    final text = 'POST https://x/y?key=$_key failed; token $_key';
    final redacted = GeminiService.redact(text);
    expect(redacted, isNot(contains(_key)));
    expect(redacted, contains('key='));
  });
}
