/// Client repository for `users/{uid}/playedScenarios/{scenarioId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/services/firestore/played_scenario_doc.dart';
import 'package:live_poker_trainer/services/firestore/scenario_pool_doc.dart';
import 'package:live_poker_trainer/services/firestore/scenario_pool_repo.dart';

/// Read / write helpers for per-user played scenario receipts.
class PlayedScenariosRepo {
  /// Creates a repo bound to [firestore] (injectable for tests).
  ///
  /// Default instance is lazy — safe to construct before Firebase init.
  PlayedScenariosRepo({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('playedScenarios');

  /// Whether [scenarioId] was already played by [uid].
  Future<bool> hasPlayed({
    required String uid,
    required String scenarioId,
  }) async {
    final snap = await _col(uid).doc(scenarioId).get();
    return snap.exists;
  }

  /// Fetches one played receipt, or null.
  Future<PlayedScenarioDoc?> fetch({
    required String uid,
    required String scenarioId,
  }) async {
    final snap = await _col(uid).doc(scenarioId).get();
    return PlayedScenarioDoc.fromSnapshot(snap);
  }

  /// All played scenario ids for [uid] (doc ids = content hashes).
  ///
  /// Loads in pages so large histories stay under Firestore limits. Use this
  /// set with [ScenarioPoolRepo.filterUnplayed] on the client.
  Future<Set<String>> playedIds({
    required String uid,
    int pageSize = 200,
  }) async {
    final ids = <String>{};
    QueryDocumentSnapshot<Map<String, dynamic>>? cursor;
    final size = pageSize.clamp(1, 500);
    while (true) {
      Query<Map<String, dynamic>> q = _col(uid).orderBy(FieldPath.documentId).limit(size);
      if (cursor != null) {
        q = q.startAfterDocument(cursor);
      }
      final snap = await q.get();
      if (snap.docs.isEmpty) break;
      for (final doc in snap.docs) {
        ids.add(doc.id);
      }
      if (snap.docs.length < size) break;
      cursor = snap.docs.last;
    }
    return ids;
  }

  /// Recent played rows for [uid], newest first.
  Future<List<PlayedScenarioDoc>> listRecent({
    required String uid,
    int limit = 50,
  }) async {
    final snap = await _col(uid)
        .orderBy('playedAt', descending: true)
        .limit(limit.clamp(1, 200))
        .get();
    return snap.docs
        .map(PlayedScenarioDoc.fromSnapshot)
        .whereType<PlayedScenarioDoc>()
        .toList(growable: false);
  }

  /// Records that [scenarioId] was graded / finished by [uid].
  ///
  /// Doc id uniqueness means the same scenario is never replayed. Uses merge
  /// so a second write refreshes grade fields without creating a second doc.
  Future<void> markPlayed({
    required String uid,
    required String scenarioId,
    required bool wasCorrect,
    required double evDeltaBb,
    required String street,
    required String archetype,
  }) async {
    final doc = PlayedScenarioDoc(
      scenarioId: scenarioId,
      playedAt: DateTime.now().toUtc(),
      wasCorrect: wasCorrect,
      evDeltaBb: evDeltaBb,
      street: street,
      archetype: archetype,
    );
    await _col(uid).doc(scenarioId).set(
          doc.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }

  /// Convenience: recent pool docs minus this user's played ids.
  Future<List<ScenarioPoolDoc>> unplayedFromPool({
    required String uid,
    required ScenarioPoolRepo pool,
    int poolLimit = 50,
  }) async {
    final played = await playedIds(uid: uid);
    final recent = await pool.listRecent(limit: poolLimit);
    return ScenarioPoolRepo.filterUnplayed(recent, played);
  }
}
