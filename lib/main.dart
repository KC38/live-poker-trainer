/// Exploitative Poker Lab entrypoint.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/firebase_options.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/analytics/crashlytics_diagnostics_sink.dart';
import 'package:live_poker_trainer/services/legacy_local_data_cleanup.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runLegacyLocalDataCleanupMigration();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Training state is fetched live from Functions; disable offline cache.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  final prefs = await SharedPreferences.getInstance();
  final analyticsEnabled =
      prefs.getBool(analyticsCollectionEnabledPrefKey) ?? true;
  await applyCollectionEnabled(analyticsEnabled);

  await _installCrashReporting(enabled: analyticsEnabled);

  AgentCommands.install();
  runApp(const ProviderScope(child: PokerLabApp()));
}

Future<void> _installCrashReporting({required bool enabled}) async {
  if (kIsWeb) return;
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    DiagnosticsLog.install(CrashlyticsDiagnosticsSink());
  } catch (e) {
    debugPrint('Crashlytics install failed: $e');
  }
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
  String? _lastRootScreen;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    // Ensure users/{uid} exists and prefs hydrate after sign-in / cold start.
    ref.watch(userDocProvider);
    final analytics = ref.watch(analyticsServiceProvider);
    final navObserver = ref.watch(analyticsNavigatorObserverProvider);

    ref.listen(authStateProvider, (prev, next) {
      final prevUid = prev?.asData?.value?.uid;
      final nextUser = next.asData?.value;
      final nextUid = nextUser?.uid;
      if (prevUid == nextUid) return;
      ref.invalidate(userDocProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(heroProfileControllerProvider);
      unawaited(analytics.setUserId(nextUid));
      _logRootScreen(analytics, nextUid == null);
    });

    // Key on uid so sign-out/in rebuilds MaterialApp and clears pushed routes
    // (e.g. Settings) that would otherwise stay on top of the new home.
    final uid = auth.asData?.value?.uid;
    final signedOut = uid == null;
    _logRootScreen(analytics, signedOut);

    return MaterialApp(
      key: ValueKey(uid ?? 'signed-out'),
      title: 'Exploitative Poker Lab',
      debugShowCheckedModeBanner: false,
      theme: buildPokerTheme(),
      navigatorObservers: [navObserver],
      home: auth.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          // Hold Home until cloud gameplay prefs hydrate so table-setup
          // edits cannot clobber Firestore with in-memory defaults.
          final userDoc = ref.watch(userDocProvider);
          return userDoc.when(
            data: (_) => const HomeScreen(),
            loading: () => const _AuthLoadingScreen(),
            error: (_, _) => const HomeScreen(),
          );
        },
        loading: () => const _AuthLoadingScreen(),
        error: (_, _) => const AuthScreen(),
      ),
    );
  }

  void _logRootScreen(AnalyticsService analytics, bool signedOut) {
    final screen =
        signedOut ? AnalyticsScreens.auth : AnalyticsScreens.home;
    if (_lastRootScreen == screen) return;
    _lastRootScreen = screen;
    unawaited(analytics.logScreenView(screen));
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
