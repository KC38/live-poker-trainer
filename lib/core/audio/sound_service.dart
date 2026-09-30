/// Table SFX and Home ambient music (no coach voice).
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Bundled table sound effects and home ambient music.
class SoundService with WidgetsBindingObserver {
  /// Creates a sound service backed by platform audio players.
  SoundService() : this._(bindPlatform: true);

  /// No-op service for unit tests (never touches audioplayers plugins).
  SoundService.silent() : this._(bindPlatform: false);

  SoundService._({required bool bindPlatform})
    : _sfx = bindPlatform
          ? AudioPlayer(playerId: 'lpt_sfx')
          : null,
      _bgm = bindPlatform
          ? AudioPlayer(playerId: 'lpt_bgm')
          : null {
    if (bindPlatform) {
      unawaited(_configurePlayers());
      WidgetsBinding.instance.addObserver(this);
    }
  }

  final AudioPlayer? _sfx;
  final AudioPlayer? _bgm;

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool _unlocked = !kIsWeb;
  bool _audioContextConfigured = false;
  bool _bgmWanted = false;
  bool _bgmPlaying = false;
  bool _pausedForBackground = false;
  int _bgmFadeGen = 0;
  double _bgmAudibleVolume = 0;
  double _sfxVolume = 1.0;

  /// Comfortable lounge level; kept low so it never fights the brand UI.
  static const double _bgmBaseVolume = 0.28;

  /// Tiny non-zero start volume — some platforms never decode a 0.0 play().
  static const double _bgmStartVolume = 0.02;

  /// Asset path relative to the Flutter `assets/` folder.
  /// WAV (not MP3) so iOS/Android can loop without encoder-delay gaps.
  static const String _bgmAsset = 'sounds/lounge_ambient.wav';

  Future<void> _configurePlayers() async {
    final bgm = _bgm;
    final sfx = _sfx;
    if (bgm == null || sfx == null) return;
    try {
      // Long looping bed needs the media player; lowLatency is for short SFX.
      await bgm.setPlayerMode(PlayerMode.mediaPlayer);
      await sfx.setPlayerMode(PlayerMode.lowLatency);
      await bgm.setReleaseMode(ReleaseMode.loop);
    } catch (error) {
      debugPrint('SoundService player configure failed: $error');
    }
  }

  /// Call after a user gesture to unlock audio (required on web; helpful on iOS).
  Future<void> unlock() async {
    _unlocked = true;
    await _ensureAudioContext();
  }

