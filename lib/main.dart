/// Exploitative Poker Lab entrypoint.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/firebase_options.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/analytics/crashlytics_diagnostics_sink.dart';
import 'package:live_poker_trainer/services/legacy_local_data_cleanup.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';
import 'package:live_poker_trainer/ui/screens/first_lesson_launch_screen.dart';
import 'package:live_poker_trainer/ui/screens/onboarding_screens.dart';
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
/// Auth gate:
/// signed-out → welcome onboarding;
/// anonymous → first lesson / save-progress;
/// linked → [AppShell].
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
    final onboarding = ref.watch(onboardingControllerProvider);

    ref.listen(authStateProvider, (prev, next) {
      final prevUid = prev?.asData?.value?.uid;
      final nextUser = next.asData?.value;
      final nextUid = nextUser?.uid;
      if (prevUid == nextUid) return;
      ref.invalidate(userDocProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(heroProfileControllerProvider);
      unawaited(analytics.setUserId(nextUid));
      _logRootScreen(analytics, _rootScreenName(nextUser, onboarding));
    });

    // Key on uid so sign-out/in rebuilds MaterialApp and clears pushed routes
    // (e.g. Settings) that would otherwise stay on top of the new home.
    final uid = auth.asData?.value?.uid;
    _logRootScreen(
      analytics,
      _rootScreenName(auth.asData?.value, onboarding),
    );

    return MaterialApp(
      key: ValueKey(uid ?? 'signed-out'),
      title: 'Exploitative Poker Lab',
      debugShowCheckedModeBanner: false,
      theme: buildPokerTheme(),
      navigatorObservers: [navObserver],
      home: auth.when(
        data: (user) => _homeForUser(user, onboarding),
        loading: () => const _AuthLoadingScreen(),
        error: (_, _) => const WelcomeScreen(),
      ),
    );
  }

  Widget _homeForUser(User? user, OnboardingDraft onboarding) {
    if (user == null) {
      return const WelcomeScreen();
    }

    if (user.isAnonymous) {
      if (onboarding.pendingSaveProgress || onboarding.firstLessonCompleted) {
        return const SaveProgressScreen();
      }
      if (onboarding.step == OnboardingStep.firstLesson ||
          onboarding.step == OnboardingStep.recommendedStart) {
        return FirstLessonLaunchScreen(
          lessonId: onboarding.recommendedLessonId ?? kFirstCourseLessonId,
        );
      }
      // Cold start with an orphan anonymous session — resume onboarding.
      return const ExperienceChoiceScreen();
    }

    // Hold shell until cloud gameplay prefs hydrate so table-setup
    // edits cannot clobber Firestore with in-memory defaults.
    final userDoc = ref.watch(userDocProvider);
    return userDoc.when(
      data: (_) => const AppShell(),
      loading: () => const _AuthLoadingScreen(),
      error: (_, _) => const AppShell(),
    );
  }

  String _rootScreenName(User? user, OnboardingDraft onboarding) {
    if (user == null) return AnalyticsScreens.welcome;
    if (user.isAnonymous) {
      if (onboarding.pendingSaveProgress) return AnalyticsScreens.saveProgress;
      return AnalyticsScreens.onboarding;
    }
    return AnalyticsScreens.home;
  }

  void _logRootScreen(AnalyticsService analytics, String screen) {
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
