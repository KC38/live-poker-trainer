/// Table SFX and Home ambient music (no coach voice).
library;

import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Bundled table sound effects and home ambient music.
///
/// Playback runs on SoLoud, which loops inside its mixer at sample accuracy.
/// Player-level looping (seek to zero on end-of-item) leaves an audible gap.
class SoundService with WidgetsBindingObserver {
  /// Creates a sound service backed by the SoLoud engine.
  SoundService() : this._(bindPlatform: true);

  /// No-op service for unit tests (never touches native audio).
  SoundService.silent() : this._(bindPlatform: false);

  SoundService._({required bool bindPlatform}) : _bindPlatform = bindPlatform {
    if (bindPlatform) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  final bool _bindPlatform;

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool _unlocked = !kIsWeb;
  bool _bgmWanted = false;
  bool _pausedForBackground = false;
  double _sfxVolume = 1.0;

  Future<bool>? _engineReady;
  AudioSource? _bgmSource;
  SoundHandle? _bgmHandle;
  final Map<SfxKind, AudioSource> _sfxSources = {};
  final List<AudioSource> _dealSources = [];

  DateTime? _dealBurstAt;
  Duration _dealBurstCursor = Duration.zero;
  var _dealCursor = 0;

  /// Spacing between overlapping hole/board deal voices in one burst.
  static const Duration dealStagger = Duration(milliseconds: 70);

  /// New cards after this gap start a fresh deal burst.
  static const Duration dealBurstWindow = Duration(milliseconds: 350);

  /// Ordered Freesound deal hits (`deal_01.wav` … `deal_08.wav`).
  static const int dealVariationCount = 8;

  /// SFX requested through [playSfx], including the silent test service.
  @visibleForTesting
  final List<SfxKind> played = [];

  /// 0-based deal clip indexes played by [deal], including the silent service.
  @visibleForTesting
  final List<int> dealVariationIndexes = [];

  /// Asset path for deal variation [index] (`0` → `deal_01.wav`).
  @visibleForTesting
  static String dealAssetFor(int index) {
    final n = (index + 1).toString().padLeft(2, '0');
    return 'assets/sounds/deal_$n.wav';
  }

  /// Serializes BGM transitions so fades and pauses cannot interleave.
  Future<void> _bgmOps = Future<void>.value();

  /// Comfortable lounge level; kept low so it never fights the brand UI.
  static const double _bgmBaseVolume = 0.28;

  static const Duration _bgmFadeIn = Duration(milliseconds: 600);
  static const Duration _bgmFadeOut = Duration(milliseconds: 400);

  /// Asset key of the gapless lounge loop.
  @visibleForTesting
  static const String bgmAsset = 'assets/sounds/lounge_ambient.wav';

  SoLoud get _soloud => SoLoud.instance;

  /// Whether lounge BGM is currently wanted while the app is foregrounded.
  @visibleForTesting
  bool get bgmWanted => _bgmWanted;

  /// Whether BGM was paused because the app left the foreground.
  @visibleForTesting
  bool get pausedForBackground => _pausedForBackground;

  /// The live BGM voice, when playing or paused.
  @visibleForTesting
  SoundHandle? get bgmHandle => _bgmHandle;

  /// Starts the engine and loads bundled sounds. Safe to call repeatedly.
  @visibleForTesting
  Future<bool> ensureEngine() {
    if (!_bindPlatform) return Future<bool>.value(false);
    return _engineReady ??= _startEngine().then((ok) {
      if (!ok) _engineReady = null;
      return ok;
    });
  }

  Future<bool> _startEngine() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.game,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        ),
      );
      await session.setActive(true);

      // A hot restart keeps the native engine alive; init() re-binds it.
      await _soloud.init(bufferSize: 1024);
      _bgmSource = await _soloud.loadAsset(bgmAsset);
      for (final kind in SfxKind.values) {
        if (kind == SfxKind.deal) continue;
        _sfxSources[kind] = await _soloud.loadAsset(
          'assets/sounds/${kind.fileName}',
        );
      }
      _dealSources
        ..clear()
        ..addAll([
          for (var i = 0; i < dealVariationCount; i++)
            await _soloud.loadAsset(dealAssetFor(i)),
        ]);
      return true;
    } catch (error) {
      debugPrint('SoundService engine start failed: $error');
      _bgmSource = null;
      _sfxSources.clear();
      _dealSources.clear();
      return false;
    }
  }

  /// Call after a user gesture to unlock audio (required on web; helpful on iOS).
  Future<void> unlock() async {
    _unlocked = true;
    await ensureEngine();
  }

  /// The configured SFX level (0..1).
  double get sfxVolume => _sfxVolume;

  /// Sets the configured SFX level (0..1).
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
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

  Future<void> _enqueueBgm(Future<void> Function() op) {
    final next = _bgmOps.then((_) => op()).catchError((Object error) {
      debugPrint('SoundService BGM op failed: $error');
    });
    _bgmOps = next;
    return next;
  }

  bool _voiceAlive(SoundHandle? handle) {
    if (handle == null || !_soloud.isInitialized) return false;
    return _soloud.getIsValidVoiceHandle(handle);
  }

  /// Fades in the lounge loop when music is enabled.
  Future<void> startHomeBgm() {
    _bgmWanted = true;
    _pausedForBackground = false;
    return _enqueueBgm(_playOrResumeBgm);
  }

  Future<void> _playOrResumeBgm() async {
    if (!_bgmWanted || !musicEnabled || !_unlocked) return;
    if (!await ensureEngine()) return;
    final source = _bgmSource;
    if (source == null) return;

    var handle = _bgmHandle;
    if (!_voiceAlive(handle)) {
      handle = _soloud.play(source, volume: 0, looping: true);
      _bgmHandle = handle;
    } else {
      _soloud.setPause(handle!, false);
    }
    _soloud.fadeVolume(handle, _bgmBaseVolume, _bgmFadeIn);
  }

  /// Fades out and pauses the lounge loop (e.g. entering Live Training).
  Future<void> pauseHomeBgm() {
    _bgmWanted = false;
    _pausedForBackground = false;
    return _enqueueBgm(() async {
      final handle = _bgmHandle;
      if (!_voiceAlive(handle)) return;
      _soloud.fadeVolume(handle!, 0, _bgmFadeOut);
      _soloud.schedulePause(handle, _bgmFadeOut);
    });
  }

  /// Resumes the lounge loop after returning from Training, if still wanted.
  Future<void> resumeHomeBgm() => startHomeBgm();

  /// Stops the lounge loop completely (music toggle off / dispose).
  Future<void> stopHomeBgm() {
    _bgmWanted = false;
    _pausedForBackground = false;
    return _enqueueBgm(() async {
      final handle = _bgmHandle;
      _bgmHandle = null;
      if (!_voiceAlive(handle)) return;
      await _soloud.stop(handle!);
    });
  }

  /// Pauses BGM when the app leaves the foreground without clearing [bgmWanted].
  Future<void> pauseForBackground() {
    if (!_bgmWanted) return Future<void>.value();
    _pausedForBackground = true;
    return _enqueueBgm(() async {
      final handle = _bgmHandle;
      if (!_voiceAlive(handle)) return;
      _soloud.setVolume(handle!, 0);
      _soloud.setPause(handle, true);
    });
  }

  /// Resumes BGM after returning to the foreground when it was background-paused.
  Future<void> resumeFromBackground() {
    if (!_pausedForBackground) return Future<void>.value();
    _pausedForBackground = false;
    if (!_bgmWanted) return Future<void>.value();
    return _enqueueBgm(_playOrResumeBgm);
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

  /// Plays a short table SFX if enabled.
  Future<void> playSfx(SfxKind kind) async {
    played.add(kind);
    if (!_bindPlatform || !sfxEnabled || !_unlocked) return;
    if (!await ensureEngine()) return;
    final source = _sfxSources[kind];
    if (source == null) return;
    try {
      _soloud.play(source, volume: _sfxVolume);
    } catch (error) {
      debugPrint('SoundService.playSfx(${kind.name}) failed: $error');
    }
  }

  Duration _nextDealDelay() {
    final now = DateTime.now();
    final burstAt = _dealBurstAt;
    if (burstAt == null || now.difference(burstAt) > dealBurstWindow) {
      _dealBurstAt = now;
      _dealBurstCursor = Duration.zero;
    }
    final delay = _dealBurstCursor;
    _dealBurstCursor += dealStagger;
    return delay;
  }

  /// Clears the in-flight deal stagger (tests).
  @visibleForTesting
  void resetDealBurst() {
    _dealBurstAt = null;
    _dealBurstCursor = Duration.zero;
  }

  /// Starts a new deal pass at `deal_01`. Later cards loop `deal_02`–`deal_08`.
  void resetDealSequence() {
    _dealCursor = 0;
  }

  int _takeDealVariationIndex() {
    final i = _dealCursor;
    _dealCursor++;
    if (i == 0) return 0;
    return 1 + (i - 1) % (dealVariationCount - 1);
  }

  /// Plays the deal SFX after a short offset so a multi-card burst does not
  /// pile up as one click.
  void dealStaggered() {
    final delay = _nextDealDelay();
    if (delay <= Duration.zero) {
      unawaited(deal());
      return;
    }
    Future<void>.delayed(delay, () {
      unawaited(deal());
    });
  }

  Future<void> deal() async {
    final index = _takeDealVariationIndex();
    dealVariationIndexes.add(index);
    played.add(SfxKind.deal);
    if (!_bindPlatform || !sfxEnabled || !_unlocked) return;
    if (!await ensureEngine()) return;
    if (index < 0 || index >= _dealSources.length) return;
    try {
      _soloud.play(_dealSources[index], volume: _sfxVolume);
    } catch (error) {
      debugPrint('SoundService.deal(variation=$index) failed: $error');
    }
  }

  Future<void> chip() => playSfx(SfxKind.chip);
  Future<void> knock() => playSfx(SfxKind.knock);
  Future<void> fold() => playSfx(SfxKind.fold);
  Future<void> win() => playSfx(SfxKind.win);

  /// Backwards-compatible alias for the card-deal SFX.
  Future<void> card() => deal();

  /// Stops sounds and detaches from lifecycle events.
  ///
  /// The SoLoud engine is process-wide and stays up for the next service.
  Future<void> dispose() async {
    if (_bindPlatform) {
      WidgetsBinding.instance.removeObserver(this);
    }
    await stopHomeBgm();
  }
}

/// Bundled SFX asset kinds.
enum SfxKind {
  deal('deal_01.wav'),
  chip('chip.wav'),
  knock('knock.wav'),
  fold('fold.wav'),
  win('win.wav');

  const SfxKind(this.fileName);
  final String fileName;
}
