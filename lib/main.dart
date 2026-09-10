/// Exploitative Poker Lab entrypoint.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/firebase_options.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Offline cache for user prefs/stats and (later) scenario pool reads.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await _loadEnv();
  AgentCommands.install();
  assert(() {
    // Source only — keys themselves are never logged.
    debugPrint('[config] anthropic key source: ${Config.anthropicKeySource}');
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
///
/// Opens the diagnostics session (app_sessions row, lifecycle heartbeats,
/// uncaught-error capture, retention pruning) once the provider scope exists.
/// Auth gate: signed-out → [AuthScreen]; signed-in → [HomeScreen].
class PokerLabApp extends ConsumerStatefulWidget {
  /// Creates the app.
  const PokerLabApp({super.key});

  @override
  ConsumerState<PokerLabApp> createState() => _PokerLabAppState();
}

class _PokerLabAppState extends ConsumerState<PokerLabApp> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: startup never waits on SQLite.
    Future<void>.microtask(() => ref.read(appSessionServiceProvider).start());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    // Ensure users/{uid} exists and prefs hydrate after sign-in / cold start.
    ref.watch(userDocProvider);

    ref.listen(authStateProvider, (prev, next) {
      final prevUid = prev?.asData?.value?.uid;
      final nextUid = next.asData?.value?.uid;
      if (prevUid == nextUid) return;
      ref.invalidate(userDocProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(heroProfileControllerProvider);
    });

    return MaterialApp(
      title: 'Exploitative Poker Lab',
      debugShowCheckedModeBanner: false,
      theme: buildPokerTheme(),
      home: auth.when(
        data: (user) =>
            user == null ? const AuthScreen() : const HomeScreen(),
        loading: () => const _AuthLoadingScreen(),
        error: (_, _) => const AuthScreen(),
      ),
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );
  }
}
