/// App-wide configuration for Anthropic coaching, Gemini scenarios, and
/// gameplay defaults.
///
/// API key resolution order (developer configuration only — keys ship with
/// the build and are never requested from the player):
/// 1. `--dart-define=ANTHROPIC_API_KEY=...` / `GEMINI_API_KEY=...`
/// 2. `.env` via flutter_dotenv (declared as an asset in `pubspec.yaml`)
/// 3. `.env.example` placeholder, which resolves to no key
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Static configuration values for the Exploitative Poker Lab.
class Config {
  Config._();

  /// Claude model used for live coach narration (Anthropic Messages API).
  ///
  /// Current recommended Sonnet-class id for low-latency coaching text.
  static const String claudeCoachModel = 'claude-sonnet-5';

  /// Anthropic Messages API endpoint.
  static const String anthropicMessagesUrl =
      'https://api.anthropic.com/v1/messages';

  /// Anthropic API version header value.
  static const String anthropicVersion = '2023-06-01';

  /// Gemini model used for scenario generation only (not coaching).
  static const String geminiModel = 'gemini-3.8-flash';

  /// Image model used for generated app art.
  static const String geminiImageModel = 'gemini-3-pro-image';

  /// Compile-time Anthropic key from `--dart-define=ANTHROPIC_API_KEY=...`.
  static const String _dartDefineAnthropicKey = String.fromEnvironment(
    'ANTHROPIC_API_KEY',
    defaultValue: '',
  );

  /// Compile-time Gemini key from `--dart-define=GEMINI_API_KEY=...`.
  static const String _dartDefineGeminiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Resolved Anthropic API key (never log or commit this value).
  static String get anthropicApiKey {
    if (_dartDefineAnthropicKey.trim().isNotEmpty) {
      return _dartDefineAnthropicKey.trim();
    }
    if (!dotenv.isInitialized) return '';
    return (dotenv.maybeGet('ANTHROPIC_API_KEY') ?? '').trim();
  }

  /// Whether a usable Anthropic API key is present (required for AI coaching).
  static bool get hasAnthropicKey => anthropicApiKey.isNotEmpty;

  /// Where the Anthropic key came from. Never includes the key itself.
  static String get anthropicKeySource {
    if (_dartDefineAnthropicKey.trim().isNotEmpty) return 'dart-define';
    if (!dotenv.isInitialized) return 'unloaded';
    return hasAnthropicKey ? 'env-asset' : 'missing';
  }

  /// Resolved Gemini API key (never log or commit this value).
  ///
  /// Used for scenario / image generation only — never for coach text.
  static String get geminiApiKey {
    if (_dartDefineGeminiKey.trim().isNotEmpty) {
      return _dartDefineGeminiKey.trim();
    }
    if (!dotenv.isInitialized) return '';
    return (dotenv.maybeGet('GEMINI_API_KEY') ?? '').trim();
  }

  /// Whether a usable Gemini API key is present.
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Where the Gemini key came from. Never includes the key itself.
  static String get geminiKeySource {
    if (_dartDefineGeminiKey.trim().isNotEmpty) return 'dart-define';
    if (!dotenv.isInitialized) return 'unloaded';
    return hasGeminiKey ? 'env-asset' : 'missing';
  }

  /// Gemini generateContent endpoint for [model] (defaults to [geminiModel]).
  static Uri geminiGenerateContentUri({String? model}) {
    return Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${model ?? geminiModel}:generateContent',
    );
  }

  /// Prefetch when unplayed cached scenarios fall below this count.
  static const int scenarioPrefetchThreshold = 5;

  /// Default user id for local single-player progress.
  static const String defaultUserId = 'local';
}
