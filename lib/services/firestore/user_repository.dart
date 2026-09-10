/// Firestore `users/{uid}` create / load / prefs+stats sync.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

/// CRUD + merge helpers for the per-user Firestore document.
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
    final snap = await _doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserDocument.fromFirestore(snap.data()!);
  }

  /// Creates the user doc on first login; returns the existing doc otherwise.
  ///
  /// Defaults: [displayName] / empty avatar, [preferences] from current
  /// [GameSettingsModel] (non-audio fields persisted), empty [UserStatsModel].
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
      stats: const UserStatsModel(),
    );
    await _doc(uid).set(doc.toFirestoreMap());
    return doc;
  }

  /// Watches the user document (emits null while missing).
  Stream<UserDocument?> watchUser(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserDocument.fromFirestore(snap.data()!);
    });
  }

  /// Updates profile identity fields and stamps [updatedAt].
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarRef,
  }) async {
    final patch = <String, Object?>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
    await _doc(uid).set(
      {
        'preferences': settings.toFirestorePreferences(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Replaces the full `stats` map.
  Future<void> syncStats({
    required String uid,
    required UserStatsModel stats,
  }) async {
    await _doc(uid).set(
      {
        'stats': stats.toFirestoreMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Loads stats from the user doc (empty model when missing).
  Future<UserStatsModel> getStats(String uid) async {
    final doc = await getUser(uid);
    return doc?.stats ?? const UserStatsModel();
  }

  /// Applies a practice grading outcome and persists updated stats.
  Future<UserStatsModel> recordPracticeResult({
    required String uid,
    required bool wasCorrect,
    required double evDeltaBb,
    required String street,
    required String archetype,
  }) async {
    final current = await getStats(uid);
    final arch = Map<String, ArchetypeStat>.from(current.archetypeAccuracy);
    final prevArch = arch[archetype] ?? ArchetypeStat(archetype: archetype);
    arch[archetype] = prevArch.copyWith(
      played: prevArch.played + 1,
      correct: prevArch.correct + (wasCorrect ? 1 : 0),
      evBb: prevArch.evBb + evDeltaBb,
    );

    final streets = Map<String, StreetStat>.from(current.streetAccuracy);
    final prevStreet = streets[street] ?? StreetStat(street: street);
    streets[street] = prevStreet.copyWith(
      played: prevStreet.played + 1,
      correct: prevStreet.correct + (wasCorrect ? 1 : 0),
    );

    final recent = [...current.recentEvDeltas, evDeltaBb];
    if (recent.length > 40) {
      recent.removeRange(0, recent.length - 40);
    }

    final updated = current.copyWith(
      totalSpots: current.totalSpots + 1,
      correctSpots: current.correctSpots + (wasCorrect ? 1 : 0),
      netEvBb: current.netEvBb + evDeltaBb,
      archetypeAccuracy: arch,
      streetAccuracy: streets,
      recentEvDeltas: recent,
    );
    await syncStats(uid: uid, stats: updated);
    return updated;
  }
}
