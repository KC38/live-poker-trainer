/// Table SFX plus coach voice: cached Gemini speech, device TTS as last resort.
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:live_poker_trainer/core/audio/sfx_ducker.dart';
import 'package:live_poker_trainer/core/audio/voice_cache.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/services/gemini_service.dart';

/// Result of attempting coach voice playback.
class CoachVoicePlayback {
  /// Creates a playback result.
  const CoachVoicePlayback({
    required this.spoke,
    this.diagnostic,
    this.fromCache = false,
    this.usedDeviceVoice = false,
  });

  final bool spoke;

  /// Developer-facing reason the preferred path was not used.
  ///
  /// Logged to [DiagnosticsLog], never rendered. The coach degrades to the
  /// device voice (or to silence) without ever asking the player to configure
  /// anything.
  final String? diagnostic;

  /// Whether the clip came from the on-disk cache (instant playback).
  final bool fromCache;

  /// Whether the flat device voice was used instead of Gemini speech.
  final bool usedDeviceVoice;
}

/// Bundled table sound effects, home ambient music, and coach voice.
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
  final AudioPlayer _bgm = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool sfxEnabled = true;
  bool ttsEnabled = true;
  bool musicEnabled = true;
  bool _unlocked = !kIsWeb;
  bool _ttsReady = false;
  bool _audioContextConfigured = false;
  bool _bgmWanted = false;
  bool _bgmPlaying = false;
  int _bgmFadeGen = 0;
  double _bgmAudibleVolume = 0;

  /// Comfortable lounge level; kept low so it never fights the brand UI.
  static const double _bgmBaseVolume = 0.28;

  /// Asset path relative to the Flutter `assets/` folder.
  static const String _bgmAsset = 'sounds/lounge_ambient.mp3';

  /// Drops SFX under the coach voice; see [setSfxVolume] for the base level.
  late final SfxDucker _ducker = SfxDucker(
    applyVolume: (volume) => _sfx.setVolume(volume),
  );

  /// Ducks home BGM further when coach speech could overlap (e.g. transitions).
  late final SfxDucker _bgmDucker = SfxDucker(
    applyVolume: (volume) async {
      _bgmAudibleVolume = volume;
      await _bgm.setVolume(volume);
    },
    duckFactor: 0.12,
  );

  StreamSubscription<void>? _voiceDoneSub;
  Timer? _duckWatchdog;

  /// Maps speech-completion token → BGM hold taken for that coach line.
  final Map<int, int> _speechBgmHolds = <int, int>{};

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
      await _bgm.setAudioContext(ctx);
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

  /// Applies the Settings music toggle; stops BGM immediately when disabled.
  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled = enabled;
    if (!enabled) {
      await stopHomeBgm();
    } else if (_bgmWanted) {
      await startHomeBgm();
    }
  }

  /// Fades in the Home lounge loop when music is enabled.
  Future<void> startHomeBgm() async {
    _bgmWanted = true;
    if (!musicEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
      await _bgmDucker.setBaseVolume(_bgmBaseVolume);
      if (!_bgmPlaying) {
        await _bgm.setReleaseMode(ReleaseMode.loop);
        await _bgm.setVolume(0);
        await _bgm.play(AssetSource(_bgmAsset), volume: 0);
        _bgmPlaying = true;
      } else {
        await _bgm.resume();
      }
      await _fadeBgmTo(_bgmDucker.isDucked
          ? _bgmDucker.duckedVolume
          : _bgmBaseVolume);
    } catch (_) {
      _bgmPlaying = false;
    }
  }

  /// Fades out and pauses the Home loop (e.g. entering Training).
  Future<void> pauseHomeBgm() async {
    _bgmWanted = false;
    if (!_bgmPlaying) return;
    try {
      await _fadeBgmTo(0);
      await _bgm.pause();
    } catch (_) {}
  }

  /// Resumes the Home loop after returning from Training, if still wanted.
  Future<void> resumeHomeBgm() async {
    _bgmWanted = true;
    if (!musicEnabled || !_unlocked) return;
    if (_bgmPlaying) {
      try {
        await _bgm.resume();
        await _fadeBgmTo(_bgmDucker.isDucked
            ? _bgmDucker.duckedVolume
            : _bgmBaseVolume);
      } catch (_) {}
      return;
    }
    await startHomeBgm();
  }

  /// Stops the Home loop completely (music toggle off / dispose).
  Future<void> stopHomeBgm() async {
    _bgmWanted = false;
    _bgmFadeGen++;
    _bgmPlaying = false;
    _bgmAudibleVolume = 0;
    try {
      await _bgm.stop();
      await _bgm.setVolume(0);
    } catch (_) {}
  }

  Future<void> _fadeBgmTo(double target) async {
    final gen = ++_bgmFadeGen;
    final from = _bgmAudibleVolume;
    const steps = 10;
    const stepDelay = Duration(milliseconds: 40);
    for (var step = 1; step <= steps; step++) {
      if (gen != _bgmFadeGen) return;
      final next = from + (target - from) * (step / steps);
      _bgmAudibleVolume = next.clamp(0.0, 1.0);
      try {
        await _bgm.setVolume(_bgmAudibleVolume);
      } catch (_) {
        return;
      }
      if (step < steps) {
        await Future<void>.delayed(stepDelay);
      }
    }
  }

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
      return _report(const CoachVoicePlayback(
        spoke: false,
        diagnostic: 'coach voice muted in settings',
      ));
    }
    final cleaned = text.trim();
    if (cleaned.isEmpty) return const CoachVoicePlayback(spoke: false);
    if (!_unlocked) {
      return _report(const CoachVoicePlayback(
        spoke: false,
        diagnostic: 'audio not unlocked yet',
      ));
    }

    final gemini = this.gemini;
    if (gemini != null && gemini.hasApiKey) {
      final key = VoiceCache.keyFor(
        text: cleaned,
        voice: Config.coachVoice,
        model: Config.geminiTtsModel,
      );

      final cached = await _cache.get(key);
      if (cached != null && await _playClip(cached)) {
        return const CoachVoicePlayback(spoke: true, fromCache: true);
      }

      final synthesized = await gemini.synthesizeSpeech(cleaned);
      if (synthesized != null && synthesized.isNotEmpty) {
        final stored = await _cache.putDescribed(
          key,
          synthesized,
          text: cleaned,
          voice: Config.coachVoice,
          modelId: Config.geminiTtsModel,
        );
        _warmKeys.add(key);
        if (stored != null && await _playClip(stored)) {
          return const CoachVoicePlayback(spoke: true);
        }
        if (await _playBytes(synthesized)) {
          return const CoachVoicePlayback(spoke: true);
        }
      }
    }

    // Last resort: the flat device voice, used quietly. The player is never
    // told the Gemini voice was skipped, and never asked for a key.
    final spoke = await _speakWithDevice(cleaned);
    if (!spoke) {
      DiagnosticsLog.warning(
        'SoundService.speakCoachLine',
        'Coach voice failed on every backend',
        extra: {'hasKey': gemini?.hasApiKey ?? false},
      );
    }
    if (spoke) {
      return _report(CoachVoicePlayback(
        spoke: true,
        usedDeviceVoice: true,
        diagnostic: 'gemini speech unavailable, used device voice',
      ));
    }
    return _report(const CoachVoicePlayback(
      spoke: false,
      diagnostic: 'no voice backend could play the line',
    ));
  }

  /// Sends a fallback reason to diagnostics only, so nothing about audio
  /// configuration can leak into the coach shelf.
  CoachVoicePlayback _report(CoachVoicePlayback playback) {
    final diagnostic = playback.diagnostic;
    if (diagnostic != null) {
      DiagnosticsLog.info(
        'SoundService.speakCoachLine',
        diagnostic,
        extra: {'hasKey': Config.hasGeminiKey},
      );
    }
    return playback;
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
    await _cache.putDescribed(
      key,
      bytes,
      text: cleaned,
      voice: Config.coachVoice,
      modelId: Config.geminiTtsModel,
    );
    _warmKeys.add(key);
    return true;
  }

  /// Plays a cached clip from its file, or from bytes when database-backed.
  Future<bool> _playClip(CachedVoiceClip clip) {
    if (clip.hasFile) return _playFile(clip.path);
    final data = clip.data;
    return data == null ? Future.value(false) : _playBytes(data);
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

  /// Ducks SFX and BGM for one coach line; returns the SFX (or BGM) hold token.
  ///
  /// Returns [SfxDucker.noHold] when neither stream needs ducking. Releasing
  /// restores both; SFX still uses token matching so an interrupted line cannot
  /// unduck a newer one.
  Future<int> _duckForSpeech() async {
    final sfxHold = sfxEnabled ? await _ducker.hold() : SfxDucker.noHold;
    var bgmHold = SfxDucker.noHold;
    if (_bgmPlaying || _bgmWanted) {
      _bgmFadeGen++; // cancel an in-flight fade so duck owns volume
      bgmHold = await _bgmDucker.hold();
    }
    if (sfxHold == SfxDucker.noHold && bgmHold == SfxDucker.noHold) {
      return SfxDucker.noHold;
    }
    // Prefer the SFX token for completion callbacks; fall back to BGM's.
    final hold = sfxHold != SfxDucker.noHold ? sfxHold : bgmHold;
    _speechBgmHolds[hold] = bgmHold;
    _duckWatchdog?.cancel();
    _duckWatchdog = Timer(_maxDuckHold, () => _releaseDuck(hold));
    return hold;
  }

  Future<void> _releaseDuck(int hold) async {
    if (hold == SfxDucker.noHold) return;
    final bgmHold = _speechBgmHolds.remove(hold) ?? SfxDucker.noHold;
    await _ducker.release(hold);
    await _bgmDucker.release(bgmHold);
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

  /// Stops any in-flight coach voice and restores SFX / BGM volume.
  Future<void> stopVoice() async {
    _duckWatchdog?.cancel();
    _duckWatchdog = null;
    await _stopAllVoice();
    _speechBgmHolds.clear();
    await _ducker.releaseAll();
    await _bgmDucker.releaseAll();
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
    _speechBgmHolds.clear();
    await stopHomeBgm();
    await _sfx.dispose();
    await _voice.dispose();
    await _bgm.dispose();
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
