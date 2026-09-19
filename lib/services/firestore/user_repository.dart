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
  /// Defaults: [displayName] / empty avatar and non-audio [preferences].
  Future<UserDocument> ensureUserDoc({
    required String uid,
    String? displayName,
    String? avatarRef,
    GameSettingsModel preferences = const GameSettingsModel(),
  }) async {
    final existing = await getUser(uid);
    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    final doc = UserDocument(
      displayName: HeroIdentity.sanitizeName(
        displayName ?? HeroIdentity.defaultDisplayName,
      ),
      avatarRef: avatarRef ?? '',
      createdAt: now,
      updatedAt: now,
      preferences: preferences,
    );
    await _doc(uid).set(doc.toFirestoreMap());
    return doc;
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
