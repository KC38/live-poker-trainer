/// Gemini scenario generation, coach text, and coach speech synthesis.
///
/// Every HTTP attempt is reported to an optional [AiRequestLogger] with model,
/// prompt hashes, latency, status, token usage and a redacted error, so the
/// `ai_requests` table is a complete record of what the app asked and got.
/// The API key is scrubbed from anything that leaves this file.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:live_poker_trainer/core/audio/wav_codec.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/services/ai_request_log.dart';

export 'package:live_poker_trainer/services/ai_request_log.dart'
    show AiRequestKind, AiRequestLogEntry, AiRequestLogger, AiTokenUsage;

/// Result of a coach turn.
class CoachAudioResult {
  /// Creates a coach result.
  const CoachAudioResult({
    required this.text,
    this.audioBytes,
    this.audioMimeType,
    this.aiRequestId,
  });

  final String text;

  /// WAV-wrapped speech, when synthesized.
  final Uint8List? audioBytes;

  /// MIME for [audioBytes] (`audio/wav` after normalization).
  final String? audioMimeType;

  /// `ai_requests.id` of the coach text call, when it was logged.
  final int? aiRequestId;

  /// Whether the text came from Gemini (vs. an empty fallback).
  bool get fromGemini => text.trim().isNotEmpty;
}

/// Thrown for non-2xx Gemini responses; the body is already redacted.
class GeminiHttpException implements Exception {
  /// Creates an HTTP exception.
  const GeminiHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  /// Whether a retry is reasonable (rate limit / server error).
  bool get retryable => statusCode == 429 || statusCode >= 500;

  @override
  String toString() => 'Gemini HTTP $statusCode: $body';
}

/// REST client for Gemini generateContent (JSON scenarios, coach, speech).
class GeminiService {
  /// Creates a Gemini service.
  ///
  /// [client] is injectable for tests; [logger] receives one entry per HTTP
  /// attempt; [maxAttempts] bounds retries on 429 / 5xx / network errors.
  GeminiService({
    http.Client? client,
    AiRequestLogger? logger,
    this.maxAttempts = 2,
    this.retryDelay = const Duration(milliseconds: 400),
  })  : _client = client ?? http.Client(),
        // ignore: prefer_initializing_formals
        _logger = logger;

  final http.Client _client;
  final AiRequestLogger? _logger;

  /// Total attempts per request, including the first.
  final int maxAttempts;

  /// Base back-off between attempts (multiplied by the attempt number).
  final Duration retryDelay;

  bool get hasApiKey => Config.hasGeminiKey;

  static const _scenarioSystem = '''
You are a game theory and exploitative poker scenario architect for \$1/\$2 to \$5/\$10 No-Limit Hold'em.
Output valid JSON containing an intense decision spot. Include: table_size (2-9), hero_position, hero_hand, board_cards (flop, turn, river up to spot), pot_size, villain_seat, villain_archetype ('Maniac', 'Nit', 'Calling Station', 'TAG', 'LAG'), previous_action_narrative, villain_action, call_amount, min_raise, max_raise, optimal_exploit_action ('FOLD', 'CALL', 'RAISE'), optimal_sizing_bb, theoretical_ev_explanation, exploit_reasoning.
''';

  static const _coachSystem = '''
You are an elite exploitative No-Limit Texas Hold'em coach at a live table. You are given one concrete decision: the street, the board, the hero's hand, the villain's archetype and stats, what the hero did, and the recommended line.
Respond with 1-2 sentences, under 32 words, spoken aloud to the player. You MUST reference the specific street and the villain's archetype tendency by name, and say why the recommended line beats what the hero did. Never give generic advice, never repeat a stock phrase, never use markdown, bullets, asterisks, or greetings.
When the prompt includes "Leak history" for a repeated mistake, open by saying it is a repeat, quote the occurrence count, and name the pattern (for example "That's the third time you've raised a Nit's river bet when calling was better"). When it describes a fixed leak, open by acknowledging the improvement and what the player used to do. In those cases you may use up to 40 words.
''';

  /// Removes the API key (and any `key=` query value) from [text].
  static String redact(String text) {
    var out = text;
    final key = Config.geminiApiKey;
    if (key.isNotEmpty) out = out.replaceAll(key, '[REDACTED]');
    return out.replaceAll(
      RegExp(r'([?&]key=)[^&\s"]+'),
      r'$1[REDACTED]',
    );
  }

