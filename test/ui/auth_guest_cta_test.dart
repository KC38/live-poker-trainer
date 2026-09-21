/// Guest CTA visibility is gated by learningPlatformEnabled.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/curriculum/learning_feature_flags.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/feature_flags_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

class _FakeAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  String? get currentUid => null;

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
  Future<User> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<User> signInAnonymously() {
    throw UnimplementedError();
  }

  @override
  Future<User> linkWithCredential(AuthCredential credential) {
    throw UnimplementedError();
  }

  @override
  Future<User> linkWithEmailPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> linkWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAuth(
    WidgetTester tester, {
    required LearningFeatureFlags flags,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_FakeAuthService()),
          learningFeatureFlagsValueProvider.overrideWithValue(flags),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const AuthScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('hides Continue as guest when learning platform is off', (
    tester,
  ) async {
    await pumpAuth(tester, flags: LearningFeatureFlags.defaults);

    expect(find.text('Continue as guest'), findsNothing);
    expect(find.byKey(const Key('continue_as_guest')), findsNothing);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('shows Continue as guest when learning platform is on', (
    tester,
  ) async {
    await pumpAuth(
      tester,
      flags: const LearningFeatureFlags(learningPlatformEnabled: true),
    );

    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.byKey(const Key('continue_as_guest')), findsOneWidget);
  });
}
