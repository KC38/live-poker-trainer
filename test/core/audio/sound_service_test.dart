/// SoundService BGM lifecycle flags and asset format (no native audio).
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'background pause keeps BGM wanted and resume clears the flag',
    () async {
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
    },
  );

  test(
    'pauseHomeBgm clears wanted so background resume will not restart',
    () async {
      final sound = SoundService.silent();
      await sound.startHomeBgm();
      await sound.pauseHomeBgm();
      expect(sound.bgmWanted, isFalse);

      await sound.pauseForBackground();
      expect(sound.pausedForBackground, isFalse);

      await sound.resumeFromBackground();
      expect(sound.bgmWanted, isFalse);

      await sound.dispose();
    },
  );

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

  test('BGM asset is a mono 44.1 kHz WAV that loops on a whole second', () {
    expect(SoundService.bgmAsset, 'assets/sounds/lounge_ambient.wav');
    final bytes = File(SoundService.bgmAsset).readAsBytesSync();
    final header = ByteData.sublistView(bytes, 0, 44);
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(header.getUint16(20, Endian.little), 1, reason: 'PCM');
    expect(header.getUint16(22, Endian.little), 1, reason: 'mono');
    expect(header.getUint32(24, Endian.little), 44100);
    final frames = header.getUint32(40, Endian.little) ~/ 2;
    expect(frames % 44100, 0);
  });

  test('silent service never starts the native engine', () async {
    final sound = SoundService.silent();
    expect(await sound.ensureEngine(), isFalse);
    await sound.unlock();
    await sound.startHomeBgm();
    await sound.chip();
    expect(sound.bgmHandle, isNull);
    await sound.dispose();
  });

  test(
    'dealStaggered plays the first card now and staggers the rest',
    () async {
      final sound = SoundService.silent();
      await sound.unlock();
      sound.dealStaggered();
      sound.dealStaggered();
      sound.dealStaggered();
      expect(sound.played, [SfxKind.deal]);

      sound.resetDealBurst();
      sound.dealStaggered();
      expect(sound.played, [SfxKind.deal, SfxKind.deal]);

      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(sound.played, [
        SfxKind.deal,
        SfxKind.deal,
        SfxKind.deal,
        SfxKind.deal,
      ]);
      await sound.dispose();
    },
  );

  test('deal plays first clip once then loops variations 2-8', () async {
    final sound = SoundService.silent();
    await sound.unlock();
    for (var i = 0; i < 10; i++) {
      await sound.deal();
    }
    expect(sound.dealVariationIndexes, [0, 1, 2, 3, 4, 5, 6, 7, 1, 2]);
    sound.resetDealSequence();
    await sound.deal();
    expect(sound.dealVariationIndexes.last, 0);
    await sound.dispose();
  });
}
