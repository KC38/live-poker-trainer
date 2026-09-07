/// On-disk cache for synthesized coach voice clips, mirrored in the database.
///
/// Coaching lines repeat a lot ("Good fold on the turn…"), and a Gemini TTS
/// round trip costs a second or more. Clips are keyed by a SHA-256 of the
/// spoken text plus the voice and model, so a repeated line plays instantly
/// and never hits the network again. The cache is bounded by total bytes and
/// a TTL, evicting least-recently-used clips first.
///
/// When a [VoiceClipStore] is attached, every put / hit / eviction is recorded
/// in the `voice_clips` table (text, voice, model, size, hit count, expiry,
/// eviction reason). On platforms with no writable support directory (web) the
/// WAV bytes themselves are kept in the store so the cache still works.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:path_provider/path_provider.dart';

/// A cached voice clip.
class CachedVoiceClip {
  /// Creates a cache entry.
  const CachedVoiceClip({
    required this.path,
    required this.bytes,
    this.data,
  });

  /// Absolute file path, playable directly by `audioplayers`; empty when the
  /// clip is only available as [data].
  final String path;

  /// Clip size in bytes.
  final int bytes;

  /// In-memory WAV bytes when no file exists (database-backed clip).
  final Uint8List? data;

  /// Whether [path] points at a real file.
  bool get hasFile => path.isNotEmpty;
}

/// Why a clip left the cache.
enum VoiceEvictionReason { ttl, lru, clear, missing }

/// Persistence for voice clip metadata (and bytes when no disk is available).
///
/// Implemented by `VoiceClipDao`; kept abstract so the audio layer does not
/// depend on Drift and tests can run without a database.
abstract class VoiceClipStore {
  /// Records a fresh clip. [filePath] is null when [audioBlob] is provided.
  Future<void> recordPut({
    required String cacheKey,
    required String text,
    required String voice,
    required String modelId,
    required int byteSize,
    required DateTime expiresAt,
    String? filePath,
    Uint8List? audioBlob,
  });

  /// Bumps hit count / last access for a cache hit.
  Future<void> recordHit(String cacheKey);

  /// Marks a clip evicted.
  Future<void> recordEviction(String cacheKey, VoiceEvictionReason reason);

  /// Marks every live clip evicted with [reason].
  Future<void> recordClear(VoiceEvictionReason reason);

  /// Bytes of a database-backed clip, or null when not stored / evicted.
  Future<Uint8List?> readBlob(String cacheKey);
}

/// LRU + TTL bounded audio cache stored under the app support directory.
class VoiceCache {
  /// Creates a voice cache.
  ///
  /// [maxBytes] and [ttl] bound disk usage. [directoryOverride] is for tests.
  /// [store] mirrors metadata into the database when provided.
  VoiceCache({
    required this.maxBytes,
    required this.ttl,
    this.directoryOverride,
    this.store,
  });

  /// Byte budget for the cache directory.
  final int maxBytes;

  /// Age after which a clip is discarded.
  final Duration ttl;

  /// Base directory override, used by tests.
  final Directory? directoryOverride;

  /// Metadata / blob persistence (optional).
  final VoiceClipStore? store;

  Directory? _dir;
  bool _unavailable = false;

  /// Metadata for the clip currently being written; see [putDescribed].
  static const String _unknownText = '';

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
      DiagnosticsLog.warning('VoiceCache.ensureDir', 'unavailable: $e');
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
    if (dir == null) return _getFromStore(key);
    try {
      final file = _fileFor(dir, key);
      if (file == null) return null;
      final stat = file.statSync();
      if (DateTime.now().difference(stat.modified) > ttl) {
        await file.delete();
        _note(store?.recordEviction(key, VoiceEvictionReason.ttl));
        return null;
      }
      // Touch for LRU ordering.
      file.setLastModifiedSync(DateTime.now());
      _note(store?.recordHit(key));
      return CachedVoiceClip(path: file.path, bytes: stat.size);
    } catch (e, s) {
      DiagnosticsLog.error('VoiceCache.get', e, s);
      return null;
    }
  }

  Future<CachedVoiceClip?> _getFromStore(String key) async {
    final s = store;
    if (s == null) return null;
    try {
      final blob = await s.readBlob(key);
      if (blob == null || blob.isEmpty) return null;
      _note(s.recordHit(key));
      return CachedVoiceClip(path: '', bytes: blob.length, data: blob);
    } catch (e, st) {
      DiagnosticsLog.error('VoiceCache.getFromStore', e, st);
      return null;
    }
  }

  /// Writes [bytes] under [key] and returns the playable clip.
  ///
  /// Prefer [putDescribed] so the database row carries the spoken text.
  Future<CachedVoiceClip?> put(String key, Uint8List bytes) => putDescribed(
        key,
        bytes,
        text: _unknownText,
        voice: '',
        modelId: '',
      );

  /// Writes [bytes] under [key], recording [text] / [voice] / [modelId] in the
  /// metadata store, and returns the playable clip.
  Future<CachedVoiceClip?> putDescribed(
    String key,
    Uint8List bytes, {
    required String text,
    required String voice,
    required String modelId,
  }) async {
    if (bytes.isEmpty) return null;
    final expiresAt = DateTime.now().add(ttl);
    final dir = await _ensureDir();
    if (dir == null) {
      final s = store;
      if (s == null) return null;
      try {
        await s.recordPut(
          cacheKey: key,
          text: text,
          voice: voice,
          modelId: modelId,
          byteSize: bytes.length,
          expiresAt: expiresAt,
          audioBlob: bytes,
        );
        return CachedVoiceClip(path: '', bytes: bytes.length, data: bytes);
      } catch (e, st) {
        DiagnosticsLog.error('VoiceCache.putToStore', e, st);
        return null;
      }
    }
    try {
      final file = File('${dir.path}/$key.wav');
      await file.writeAsBytes(bytes, flush: true);
      _note(
        store?.recordPut(
          cacheKey: key,
          text: text,
          voice: voice,
          modelId: modelId,
          byteSize: bytes.length,
          expiresAt: expiresAt,
          filePath: file.path,
        ),
      );
      await _evict(dir);
      return CachedVoiceClip(path: file.path, bytes: bytes.length);
    } catch (e, s) {
      DiagnosticsLog.error('VoiceCache.put', e, s);
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
          _note(store?.recordEviction(_keyOf(f), VoiceEvictionReason.ttl));
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
        _note(store?.recordEviction(_keyOf(f), VoiceEvictionReason.lru));
      }
    } catch (e, s) {
      DiagnosticsLog.error('VoiceCache.evict', e, s);
    }
  }

  static String _keyOf(File f) {
    final name = f.uri.pathSegments.last;
    return name.endsWith('.wav') ? name.substring(0, name.length - 4) : name;
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
    _note(store?.recordClear(VoiceEvictionReason.clear));
    final dir = await _ensureDir();
    if (dir == null) return;
    try {
      for (final f in dir.listSync().whereType<File>()) {
        await f.delete();
      }
    } catch (e, s) {
      DiagnosticsLog.error('VoiceCache.clear', e, s);
    }
  }

  /// Fire-and-forget metadata write; store failures never affect playback.
  void _note(Future<void>? future) {
    future?.catchError((Object e) {
      debugPrint('VoiceCache store write failed: $e');
    });
  }
}
