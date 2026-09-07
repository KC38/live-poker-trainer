/// App-wide configuration for Gemini and gameplay defaults.
///
/// API key resolution order (developer configuration only — the key ships with
/// the build and is never requested from the player):
/// 1. `--dart-define=GEMINI_API_KEY=...`
/// 2. `.env` via flutter_dotenv (declared as an asset in `pubspec.yaml`)
/// 3. `.env.example` placeholder, which resolves to no key
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Static configuration values for the Exploitative Poker Lab.
class Config {
  Config._();

  /// Gemini model used for scenario generation and coaching text.
  static const String geminiModel = 'gemini-3.8-flash';


  /// Image model used for generated app art.
  static const String geminiImageModel = 'gemini-3-pro-image';

  /// Compile-time key from `--dart-define=GEMINI_API_KEY=...`.
  static const String _dartDefineKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Resolved Gemini API key (never log or commit this value).
  ///
  /// The key ships with the build — players are never asked to supply one.
  static String get geminiApiKey {
    if (_dartDefineKey.trim().isNotEmpty) {
      return _dartDefineKey.trim();
    }
    // Reading `dotenv.env` before `load()` throws, which would take down any
    // caller that runs outside `main` (unit tests, isolates).
    if (!dotenv.isInitialized) return '';
    return (dotenv.maybeGet('GEMINI_API_KEY') ?? '').trim();
  }

  /// Whether a usable API key is present.
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Where the key came from, for diagnostics. Never includes the key itself.
  static String get geminiKeySource {
    if (_dartDefineKey.trim().isNotEmpty) return 'dart-define';
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
