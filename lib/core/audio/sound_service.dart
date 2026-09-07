/// Table SFX plus coach voice: cached Gemini speech, device TTS as last resort.
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:live_poker_trainer/core/audio/sfx_ducker.dart';
import 'package:live_poker_trainer/core/audio/voice_cache.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/services/gemini_service.dart';

/// Result of attempting coach voice playback.
class CoachVoicePlayback {
  /// Creates a playback result.
  const CoachVoicePlayback({
    required this.spoke,
    this.note,
    this.fromCache = false,
    this.usedDeviceVoice = false,
  });

  final bool spoke;
  final String? note;

  /// Whether the clip came from the on-disk cache (instant playback).
  final bool fromCache;

  /// Whether the flat device voice was used instead of Gemini speech.
  final bool usedDeviceVoice;
}

/// Bundled table sound effects and coach voice.
class SoundService {
  /// Creates a sound service.
  ///
  /// [gemini] supplies real speech synthesis; [voiceCache] persists clips.
  SoundService({
    this.gemini,
    VoiceCache? voiceCache,
  }) : _cache = voiceCache ??
            VoiceCache(
              maxBytes: Config.voiceCacheMaxBytes,
              ttl: Config.voiceCacheTtl,
            );

  /// Speech synthesis backend; null disables the Gemini voice path.
  final GeminiService? gemini;

  final VoiceCache _cache;

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _voice = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool sfxEnabled = true;
  bool ttsEnabled = true;
  bool _unlocked = !kIsWeb;
  bool _ttsReady = false;
  bool _audioContextConfigured = false;

  /// Drops SFX under the coach voice; see [setSfxVolume] for the base level.
  late final SfxDucker _ducker = SfxDucker(
    applyVolume: (volume) => _sfx.setVolume(volume),
  );

  StreamSubscription<void>? _voiceDoneSub;
  Timer? _duckWatchdog;

  /// Backstop so a missing completion callback cannot leave SFX quiet forever.
  static const Duration _maxDuckHold = Duration(seconds: 30);

  /// In-memory memo of cache keys already on disk, to skip a stat per line.
  final Set<String> _warmKeys = <String>{};

  /// Call after a user gesture to unlock audio (required on web; helpful on iOS).
  Future<void> unlock() async {
    _unlocked = true;
    await _ensureAudioContext();
  }

