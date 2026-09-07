/// AnthropicService unit tests with mocked HTTP.
library;

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/services/ai_request_log.dart';
import 'package:live_poker_trainer/services/anthropic_service.dart';

const _key = 'sk-ant-api03-TESTKEY_NOT_REAL_00000000000000000000';

class _MemoryLogger implements AiRequestLogger {
  final List<AiRequestLogEntry> entries = [];

  @override
  Future<int?> logRequest(AiRequestLogEntry entry) async {
    entries.add(entry);
    return entries.length;
  }
}

String _messagesBody(String text) => jsonEncode({
      'id': 'msg_test',
      'type': 'message',
      'role': 'assistant',
      'content': [
        {'type': 'text', 'text': text},
      ],
      'model': 'claude-sonnet-5',
      'usage': {'input_tokens': 40, 'output_tokens': 12},
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.loadFromString(
      envString: 'ANTHROPIC_API_KEY=$_key\nGEMINI_API_KEY=',
    );
  });
  tearDown(dotenv.clean);

  test('successful coach call logs claude model id and text', () async {
    final logger = _MemoryLogger();
    http.Request? seen;
    final client = MockClient((req) async {
      seen = req;
      return http.Response(
        _messagesBody('Fold preflop vs a Nit at the BB — they did not fire.'),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = AnthropicService(client: client, logger: logger);

    final result = await service.coach(
      prompt: 'Street being graded: PREFLOP. Villain role: NOT the aggressor.',
      handId: 9,
    );
    expect(seen, isNotNull);
    expect(seen!.url.toString(), Config.anthropicMessagesUrl);
    expect(seen!.headers['x-api-key'], _key);
    expect(seen!.headers['anthropic-version'], Config.anthropicVersion);
    final body = jsonDecode(seen!.body) as Map<String, dynamic>;
    expect(body['model'], Config.claudeCoachModel);

    expect(result.text, contains('Fold preflop'));
    expect(result.aiRequestId, 1);
    expect(result.fromClaude, isTrue);

    final e = logger.entries.single;
    expect(e.kind, AiRequestKind.coach);
    expect(e.modelId, Config.claudeCoachModel);
    expect(e.success, isTrue);
    expect(e.httpStatus, 200);
    expect(e.handId, 9);
    expect(e.usage?.prompt, 40);
    expect(e.usage?.response, 12);
    expect(e.responseText, contains('Nit'));
    expect(e.errorMessage, isNull);
  });

  test('missing key returns empty without HTTP', () async {
    dotenv.clean();
    dotenv.loadFromString(envString: 'ANTHROPIC_API_KEY=');
    var called = false;
    final client = MockClient((req) async {
      called = true;
      return http.Response('{}', 500);
    });
    final service = AnthropicService(client: client);
    final result = await service.coach(prompt: 'anything');
    expect(result.text, isEmpty);
    expect(called, isFalse);
  });

  test('redact strips anthropic key material', () {
    final raw = 'Authorization $_key and sk-ant-api03-abcDEF123_xyz';
    final scrubbed = AnthropicService.redact(raw);
    expect(scrubbed, isNot(contains(_key)));
    expect(scrubbed, contains('[REDACTED]'));
  });
}
