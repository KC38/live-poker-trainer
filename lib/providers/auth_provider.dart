/// Riverpod auth state, uid, and sign-in / sign-out actions.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/user_document.dart';
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
/// Prefer this over [Config.defaultUserId] for any user-scoped Firestore path
/// (prefs, stats, profile) once the auth gate has admitted the session.
final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

/// Ensures `users/{uid}` exists and hydrates synced settings after sign-in.
final userDocProvider = FutureProvider<UserDocument?>((ref) async {
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

  /// Signs out; clears the user doc cache.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _auth.signOut();
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
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);
