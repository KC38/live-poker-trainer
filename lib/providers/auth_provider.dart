/// Riverpod auth state, uid, and sign-in / sign-out actions.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/main.dart' show firebaseAvailable;
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';

/// Whether the session is running in guest (offline) mode.
///
/// Flipped to `true` by the auth screen's "Continue as guest" CTA and reset
/// on explicit sign-out. When `true`, [authStateProvider] / [authUidProvider]
/// are ignored and the app navigates straight to HomeScreen.
final guestModeProvider = StateProvider<bool>((ref) => false);

/// Shared [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Firebase auth state stream (`null` when signed out).
///
/// Emits a single `null` immediately when Firebase failed to initialise,
/// so downstream listeners never stall.
final authStateProvider = StreamProvider<User?>((ref) {
  if (!firebaseAvailable) return Stream.value(null);
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current Firebase uid, or `null` when signed out.
///
/// Prefer this over [Config.defaultUserId] for any user-scoped Firestore path
/// (prefs, stats, profile) once the auth gate has admitted the session.
final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

/// Ensures `users/{uid}` exists and hydrates synced settings after sign-in.
///
/// Returns `null` immediately when Firebase is unavailable or guest mode is
/// active — all Firestore-dependent syncing is skipped.
final userDocProvider = FutureProvider<UserDocument?>((ref) async {
  if (!firebaseAvailable || ref.watch(guestModeProvider)) return null;

  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;

  final settings = ref.read(settingsProvider);
  final repo = ref.read(userRepositoryProvider);
  final doc = await repo.ensureUserDoc(
    uid: user.uid,
    displayName: user.displayName,
    preferences: settings,
  );

  // Apply remote gameplay prefs; keep device-local audio.
  unawaited(
    ref.read(settingsProvider.notifier).applyRemotePreferences(doc.preferences),
  );
  return doc;
});

/// Auth actions used by the login / register UI.
class AuthController extends StateNotifier<AsyncValue<void>> {
  /// Creates the controller.
  AuthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  AuthService get _auth => _ref.read(authServiceProvider);

  Future<void> _run(Future<User> Function() action) async {
    state = const AsyncValue.loading();
    try {
      final user = await action();
      await _ref.read(userRepositoryProvider).ensureUserDoc(
            uid: user.uid,
            displayName: user.displayName,
            preferences: _ref.read(settingsProvider),
          );
      // Refresh providers that key off the signed-in user.
      _ref.invalidate(userDocProvider);
      state = const AsyncValue.data(null);
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
    );
  }

  /// Email / password sign-in.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _run(
      () => _auth.signInWithEmail(email: email, password: password),
    );
  }

  /// Google Sign-In.
  Future<void> signInWithGoogle() {
    return _run(_auth.signInWithGoogle);
  }

  /// Signs out; clears the user doc cache and exits guest mode.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      _ref.read(guestModeProvider.notifier).state = false;
      if (firebaseAvailable) await _auth.signOut();
      _ref.invalidate(userDocProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Enters guest / offline mode (no Firebase required).
  void enterGuestMode() {
    _ref.read(guestModeProvider.notifier).state = true;
  }
}

/// Auth action controller.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);