  Future<void> _ensureAudioContext() async {
    if (_audioContextConfigured) return;
    try {
      final ctx = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistanceAccessibility,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      );
      await AudioPlayer.global.setAudioContext(ctx);
      await _sfx.setAudioContext(ctx);
      await _voice.setAudioContext(ctx);
      _audioContextConfigured = true;
    } catch (_) {
      // Platform may not support AudioContext configuration.
    }
  }

  Future<void> _ensureTts() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsReady = true;
    } catch (_) {
      // Device TTS unavailable — Gemini audio path may still work.
    }
  }

  /// The configured SFX level, before any coach-voice ducking.
  double get sfxVolume => _ducker.baseVolume;

  /// Whether SFX are currently ducked under the coach voice.
  bool get sfxDucked => _ducker.isDucked;

  /// Sets the configured SFX level (0..1), keeping any active duck in place.
  Future<void> setSfxVolume(double volume) => _ducker.setBaseVolume(volume);

  /// Plays a short table SFX if enabled, at the current (possibly ducked) level.
  Future<void> playSfx(SfxKind kind) async {
    if (!sfxEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
      await _sfx.stop();
      await _sfx.play(
        AssetSource('sounds/${kind.fileName}'),
        volume: _ducker.currentVolume,
      );
    } catch (_) {
      // Ignore missing assets / autoplay blocks.
    }
  }

  Future<void> deal() => playSfx(SfxKind.deal);
  Future<void> chip() => playSfx(SfxKind.chip);
  Future<void> knock() => playSfx(SfxKind.knock);
  Future<void> fold() => playSfx(SfxKind.fold);
  Future<void> win() => playSfx(SfxKind.win);

  /// Backwards-compatible alias for the card-deal SFX.
  Future<void> card() => deal();

  /// Speaks a coach line, preferring cached Gemini speech.
  ///
  /// Order of preference:
  /// 1. On-disk cached WAV for this exact line (instant, no network).
  /// 2. Fresh Gemini speech synthesis, then cached for next time.
  /// 3. `flutter_tts` device voice (flat, last resort only).
  Future<CoachVoicePlayback> speakCoachLine({
    required String text,
    bool enabled = true,
  }) async {
    if (!enabled || !ttsEnabled) {
      return const CoachVoicePlayback(
        spoke: false,
        note: 'Coach voice is muted in Settings.',
      );
    }
    final cleaned = text.trim();
    if (cleaned.isEmpty) return const CoachVoicePlayback(spoke: false);
    if (!_unlocked) {
      return const CoachVoicePlayback(
        spoke: false,
        note: 'Tap Start training once to unlock coach voice.',
      );
    }

    final gemini = this.gemini;
    if (gemini != null && gemini.hasApiKey) {
      final key = VoiceCache.keyFor(
        text: cleaned,
        voice: Config.coachVoice,
        model: Config.geminiTtsModel,
      );

      final cached = await _cache.get(key);
      if (cached != null && await _playFile(cached.path)) {
        return const CoachVoicePlayback(spoke: true, fromCache: true);
      }

      final synthesized = await gemini.synthesizeSpeech(cleaned);
      if (synthesized != null && synthesized.isNotEmpty) {
        final stored = await _cache.put(key, synthesized);
        _warmKeys.add(key);
        if (stored != null && await _playFile(stored.path)) {
          return const CoachVoicePlayback(spoke: true);
        }
        if (await _playBytes(synthesized)) {
          return const CoachVoicePlayback(spoke: true);
        }
      }
    }

    // Last resort: flat device voice.
    final spoke = await _speakWithDevice(cleaned);
    if (spoke) {
      return CoachVoicePlayback(
        spoke: true,
        usedDeviceVoice: true,
        note: gemini != null && gemini.hasApiKey
            ? null
            : 'Device voice — add a Gemini API key for the real coach voice.',
      );
    }
    return const CoachVoicePlayback(
      spoke: false,
      note: 'Coach voice failed to play on this device.',
    );
  }

  /// Pre-synthesizes and caches [text] without playing it.
  Future<bool> warmCoachLine(String text) async {
    final gemini = this.gemini;
    final cleaned = text.trim();
    if (gemini == null || !gemini.hasApiKey || cleaned.isEmpty) return false;
    final key = VoiceCache.keyFor(
      text: cleaned,
      voice: Config.coachVoice,
      model: Config.geminiTtsModel,
    );
    if (_warmKeys.contains(key)) return true;
    if (await _cache.get(key) != null) {
      _warmKeys.add(key);
      return true;
    }
    final bytes = await gemini.synthesizeSpeech(cleaned);
    if (bytes == null || bytes.isEmpty) return false;
    await _cache.put(key, bytes);
    _warmKeys.add(key);
    return true;
  }

  Future<bool> _playFile(String path) async {
    final hold = await _duckForSpeech();
    await _stopAllVoice();
    try {
      await _voice.setReleaseMode(ReleaseMode.stop);
      await _voice.play(DeviceFileSource(path), volume: 1.0);
      _restoreWhenVoiceEnds(hold);
      return true;
    } catch (_) {
      await _releaseDuck(hold);
      return false;
    }
  }

  Future<bool> _playBytes(Uint8List bytes) async {
    final hold = await _duckForSpeech();
    await _stopAllVoice();
    try {
      await _voice.play(BytesSource(bytes, mimeType: 'audio/wav'), volume: 1.0);
      _restoreWhenVoiceEnds(hold);
      return true;
    } catch (_) {
      await _releaseDuck(hold);
      return false;
    }
  }

  Future<bool> _speakWithDevice(String text) async {
    await _ensureTts();
    final hold = await _duckForSpeech();
    await _stopAllVoice();
    _bindTtsHandlers(hold);
    try {
      final result = await _tts.speak(text);
      final spoke = result == 1 || result == true;
      if (!spoke) await _releaseDuck(hold);
      return spoke;
    } catch (_) {
      await _releaseDuck(hold);
      return false;
    }
  }

  /// Ducks SFX for one coach line; returns the token used to restore them.
  ///
  /// Returns [SfxDucker.noHold] when SFX are muted, since there is nothing to
  /// duck; releasing that token is a no-op.
  Future<int> _duckForSpeech() async {
    if (!sfxEnabled) return SfxDucker.noHold;
    final hold = await _ducker.hold();
    _duckWatchdog?.cancel();
    _duckWatchdog = Timer(_maxDuckHold, () => _releaseDuck(hold));
    return hold;
  }

  Future<void> _releaseDuck(int hold) async {
    if (hold == SfxDucker.noHold) return;
    await _ducker.release(hold);
  }

  /// Points the device-voice callbacks at [hold] so a late event from an
  /// interrupted line releases its own hold rather than the current one.
  void _bindTtsHandlers(int hold) {
    void done() => _releaseDuck(hold);
    try {
      _tts.setCompletionHandler(done);
      _tts.setCancelHandler(done);
      _tts.setErrorHandler((_) => done());
    } catch (_) {
      // Handlers unsupported here — the watchdog still restores volume.
    }
  }

  /// Restores SFX volume as soon as the Gemini clip finishes playing.
  void _restoreWhenVoiceEnds(int hold) {
    if (hold == SfxDucker.noHold) return;
    try {
      _voiceDoneSub = _voice.onPlayerComplete.listen((_) {
        _releaseDuck(hold);
      });
    } catch (_) {
      // No completion stream on this platform — the watchdog covers us.
    }
  }

  /// Stops both voice backends without touching the duck state, so a new line
  /// can take over the hold instead of flapping the SFX volume back up.
  Future<void> _stopAllVoice() async {
    final sub = _voiceDoneSub;
    _voiceDoneSub = null;
    await sub?.cancel();
    try {
      await _voice.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Stops any in-flight coach voice and restores SFX volume.
  Future<void> stopVoice() async {
    _duckWatchdog?.cancel();
    _duckWatchdog = null;
    await _stopAllVoice();
    await _ducker.releaseAll();
  }

  /// Total bytes of cached coach audio.
  Future<int> voiceCacheBytes() => _cache.sizeInBytes();

  /// Clears cached coach audio.
  Future<void> clearVoiceCache() async {
    _warmKeys.clear();
    await _cache.clear();
  }

  /// Releases players.
  Future<void> dispose() async {
    _duckWatchdog?.cancel();
    _duckWatchdog = null;
    await _voiceDoneSub?.cancel();
    _voiceDoneSub = null;
    await _sfx.dispose();
    await _voice.dispose();
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Bundled SFX asset kinds.
enum SfxKind {
  deal('deal.wav'),
  chip('chip.wav'),
  knock('knock.wav'),
  fold('fold.wav'),
  win('win.wav');

  const SfxKind(this.fileName);
  final String fileName;
}
