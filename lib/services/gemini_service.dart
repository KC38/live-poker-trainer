/// Gemini scenario generation, coach text, and coach speech synthesis.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:live_poker_trainer/core/audio/wav_codec.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Result of a coach turn.
class CoachAudioResult {
  /// Creates a coach result.
  const CoachAudioResult({
    required this.text,
    this.audioBytes,
    this.audioMimeType,
  });

  final String text;

  /// WAV-wrapped speech, when synthesized.
  final Uint8List? audioBytes;

  /// MIME for [audioBytes] (`audio/wav` after normalization).
  final String? audioMimeType;
}

/// REST client for Gemini generateContent (JSON scenarios, coach, speech).
class GeminiService {
  /// Creates a Gemini service with optional [client] for tests.
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

  /// Generates up to [count] unique scenarios.
  Future<List<ScenarioModel>> generateScenarios({int count = 3}) async {
    if (!hasApiKey) return [];

    final scenarios = <ScenarioModel>[];
    for (var i = 0; i < count; i++) {
      try {
        final json = await _generateJson(
          system: _scenarioSystem,
          user:
              'Generate one unique tough exploitative spot. Variation seed: $i.',
        );
        if (json != null) {
          scenarios.add(ScenarioModel.fromGeminiJson(json));
        }
      } catch (_) {
        // Continue remaining batch items.
      }
    }
    return scenarios;
  }

  /// Coach text for one decision.
  ///
  /// Returns an empty string when no key is configured or the call fails, so
  /// the caller keeps its own spot-specific line instead of a stock phrase.
  Future<CoachAudioResult> coach({required String prompt}) async {
    if (!hasApiKey || prompt.trim().isEmpty) {
      return const CoachAudioResult(text: '');
    }
    try {
      final response = await _post({
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
      });
      return CoachAudioResult(text: _extractText(response) ?? '');
    } catch (_) {
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
  }) async {
    final cleaned = text.trim();
    if (!hasApiKey || cleaned.isEmpty) return null;
    try {
      final response = await _post(
        {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': 'Say this as a sharp, encouraging live poker coach '
                      'sitting next to the player: $cleaned',
                },
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
        model: Config.geminiTtsModel,
      );
      final audio = _extractInlineData(response, wantAudio: true);
      if (audio == null) return null;
      return WavCodec.ensurePlayable(
        audio.bytes,
        mimeType: audio.mimeType,
      ).bytes;
    } catch (_) {
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
      final response = await _post(
        {
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
        model: model ?? Config.geminiImageModel,
      );
      final image = _extractInlineData(response, wantAudio: false);
      if (image == null) return null;
      return (bytes: image.bytes, mimeType: image.mimeType ?? 'image/png');
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _generateJson({
    required String system,
    required String user,
  }) async {
    final body = {
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
    };
    final response = await _post(body);
    final text = _extractText(response);
    if (text == null || text.isEmpty) return null;
    final decoded = jsonDecode(_stripFences(text));
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  Future<Map<String, dynamic>> _post(
    Map<String, dynamic> body, {
    String? model,
  }) async {
    final uri = Config.geminiGenerateContentUri(model: model).replace(
      queryParameters: {'key': Config.geminiApiKey},
    );
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Gemini HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
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
