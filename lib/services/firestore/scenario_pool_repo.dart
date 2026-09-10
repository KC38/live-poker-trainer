/// Client repository for the global Firestore scenario pool.
///
/// Doc id is `contentHash`. Creates / payload writes are Functions-only;
/// clients may bump serve counters via [markServed] (rules allowlist).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/services/firestore/scenario_pool_doc.dart';

/// Read / serve helpers for `scenarios/{contentHash}`.
class ScenarioPoolRepo {
  /// Creates a repo bound to [firestore] (injectable for tests).
  ///
  /// The default instance is resolved lazily so constructing the repo (e.g. in
  /// a Riverpod provider) does not require Firebase to be initialized yet.
  ScenarioPoolRepo({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('scenarios');

  /// Fetches one scenario by [contentHash], or null if missing.
  Future<ScenarioPoolDoc?> fetch(String contentHash) async {
    final snap = await _col.doc(contentHash).get();
    return ScenarioPoolDoc.fromSnapshot(snap);
  }

  /// Lists pool docs, newest [generatedAt] first.
  ///
  /// Requires only the default single-field index on `generatedAt`.
  Future<List<ScenarioPoolDoc>> listRecent({int limit = 50}) async {
    final snap = await _col
        .orderBy('generatedAt', descending: true)
        .limit(limit.clamp(1, 200))
        .get();
    return snap.docs
        .map(ScenarioPoolDoc.fromSnapshot)
        .whereType<ScenarioPoolDoc>()
        .toList(growable: false);
  }

  /// Returns [ScenarioModel]s for recent pool docs (payload parse).
  Future<List<ScenarioModel>> listRecentModels({int limit = 50}) async {
    final docs = await listRecent(limit: limit);
    return docs.map((d) => d.toScenarioModel()).toList(growable: false);
  }

  /// Filters [candidates] to those whose [ScenarioPoolDoc.contentHash] is not
  /// in [playedIds]. Prefer this on the client after loading played ids.
  static List<ScenarioPoolDoc> filterUnplayed(
    Iterable<ScenarioPoolDoc> candidates,
    Set<String> playedIds,
  ) {
    if (playedIds.isEmpty) {
      return List<ScenarioPoolDoc>.unmodifiable(candidates);
    }
    return [
      for (final doc in candidates)
        if (!playedIds.contains(doc.contentHash)) doc,
    ];
  }

  /// Same as [filterUnplayed] but returns parsed [ScenarioModel]s.
  static List<ScenarioModel> filterUnplayedModels(
    Iterable<ScenarioPoolDoc> candidates,
    Set<String> playedIds,
  ) {
    return filterUnplayed(candidates, playedIds)
        .map((d) => d.toScenarioModel())
        .toList(growable: false);
  }

  /// Bumps `timesServed` and sets `lastServedAt` for [contentHash].
  ///
  /// No-op if the doc does not exist. Rules allow only these two fields to
  /// change from authenticated clients.
  Future<void> markServed(String contentHash) async {
    final ref = _col.doc(contentHash);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      tx.update(ref, {
        'timesServed': FieldValue.increment(1),
        'lastServedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
