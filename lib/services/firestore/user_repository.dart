/// Firestore `users/{uid}` create / load / prefs+stats sync.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';

/// CRUD + merge helpers for server-backed profile and preferences.
class UserRepository {
  /// Creates a repository bound to [firestore] (defaults to the app instance).
  ///
  /// Default instance is lazy — safe to construct before Firebase init.
  UserRepository({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _users.doc(uid);

  /// Loads `users/{uid}`, or null when missing.
  Future<UserDocument?> getUser(String uid) async {
    final snap = await _doc(uid).get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return UserDocument.fromFirestore(snap.data()!);
  }

  /// Creates the user doc on first login; returns the existing doc otherwise.
  ///
  /// A later create that only has the default name does not replace a name
  /// the player already chose. The reverse does upgrade `Hero` when registration
  /// supplies a real name after auth state has already created the doc.
  Future<UserDocument> ensureUserDoc({
    required String uid,
    String? displayName,
    String? avatarRef,
    GameSettingsModel preferences = const GameSettingsModel(),
  }) async {
    final requested = HeroIdentity.sanitizeName(
      displayName ?? HeroIdentity.defaultDisplayName,
    );
    final now = DateTime.now().toUtc();
    return _db.runTransaction((tx) async {
      final snap = await tx.get(_doc(uid));
      if (snap.exists && snap.data() != null) {
        final existing = UserDocument.fromFirestore(snap.data()!);
        final upgrade =
            existing.displayName == HeroIdentity.defaultDisplayName &&
            requested != HeroIdentity.defaultDisplayName;
        if (!upgrade) return existing;
        tx.update(_doc(uid), {
          'displayName': requested,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return UserDocument(
          displayName: requested,
          avatarRef: existing.avatarRef,
          createdAt: existing.createdAt,
          updatedAt: now,
          preferences: existing.preferences,
        );
      }

      final doc = UserDocument(
        displayName: requested,
        avatarRef: avatarRef ?? '',
        createdAt: now,
        updatedAt: now,
        preferences: preferences,
      );
      tx.set(_doc(uid), doc.toFirestoreMap());
      return doc;
    });
  }

  /// Updates profile identity fields and stamps [updatedAt].
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarRef,
  }) async {
    final patch = <String, Object?>{'updatedAt': FieldValue.serverTimestamp()};
    if (displayName != null) {
      patch['displayName'] = HeroIdentity.sanitizeName(displayName);
    }
    if (avatarRef != null) {
      patch['avatarRef'] = avatarRef;
    }
    await _doc(uid).set(patch, SetOptions(merge: true));
  }

  /// Writes non-audio preferences under `preferences`.
  Future<void> syncPreferences({
    required String uid,
    required GameSettingsModel settings,
  }) async {
    await _doc(uid).set({
      'preferences': settings.toFirestorePreferences(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
