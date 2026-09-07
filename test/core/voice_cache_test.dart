/// Tests for the on-disk coach voice cache (keying, TTL, LRU eviction).
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/voice_cache.dart';

Uint8List _bytes(int length, [int fill = 7]) =>
    Uint8List.fromList(List<int>.filled(length, fill));

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('voice_cache_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  VoiceCache cache({int maxBytes = 1024, Duration? ttl}) => VoiceCache(
        maxBytes: maxBytes,
        ttl: ttl ?? const Duration(days: 7),
        directoryOverride: tempDir,
      );

  group('keyFor', () {
    test('is stable across whitespace differences', () {
      final a = VoiceCache.keyFor(
        text: 'Good fold on the turn.',
        voice: 'Puck',
        model: 'tts',
      );
      final b = VoiceCache.keyFor(
        text: '  Good fold\n on   the turn.  ',
        voice: 'Puck',
        model: 'tts',
      );
      expect(a, b);
    });

    test('changes with text, voice, and model', () {
      final base = VoiceCache.keyFor(
        text: 'Call is better here.',
        voice: 'Puck',
        model: 'tts',
      );
      expect(
        VoiceCache.keyFor(
          text: 'Raise is better here.',
          voice: 'Puck',
          model: 'tts',
        ),
        isNot(base),
      );
      expect(
        VoiceCache.keyFor(
          text: 'Call is better here.',
          voice: 'Kore',
          model: 'tts',
        ),
        isNot(base),
      );
      expect(
        VoiceCache.keyFor(
          text: 'Call is better here.',
          voice: 'Puck',
          model: 'tts-2',
        ),
        isNot(base),
      );
    });
  });

  test('a stored clip is returned on the next lookup', () async {
    final c = cache();
    final key = VoiceCache.keyFor(text: 'nice fold', voice: 'Puck', model: 'm');

    expect(await c.get(key), isNull);
    final stored = await c.put(key, _bytes(64));
    expect(stored, isNotNull);
    expect(stored!.bytes, 64);
    expect(File(stored.path).existsSync(), isTrue);

    final hit = await c.get(key);
    expect(hit, isNotNull);
    expect(hit!.path, stored.path);
  });

  test('empty audio is never cached', () async {
    final c = cache();
    expect(await c.put('empty', Uint8List(0)), isNull);
    expect(await c.sizeInBytes(), 0);
  });

  test('entries past the TTL are treated as a miss and deleted', () async {
    final c = cache(ttl: const Duration(milliseconds: 1));
    final clip = await c.put('stale', _bytes(32));
    expect(clip, isNotNull);

    // Backdate the file so it is definitively expired.
    File(clip!.path).setLastModifiedSync(
      DateTime.now().subtract(const Duration(hours: 1)),
    );

    expect(await c.get('stale'), isNull);
    expect(File(clip.path).existsSync(), isFalse);
  });

  test('stays under the byte budget by evicting least-recent clips', () async {
    final c = cache(maxBytes: 300);
    final now = DateTime.now();

    for (var i = 0; i < 4; i++) {
      final clip = await c.put('clip$i', _bytes(100, i));
      expect(clip, isNotNull);
      // Age the earlier clips so LRU order is deterministic.
      File(clip!.path).setLastModifiedSync(
        now.subtract(Duration(minutes: 10 - i)),
      );
    }

    // Writing a fifth clip triggers eviction down to the budget.
    await c.put('clip4', _bytes(100, 9));
    final size = await c.sizeInBytes();
    expect(size, lessThanOrEqualTo(300));

    // The newest clip survived; the oldest did not.
    expect(await c.get('clip4'), isNotNull);
    expect(await c.get('clip0'), isNull);
  });

  test('clear removes everything', () async {
    final c = cache();
    await c.put('a', _bytes(16));
    await c.put('b', _bytes(16));
    expect(await c.sizeInBytes(), greaterThan(0));

    await c.clear();
    expect(await c.sizeInBytes(), 0);
    expect(await c.get('a'), isNull);
  });
}
