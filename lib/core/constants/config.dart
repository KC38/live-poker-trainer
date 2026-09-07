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

  /// Gemini model used for scenario generation and coaching text.
  static const String geminiModel = 'gemini-3.8-flash';

  /// Dedicated speech model. The general chat models silently ignore the
  /// `AUDIO` response modality and return text only, which is why the coach
  /// used to fall back to the flat device voice even with a valid key.
  static const String geminiTtsModel = 'gemini-3.1-flash-tts-preview';

  /// Prebuilt Gemini voice used for the coach.
  static const String coachVoice = 'Puck';

  /// Image model used for generated app art.
  static const String geminiImageModel = 'gemini-3-pro-image';

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

  /// Gemini generateContent endpoint for [model] (defaults to [geminiModel]).
  static Uri geminiGenerateContentUri({String? model}) {
    return Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${model ?? geminiModel}:generateContent',
    );
  }

  /// Max bytes of cached coach audio kept on disk.
  static const int voiceCacheMaxBytes = 24 * 1024 * 1024;

  /// How long a cached coach clip stays valid.
  static const Duration voiceCacheTtl = Duration(days: 30);

  /// Prefetch when unplayed cached scenarios fall below this count.
  static const int scenarioPrefetchThreshold = 5;

  /// Default user id for local single-player progress.
  static const String defaultUserId = 'local';
}
