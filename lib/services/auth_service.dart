/// Firebase Auth + Google Sign-In wrappers for email and Google providers.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Web / server OAuth client (type 3) from Firebase — needed for Google ID
/// tokens on Android and as the web [GoogleSignIn] client id.
const String kGoogleServerClientId =
    '584262608034-0ev32dvo4qtm4h7hg31tsih29pmq7rmq.apps.googleusercontent.com';

/// Thin facade over [FirebaseAuth] and [GoogleSignIn].
class AuthService {
  /// Creates an auth service. Optional overrides support tests.
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  Future<void>? _googleInit;

  /// Auth state changes (null when signed out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Current uid, or null when signed out.
  String? get currentUid => _auth.currentUser?.uid;

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= _google.initialize(
      clientId: kIsWeb ? kGoogleServerClientId : null,
      serverClientId: kGoogleServerClientId,
    );
  }

  /// Registers with email + password and returns the Firebase user.
  Future<User> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Registration succeeded but no user was returned.',
      );
    }
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      await user.updateDisplayName(name);
      await user.reload();
    }
    return _auth.currentUser ?? user;
  }

  /// Signs in with email + password.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Sign-in succeeded but no user was returned.',
      );
    }
    return user;
  }

  /// Interactive Google Sign-In, then Firebase credential exchange.
  ///
  /// Android requires the app SHA-1 in the Firebase console; without it this
  /// fails at runtime (documented blocker).
  Future<User> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google Sign-In did not return an ID token.',
      );
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Google sign-in succeeded but no user was returned.',
      );
    }
    return user;
  }

  /// Creates an anonymous Firebase session (guest bootstrap).
  ///
  /// Requires Anonymous Auth enabled in the Firebase console.
  Future<User> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Anonymous sign-in succeeded but no user was returned.',
      );
    }
    return user;
  }

  /// Links the current user (typically anonymous) with [credential].
  ///
  /// Used to upgrade a guest session to a durable email/Google account
  /// without losing the same Firebase uid.
  Future<User> linkWithCredential(AuthCredential credential) async {
    final current = _auth.currentUser;
    if (current == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Sign in before linking a credential.',
      );
    }
    final cred = await current.linkWithCredential(credential);
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Link succeeded but no user was returned.',
      );
    }
    return _auth.currentUser ?? user;
  }

  /// Links the current user with email + password credentials.
  Future<User> linkWithEmailPassword({
    required String email,
    required String password,
  }) {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    return linkWithCredential(credential);
  }

  /// Interactive Google account link for the current (guest) user.
  Future<User> linkWithGoogle() async {
    await _ensureGoogleInitialized();
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google Sign-In did not return an ID token.',
      );
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return linkWithCredential(credential);
  }

  /// Sends a password-reset email for [email].
  ///
  /// Treats `user-not-found` as success so the UI cannot leak whether an
  /// account exists.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return;
      }
      rethrow;
    }
  }

  /// Signs out of Firebase and Google (best-effort).
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await _google.signOut();
    } catch (_) {
      // Google may not have been used this session.
    }
    await _auth.signOut();
  }
}
