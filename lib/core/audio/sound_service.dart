/// Table SFX and Home ambient music (no coach voice).
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Bundled table sound effects and home ambient music.
class SoundService {
  /// Creates a sound service.
  SoundService();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _bgm = AudioPlayer();

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool _unlocked = !kIsWeb;
  bool _audioContextConfigured = false;
  bool _bgmWanted = false;
  bool _bgmPlaying = false;
  int _bgmFadeGen = 0;
  double _bgmAudibleVolume = 0;
  double _sfxVolume = 1.0;

  /// Comfortable lounge level; kept low so it never fights the brand UI.
  static const double _bgmBaseVolume = 0.28;

  /// Asset path relative to the Flutter `assets/` folder.
  static const String _bgmAsset = 'sounds/lounge_ambient.mp3';

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
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );
      await AudioPlayer.global.setAudioContext(ctx);
      await _sfx.setAudioContext(ctx);
      await _bgm.setAudioContext(ctx);
      _audioContextConfigured = true;
    } catch (_) {
      // Platform may not support AudioContext configuration.
    }
  }

  /// The configured SFX level (0..1).
  double get sfxVolume => _sfxVolume;

  /// Sets the configured SFX level (0..1).
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    try {
      await _sfx.setVolume(_sfxVolume);
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

  /// Fades in the Home lounge loop when music is enabled.
  Future<void> startHomeBgm() async {
    _bgmWanted = true;
    if (!musicEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
      if (!_bgmPlaying) {
        await _bgm.setReleaseMode(ReleaseMode.loop);
        await _bgm.setVolume(0);
        await _bgm.play(AssetSource(_bgmAsset), volume: 0);
        _bgmPlaying = true;
      } else {
        await _bgm.resume();
      }
      await _fadeBgmTo(_bgmBaseVolume);
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
        await _fadeBgmTo(_bgmBaseVolume);
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

  /// Plays a short table SFX if enabled.
  Future<void> playSfx(SfxKind kind) async {
    if (!sfxEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
      await _sfx.stop();
      await _sfx.play(
        AssetSource('sounds/${kind.fileName}'),
        volume: _sfxVolume,
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

  /// Releases players.
  Future<void> dispose() async {
    await stopHomeBgm();
    await _sfx.dispose();
    await _bgm.dispose();
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