  /// Generates up to [count] unique scenarios.
  Future<List<ScenarioModel>> generateScenarios({int count = 3}) async {
    if (!hasApiKey) return [];

    final scenarios = <ScenarioModel>[];
    for (var i = 0; i < count; i++) {
      try {
        final json = await _generateJson(
          kind: AiRequestKind.scenario,
          system: _scenarioSystem,
          user:
              'Generate one unique tough exploitative spot. Variation seed: $i.',
        );
        if (json != null) {
          scenarios.add(ScenarioModel.fromGeminiJson(json));
        }
      } catch (e, s) {
        DiagnosticsLog.error('GeminiService.generateScenarios', e, s, {
          'seed': i,
        });
        // Continue remaining batch items.
      }
    }
    return scenarios;
  }

  /// Coach text for one decision.
  ///
  /// Returns an empty string when no key is configured or the call fails, so
  /// the caller keeps its own spot-specific line instead of a stock phrase.
  Future<CoachAudioResult> coach({required String prompt, int? handId}) async {
    if (!hasApiKey || prompt.trim().isEmpty) {
      return const CoachAudioResult(text: '');
    }
    try {
      final result = await _post(
        kind: AiRequestKind.coach,
        prompt: prompt,
        system: _coachSystem,
        handId: handId,
        body: {
          'system_instruction': {
            'parts': [
              {'text': _coachSystem},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 1.0,
            'maxOutputTokens': 2048,
          },
        },
      );
      return CoachAudioResult(
        text: _extractText(result.json) ?? '',
        aiRequestId: result.requestId,
      );
    } catch (e, s) {
      DiagnosticsLog.error('GeminiService.coach', e, s, null, handId);
      return const CoachAudioResult(text: '');
    }
  }

  /// Synthesizes [text] with the Gemini speech model, returning WAV bytes.
  ///
  /// Returns null when no key is configured or synthesis fails, letting the
  /// caller fall back to the device voice.
  Future<Uint8List?> synthesizeSpeech(
    String text, {
    String voice = Config.coachVoice,
    int? handId,
  }) async {
    final cleaned = text.trim();
    if (!hasApiKey || cleaned.isEmpty) return null;
    final prompt = 'Say this as a sharp, encouraging live poker coach '
        'sitting next to the player: $cleaned';
    try {
      final result = await _post(
        kind: AiRequestKind.tts,
        prompt: prompt,
        model: Config.geminiTtsModel,
        handId: handId,
        body: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {'voiceName': voice},
              },
            },
          },
        },
      );
      final audio = _extractInlineData(result.json, wantAudio: true);
      if (audio == null) {
        DiagnosticsLog.warning(
          'GeminiService.synthesizeSpeech',
          'No inline audio in response',
          extra: {'aiRequestId': result.requestId},
          handId: handId,
        );
        return null;
      }
      return WavCodec.ensurePlayable(
        audio.bytes,
        mimeType: audio.mimeType,
      ).bytes;
    } catch (e, s) {
      DiagnosticsLog.error('GeminiService.synthesizeSpeech', e, s, null, handId);
      return null;
    }
  }

  /// Generates a PNG/JPEG image from [prompt], or null on failure.
  Future<({Uint8List bytes, String mimeType})?> generateImage(
    String prompt, {
    String? model,
  }) async {
    if (!hasApiKey) return null;
    try {
      final result = await _post(
        kind: AiRequestKind.image,
        prompt: prompt,
        model: model ?? Config.geminiImageModel,
        body: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': ['IMAGE'],
          },
        },
      );
      final image = _extractInlineData(result.json, wantAudio: false);
      if (image == null) return null;
      return (bytes: image.bytes, mimeType: image.mimeType ?? 'image/png');
    } catch (e, s) {
      DiagnosticsLog.error('GeminiService.generateImage', e, s);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _generateJson({
    required AiRequestKind kind,
    required String system,
    required String user,
  }) async {
    final result = await _post(
      kind: kind,
      prompt: user,
      system: system,
      body: {
        'system_instruction': {
          'parts': [
            {'text': system},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': user},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.9,
        },
      },
    );
    final text = _extractText(result.json);
    if (text == null || text.isEmpty) return null;
    try {
      final decoded = jsonDecode(_stripFences(text));
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } on FormatException catch (e, s) {
      DiagnosticsLog.error('GeminiService.parseJson', e, s, {
        'aiRequestId': result.requestId,
        'head': text.length > 200 ? text.substring(0, 200) : text,
      });
      rethrow;
    }
  }

  /// Sends [body], retrying retryable failures, and logs every attempt.
  Future<({Map<String, dynamic> json, int? requestId})> _post({
    required AiRequestKind kind,
    required String prompt,
    required Map<String, dynamic> body,
    String system = '',
    String? model,
    int? handId,
  }) async {
    final modelId = model ?? Config.geminiModel;
    final uri = Config.geminiGenerateContentUri(model: modelId).replace(
      queryParameters: {'key': Config.geminiApiKey},
    );
    final encoded = jsonEncode(body);
    final attempts = maxAttempts < 1 ? 1 : maxAttempts;

    Object? lastError;
    for (var attempt = 1; attempt <= attempts; attempt++) {
      final requestedAt = DateTime.now().toUtc();
      int? status;
      Map<String, dynamic>? json;
      Object? error;
      try {
        final res = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: encoded,
        );
        status = res.statusCode;
        if (status < 200 || status >= 300) {
          throw GeminiHttpException(status, redact(res.body));
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
          usage: json == null ? null : AiTokenUsage.fromResponse(json),
          responseText: json == null ? null : _summarizeResponse(json),
          responseBytes: json == null ? null : _binaryResponseSize(json),
          attempt: attempt,
          handId: handId,
        ),
      );

      if (json != null) return (json: json, requestId: requestId);

      lastError = error;
      final retryable = error is GeminiHttpException
          ? error.retryable
          : error is http.ClientException || error is TimeoutException;
      if (!retryable || attempt == attempts) break;
      await Future<void>.delayed(retryDelay * attempt);
    }
    throw lastError ?? Exception('Gemini request failed');
  }

  Future<int?> _log(AiRequestLogEntry entry) async {
    final logger = _logger;
    if (logger == null) return null;
    try {
      return await logger.logRequest(entry);
    } catch (_) {
      // Logging must never break a request.
      return null;
    }
  }

  /// Text for the log: the response text, or a summary for binary payloads.
  String? _summarizeResponse(Map<String, dynamic> json) {
    final text = _extractText(json);
    if (text != null) return redact(text);
    final parts = _partsOf(json);
    if (parts == null) return null;
    for (final part in parts) {
      if (part is! Map) continue;
      final inline = part['inlineData'] ?? part['inline_data'];
      if (inline is Map && inline['data'] is String) {
        final mime = inline['mimeType'] ?? inline['mime_type'] ?? 'binary';
        final bytes = (inline['data'] as String).length * 3 ~/ 4;
        return '$mime ($bytes bytes)';
      }
    }
    return null;
  }

  int? _binaryResponseSize(Map<String, dynamic> json) {
    final parts = _partsOf(json);
    if (parts == null) return null;
    for (final part in parts) {
      if (part is! Map) continue;
      final inline = part['inlineData'] ?? part['inline_data'];
      if (inline is Map && inline['data'] is String) {
        return (inline['data'] as String).length * 3 ~/ 4;
      }
    }
    return null;
  }

  String? _extractText(Map<String, dynamic> response) {
    final parts = _partsOf(response);
    if (parts == null) return null;
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  ({Uint8List bytes, String? mimeType})? _extractInlineData(
    Map<String, dynamic> response, {
    required bool wantAudio,
  }) {
    final parts = _partsOf(response);
    if (parts == null) return null;
    for (final part in parts) {
      if (part is! Map) continue;
      final inline = part['inlineData'] ?? part['inline_data'];
      if (inline is! Map || inline['data'] is! String) continue;
      final mime = (inline['mimeType'] ?? inline['mime_type']) as String?;
      final isAudio = mime == null || mime.startsWith('audio');
      if (wantAudio != isAudio) continue;
      return (
        bytes: base64Decode(inline['data'] as String),
        mimeType: mime,
      );
    }
    return null;
  }

  List<dynamic>? _partsOf(Map<String, dynamic> response) {
    final candidates = response['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = candidates.first['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    return parts is List ? parts : null;
  }

  String _stripFences(String text) {
    var t = text.trim();
    if (t.startsWith('```')) {
      t = t.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      t = t.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return t.trim();
  }

  /// Closes the HTTP client.
  void dispose() => _client.close();
}
