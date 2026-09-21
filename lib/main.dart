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
import 'package:live_poker_trainer/core/debug/agent_ui_driver.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/firebase_options.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/providers/course_progress_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/routing/app_root.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/analytics/crashlytics_diagnostics_sink.dart';
import 'package:live_poker_trainer/services/legacy_local_data_cleanup.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
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
  runApp(
    const ProviderScope(
      child: _AgentUiBootstrap(child: PokerLabApp()),
    ),
  );
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
    final auth = ref.watch(appAuthProvider);
    // Ensure users/{uid} exists and prefs hydrate after sign-in / cold start.
    ref.watch(userDocProvider);
    final analytics = ref.watch(analyticsServiceProvider);
    final navObserver = ref.watch(analyticsNavigatorObserverProvider);
    final onboarding = ref.watch(onboardingControllerProvider);
    final gate = courseFlagsForRouting(ref.watch(courseFlagsProvider));
    final flags = gate.flags;
    final flagsReady = gate.ready;

    ref.listen(appAuthProvider, (prev, next) {
      final prevUid = prev?.asData?.value.uid;
      final nextSession = next.asData?.value;
      final nextUid = nextSession?.uid;
      if (prevUid == nextUid) return;
      ref.invalidate(userDocProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(heroProfileControllerProvider);
      ref.invalidate(courseProgressProvider);
      unawaited(analytics.setUserId(nextUid));
      _logRootScreen(
        analytics,
        _rootScreenName(nextSession, onboarding, flags, flagsReady),
      );
    });

    // Signed-out and anonymous share a navigator key so the first lesson
    // survives anonymous sign-in. A resolved auth gate still remounts so a
    // real flag denial clears that lesson. Linked accounts key on uid.
    final session = auth.asData?.value;
    final destination = _destinationFor(session, onboarding, flags, flagsReady);
    _logRootScreen(analytics, _screenName(destination));

    return MaterialApp(
      key: ValueKey(
        rootNavigatorKeyFor(
          uid: session?.uid,
          anonymous: session?.isAnonymous == true,
          resetForAuthGate: destination == AppRootDestination.auth,
        ),
      ),
      title: 'Exploitative Poker Lab',
      debugShowCheckedModeBanner: false,
      theme: buildPokerTheme(),
      navigatorObservers: [navObserver],
      home: auth.when(
        data:
            (session) => _homeForDestination(
              _destinationFor(session, onboarding, flags, flagsReady),
              onboarding,
            ),
        loading: () => const _AuthLoadingScreen(),
        error:
            (_, _) =>
                flagsReady && guestCourseEntryEnabled(flags)
                    ? const WelcomeScreen()
                    : flagsReady
                    ? const AuthScreen()
                    : const _AuthLoadingScreen(),
      ),
    );
  }

  AppRootDestination _destinationFor(
    AppAuthSnapshot? session,
    OnboardingDraft onboarding,
    CourseFlags? flags,
    bool flagsReady,
  ) {
    return resolveAppRoot(
      signedIn: session?.signedIn == true,
      anonymous: session?.isAnonymous == true,
      flagsReady: flagsReady,
      flags: flags,
      onboarding: onboarding,
    );
  }

  Widget _homeForDestination(
    AppRootDestination destination,
    OnboardingDraft onboarding,
  ) {
    switch (destination) {
      case AppRootDestination.loading:
        return const _AuthLoadingScreen();
      case AppRootDestination.auth:
        return const AuthScreen();
      case AppRootDestination.welcome:
        return const WelcomeScreen();
      case AppRootDestination.saveProgress:
        return const SaveProgressScreen();
      case AppRootDestination.guestCourse:
        if (onboarding.step == OnboardingStep.firstLesson ||
            onboarding.step == OnboardingStep.recommendedStart) {
          return FirstLessonLaunchScreen(
            lessonId: onboarding.recommendedLessonId ?? kFirstCourseLessonId,
          );
        }
        return const ExperienceChoiceScreen();
      case AppRootDestination.shell:
        // Hold shell until cloud gameplay prefs hydrate so table-setup
        // edits cannot clobber Firestore with in-memory defaults.
        final userDoc = ref.watch(userDocProvider);
        return userDoc.when(
          data: (_) => const AppShell(),
          loading: () => const _AuthLoadingScreen(),
          error: (_, _) => const AppShell(),
        );
    }
  }

  String _rootScreenName(
    AppAuthSnapshot? session,
    OnboardingDraft onboarding,
    CourseFlags? flags,
    bool flagsReady,
  ) {
    return _screenName(_destinationFor(session, onboarding, flags, flagsReady));
  }

  String _screenName(AppRootDestination destination) {
    return switch (destination) {
      AppRootDestination.welcome => AnalyticsScreens.welcome,
      AppRootDestination.guestCourse => AnalyticsScreens.onboarding,
      AppRootDestination.saveProgress => AnalyticsScreens.saveProgress,
      AppRootDestination.shell => AnalyticsScreens.home,
      AppRootDestination.auth ||
      AppRootDestination.loading => AnalyticsScreens.auth,
    };
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

/// Wires debug agent UI taps + sign-out after [ProviderScope] exists.
final class _AgentUiBootstrap extends ConsumerStatefulWidget {
  const _AgentUiBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_AgentUiBootstrap> createState() => _AgentUiBootstrapState();
}

class _AgentUiBootstrapState extends ConsumerState<_AgentUiBootstrap> {
  @override
  void initState() {
    super.initState();
    AgentUiDriver.install(
      signOut: () => ref.read(authControllerProvider.notifier).signOut(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
