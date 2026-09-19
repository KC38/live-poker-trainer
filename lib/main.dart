/// Exploitative Poker Lab entrypoint.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/firebase_options.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/services/legacy_local_data_cleanup.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runLegacyLocalDataCleanupMigration();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Training state is fetched live from Functions; disable offline cache.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  AgentCommands.install();
  runApp(const ProviderScope(child: PokerLabApp()));
}

/// Root application widget.
///
/// Auth gate: signed-out → [AuthScreen]; signed-in → [HomeScreen].
class PokerLabApp extends ConsumerStatefulWidget {
  /// Creates the app.
  const PokerLabApp({super.key});

  @override
  ConsumerState<PokerLabApp> createState() => _PokerLabAppState();
}

class _PokerLabAppState extends ConsumerState<PokerLabApp> {
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

    // Key on uid so sign-out/in rebuilds MaterialApp and clears pushed routes
    // (e.g. Settings) that would otherwise stay on top of the new home.
    final uid = auth.asData?.value?.uid;
    return MaterialApp(
      key: ValueKey(uid ?? 'signed-out'),
      title: 'Exploitative Poker Lab',
      debugShowCheckedModeBanner: false,
      theme: buildPokerTheme(),
      home: auth.when(
        data: (user) => user == null ? const AuthScreen() : const HomeScreen(),
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
      body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
  }
}
