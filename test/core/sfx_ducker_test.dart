/// Tests for coach-voice SFX ducking: duck, restore, overlap, and stop paths.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sfx_ducker.dart';

void main() {
  late List<double> applied;

  setUp(() => applied = <double>[]);

  /// Builds a ducker with instant ramps so tests do not wait on wall time.
  SfxDucker ducker({
    double duckFactor = SfxDucker.defaultDuckFactor,
    int rampSteps = 4,
    bool failToApply = false,
  }) {
    return SfxDucker(
      applyVolume: (volume) async {
        applied.add(volume);
        if (failToApply) throw StateError('player detached');
      },
      duckFactor: duckFactor,
      rampSteps: rampSteps,
      sleeper: (_) async {},
    );
  }

  test('starts at the configured level and is not ducked', () {
    final d = ducker();
    expect(d.baseVolume, 1.0);
    expect(d.currentVolume, 1.0);
    expect(d.isDucked, isFalse);
  });

  test('a hold ducks to the configured fraction and release restores it',
      () async {
    final d = ducker();

    final hold = await d.hold();
    expect(d.isDucked, isTrue);
    expect(d.currentVolume, closeTo(0.18, 1e-9));

    await d.release(hold);
    expect(d.isDucked, isFalse);
    expect(d.currentVolume, closeTo(1.0, 1e-9));
  });

  test('ducking ramps down and back up instead of hard-cutting', () async {
    final d = ducker(rampSteps: 4);

    final hold = await d.hold();
    expect(applied.length, 4);
    expect(applied.first, lessThan(1.0));
    expect(applied.first, greaterThan(applied.last));

    applied.clear();
    await d.release(hold);
    expect(applied.length, 4);
    expect(applied.first, greaterThan(0.18));
    expect(applied.last, closeTo(1.0, 1e-9));
  });

  test('duck level scales with the configured SFX level', () async {
    final d = ducker();
    await d.setBaseVolume(0.5);
    expect(d.currentVolume, closeTo(0.5, 1e-9));

    final hold = await d.hold();
    expect(d.currentVolume, closeTo(0.09, 1e-9));

    await d.release(hold);
    expect(d.currentVolume, closeTo(0.5, 1e-9));
  });

  test('a level change mid-speech keeps the duck applied', () async {
    final d = ducker();
    final hold = await d.hold();

    await d.setBaseVolume(0.4);
    expect(d.isDucked, isTrue);
    expect(d.currentVolume, closeTo(0.4 * 0.18, 1e-9));

    await d.release(hold);
    expect(d.currentVolume, closeTo(0.4, 1e-9));
  });

  group('interrupted and overlapping speech', () {
    test('a new line supersedes the old hold and stays ducked', () async {
      final d = ducker();
      final first = await d.hold();
      final second = await d.hold();
      expect(second, isNot(first));

      // The interrupted line completes late; it must not un-duck the new one.
      await d.release(first);
      expect(d.isDucked, isTrue);
      expect(d.currentVolume, closeTo(0.18, 1e-9));

      await d.release(second);
      expect(d.isDucked, isFalse);
      expect(d.currentVolume, closeTo(1.0, 1e-9));
    });

    test('volume never rises above the duck level while a hold is live',
        () async {
      final d = ducker();
      final first = await d.hold();
      final second = await d.hold();
      applied.clear();

      await d.release(first);
      expect(applied, isEmpty);

      await d.release(second);
      expect(applied.last, closeTo(1.0, 1e-9));
    });

    test('overlapping holds each restore exactly once', () async {
      final d = ducker();
      final holds = <int>[for (var i = 0; i < 3; i++) await d.hold()];

      await d.release(holds[0]);
      await d.release(holds[1]);
      expect(d.isDucked, isTrue);

      await d.release(holds.last);
      expect(d.isDucked, isFalse);

      // Repeat releases are inert, so nothing pushes volume around later.
      applied.clear();
      for (final hold in holds) {
        await d.release(hold);
      }
      expect(applied, isEmpty);
      expect(d.currentVolume, closeTo(1.0, 1e-9));
    });
  });

  test('releaseAll restores volume no matter which line holds it', () async {
    final d = ducker();
    await d.hold();
    await d.hold();

    await d.releaseAll();
    expect(d.isDucked, isFalse);
    expect(d.currentVolume, closeTo(1.0, 1e-9));
  });

  test('releasing the no-hold token is a no-op', () async {
    final d = ducker();
    final hold = await d.hold();
    applied.clear();

    await d.release(SfxDucker.noHold);
    expect(d.isDucked, isTrue);

    await d.release(hold);
    expect(d.isDucked, isFalse);
  });

  test('a failing volume setter still leaves the duck state consistent',
      () async {
    final d = ducker(failToApply: true);

    final hold = await d.hold();
    expect(d.isDucked, isTrue);

    await d.release(hold);
    expect(d.isDucked, isFalse);
    expect(d.currentVolume, closeTo(1.0, 1e-9));
  });

  test('a zero duck factor mutes SFX and still restores', () async {
    final d = ducker(duckFactor: 0.0);

    final hold = await d.hold();
    expect(d.currentVolume, 0.0);

    await d.release(hold);
    expect(d.currentVolume, closeTo(1.0, 1e-9));
  });
}
