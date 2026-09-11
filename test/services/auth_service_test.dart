/// Unit tests for [AuthService] sign-out flow.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:live_poker_trainer/services/auth_service.dart';

/// Fake [FirebaseAuth] that records sign-out calls.
class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  bool signedOut = false;

  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

/// Fake [GoogleSignIn] that records signOut and disconnect calls.
class _FakeGoogleSignIn extends Fake implements GoogleSignIn {
  bool signedOut = false;
  bool disconnected = false;
  bool initialized = false;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    initialized = true;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<void> disconnect() async {
    disconnected = true;
  }
}

void main() {
  group('AuthService.signOut', () {
    late _FakeFirebaseAuth fakeAuth;
    late _FakeGoogleSignIn fakeGoogle;
    late AuthService service;

    setUp(() {
      fakeAuth = _FakeFirebaseAuth();
      fakeGoogle = _FakeGoogleSignIn();
      service = AuthService(
        firebaseAuth: fakeAuth,
        googleSignIn: fakeGoogle,
      );
    });

    test('signs out of Firebase', () async {
      await service.signOut();
      expect(fakeAuth.signedOut, isTrue);
    });

    test('signs out of Google Sign-In', () async {
      await service.signOut();
      expect(fakeGoogle.signedOut, isTrue);
    });

    test('disconnects Google to clear silent credentials', () async {
      await service.signOut();
      expect(fakeGoogle.disconnected, isTrue);
    });

    test('initializes Google before sign-out', () async {
      await service.signOut();
      expect(fakeGoogle.initialized, isTrue);
    });

    test('Firebase signs out even if Google disconnect throws', () async {
      final failGoogle = _FailingDisconnectGoogle();
      final svc = AuthService(
        firebaseAuth: fakeAuth,
        googleSignIn: failGoogle,
      );
      await svc.signOut();
      expect(fakeAuth.signedOut, isTrue);
    });
  });
}

/// Google Sign-In that throws on disconnect but succeeds on signOut.
class _FailingDisconnectGoogle extends Fake implements GoogleSignIn {
  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> disconnect() async {
    throw Exception('disconnect failed');
  }
}
