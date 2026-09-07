/// On-disk cache for synthesized coach voice clips.
///
/// Coaching lines repeat a lot ("Good fold on the turn…"), and a Gemini TTS
/// round trip costs a second or more. Clips are keyed by a SHA-256 of the
/// spoken text plus the voice and model, so a repeated line plays instantly
/// and never hits the network again. The cache is bounded by total bytes and
/// a TTL, evicting least-recently-used clips first.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// A cached voice clip on disk.
class CachedVoiceClip {
  /// Creates a cache entry.
  const CachedVoiceClip({required this.path, required this.bytes});

  /// Absolute file path, playable directly by `audioplayers`.
  final String path;

  /// Clip size in bytes.
  final int bytes;
}

/// LRU + TTL bounded audio cache stored under the app support directory.
class VoiceCache {
  /// Creates a voice cache.
  ///
  /// [maxBytes] and [ttl] bound disk usage. [directoryOverride] is for tests.
  VoiceCache({
    required this.maxBytes,
    required this.ttl,
    this.directoryOverride,
  });

  /// Byte budget for the cache directory.
  final int maxBytes;

  /// Age after which a clip is discarded.
  final Duration ttl;

  /// Base directory override, used by tests.
  final Directory? directoryOverride;

  Directory? _dir;
  bool _unavailable = false;

  /// Stable cache key for a coach line.
  static String keyFor({
    required String text,
    required String voice,
    required String model,
  }) {
    final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final digest = sha256.convert(
      utf8.encode('$model|$voice|$normalized'),
    );
    return digest.toString().substring(0, 32);
  }

  Future<Directory?> _ensureDir() async {
    if (_unavailable) return null;
    final existing = _dir;
    if (existing != null) return existing;
    try {
      final base = directoryOverride ?? await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/coach_voice');
      if (!dir.existsSync()) await dir.create(recursive: true);
      _dir = dir;
      return dir;
    } catch (e) {
      // Web / restricted platforms have no writable app support directory.
      debugPrint('VoiceCache unavailable: $e');
      _unavailable = true;
      return null;
    }
  }

  File? _fileFor(Directory dir, String key) {
    final file = File('${dir.path}/$key.wav');
    return file.existsSync() ? file : null;
  }

  /// Returns a cached clip for [key], or null on a miss / expired entry.
  Future<CachedVoiceClip?> get(String key) async {
    final dir = await _ensureDir();
    if (dir == null) return null;
    try {
      final file = _fileFor(dir, key);
      if (file == null) return null;
      final stat = file.statSync();
      if (DateTime.now().difference(stat.modified) > ttl) {
        await file.delete();
        return null;
      }
      // Touch for LRU ordering.
      file.setLastModifiedSync(DateTime.now());
      return CachedVoiceClip(path: file.path, bytes: stat.size);
    } catch (_) {
      return null;
    }
  }

  /// Writes [bytes] under [key] and returns the playable clip.
  Future<CachedVoiceClip?> put(String key, Uint8List bytes) async {
    if (bytes.isEmpty) return null;
    final dir = await _ensureDir();
    if (dir == null) return null;
    try {
      final file = File('${dir.path}/$key.wav');
      await file.writeAsBytes(bytes, flush: true);
      await _evict(dir);
      return CachedVoiceClip(path: file.path, bytes: bytes.length);
    } catch (_) {
      return null;
    }
  }

  /// Drops expired entries, then LRU-evicts until under the byte budget.
  Future<void> _evict(Directory dir) async {
    try {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.wav'))
          .toList();

      final now = DateTime.now();
      final live = <File>[];
      for (final f in files) {
        if (now.difference(f.statSync().modified) > ttl) {
          await f.delete();
        } else {
          live.add(f);
        }
      }

      var total = live.fold<int>(0, (sum, f) => sum + f.statSync().size);
      if (total <= maxBytes) return;

      live.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );
      for (final f in live) {
        if (total <= maxBytes) break;
        total -= f.statSync().size;
        await f.delete();
      }
    } catch (_) {
      // Eviction is best-effort.
    }
  }

  /// Total bytes currently cached (0 when unavailable).
  Future<int> sizeInBytes() async {
    final dir = await _ensureDir();
    if (dir == null) return 0;
    try {
      return dir
          .listSync()
          .whereType<File>()
          .fold<int>(0, (sum, f) => sum + f.statSync().size);
    } catch (_) {
      return 0;
    }
  }

  /// Deletes every cached clip.
  Future<void> clear() async {
    final dir = await _ensureDir();
    if (dir == null) return;
    try {
      for (final f in dir.listSync().whereType<File>()) {
        await f.delete();
      }
    } catch (_) {
      // Best-effort.
    }
  }
}
