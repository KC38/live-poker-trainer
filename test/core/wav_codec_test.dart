import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/wav_codec.dart';

void main() {
  group('WavCodec', () {
    test('wraps raw PCM into RIFF/WAVE', () {
      final pcm = Uint8List.fromList(List<int>.generate(48, (i) => i % 256));
      final wav = WavCodec.pcmToWav(pcm, sampleRate: 24000);
      expect(WavCodec.isWav(wav), isTrue);
      expect(wav.length, 44 + pcm.length);
      // Sample rate little-endian at offset 24
      expect(wav[24] | (wav[25] << 8) | (wav[26] << 16) | (wav[27] << 24), 24000);
    });

    test('ensurePlayable wraps audio/pcm;rate=24000', () {
      final pcm = Uint8List(100);
      final playable = WavCodec.ensurePlayable(
        pcm,
        mimeType: 'audio/pcm;rate=24000',
      );
      expect(playable.mimeType, 'audio/wav');
      expect(WavCodec.isWav(playable.bytes), isTrue);
    });

    test('ensurePlayable leaves existing WAV alone', () {
      final pcm = Uint8List(20);
      final wav = WavCodec.pcmToWav(pcm);
      final playable = WavCodec.ensurePlayable(wav, mimeType: 'audio/wav');
      expect(identical(playable.bytes, wav) || playable.bytes.length == wav.length, isTrue);
      expect(WavCodec.isWav(playable.bytes), isTrue);
    });

    test('parses rate from L16 mime', () {
      expect(
        WavCodec.sampleRateFromMime('audio/L16;codec=pcm;rate=16000'),
        16000,
      );
    });
  });
}
