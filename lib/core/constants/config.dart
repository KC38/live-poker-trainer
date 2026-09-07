/// App-wide configuration for Gemini and gameplay defaults.
///
/// API key resolution order:
/// 1. `--dart-define=GEMINI_API_KEY=...`
/// 2. `.env` via flutter_dotenv
/// 3. Optional SharedPreferences device override (Settings)
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Static configuration values for the Exploitative Poker Lab.
class Config {
  Config._();

  /// Gemini model used for scenario generation and coaching.
  static const String geminiModel = 'gemini-3.8-flash';

  /// Compile-time key from `--dart-define=GEMINI_API_KEY=...`.
  static const String _dartDefineKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Optional runtime override set from Settings (device-local only).
  static String? deviceKeyOverride;

  /// Resolved Gemini API key (never log or commit this value).
  static String get geminiApiKey {
    if (deviceKeyOverride != null && deviceKeyOverride!.trim().isNotEmpty) {
      return deviceKeyOverride!.trim();
    }
    if (_dartDefineKey.trim().isNotEmpty) {
      return _dartDefineKey.trim();
    }
    final fromEnv = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    return fromEnv.trim();
  }

  /// Whether a usable API key is present.
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Gemini generateContent endpoint for [geminiModel].
  static Uri geminiGenerateContentUri() {
    return Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$geminiModel:generateContent',
    );
  }

  /// Prefetch when unplayed cached scenarios fall below this count.
  static const int scenarioPrefetchThreshold = 5;

  /// Default user id for local single-player progress.
  static const String defaultUserId = 'local';
}
