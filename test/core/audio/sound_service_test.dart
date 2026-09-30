/// SoundService BGM lifecycle flags (no platform audioplayers).
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('background pause keeps BGM wanted and resume clears the flag', () async {
    final sound = SoundService.silent();
    await sound.startHomeBgm();
    expect(sound.bgmWanted, isTrue);
    expect(sound.pausedForBackground, isFalse);

    await sound.pauseForBackground();
    expect(sound.bgmWanted, isTrue);
    expect(sound.pausedForBackground, isTrue);

    await sound.resumeFromBackground();
    expect(sound.bgmWanted, isTrue);
    expect(sound.pausedForBackground, isFalse);

    await sound.dispose();
  });

  test('pauseHomeBgm clears wanted so background resume will not restart', () async {
    final sound = SoundService.silent();
    await sound.startHomeBgm();
    await sound.pauseHomeBgm();
    expect(sound.bgmWanted, isFalse);

    await sound.pauseForBackground();
    expect(sound.pausedForBackground, isFalse);

    await sound.resumeFromBackground();
    expect(sound.bgmWanted, isFalse);

    await sound.dispose();
  });

  test('lifecycle observer pauses on hidden and resumes on resumed', () async {
    final sound = SoundService.silent();
    await sound.startHomeBgm();

    sound.didChangeAppLifecycleState(AppLifecycleState.hidden);
    await pumpEventQueue();
    expect(sound.pausedForBackground, isTrue);

    sound.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(sound.pausedForBackground, isFalse);

    await sound.dispose();
  });

  test('SoundService points BGM at the gapless WAV asset', () {
    final source = File('lib/core/audio/sound_service.dart').readAsStringSync();
    expect(source, contains("sounds/lounge_ambient.wav"));
    expect(source, contains('PlayerMode.mediaPlayer'));
    expect(source, contains('pauseForBackground'));
  });
}
