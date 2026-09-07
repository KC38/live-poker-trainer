/// Exploitative Poker Lab entrypoint.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnv();
  assert(() {
    // Source only — the key itself is never logged.
    debugPrint('[config] gemini key source: ${Config.geminiKeySource}');
    return true;
  }());
  runApp(const ProviderScope(child: PokerLabApp()));
}

/// Loads the bundled env files before any [Config] read.
///
/// `.env.example` is the always-present base; the gitignored `.env` overrides
/// it (override files are parsed first and the first definition wins). Both are
/// declared as assets in `pubspec.yaml`, so the key resolves on a plain
/// `flutter run` or release build with no extra flags.
Future<void> _loadEnv() async {
  try {
    await dotenv.load(
      fileName: '.env.example',
      overrideWithFiles: const ['.env'],
      isOptional: true,
    );
  } catch (_) {
    // Never block startup on config: the app runs fine without a key.
    dotenv.loadFromString(envString: '', isOptional: true);
  }
}

/// Root application widget.
class PokerLabApp extends StatelessWidget {
  /// Creates the app.
  const PokerLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exploitative Poker Lab',
      debugShowCheckedModeBanner: false,
      theme: buildPokerTheme(),
      home: const HomeScreen(),
    );
  }
}
