/// VoiceClipDao through VoiceCache: metadata mirroring on disk and the
/// database blob fallback when no cache directory is available.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/voice_cache.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/voice_clip_dao.dart';

Uint8List _bytes(int n, [int fill = 1]) =>
    Uint8List.fromList(List<int>.filled(n, fill));

void main() {
  late AppDatabase db;
  late VoiceClipDao store;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = VoiceClipDao(db);
    tempDir = Directory.systemTemp.createTempSync('voice_clip_dao');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('disk-backed cache mirrors put / hit / eviction metadata', () async {
    final cache = VoiceCache(
      maxBytes: 100,
      ttl: const Duration(days: 1),
      directoryOverride: tempDir,
      store: store,
    );
    final k1 = VoiceCache.keyFor(text: 'one', voice: 'Puck', model: 'tts');
    final k2 = VoiceCache.keyFor(text: 'two', voice: 'Puck', model: 'tts');

    await cache.putDescribed(k1, _bytes(60),
        text: 'one', voice: 'Puck', modelId: 'tts');
    await cache.get(k1);
    await cache.get(k1);
    // Let fire-and-forget hit updates land.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    var row = (await store.liveClips()).single;
    expect(row.cacheKey, k1);
    expect(row.spokenText, 'one');
    expect(row.voice, 'Puck');
    expect(row.modelId, 'tts');
    expect(row.byteSize, 60);
    expect(row.hitCount, 2);
    expect(row.filePath, isNotNull);
    expect(row.audioBlob, isNull, reason: 'bytes live on disk');
    expect(row.expiresAtMs, greaterThan(row.createdAtMs));

    // Second clip exceeds the byte budget; the LRU clip is evicted.
    await cache.putDescribed(k2, _bytes(60),
        text: 'two', voice: 'Puck', modelId: 'tts');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final live = await store.liveClips();
    expect(live.map((r) => r.cacheKey), [k2]);
    final all = await db.select(db.voiceClips).get();
    row = all.firstWhere((r) => r.cacheKey == k1);
    expect(row.evictedAtMs, isNotNull);
    expect(row.evictionReason, VoiceEvictionReason.lru.name);

    final stats = await store.stats();
    expect(stats.live, 1);
    expect(stats.evicted, 1);
    expect(stats.bytes, 60);
    expect(stats.hits, 2);
  });

  test('clear marks every live clip evicted', () async {
    final cache = VoiceCache(
      maxBytes: 1000,
      ttl: const Duration(days: 1),
      directoryOverride: tempDir,
      store: store,
    );
    await cache.putDescribed('k', _bytes(5),
        text: 't', voice: 'v', modelId: 'm');
    await cache.clear();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final row = (await db.select(db.voiceClips).get()).single;
    expect(row.evictionReason, VoiceEvictionReason.clear.name);
    expect(await store.liveClips(), isEmpty);
  });

  test('blob fallback serves clips from the database', () async {
    // No directory override and no path_provider in tests: the cache has no
    // writable directory, so bytes are kept in `voice_clips.audio_blob`.
    final cache = VoiceCache(
      maxBytes: 1000,
      ttl: const Duration(days: 1),
      store: store,
    );
    final stored = await cache.putDescribed('blobkey', _bytes(12, 9),
        text: 'hello', voice: 'Puck', modelId: 'tts');
    expect(stored, isNotNull);
    expect(stored!.hasFile, isFalse);
    expect(stored.data, isNotNull);

    final row = (await store.liveClips()).single;
    expect(row.filePath, isNull);
    expect(row.audioBlob, hasLength(12));

    final fetched = await cache.get('blobkey');
    expect(fetched, isNotNull);
    expect(fetched!.hasFile, isFalse);
    expect(fetched.data, equals(_bytes(12, 9)));
    expect(await store.readBlob('missing'), isNull);
  });

  test('expired blobs are evicted on read', () async {
    await store.recordPut(
      cacheKey: 'old',
      text: 't',
      voice: 'v',
      modelId: 'm',
      byteSize: 3,
      expiresAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
      audioBlob: _bytes(3),
    );
    expect(await store.readBlob('old'), isNull);
    final row = (await db.select(db.voiceClips).get()).single;
    expect(row.evictionReason, VoiceEvictionReason.ttl.name);
    expect(row.audioBlob, isNull);
  });
}