  Future<void> _ensureAudioContext() async {
    final sfx = _sfx;
    final bgm = _bgm;
    if (sfx == null || bgm == null || _audioContextConfigured) return;
    try {
      final ctx = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );
      await AudioPlayer.global.setAudioContext(ctx);
      await sfx.setAudioContext(ctx);
      await bgm.setAudioContext(ctx);
      _audioContextConfigured = true;
    } catch (error) {
      debugPrint('SoundService audio context failed: $error');
    }
  }

  /// The configured SFX level (0..1).
  double get sfxVolume => _sfxVolume;

  /// Whether lounge BGM is currently wanted while the app is foregrounded.
  @visibleForTesting
  bool get bgmWanted => _bgmWanted;

  /// Whether BGM was paused because the app left the foreground.
  @visibleForTesting
  bool get pausedForBackground => _pausedForBackground;

  /// Sets the configured SFX level (0..1).
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    try {
      await _sfx?.setVolume(_sfxVolume);
    } catch (_) {}
  }

  /// Applies the Settings music toggle; stops BGM immediately when disabled.
  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled = enabled;
    if (!enabled) {
      await stopHomeBgm();
    } else if (_bgmWanted) {
      await startHomeBgm();
    }
  }

  /// Fades in the lounge loop when music is enabled.
  Future<void> startHomeBgm() async {
    _bgmWanted = true;
    _pausedForBackground = false;
    final bgm = _bgm;
    if (bgm == null || !musicEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
      await bgm.setReleaseMode(ReleaseMode.loop);
      if (!_bgmPlaying) {
        await bgm.setVolume(_bgmStartVolume);
        _bgmAudibleVolume = _bgmStartVolume;
        // setSource + resume is more reliable than play() for looped WAV beds.
        await bgm.setSource(AssetSource(_bgmAsset));
        await bgm.resume();
        _bgmPlaying = true;
      } else {
        await bgm.resume();
      }
      await _fadeBgmTo(_bgmBaseVolume);
    } catch (error) {
      _bgmPlaying = false;
      debugPrint('SoundService.startHomeBgm failed: $error');
    }
  }

  /// Fades out and pauses the lounge loop (e.g. entering Live Training).
  Future<void> pauseHomeBgm() async {
    _bgmWanted = false;
    _pausedForBackground = false;
    final bgm = _bgm;
    if (bgm == null || !_bgmPlaying) return;
    try {
      await _fadeBgmTo(0);
      await bgm.pause();
    } catch (_) {}
  }

  /// Resumes the lounge loop after returning from Training, if still wanted.
  Future<void> resumeHomeBgm() async {
    _bgmWanted = true;
    _pausedForBackground = false;
    final bgm = _bgm;
    if (bgm == null || !musicEnabled || !_unlocked) return;
    if (_bgmPlaying) {
      try {
        await bgm.resume();
        await _fadeBgmTo(_bgmBaseVolume);
      } catch (error) {
        debugPrint('SoundService.resumeHomeBgm failed: $error');
      }
      return;
    }
    await startHomeBgm();
  }

  /// Stops the lounge loop completely (music toggle off / dispose).
  Future<void> stopHomeBgm() async {
    _bgmWanted = false;
    _pausedForBackground = false;
    _bgmFadeGen++;
    _bgmPlaying = false;
    _bgmAudibleVolume = 0;
    try {
      await _bgm?.stop();
      await _bgm?.setVolume(0);
    } catch (_) {}
  }

  /// Pauses BGM when the app leaves the foreground without clearing [_bgmWanted].
  Future<void> pauseForBackground() async {
    if (!_bgmWanted) return;
    _pausedForBackground = true;
    final bgm = _bgm;
    if (bgm == null || !_bgmPlaying) return;
    _bgmFadeGen++;
    _bgmAudibleVolume = 0;
    try {
      await bgm.setVolume(0);
      await bgm.pause();
    } catch (_) {}
  }

  /// Resumes BGM after returning to the foreground when it was background-paused.
  Future<void> resumeFromBackground() async {
    if (!_pausedForBackground) return;
    _pausedForBackground = false;
    if (!_bgmWanted || !musicEnabled || !_unlocked) return;
    await resumeHomeBgm();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(resumeFromBackground());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(pauseForBackground());
    }
  }

  Future<void> _fadeBgmTo(double target) async {
    final bgm = _bgm;
    if (bgm == null) {
      _bgmAudibleVolume = target.clamp(0.0, 1.0);
      return;
    }
    final gen = ++_bgmFadeGen;
    final from = _bgmAudibleVolume;
    const steps = 10;
    const stepDelay = Duration(milliseconds: 40);
    for (var step = 1; step <= steps; step++) {
      if (gen != _bgmFadeGen) return;
      final next = from + (target - from) * (step / steps);
      _bgmAudibleVolume = next.clamp(0.0, 1.0);
      try {
        await bgm.setVolume(_bgmAudibleVolume);
      } catch (_) {
        return;
      }
      if (step < steps) {
        await Future<void>.delayed(stepDelay);
      }
    }
  }

  /// Plays a short table SFX if enabled.
  Future<void> playSfx(SfxKind kind) async {
    final sfx = _sfx;
    if (sfx == null || !sfxEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
      await sfx.stop();
      await sfx.play(
        AssetSource('sounds/${kind.fileName}'),
        volume: _sfxVolume,
      );
    } catch (error) {
      debugPrint('SoundService.playSfx(${kind.name}) failed: $error');
    }
  }

  Future<void> deal() => playSfx(SfxKind.deal);
  Future<void> chip() => playSfx(SfxKind.chip);
  Future<void> knock() => playSfx(SfxKind.knock);
  Future<void> fold() => playSfx(SfxKind.fold);
  Future<void> win() => playSfx(SfxKind.win);

  /// Backwards-compatible alias for the card-deal SFX.
  Future<void> card() => deal();

  /// Releases players.
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await stopHomeBgm();
    await _sfx?.dispose();
    await _bgm?.dispose();
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
