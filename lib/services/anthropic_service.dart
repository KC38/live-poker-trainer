/// Anthropic Messages API client for live coach narration.
///
/// Coaching text is Claude-only. Gemini is never consulted for advice.
/// Every HTTP attempt is reported to an optional [AiRequestLogger] so the
/// `ai_requests` table records model id, latency, and redacted errors.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/services/ai_request_log.dart';

/// Result of a coach text turn from Claude.
class CoachTextResult {
  /// Creates a coach text result.
  const CoachTextResult({
    required this.text,
    this.aiRequestId,
  });

  final String text;

  /// `ai_requests.id` of the coach text call, when it was logged.
  final int? aiRequestId;

  /// Whether the text came from Claude (vs. an empty fallback).
  bool get fromClaude => text.trim().isNotEmpty;
}

/// Thrown for non-2xx Anthropic responses; the body is already redacted.
class AnthropicHttpException implements Exception {
  /// Creates an HTTP exception.
  const AnthropicHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  /// Whether a retry is reasonable (rate limit / server error).
  bool get retryable => statusCode == 429 || statusCode >= 500;

  @override
  String toString() => 'Anthropic HTTP $statusCode: $body';
}

/// REST client for Anthropic Messages (coach text only).
class AnthropicService {
  /// Creates an Anthropic service.
  ///
  /// [client] is injectable for tests; [logger] receives one entry per HTTP
  /// attempt; [maxAttempts] bounds retries on 429 / 5xx / network errors.
  AnthropicService({
    http.Client? client,
    AiRequestLogger? logger,
    this.maxAttempts = 2,
    this.retryDelay = const Duration(milliseconds: 400),
  })  : _client = client ?? http.Client(),
        _logger = logger;

  final http.Client _client;
  final AiRequestLogger? _logger;

  /// Total attempts per request, including the first.
  final int maxAttempts;

  /// Base back-off between attempts (multiplied by the attempt number).
  final Duration retryDelay;

  bool get hasApiKey => Config.hasAnthropicKey;

  /// Coach sampling temperature — low so narration stays on the slot-fill
  /// contract instead of inventing strategy.
  static const double coachTemperature = 0.25;

  /// System prompt for coach narration. Persona is voice only; facts stay
  /// locked by the slot-fill contract and [CoachAdviceGuard].
  static const coachSystemPrompt = '''
You are ${CoachPersona.name}, ${CoachPersona.blurb}.
You are a slot-fill narrator for an exploitative live No-Limit Hold'em coach.
You do NOT invent strategy. The grade already decided the line; you only voice
locked facts in a tight template.

${CoachPersona.styleGuide}

You receive ONE graded decision with: street, hero cards, board, pot, call
amount, positions, villain name + archetype, aggressor flag, hero action,
recommended action, CORRECT/INCORRECT, equity%, price (required equity%),
and curriculum reason codes with required phrases.

Respond with 1-2 sentences, under 36 words, as text on the coach shelf.

REQUIRED slots — every reply MUST include all of:
1. The graded street (by name).
2. The villain archetype (by name).
3. The equity% and, when a call is priced, the required equity% — quote the
   numbers exactly; never change them.
4. An endorsement of the recommended action only.
5. The curriculum reason phrase(s) from the prompt — prefer verbatim wording;
   do not substitute a different principle.

CRITICAL accuracy rules:
- No free-form strategy invention. No multi-street lines the grade did not
  price. No reasons outside the curriculum phrases.
- Never invent aggressors. If the villain is NOT the aggressor (e.g. only
  posted the big blind), do not say they "fired", "bet", "raised", or "led".
  Describe facing a price / completing / calling instead.
- Ground every sentence in the given street. Never name a different street.
- Position labels (SB/BB/BTN/UTG/…) are facts — do not reassign them.
- Endorse the recommended action only. If FOLD, never urge calling. If CALL,
  never urge folding. If RAISE/BET, never fold.
- Never contradict yourself inside one reply.
- Never use markdown, bullets, asterisks, or greetings.

When the prompt includes "Leak history" for a repeated mistake, open by
saying it is a repeat, quote the occurrence count, and name the pattern.
When it describes a fixed leak, open by acknowledging the improvement.
In those cases you may use up to 42 words.
''';

  static const _coachSystem = coachSystemPrompt;

