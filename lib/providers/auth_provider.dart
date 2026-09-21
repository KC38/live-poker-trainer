/// Riverpod auth state, uid, and sign-in / sign-out actions.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';

/// Shared [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Firebase auth state stream (`null` when signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current Firebase uid, or `null` when signed out.
///
/// All user-scoped data requires this authenticated server identity.
final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

/// Ensures `users/{uid}` exists and hydrates synced settings after sign-in.
///
/// Waits for durable [SharedPreferences] first so remote table-setup / gameplay
/// prefs are never applied to the temporary in-memory settings notifier (which
/// is discarded when real prefs resolve).
final userDocProvider = FutureProvider<UserDocument?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;

  // Gate on SharedPreferences so [settingsProvider] has the durable notifier.
  await ref.watch(sharedPreferencesProvider.future);

  final settings = ref.read(settingsProvider);
  final repo = ref.read(userRepositoryProvider);
  final doc = await repo.ensureUserDoc(
    uid: user.uid,
    displayName: user.displayName,
    preferences: settings,
  );

  // Apply remote gameplay prefs (table setup, blinds, lineup, …); keep audio local.
  final settingsNotifier = ref.read(settingsProvider.notifier);
  await settingsNotifier.applyRemotePreferences(doc.preferences);
  settingsNotifier.setCloudSyncEnabled(true);
  return doc;
});

/// Auth actions used by the login / register UI.
class AuthController extends StateNotifier<AsyncValue<void>> {
  /// Creates the controller.
  AuthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  AuthService get _auth => _ref.read(authServiceProvider);

