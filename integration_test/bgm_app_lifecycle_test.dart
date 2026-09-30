/// On-device check that lounge music starts on first launch (before
/// onboarding finishes) and stops while the app is in the background.
///
/// Run against a fresh install on a booted simulator or device:
///
/// ```bash
/// flutter test integration_test/bgm_app_lifecycle_test.dart -d <device-id>
/// ```
///
/// With `--dart-define=BGM_HOST_LIFECYCLE=true` the background step waits for
/// the host to really background the app (for example by launching
/// `com.apple.Preferences` with `xcrun simctl launch`) after
/// `BGM_APP READY_FOR_BACKGROUND`, then to bring it back after
/// `BGM_APP READY_FOR_FOREGROUND`. Otherwise the lifecycle transitions are
/// simulated through the binding.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/main.dart' as app;
import 'package:live_poker_trainer/providers/service_providers.dart';

const _hostLifecycle = bool.fromEnvironment('BGM_HOST_LIFECYCLE');

/// Mixer output level over [duration], in dBFS (-inf when digitally silent).
Future<double> _mixerLevelDb(Duration duration) async {
  final bytes = BytesBuilder(copy: false);
  final sub = SoLoud.instance.startMixerOutputStream().listen(bytes.add);
  await Future<void>.delayed(duration);
  SoLoud.instance.stopMixerOutputStream();
  await sub.cancel();
  final raw = bytes.takeBytes();
  final x = Float32List.view(raw.buffer, raw.offsetInBytes, raw.length ~/ 4);
  if (x.isEmpty) return double.negativeInfinity;
  var e = 0.0;
  for (final v in x) {
    e += v * v;
  }
  if (e == 0) return double.negativeInfinity;
  return 10 * math.log(e / x.length) / math.ln10;
}

Future<void> _waitFor(
  bool Function() done, {
  required Duration timeout,
  required String what,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!done()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for $what');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

void _log(String message) {
  // ignore: avoid_print
  print('BGM_APP $message');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('music plays from first launch and pauses in background', (
    tester,
  ) async {
    await app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final container = ProviderScope.containerOf(
      tester.element(find.byType(app.PokerLabApp)),
    );
    final sound = container.read(soundServiceProvider);
    final soloud = SoLoud.instance;

    await tester.runAsync(() async {
      await _waitFor(
        () => sound.bgmHandle != null,
        timeout: const Duration(seconds: 15),
        what: 'BGM to start on the first screen',
      );
      final handle = sound.bgmHandle!;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(sound.bgmWanted, isTrue);
      expect(soloud.getIsValidVoiceHandle(handle), isTrue);
      expect(soloud.getPause(handle), isFalse);
      final playingDb = await _mixerLevelDb(const Duration(seconds: 1));
      _log('first-screen level ${playingDb.toStringAsFixed(1)} dBFS');
      expect(playingDb, greaterThan(-50));

      if (_hostLifecycle) {
        _log('READY_FOR_BACKGROUND');
        await _waitFor(
          () => soloud.getPause(handle),
          timeout: const Duration(seconds: 60),
          what: 'OS background to pause BGM',
        );
      } else {
        for (final state in const [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
      expect(soloud.getPause(handle), isTrue);
      expect(sound.bgmWanted, isTrue);
      final backgroundDb = await _mixerLevelDb(const Duration(seconds: 1));
      _log('background level $backgroundDb dBFS');
      expect(backgroundDb, lessThan(-90));

      if (_hostLifecycle) {
        _log('READY_FOR_FOREGROUND');
        await _waitFor(
          () => !soloud.getPause(handle),
          timeout: const Duration(seconds: 60),
          what: 'foreground to resume BGM',
        );
      } else {
        for (final state in const [
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(soloud.getPause(handle), isFalse);
      final resumedDb = await _mixerLevelDb(const Duration(seconds: 1));
      _log('resumed level ${resumedDb.toStringAsFixed(1)} dBFS');
      expect(resumedDb, greaterThan(-50));

      // A resume right after a fade-out pause must cancel the scheduled pause.
      await sound.pauseHomeBgm();
      await sound.startHomeBgm();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(soloud.getPause(handle), isFalse);
      final bounceDb = await _mixerLevelDb(const Duration(milliseconds: 500));
      _log('pause-then-resume level ${bounceDb.toStringAsFixed(1)} dBFS');
      expect(bounceDb, greaterThan(-50));

      // Table SFX share the engine and still sound over the music.
      await sound.stopHomeBgm();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final level = _mixerLevelDb(const Duration(milliseconds: 400));
      await sound.chip();
      final sfxDb = await level;
      _log('sfx level ${sfxDb.toStringAsFixed(1)} dBFS');
      expect(sfxDb, greaterThan(-50));
    });
  });
}