  /// Removes Anthropic and Gemini keys (and `key=` / `sk-ant-` values) from
  /// [text] before anything is logged.
  static String redact(String text) {
    var out = text;
    final anthropic = Config.anthropicApiKey;
    if (anthropic.isNotEmpty) out = out.replaceAll(anthropic, '[REDACTED]');
    final gemini = Config.geminiApiKey;
    if (gemini.isNotEmpty) out = out.replaceAll(gemini, '[REDACTED]');
    out = out.replaceAllMapped(
      RegExp(r'([?&]key=)[^&\s"]+'),
      (m) => '${m[1]}[REDACTED]',
    );
    out = out.replaceAllMapped(
      RegExp(r'sk-ant-api03-[A-Za-z0-9_-]+'),
      (_) => 'sk-ant-api03-[REDACTED]',
    );
    return out;
  }

  /// Coach text for one graded decision.
  ///
  /// Returns empty text when no key is configured or the call fails so the
  /// caller keeps its offline [LeakLines] / [CoachLines] fallback.
  Future<CoachTextResult> coach({
    required String prompt,
    int? handId,
  }) async {
    if (!hasApiKey || prompt.trim().isEmpty) {
      return const CoachTextResult(text: '');
    }
    try {
      final result = await _post(
        kind: AiRequestKind.coach,
        prompt: prompt,
        system: _coachSystem,
        handId: handId,
        body: {
          'model': Config.claudeCoachModel,
          'max_tokens': 180,
          'temperature': coachTemperature,
          'system': _coachSystem,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        },
      );
      return CoachTextResult(
        text: _extractText(result.json) ?? '',
        aiRequestId: result.requestId,
      );
    } catch (e, s) {
      DiagnosticsLog.error('AnthropicService.coach', e, s, null, handId);
      return const CoachTextResult(text: '');
    }
  }

  Future<({Map<String, dynamic> json, int? requestId})> _post({
    required AiRequestKind kind,
    required String prompt,
    required String system,
    required Map<String, dynamic> body,
    int? handId,
  }) async {
    final modelId = Config.claudeCoachModel;
    final uri = Uri.parse(Config.anthropicMessagesUrl);
    final encoded = jsonEncode(body);
    final attempts = maxAttempts < 1 ? 1 : maxAttempts;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': Config.anthropicApiKey,
      'anthropic-version': Config.anthropicVersion,
    };

    Object? lastError;
    for (var attempt = 1; attempt <= attempts; attempt++) {
      final requestedAt = DateTime.now().toUtc();
      int? status;
      Map<String, dynamic>? json;
      Object? error;
      try {
        final res = await _client.post(uri, headers: headers, body: encoded);
        status = res.statusCode;
        if (status < 200 || status >= 300) {
          throw AnthropicHttpException(status, redact(res.body));
        }
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (e) {
        error = e;
      }
      final respondedAt = DateTime.now().toUtc();

      final requestId = await _log(
        AiRequestLogEntry(
          kind: kind,
          modelId: modelId,
          prompt: prompt,
          systemInstruction: system,
          requestedAt: requestedAt,
          respondedAt: respondedAt,
          success: json != null,
          httpStatus: status,
          errorMessage: error == null ? null : redact('$error'),
          usage: json == null ? null : _usageFromAnthropic(json),
          responseText: json == null ? null : redact(_extractText(json) ?? ''),
          attempt: attempt,
          handId: handId,
        ),
      );

      if (json != null) return (json: json, requestId: requestId);

      lastError = error;
      final retryable = error is AnthropicHttpException
          ? error.retryable
          : error is http.ClientException || error is TimeoutException;
      if (!retryable || attempt == attempts) break;
      await Future<void>.delayed(retryDelay * attempt);
    }
    throw lastError ?? Exception('Anthropic request failed');
  }

  Future<int?> _log(AiRequestLogEntry entry) async {
    final logger = _logger;
    if (logger == null) return null;
    try {
      return await logger.logRequest(entry);
    } catch (_) {
      return null;
    }
  }

  static AiTokenUsage? _usageFromAnthropic(Map<String, dynamic> json) {
    final usage = json['usage'];
    if (usage is! Map) return null;
    int? read(String key) {
      final v = usage[key];
      return v is num ? v.toInt() : null;
    }

    final prompt = read('input_tokens');
    final response = read('output_tokens');
    if (prompt == null && response == null) return null;
    final total = (prompt ?? 0) + (response ?? 0);
    return AiTokenUsage(
      prompt: prompt,
      response: response,
      total: total > 0 ? total : null,
    );
  }

  String? _extractText(Map<String, dynamic> response) {
    final content = response['content'];
    if (content is! List) return null;
    final buffer = StringBuffer();
    for (final part in content) {
      if (part is Map && part['type'] == 'text' && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Closes the HTTP client.
  void dispose() => _client.close();
}
