/// Gemini 3.8 Flash scenario generation and live coach (text / AUDIO).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Result of a coach turn (text and optional PCM/WAV bytes).
class CoachAudioResult {
  /// Creates a coach result.
  const CoachAudioResult({required this.text, this.audioBytes});

  final String text;
  final Uint8List? audioBytes;
}

/// REST client for Gemini generateContent (JSON scenarios + coach).
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
You are an elite exploitative No-Limit Texas Hold'em poker coach analyzing an exploitative spot. Give ultra-concise, punchy verbal strategic advice (1-2 sentences, under 28 words). Focus on opponent archetype vulnerabilities, fold equity, and bet sizing. Never use markdown, bullets, asterisks, or greetings.
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

  /// Live coach feedback; requests AUDIO when [wantAudio] is true.
  Future<CoachAudioResult> coach({
    required String prompt,
    bool wantAudio = false,
  }) async {
    if (!hasApiKey) {
      return CoachAudioResult(text: prompt.isEmpty ? 'No API key configured.' : 'Trust the exploit — punish their leak.');
    }

    final body = <String, dynamic>{
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
      'generationConfig': wantAudio
          ? {
              'responseModalities': ['AUDIO'],
              'speechConfig': {
                'voiceConfig': {
                  'prebuiltVoiceConfig': {'voiceName': 'Puck'},
                },
              },
            }
          : {
              'temperature': 0.7,
              'maxOutputTokens': 120,
            },
    };

    final response = await _post(body);
    final text = _extractText(response) ?? 'Attack their tendency hard.';
    final audio = wantAudio ? _extractInlineAudio(response) : null;
    return CoachAudioResult(text: text, audioBytes: audio);
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

  Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    final uri = Config.geminiGenerateContentUri().replace(
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
    final candidates = response['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = candidates.first['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  Uint8List? _extractInlineAudio(Map<String, dynamic> response) {
    final candidates = response['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = candidates.first['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    for (final part in parts) {
      if (part is! Map) continue;
      final inline = part['inlineData'] ?? part['inline_data'];
      if (inline is Map && inline['data'] is String) {
        return base64Decode(inline['data'] as String);
      }
    }
    return null;
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