  /// Ensures the cloud user doc exists, then invalidates [userDocProvider].
  ///
  /// When [seedLocalPreferences] is true (registration), a brand-new doc is
  /// seeded from the current device settings (table setup the user may have
  /// configured before signing up). Sign-in uses defaults so a previous
  /// account's local prefs cannot pollute a new user's first cloud doc.
  Future<void> _run(
    Future<User> Function() action, {
    bool seedLocalPreferences = false,
    required String method,
    required bool isSignUp,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await action();
      final requested = displayName?.trim();
      final resolvedName =
          (requested != null && requested.isNotEmpty)
              ? requested
              : user.displayName;
      final preferences =
          seedLocalPreferences
              ? _ref.read(settingsProvider)
              : const GameSettingsModel();
      final repo = _ref.read(userRepositoryProvider);
      await repo.ensureUserDoc(
        uid: user.uid,
        displayName: resolvedName,
        preferences: preferences,
      );
      // Auth state can create the doc before updateDisplayName lands on web.
      if (requested != null && requested.isNotEmpty) {
        await repo.updateProfile(uid: user.uid, displayName: requested);
      }
      // Refresh providers that key off the signed-in user (re-hydrates prefs).
      _ref.invalidate(userDocProvider);
      final analytics = _ref.read(analyticsServiceProvider);
      unawaited(analytics.setUserId(user.uid));
      if (isSignUp) {
        unawaited(analytics.logSignUp(method: method));
      } else {
        unawaited(analytics.logLogin(method: method));
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Transparent anonymous session for the first course lesson.
  Future<User> ensureAnonymousSession() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    state = const AsyncValue.loading();
    try {
      final user = await _auth.signInAnonymously();
      final repo = _ref.read(userRepositoryProvider);
      await repo.ensureUserDoc(
        uid: user.uid,
        displayName: 'Guest',
        preferences: const GameSettingsModel(),
      );
      _ref.invalidate(userDocProvider);
      unawaited(_ref.read(analyticsServiceProvider).setUserId(user.uid));
      unawaited(
        _ref
            .read(analyticsServiceProvider)
            .logEventSafe('guest_session_started'),
      );
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Email / password registration.
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _run(
      () => _auth.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
      seedLocalPreferences: true,
      method: 'email',
      isSignUp: true,
      displayName: displayName,
    );
  }

  /// Link email to the current anonymous user, or transfer on conflict.
  Future<void> registerOrLinkEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        await _run(
          () => _auth.linkWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          ),
          seedLocalPreferences: false,
          method: 'email_link',
          isSignUp: true,
          displayName: displayName,
        );
        unawaited(
          _ref
              .read(analyticsServiceProvider)
              .logAccountConversion(method: 'email_link', outcome: 'linked'),
        );
        return;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'email-already-in-use' &&
            error.code != 'credential-already-in-use') {
          unawaited(
            _ref
                .read(analyticsServiceProvider)
                .logAccountConversion(method: 'email_link', outcome: 'failed'),
          );
          rethrow;
        }
        await _transferThenSignIn(
          () => _auth.signInWithEmail(email: email, password: password),
          method: 'email',
        );
        return;
      }
    }
    await register(email: email, password: password, displayName: displayName);
  }

  /// Email / password sign-in (issues transfer first when anonymous).
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      await _transferThenSignIn(
        () => _auth.signInWithEmail(email: email, password: password),
        method: 'email',
      );
      return;
    }
    await _run(
      () => _auth.signInWithEmail(email: email, password: password),
      method: 'email',
      isSignUp: false,
    );
  }

  /// Google Sign-In / link / transfer.
  Future<void> signInWithGoogle() async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        await _run(_auth.linkWithGoogle, method: 'google_link', isSignUp: true);
        unawaited(
          _ref
              .read(analyticsServiceProvider)
              .logAccountConversion(method: 'google_link', outcome: 'linked'),
        );
        return;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use' &&
            error.code != 'email-already-in-use') {
          unawaited(
            _ref
                .read(analyticsServiceProvider)
                .logAccountConversion(method: 'google_link', outcome: 'failed'),
          );
          rethrow;
        }
        await _transferThenSignIn(_auth.signInWithGoogle, method: 'google');
        return;
      }
    }
    await _run(_auth.signInWithGoogle, method: 'google', isSignUp: false);
  }

  Future<void> _transferThenSignIn(
    Future<User> Function() signIn, {
    required String method,
  }) async {
    state = const AsyncValue.loading();
    try {
      final course = _ref.read(courseServiceProvider);
      final issued = await course.issueAnonymousProgressTransfer();
      final receiptId = issued['receiptId'] as String?;
      final nonce = issued['nonce'] as String?;
      if (receiptId == null ||
          receiptId.isEmpty ||
          nonce == null ||
          nonce.isEmpty) {
        throw StateError('Transfer receipt missing nonce.');
      }
      final user = await signIn();
      final repo = _ref.read(userRepositoryProvider);
      await repo.ensureUserDoc(
        uid: user.uid,
        displayName: user.displayName,
        preferences: const GameSettingsModel(),
      );
      await course.redeemAnonymousProgressTransfer(
        receiptId: receiptId,
        nonce: nonce,
      );
      _ref.invalidate(userDocProvider);
      final analytics = _ref.read(analyticsServiceProvider);
      unawaited(analytics.setUserId(user.uid));
      unawaited(analytics.logLogin(method: method));
      unawaited(
        analytics.logAccountConversion(method: method, outcome: 'merged'),
      );
      unawaited(analytics.logProgressMerge(outcome: 'succeeded'));
      unawaited(analytics.logEventSafe('guest_progress_transferred'));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      unawaited(
        _ref.read(analyticsServiceProvider).logProgressMerge(outcome: 'failed'),
      );
      unawaited(
        _ref
            .read(analyticsServiceProvider)
            .logAccountConversion(method: method, outcome: 'failed'),
      );
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Emails a password-reset link. Does not sign the user in.
  Future<void> sendPasswordReset({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Signs out; clears synced gameplay prefs from the device (keeps audio).
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final analytics = _ref.read(analyticsServiceProvider);
      unawaited(analytics.logLogout());
      unawaited(analytics.setUserId(null));
      await _auth.signOut();
      // After uid is cleared so we do not push defaults back to Firestore.
      final settingsNotifier = _ref.read(settingsProvider.notifier);
      settingsNotifier.setCloudSyncEnabled(false);
      await settingsNotifier.resetSyncedToDefaults();
      _ref.invalidate(userDocProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Auth action controller.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
