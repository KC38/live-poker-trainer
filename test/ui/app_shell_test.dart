/// AppShell: three tabs, state retention, Live Training launch, Profile root.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/progress_repository.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/screens/live_training_screen.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/screens/profile_screen.dart';
import 'package:live_poker_trainer/ui/screens/settings_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository()
    : document = UserDocument(
        displayName: HeroIdentity.defaultDisplayName,
        avatarRef: '',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        preferences: const GameSettingsModel(),
      );

  final UserDocument document;
}

class _FakeProgressRepository extends ProgressRepository {
  @override
  Future<List<HeroHandSample>> loadHandSamples(
    String uid, {
    int limit = 100,
  }) async =>
      const [];

  @override
  Future<UserStatsModel> loadStats(String uid) async => const UserStatsModel();
}

class _TrackingController extends GameController {
  _TrackingController(super.ref);

  final List<String> log = <String>[];

  @override
  void prepareTraining() {
    log.add('prepare');
    super.prepareTraining();
  }

  @override
  Future<void> startTraining({bool continueTable = false}) async {
    log.add('start');
    state = state.copyWith(loading: true);
  }
}

Finder _navLabel(String label) => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text(label),
);

List<Override> _shellOverrides() {
  final users = _FakeUserRepository();
  return [
    authUidProvider.overrideWithValue('test-user'),
    userDocProvider.overrideWith((ref) async => users.document),
    userRepositoryProvider.overrideWithValue(users),
    progressRepositoryProvider.overrideWithValue(_FakeProgressRepository()),
    analyticsServiceProvider.overrideWithValue(
      AnalyticsService(enabled: false),
    ),
  ];
}

Future<void> _pumpShell(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  List<Override> extraOverrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [..._shellOverrides(), ...extraOverrides],
      child: MaterialApp(
        theme: buildPokerTheme(),
        home: const AppShell(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bottom navigation has exactly three destinations', (
    tester,
  ) async {
    await _pumpShell(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(_navLabel('Home'), findsOneWidget);
    expect(_navLabel('Live Training'), findsOneWidget);
    expect(_navLabel('Profile'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LiveTrainingScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('small-phone layout still shows all three tab labels', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(320, 568));

    expect(_navLabel('Home'), findsOneWidget);
    expect(_navLabel('Live Training'), findsOneWidget);
    expect(_navLabel('Profile'), findsOneWidget);
  });

  testWidgets('switching tabs preserves Live Training setup expansion', (
    tester,
  ) async {
    await _pumpShell(tester);

    await tester.tap(_navLabel('Live Training'));
    await tester.pumpAndSettle();

    expect(find.text('Start training'), findsOneWidget);
    await tester.tap(find.text('Table setup'));
    await tester.pumpAndSettle();
    expect(find.text('Seats'), findsOneWidget);

    await tester.tap(_navLabel('Home'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Your live cash course lives here'),
      findsOneWidget,
    );

    await tester.tap(_navLabel('Live Training'));
    await tester.pumpAndSettle();
    // IndexedStack kept the expanded setup section mounted.
    expect(find.text('Seats'), findsOneWidget);
  });

  testWidgets('Start training prepares then pushes full-screen table', (
    tester,
  ) async {
    late _TrackingController controller;
    await _pumpShell(
      tester,
      extraOverrides: [
        gameControllerProvider.overrideWith((ref) {
          controller = _TrackingController(ref);
          return controller;
        }),
      ],
    );

    await tester.tap(_navLabel('Live Training'));
    await tester.pumpAndSettle();

    expect(controller.log, isEmpty);
    await tester.tap(find.text('Start training'));
    await tester.pump();

    expect(controller.log, contains('prepare'));
    expect(controller.log, isNot(contains('start')));

    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(PokerTableScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();
    expect(controller.log, contains('start'));
  });

  testWidgets('Profile tab is a root with Settings and without a back button', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(390, 1600));

    await tester.tap(_navLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
