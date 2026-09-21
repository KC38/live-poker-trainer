/// Player Profile screen: the low-sample contract and identity editing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/progress_repository.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';
import 'package:live_poker_trainer/ui/screens/profile_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/profile_avatar.dart';
import 'package:live_poker_trainer/ui/widgets/profile_identity_sheet.dart';

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository()
    : document = UserDocument(
        displayName: HeroIdentity.defaultDisplayName,
        avatarRef: '',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        preferences: const GameSettingsModel(),
      );

  UserDocument document;

  @override
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarRef,
  }) async {
    document = UserDocument(
      displayName: displayName ?? document.displayName,
      avatarRef: avatarRef ?? document.avatarRef,
      createdAt: document.createdAt,
      updatedAt: DateTime.utc(2026, 1, 2),
      preferences: document.preferences,
    );
  }
}

class _FakeProgressRepository extends ProgressRepository {
  Object? failure;

  @override
  Future<List<HeroHandSample>> loadHandSamples(
    String uid, {
    int limit = 100,
  }) async {
    if (failure case final error?) throw error;
    return const [];
  }

  @override
  Future<UserStatsModel> loadStats(String uid) async => const UserStatsModel();
}

void main() {
  late _FakeUserRepository users;
  late _FakeProgressRepository progress;

  setUp(() {
    users = _FakeUserRepository();
    progress = _FakeProgressRepository();
  });

  /// Pumps the profile screen against server-repository fakes.
  ///
  /// The viewport is made tall so the whole page is laid out; a ListView only
  /// builds what is on screen, and this test is auditing the full contents.
  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUidProvider.overrideWithValue('test-user'),
          userDocProvider.overrideWith((ref) async => users.document),
          userRepositoryProvider.overrideWithValue(users),
          progressRepositoryProvider.overrideWithValue(progress),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with no hands the screen withholds every rate and the style', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    // No style is claimed, and the reason is spelled out.
    expect(find.text('Style forming'), findsOneWidget);
    expect(find.textContaining('0 hands logged'), findsOneWidget);
    expect(find.textContaining('style shows up here'), findsWidgets);
    // Every rate tile renders an em dash rather than a fabricated 0%.
    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('needs '), findsWidgets);
    // The default identity falls back to initials.
    expect(find.byType(ProfileAvatar), findsWidgets);
  });

  testWidgets('server hand-history errors replace cached-looking profile UI', (
    tester,
  ) async {
    progress.failure = Exception('network unavailable');

    await pumpProfile(tester);

    expect(find.textContaining('network unavailable'), findsOneWidget);
    expect(find.text('Style forming'), findsNothing);
  });

  testWidgets('a stat tile explains itself in plain English', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('VPIP'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('How often you put money in preflop'),
      findsOneWidget,
    );
    expect(find.text('Healthy range'), findsOneWidget);
    expect(find.textContaining('Not shown yet'), findsOneWidget);
  });

  testWidgets('editing the display name updates the header and persists', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileIdentitySheet), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Kushal');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileIdentitySheet), findsNothing);
    expect(find.text('Kushal'), findsOneWidget);
    expect(users.document.displayName, 'Kushal');
  });

  testWidgets('a blank name reverts to the default rather than an empty seat', (
    tester,
  ) async {
    await users.updateProfile(uid: 'test-user', displayName: 'Kushal');
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(HeroIdentity.defaultDisplayName), findsOneWidget);
    expect(users.document.displayName, HeroIdentity.defaultDisplayName);
  });

  testWidgets('picking a built-in avatar applies and persists immediately', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // The choices are unlabelled circles, so they are found by the avatar
    // each one previews.
    final choice = BuiltInAvatar.values.first;
    await tester.tap(
      find
          .byWidgetPredicate(
            (w) => w is ProfileAvatar && w.identity.avatar.builtIn == choice,
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(AvatarRef.parse(users.document.avatarRef).builtIn, choice);
    // Applying immediately means a remove affordance now exists.
    expect(find.text('Remove picture'), findsOneWidget);

    await tester.tap(find.text('Remove picture'));
    await tester.pumpAndSettle();

    expect(AvatarRef.parse(users.document.avatarRef).kind, AvatarKind.none);
    expect(find.text('Remove picture'), findsNothing);
  });

  testWidgets('a saved identity is loaded on open', (tester) async {
    await users.updateProfile(
      uid: 'test-user',
      displayName: 'Kushal C',
      avatarRef: AvatarRef.builtIn(BuiltInAvatar.values.last).storageValue,
    );

    await pumpProfile(tester);

    expect(find.text('Kushal C'), findsOneWidget);
  });
}
