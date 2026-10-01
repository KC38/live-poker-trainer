/// Locks the AI audio generator contract to SoundService filenames.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';

void main() {
  test('gen_audio_ai.py covers every SoundService asset filename', () {
    final script = File('tool/gen_audio_ai.py').readAsStringSync();
    for (final kind in SfxKind.values) {
      expect(
        script,
        contains("out_name=\"${kind.fileName}\""),
        reason: 'Missing SFX asset ${kind.fileName} in gen_audio_ai.py',
      );
    }
    expect(script, contains('out_name="lounge_ambient.wav"'));
    expect(script, contains('ELEVENLABS_API_KEY'));
    expect(script, contains('tool/.env.local'));
    expect(script, contains('make_seamless_loop_wav'));
  });

  test('bundled sound assets exist for SoundService', () {
    for (final kind in SfxKind.values) {
      final path = File('assets/sounds/${kind.fileName}');
      expect(path.existsSync(), isTrue, reason: path.path);
      expect(path.lengthSync(), greaterThan(1000));
    }
    final ambient = File('assets/sounds/lounge_ambient.wav');
    expect(ambient.existsSync(), isTrue);
    expect(ambient.lengthSync(), greaterThan(1000));
    expect(File('assets/sounds/lounge_ambient.mp3').existsSync(), isFalse);
  });
}
