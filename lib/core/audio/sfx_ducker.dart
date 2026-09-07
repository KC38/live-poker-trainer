/// SFX volume ducking while the coach voice speaks, with overlap-safe holds.
library;

import 'dart:async';

/// Applies [volume] (0..1) to the SFX output.
typedef VolumeSetter = Future<void> Function(double volume);

/// Sleeps for [duration]; injectable so tests do not wait on real ramps.
typedef DelaySleeper = Future<void> Function(Duration duration);

/// Scales SFX volume down while coach speech is playing and back up after.
///
/// Callers take a *hold* for each coach line and release it with the token they
/// were handed. A hold taken while another is outstanding supersedes it, so a
/// late release from the interrupted line cannot un-duck audio that is still
/// being spoken over. [noHold] releases are ignored, which lets callers treat
/// "ducking was skipped" and "ducking finished" the same way.
class SfxDucker {
  /// Creates a ducker that pushes volume changes through [applyVolume].
  SfxDucker({
    required this.applyVolume,
    double duckFactor = defaultDuckFactor,
    int rampSteps = 4,
    this.rampStep = const Duration(milliseconds: 30),
    DelaySleeper? sleeper,
  })  : _duckFactor = duckFactor.clamp(0.0, 1.0),
        _rampSteps = rampSteps < 1 ? 1 : rampSteps,
        _sleeper = sleeper ?? Future<void>.delayed;

  /// Fraction of the configured level kept while the coach is speaking.
  static const double defaultDuckFactor = 0.18;

  /// Token meaning "no hold was taken"; releasing it is a no-op.
  static const int noHold = 0;

  /// Sink that pushes a volume onto the SFX player.
  final VolumeSetter applyVolume;

  /// Pause between ramp steps; [Duration.zero] makes volume changes immediate.
  final Duration rampStep;

  final double _duckFactor;
  final int _rampSteps;
  final DelaySleeper _sleeper;

  double _baseVolume = 1.0;
  double _currentVolume = 1.0;
  int _lastToken = noHold;
  int _activeToken = noHold;

  /// The user-configured SFX level that playback returns to.
  double get baseVolume => _baseVolume;

  /// The volume most recently pushed to the SFX output.
  double get currentVolume => _currentVolume;

  /// Whether a coach line currently holds the volume down.
  bool get isDucked => _activeToken != noHold;

  /// Target volume while ducked.
  double get duckedVolume => _baseVolume * _duckFactor;

  /// Sets the configured SFX level, re-applying it (or its ducked form) now.
  Future<void> setBaseVolume(double volume) async {
    _baseVolume = volume.clamp(0.0, 1.0);
    await _push(isDucked ? duckedVolume : _baseVolume);
  }

  /// Ducks the SFX output for one coach line and returns its release token.
  Future<int> hold() async {
    final token = ++_lastToken;
    _activeToken = token;
    await _rampTo(duckedVolume, token);
    return token;
  }

  /// Restores volume if [token] still owns the hold.
  Future<void> release(int token) async {
    if (token == noHold || token != _activeToken) return;
    _activeToken = noHold;
    await _rampTo(_baseVolume, noHold);
  }

  /// Restores volume whichever line holds it; used by stop/dispose paths.
  Future<void> releaseAll() => release(_activeToken);

  /// Ramps toward [target], bailing out if another hold changes ownership.
  Future<void> _rampTo(double target, int guardToken) async {
    if (_currentVolume == target) return;
    final from = _currentVolume;
    for (var step = 1; step <= _rampSteps; step++) {
      if (_activeToken != guardToken) return;
      final next = from + (target - from) * (step / _rampSteps);
      await _push(next);
      if (step < _rampSteps && rampStep > Duration.zero) {
        await _sleeper(rampStep);
      }
    }
  }

  Future<void> _push(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    try {
      await applyVolume(_currentVolume);
    } catch (_) {
      // A detached or disposed player must not strand the duck state.
    }
  }
}
