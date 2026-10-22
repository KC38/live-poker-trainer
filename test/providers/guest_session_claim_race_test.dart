/// AppRoot reconciles the guest install on every auth-state event. The event
/// for a brand-new guest can land before [AuthController.ensureAnonymousSession]
/// claims the uid; that must not sign the new guest out (LPT lesson start
/// permission-denied on a fresh install).
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';
import 'package:live_poker_trainer/services/guest_install.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer containerFor({
    required MockFirebaseAuth auth,
    required SharedPreferences prefs,
    required AuthService authService,
  }) {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        userRepositoryProvider.overrideWithValue(_NoopUserRepository()),
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(enabled: false),
        ),
        authControllerProvider.overrideWith(
          (ref) => AuthController(
            ref,
            guestUserDocTimeout: const Duration(milliseconds: 50),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('auth event before the claim does not sign out the new guest', () async {
    // Fresh install: no claimed uid yet, restored guests are discarded.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = MockFirebaseAuth();
    late ProviderContainer container;
    var reconciledDuringSignIn = false;
    final authService = _RacingAuthService(
      auth,
      onSignedIn: () async {
        // AppRoot's auth listener fires as soon as the uid exists, before
        // ensureAnonymousSession has claimed it.
        expect(prefs.getString(guestInstallUidKey), isNull);
        await container
            .read(authControllerProvider.notifier)
            .reconcileGuestInstall();
        reconciledDuringSignIn = true;
      },
    );
    container = containerFor(
      auth: auth,
      prefs: prefs,
      authService: authService,
    );

    final user = await container
        .read(authControllerProvider.notifier)
        .ensureAnonymousSession()
        .timeout(const Duration(seconds: 2));

    expect(reconciledDuringSignIn, isTrue);
    expect(auth.currentUser, isNotNull, reason: 'new guest was signed out');
    expect(auth.currentUser!.uid, user.uid);
    expect(prefs.getString(guestInstallUidKey), user.uid);

    // A later auth event (after the claim) keeps the guest too.
    await container
        .read(authControllerProvider.notifier)
        .reconcileGuestInstall();
    expect(auth.currentUser?.uid, user.uid);
  });

  test(
    'a reload keeps the guest this install already claimed (LPT-1031)',
    () async {
      // Web reload mid-lesson: localStorage still holds this install's claim
      // and Firebase restores the same anonymous user. Both AppRoot's
      // reconcile and the runner's ensureAnonymousSession must keep it.
      SharedPreferences.setMockInitialValues({
        guestInstallUidKey: 'this-install-guest',
        discardRestoredAnonymousKey: false,
        onboardingDraftPrefsKey: '{"step":"firstLesson"}',
      });
      final prefs = await SharedPreferences.getInstance();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(isAnonymous: true, uid: 'this-install-guest'),
      );
      final container = containerFor(
        auth: auth,
        prefs: prefs,
        authService: AuthService(firebaseAuth: auth),
      );
      final controller = container.read(authControllerProvider.notifier);

      await markGuestInstallGeneration(prefs);
      await controller.reconcileGuestInstall();
      expect(auth.currentUser?.uid, 'this-install-guest');

      final user = await controller.ensureAnonymousSession().timeout(
        const Duration(seconds: 2),
      );
      expect(user.uid, 'this-install-guest');
      expect(auth.currentUser?.uid, 'this-install-guest');

      await controller.reconcileGuestInstall();
      expect(
        auth.currentUser?.uid,
        'this-install-guest',
        reason: 'guest was signed out after the lesson started',
      );
    },
  );

  test(
    'a guest restored from a previous install is still signed out',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(isAnonymous: true, uid: 'previous-install-guest'),
      );
      final container = containerFor(
        auth: auth,
        prefs: prefs,
        authService: AuthService(firebaseAuth: auth),
      );

      await container
          .read(authControllerProvider.notifier)
          .reconcileGuestInstall();

      expect(auth.currentUser, isNull);
    },
  );
}

/// Runs [onSignedIn] after Firebase creates the guest but before
/// [AuthService.signInAnonymously] returns to the controller.
class _RacingAuthService extends AuthService {
  _RacingAuthService(MockFirebaseAuth auth, {required this.onSignedIn})
    : super(firebaseAuth: auth);

  final Future<void> Function() onSignedIn;

  @override
  Future<User> signInAnonymously() async {
    final user = await super.signInAnonymously();
    await onSignedIn();
    return user;
  }
}

class _NoopUserRepository extends UserRepository {
  @override
  Future<UserDocument> ensureUserDoc({
    required String uid,
    String? displayName,
    String? avatarRef,
    GameSettingsModel preferences = const GameSettingsModel(),
  }) {
    return Completer<UserDocument>().future;
  }
}
