/// Player Profile screen: the low-sample contract and identity editing.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/models/course/course_progress.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_progress_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/services/firestore/progress_repository.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
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

class _IdleAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  String? get currentUid => null;

  @override
  bool get isAnonymous => true;

  @override
  Future<User> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<User> signInAnonymously() => throw UnimplementedError();

  @override
  Future<User> linkWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> linkWithGoogle() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}

class _FakeProgressRepository extends ProgressRepository {
  Object? failure;
  List<HeroHandSample> samples = const [];

  @override
  Future<List<HeroHandSample>> loadHandSamples(
    String uid, {
    int limit = 100,
  }) async {
    if (failure case final error?) throw error;
    return samples;
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
          courseProgressProvider.overrideWith(
            (ref) async => const CourseProgress(
              loaded: true,
              available: false,
              lifetimeXp: 12,
              currentStreak: 2,
              acceptedAccuracy: 0.5,
              mastery: 0.4,
              reviewsDue: 1,
              currentSectionTitle: 'Foundations',
            ),
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

  testWidgets('a guest can open create-account and still sign out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_IdleAuthService()),
          appAuthProvider.overrideWithValue(
            const AsyncData(
              AppAuthSnapshot(uid: 'guest', isAnonymous: true),
            ),
          ),
          authUidProvider.overrideWithValue('guest'),
          userDocProvider.overrideWith((ref) async => users.document),
          userRepositoryProvider.overrideWithValue(users),
          progressRepositoryProvider.overrideWithValue(progress),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          courseProgressProvider.overrideWith(
            (ref) async => const CourseProgress(
              loaded: true,
              available: false,
              lifetimeXp: 25,
              currentStreak: 1,
              acceptedAccuracy: 1,
              mastery: 0.4,
              reviewsDue: 0,
              currentSectionTitle: 'Cards and the table',
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Create an account')).dy,
      lessThan(tester.getTopLeft(find.text('Course')).dy),
    );

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    final screen = tester.widget<AuthScreen>(find.byType(AuthScreen));
    expect(screen.saveProgressMode, isTrue);
    expect(screen.initialRegisterMode, isTrue);
    expect(find.byTooltip('Close'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('with no hands the screen withholds every rate and the style', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    // A lesson-only guest has no live-hand style in the header.
    expect(find.text('Style forming'), findsNothing);
    expect(find.text('Needs more hands'), findsNothing);
    expect(find.text('0 hands logged'), findsNothing);
    expect(find.text('Hero'), findsOneWidget);
    // Course progress stays in the Course block.
    expect(find.text('Course XP'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Accepted accuracy'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    // Live Training still explains that style comes from full-hand play.
    expect(
      find.text('Coaching record, results, and style from full-hand play.'),
      findsOneWidget,
    );
    expect(find.textContaining('style shows up here'), findsOneWidget);
    // Every rate tile renders an em dash rather than a fabricated 0%.
    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('needs '), findsWidgets);
    // The default identity falls back to initials.
    expect(find.byType(ProfileAvatar), findsWidgets);
  });

  testWidgets('twenty live hands still show a style in the header', (
    tester,
  ) async {
    progress.samples = [
      for (var i = 0; i < 20; i++)
        HeroHandSample(
          handId: i + 1,
          playedAt: DateTime.utc(2026, 1, 1, 12, i),
          actions: const [
            HandActionSample(
              seat: 0,
              street: Street.preflop,
              kind: HandActionKind.blind,
              isHero: true,
              archetype: PlayerArchetype.hero,
              amountBb: 0.5,
            ),
            HandActionSample(
              seat: 3,
              street: Street.preflop,
              kind: HandActionKind.raise,
              archetype: PlayerArchetype.tag,
              amountBb: 3,
            ),
            HandActionSample(
              seat: 0,
              street: Street.preflop,
              kind: HandActionKind.fold,
              isHero: true,
              archetype: PlayerArchetype.hero,
            ),
          ],
          heroNetBb: -0.5,
        ),
    ];

    await pumpProfile(tester);

    expect(find.text('Nit'), findsOneWidget);
    expect(find.text('Low confidence'), findsOneWidget);
    expect(find.textContaining('20 hands logged'), findsOneWidget);
    expect(find.text('Needs more hands'), findsNothing);
    expect(find.text('0 hands logged'), findsNothing);
    expect(find.textContaining('style shows up here'), findsNothing);
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
