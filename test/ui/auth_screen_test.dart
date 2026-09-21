/// Auth screen: forgot-password control and reset messaging.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

class _FakeAuthService implements AuthService {
  String? resetEmail;
  Object? resetError;
  int resetCalls = 0;

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
  Future<void> sendPasswordResetEmail({required String email}) async {
    resetCalls += 1;
    resetEmail = email;
    if (resetError != null) {
      throw resetError!;
    }
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthService auth;

  setUp(() {
    auth = _FakeAuthService();
  });

  Future<void> pumpAuth(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const AuthScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('sign-in mode shows Forgot password and sends a reset email', (
    tester,
  ) async {
    await pumpAuth(tester);

    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '');
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(auth.resetCalls, 0);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'player@example.com',
    );
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();

    expect(auth.resetCalls, 1);
    expect(auth.resetEmail, 'player@example.com');
    expect(
      find.text('If an account exists for that email, we sent a reset link.'),
      findsOneWidget,
    );
  });

  testWidgets('forgot password is hidden while registering', (tester) async {
    await pumpAuth(tester);

    await tester.tap(find.text('Need an account? Register'));
    await tester.pump();

    expect(find.text('Forgot password?'), findsNothing);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('reset failure shows a friendly error', (tester) async {
    auth.resetError = FirebaseAuthException(code: 'too-many-requests');
    await pumpAuth(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'player@example.com',
    );
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();

    expect(
      find.text('Too many attempts. Wait a minute and try again.'),
      findsOneWidget,
    );
  });
}
