/// Turns computed hero metrics into a coach's read on the player's game.
///
/// Two paths, same shape of output:
///
/// * **Gemini** — the metrics are summarized into a compact prompt and the
///   model answers with JSON (`summary`, `leaks`, `adjustments`). No markdown
///   is allowed through: the copy is read on a phone card, not in a terminal.
/// * **Offline** — the same fields are written locally from the metrics and
///   the ranked [ProfileLeak] list, so the card is never empty and the app
///   works with no key and no network.
///
/// The caller decides *when* to run this (see
/// [ProfileCoachSummary.needsRefresh]); this service only decides *what* to
/// say. Nothing here reads or logs the API key.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';

/// A JSON-mode model call, injected so the coach is testable without HTTP.
typedef StructuredModelCall = Future<Map<String, dynamic>?> Function({
  required String system,
  required String user,
});

/// Generates (or locally derives) the profile summary.
class ProfileCoach {
  /// Creates a coach. [call] is null when no model is available, which forces
  /// the locally derived copy.
  ProfileCoach({this.modelCall, String? modelId})
      : _modelId = modelId ?? Config.geminiModel;

  /// Creates a coach backed by Gemini JSON mode.
  ///
  /// This owns its own request plumbing rather than reaching into
  /// [GeminiService]: the profile review is a single, low-frequency,
  /// JSON-only call, and keeping it self-contained means the gameplay coach
  /// and the profile review can evolve independently. [client] is injectable
  /// so tests never touch the network.
  factory ProfileCoach.gemini({http.Client? client, String? modelId}) {
    final model = modelId ?? Config.geminiModel;
    final httpClient = client ?? http.Client();
    return ProfileCoach(
      modelId: model,
      modelCall: ({required String system, required String user}) =>
          _requestJson(
        client: httpClient,
        model: model,
        system: system,
        user: user,
      ),
    );
  }

  /// The model call, or null to force locally derived copy.
  final StructuredModelCall? modelCall;

  final String _modelId;

