/// Voice clip metadata DAO backing [VoiceCache] via [VoiceClipStore].
library;

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/core/audio/voice_cache.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';

/// Persists `voice_clips` rows: one per cached coach line.
class VoiceClipDao implements VoiceClipStore {
  /// Creates a DAO bound to [db].
  VoiceClipDao(this.db);

  final AppDatabase db;

  static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  @override
  Future<void> recordPut({
    required String cacheKey,
    required String text,
    required String voice,
    required String modelId,
    required int byteSize,
    required DateTime expiresAt,
    String? filePath,
    Uint8List? audioBlob,
    String mimeType = 'audio/wav',
  }) async {
    final ts = _now();
    await db.into(db.voiceClips).insertOnConflictUpdate(
          VoiceClipsCompanion.insert(
            cacheKey: cacheKey,
            spokenText: text,
            voice: voice,
            modelId: modelId,
            mimeType: Value(mimeType),
            byteSize: byteSize,
            filePath: Value(filePath),
            audioBlob: Value(audioBlob),
            createdAtMs: ts,
            lastAccessedAtMs: ts,
            hitCount: const Value(0),
            expiresAtMs: expiresAt.toUtc().millisecondsSinceEpoch,
            evictedAtMs: const Value(null),
            evictionReason: const Value(null),
            updatedAtMs: ts,
          ),
        );
  }

  @override
  Future<void> recordHit(String cacheKey) async {
    final ts = _now();
    await db.customUpdate(
      'UPDATE voice_clips SET hit_count = hit_count + 1, '
      'last_accessed_at_ms = ?, updated_at_ms = ? WHERE cache_key = ?',
      variables: [
        Variable.withInt(ts),
        Variable.withInt(ts),
        Variable.withString(cacheKey),
      ],
      updates: {db.voiceClips},
    );
  }

  @override
  Future<void> recordEviction(
    String cacheKey,
    VoiceEvictionReason reason,
  ) async {
    final ts = _now();
    await (db.update(db.voiceClips)..where((t) => t.cacheKey.equals(cacheKey)))
        .write(
      VoiceClipsCompanion(
        evictedAtMs: Value(ts),
        evictionReason: Value(reason.name),
        audioBlob: const Value(null),
        updatedAtMs: Value(ts),
      ),
    );
  }

  @override
  Future<void> recordClear(VoiceEvictionReason reason) async {
    final ts = _now();
    await (db.update(db.voiceClips)..where((t) => t.evictedAtMs.isNull()))
        .write(
      VoiceClipsCompanion(
        evictedAtMs: Value(ts),
        evictionReason: Value(reason.name),
        audioBlob: const Value(null),
        updatedAtMs: Value(ts),
      ),
    );
  }

  @override
  Future<Uint8List?> readBlob(String cacheKey) async {
    final row = await (db.select(db.voiceClips)
          ..where((t) => t.cacheKey.equals(cacheKey) & t.evictedAtMs.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    if (row.expiresAtMs < _now()) {
      await recordEviction(cacheKey, VoiceEvictionReason.ttl);
      return null;
    }
    return row.audioBlob;
  }

  /// Live (not evicted) clips, most recently used first.
  Future<List<VoiceClip>> liveClips({int limit = 200}) =>
      (db.select(db.voiceClips)
            ..where((t) => t.evictedAtMs.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.lastAccessedAtMs)])
            ..limit(limit))
          .get();

  /// Cache-wide counters for a debug panel.
  Future<({int live, int evicted, int bytes, int hits})> stats() async {
    final rows = await db.select(db.voiceClips).get();
    var live = 0;
    var evicted = 0;
    var bytes = 0;
    var hits = 0;
    for (final r in rows) {
      if (r.evictedAtMs == null) {
        live++;
        bytes += r.byteSize;
      } else {
        evicted++;
      }
      hits += r.hitCount;
    }
    return (live: live, evicted: evicted, bytes: bytes, hits: hits);
  }
}