  /// Requests JSON-mode output from Gemini, returning null on any failure.
  ///
  /// The profile card always has offline copy to fall back to, so a failed
  /// review is a non-event and must never surface as an error.
  static Future<Map<String, dynamic>?> _requestJson({
    required http.Client client,
    required String model,
    required String system,
    required String user,
  }) async {
    if (!Config.hasGeminiKey) return null;
    try {
      final uri = Config.geminiGenerateContentUri(model: model).replace(
        queryParameters: {'key': Config.geminiApiKey},
      );
      final response = await client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
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
            'temperature': 0.7,
          },
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      return _decodeCandidate(response.body);
    } catch (_) {
      return null;
    }
  }

  /// Pulls the first text part out of a generateContent response and decodes
  /// it, tolerating the fenced ```json blocks the model sometimes emits.
  static Map<String, dynamic>? _decodeCandidate(String body) {
    try {
      final envelope = jsonDecode(body);
      if (envelope is! Map) return null;
      final candidates = envelope['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final content = candidates.first['content'];
      if (content is! Map) return null;
      final parts = content['parts'];
      if (parts is! List) return null;
      final buffer = StringBuffer();
      for (final part in parts) {
        if (part is Map && part['text'] is String) buffer.write(part['text']);
      }
      var text = buffer.toString().trim();
      if (text.startsWith('```')) {
        text = text
            .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
            .replaceFirst(RegExp(r'\s*```$'), '')
            .trim();
      }
      if (text.isEmpty) return null;
      final decoded = jsonDecode(text);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  /// Maximum leak / adjustment lines kept from a model response.
  static const int maxLines = 3;

  static const String _system = '''
You are a blunt, encouraging live No-Limit Hold'em coach reviewing one player's own statistics.
You are given their sample size, their tracked rates, their street tendencies, and how they play against each opponent type.
Reply with JSON only, using exactly these keys:
{"summary": string, "leaks": [string], "adjustments": [string]}
Rules: "summary" is 2-3 sentences describing how this player plays and what it costs them, speaking directly to them as "you". "leaks" is 1-3 short lines, each naming one concrete leak and the number behind it. "adjustments" is 1-3 short imperative fixes they can apply next session. Never use markdown, asterisks, bullet characters, headings, or emoji. Never invent a statistic that was not given to you. If the sample is small, say so plainly instead of overclaiming.
''';

  /// Produces a summary for [metrics], preferring the model and falling back
  /// to locally derived copy on any failure.
  Future<ProfileCoachSummary> summarize(
    HeroMetrics metrics, {
    DateTime? now,
  }) async {
    final stamp = (now ?? DateTime.now()).toUtc();
    final call = modelCall;
    if (call != null) {
      final response = await call(
        system: _system,
        user: buildPrompt(metrics),
      );
      final parsed = _parse(response, metrics, stamp);
      if (parsed != null) return parsed;
    }
    return offlineSummary(metrics, now: stamp);
  }

  /// The metrics digest sent to the model. Only numbers with a real sample
  /// behind them are included, so the model cannot quote noise back.
  static String buildPrompt(HeroMetrics metrics) {
    final lines = <String>[
      'Hands logged: ${metrics.handsPlayed}.',
      'Sample confidence: ${metrics.style.confidence.label}.',
      'Derived style: ${metrics.style.style.label} '
          '(${metrics.style.style.tagline}).',
      'Why: ${metrics.style.explanation}',
    ];

    final stats = <String>[];
    for (final id in HeroMetricId.values) {
      final sample = metrics.sample(id);
      if (!sample.hasEnoughData) continue;
      stats.add('${id.shortLabel} ${sample.display} (${sample.sampleLabel})');
    }
    lines.add(
      stats.isEmpty
          ? 'No rate has a large enough sample to quote yet.'
          : 'Tracked rates: ${stats.join('; ')}.',
    );

    final streetNotes = [
      for (final street in metrics.streetTendencies)
        if (street.note case final note?)
          '${street.street.name} $note '
              '(${street.decisions} decisions)',
    ];
    if (streetNotes.isNotEmpty) {
      lines.add('Street tendencies: ${streetNotes.join('; ')}.');
    }

    final villainNotes = [
      for (final tendency in metrics.archetypeTendencies)
        if (tendency.hasEnoughData)
          '${tendency.archetype.label}: folds '
              '${tendency.foldPct.toStringAsFixed(0)}%, calls '
              '${tendency.callPct.toStringAsFixed(0)}%, aggressive '
              '${tendency.aggressionPct.toStringAsFixed(0)}% over '
              '${tendency.decisions} decisions',
    ];
    if (villainNotes.isNotEmpty) {
      lines.add('Versus opponent types — ${villainNotes.join('; ')}.');
    }

    if (metrics.leaks.isNotEmpty) {
      lines.add(
        'Locally detected leaks, strongest first: '
        '${metrics.leaks.map((l) => l.title).join('; ')}.',
      );
    }

    lines.add(
      'Net result: ${metrics.netBb >= 0 ? '+' : ''}'
      '${metrics.netBb.toStringAsFixed(1)} big blinds.',
    );
    return lines.join('\n');
  }

  /// Locally derived copy used with no key, no network, or a bad response.
  static ProfileCoachSummary offlineSummary(
    HeroMetrics metrics, {
    DateTime? now,
  }) {
    final stamp = (now ?? DateTime.now()).toUtc();
    final style = metrics.style;

    final summary = StringBuffer();
    if (!style.isKnown) {
      summary.write(
        'Not enough hands yet to read your game. ${style.explanation} '
        'Keep playing full hands and this fills in automatically.',
      );
    } else {
      summary.write('${style.style.tagline}. ${style.explanation}');
      final vpipPfr = metrics.vpipPfrLabel;
      if (vpipPfr != null) {
        summary.write(
          ' Your line reads $vpipPfr over ${metrics.handsPlayed} hands.',
        );
      }
    }

    final leaks = [
      for (final leak in metrics.leaks.take(maxLines))
        '${leak.title}. ${leak.detail}',
    ];

    return ProfileCoachSummary(
      styleSummary: summary.toString(),
      leaks: leaks,
      adjustments: _offlineAdjustments(metrics),
      source: ProfileCoachSummary.offlineSource,
      modelId: '',
      handsPlayedAt: metrics.handsPlayed,
      styleId: style.style.name,
      generatedAt: stamp,
    );
  }

  static List<String> _offlineAdjustments(HeroMetrics metrics) {
    final fixes = <String>[];
    void add(String text) {
      if (fixes.length < maxLines) fixes.add(text);
    }

    switch (metrics.style.style) {
      case PlayingStyle.loosePassive:
        add('Raise or fold preflop — cut the limps entirely.');
        add('Stop calling river bets with third pair.');
      case PlayingStyle.nit:
      case PlayingStyle.tightPassive:
        add('Open every suited ace and broadway from the last two seats.');
        add('Bet the flop when you raised preflop, even on a miss.');
      case PlayingStyle.maniac:
        add('Fold your worst opens from early position.');
        add('Stop bluffing players who never fold.');
      case PlayingStyle.lag:
        add('Keep the aggression, tighten the early-position opens.');
      case PlayingStyle.tag:
        add('Take thinner value bets against the loose players.');
      case PlayingStyle.balanced:
      case PlayingStyle.forming:
        add('Play more full hands so the numbers can find your leaks.');
    }

    for (final tendency in metrics.archetypeTendencies) {
      if (fixes.length >= maxLines) break;
      final note = tendency.note;
      if (note != null) add('vs ${tendency.archetype.label}: $note');
    }
    for (final leak in metrics.leaks) {
      if (fixes.length >= maxLines) break;
      add(leak.detail);
    }
    return List.unmodifiable(fixes);
  }

  ProfileCoachSummary? _parse(
    Map<String, dynamic>? response,
    HeroMetrics metrics,
    DateTime now,
  ) {
    if (response == null) return null;
    final summary = _clean('${response['summary'] ?? ''}');
    if (summary.isEmpty) return null;
    return ProfileCoachSummary(
      styleSummary: summary,
      leaks: _cleanList(response['leaks']),
      adjustments: _cleanList(response['adjustments']),
      source: ProfileCoachSummary.geminiSource,
      modelId: _modelId,
      handsPlayedAt: metrics.handsPlayed,
      styleId: metrics.style.style.name,
      generatedAt: now,
    );
  }

  static List<String> _cleanList(Object? raw) {
    if (raw is! List) return const [];
    return List.unmodifiable([
      for (final entry in raw.take(maxLines))
        if (_clean('$entry') case final line when line.isNotEmpty) line,
    ]);
  }

  /// Strips markdown the model was told not to use, plus stray bullets.
  static String _clean(String raw) {
    return raw
        .replaceAll(RegExp(r'[*_`#]'), '')
        .replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }
}
