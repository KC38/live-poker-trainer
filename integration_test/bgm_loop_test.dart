/// On-device check that the Home lounge loop restarts without a gap.
///
/// Records SoLoud's master mixer output (what is handed to the audio device)
/// across several loop restarts, aligns it to the bundled WAV once, then
/// requires every 10 ms window to keep matching. A gap of even one sample at
/// a restart shifts the alignment and fails the residual check.
///
/// ```bash
/// flutter test integration_test/bgm_loop_test.dart -d <device-id>
/// ```
///
/// The capture is also written as `bgm_loop_capture.wav` for listening, to
/// `--dart-define=BGM_CAPTURE_DIR=<host dir>` on a simulator, otherwise to the
/// app's documents directory.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:path_provider/path_provider.dart';

const _sampleRate = 44100;

/// Long enough for three restarts of the 11 s loop.
const _captureSeconds = 37;

/// Mono 16-bit PCM samples from a canonical WAV file, as floats.
Float32List _decodeWav(ByteData data) {
  var offset = 12;
  while (offset + 8 <= data.lengthInBytes) {
    final id = String.fromCharCodes(
      data.buffer.asUint8List(data.offsetInBytes + offset, 4),
    );
    final size = data.getUint32(offset + 4, Endian.little);
    if (id == 'data') {
      final count = size ~/ 2;
      final out = Float32List(count);
      for (var i = 0; i < count; i++) {
        out[i] = data.getInt16(offset + 8 + i * 2, Endian.little) / 32768.0;
      }
      return out;
    }
    offset += 8 + size + (size.isOdd ? 1 : 0);
  }
  throw StateError('no data chunk');
}

/// Residual energy of [x] against gain-fitted [ref] over a window, 0 = exact.
({double gain, double ratio}) _fit(
  Float32List x,
  Float32List ref,
  int xStart,
  int refStart,
  int length,
) {
  var xr = 0.0, rr = 0.0, xx = 0.0;
  for (var i = 0; i < length; i++) {
    final a = x[xStart + i];
    final b = ref[(refStart + i) % ref.length];
    xr += a * b;
    rr += b * b;
    xx += a * a;
  }
  if (rr == 0 || xx == 0) return (gain: 0, ratio: 1);
  final gain = xr / rr;
  var resid = 0.0;
  for (var i = 0; i < length; i++) {
    final d = x[xStart + i] - gain * ref[(refStart + i) % ref.length];
    resid += d * d;
  }
  return (gain: gain, ratio: resid / xx);
}

Uint8List _wavBytes(Float32List mono) {
  final pcm = ByteData(mono.length * 2);
  for (var i = 0; i < mono.length; i++) {
    final v = (mono[i].clamp(-1.0, 1.0) * 32767).round();
    pcm.setInt16(i * 2, v, Endian.little);
  }
  final header = ByteData(44);
  void tag(int at, String s) {
    for (var i = 0; i < 4; i++) {
      header.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  header.setUint32(4, 36 + pcm.lengthInBytes, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, _sampleRate, Endian.little);
  header.setUint32(28, _sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  header.setUint32(40, pcm.lengthInBytes, Endian.little);
  return (BytesBuilder()
        ..add(header.buffer.asUint8List())
        ..add(pcm.buffer.asUint8List()))
      .takeBytes();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lounge loop restarts sample-continuously', (tester) async {
    final sound = SoundService();
    await tester.runAsync(() async {
      await sound.unlock();
      expect(SoLoud.instance.isInitialized, isTrue);

      final ref = _decodeWav(await rootBundle.load(SoundService.bgmAsset));
      expect(ref.length, 11 * _sampleRate);

      // Native engine format (stereo f32 at the engine rate): no converter
      // sits between the mixer and this capture.
      final bytes = BytesBuilder(copy: false);
      final watch = Stopwatch()..start();
      final sub = SoLoud.instance
          .startMixerOutputStream(bufferSizeBytes: 16 * 1024 * 1024)
          .listen(bytes.add);

      await sound.startHomeBgm();
      await Future<void>.delayed(const Duration(seconds: _captureSeconds));
      SoLoud.instance.stopMixerOutputStream();
      await sub.cancel();
      watch.stop();
      await sound.stopHomeBgm();

      final raw = bytes.takeBytes();
      final interleaved = Float32List.view(
        raw.buffer,
        raw.offsetInBytes,
        raw.lengthInBytes ~/ 4,
      );
      final floatsPerSecond =
          interleaved.length / (watch.elapsedMilliseconds / 1000);
      // ignore: avoid_print
      print(
        'BGM_LOOP captured ${raw.lengthInBytes} bytes in '
        '${watch.elapsedMilliseconds} ms '
        '(${floatsPerSecond.round()} floats/s)',
      );
      expect(
        (floatsPerSecond / (2 * _sampleRate) - 1).abs(),
        lessThan(0.02),
        reason: 'expected stereo f32 at $_sampleRate Hz',
      );
      final x = Float32List(interleaved.length ~/ 2);
      for (var i = 0; i < x.length; i++) {
        x[i] = (interleaved[2 * i] + interleaved[2 * i + 1]) / 2;
      }

      const hostDir = String.fromEnvironment('BGM_CAPTURE_DIR');
      final dir =
          hostDir.isNotEmpty
              ? Directory(hostDir)
              : await getApplicationDocumentsDirectory();
      await File('${dir.path}/bgm_loop_capture.f32').writeAsBytes(raw);
      final capturePath = '${dir.path}/bgm_loop_capture.wav';
      await File(capturePath).writeAsBytes(_wavBytes(x));
      // ignore: avoid_print
      print('BGM_LOOP capture file: $capturePath');

      // Sound starts where the output first leaves digital silence.
      var s0 = 0;
      while (s0 < x.length && x[s0].abs() < 1e-7) {
        s0++;
      }
      expect(s0, lessThan(x.length), reason: 'mixer output was silent');

      // Fine-align on a window after the 600 ms fade-in.
      final probeStart = s0 + _sampleRate;
      const probeLen = _sampleRate ~/ 4;
      var best = (lag: 0, ratio: double.infinity, gain: 0.0);
      for (var lag = -2048; lag <= 2048; lag++) {
        final refStart = (probeStart - (s0 + lag)) % ref.length;
        final f = _fit(x, ref, probeStart, refStart, probeLen);
        if (f.ratio < best.ratio) {
          best = (lag: lag, ratio: f.ratio, gain: f.gain);
        }
      }
      final origin = s0 + best.lag;
      // ignore: avoid_print
      print(
        'BGM_LOOP align lag=${best.lag} gain=${best.gain.toStringAsFixed(4)} '
        'probeResidual=${best.ratio.toStringAsExponential(2)}',
      );
      expect(best.ratio, lessThan(1e-3), reason: 'could not align capture');

      // Every 10 ms window after the fade must track the reference.
      const win = _sampleRate ~/ 100;
      var worst = 0.0;
      var worstAt = 0;
      var minRmsDb = 0.0;
      var windows = 0;
      final restarts = <int>[];
      for (var at = probeStart; at + win <= x.length - win; at += win) {
        final f = _fit(x, ref, at, (at - origin) % ref.length, win);
        var e = 0.0;
        for (var i = 0; i < win; i++) {
          e += x[at + i] * x[at + i];
        }
        final rmsDb = 10 * math.log(e / win + 1e-20) / math.ln10;
        minRmsDb = windows == 0 ? rmsDb : math.min(minRmsDb, rmsDb);
        if (f.ratio > worst) {
          worst = f.ratio;
          worstAt = at;
        }
        windows++;
      }
      for (var k = 1; origin + k * ref.length < x.length - win; k++) {
        final at = origin + k * ref.length - win ~/ 2;
        final f = _fit(x, ref, at, (at - origin) % ref.length, win);
        restarts.add(at);
        // ignore: avoid_print
        print(
          'BGM_LOOP restart #$k at ${(at / _sampleRate).toStringAsFixed(3)}s '
          'residual=${f.ratio.toStringAsExponential(2)}',
        );
        expect(f.ratio, lessThan(1e-4), reason: 'discontinuity at restart $k');
      }
      // ignore: avoid_print
      print(
        'BGM_LOOP windows=$windows restarts=${restarts.length} '
        'worstResidual=${worst.toStringAsExponential(2)} '
        '@${(worstAt / _sampleRate).toStringAsFixed(3)}s '
        'minRms=${minRmsDb.toStringAsFixed(1)}dB',
      );
      expect(restarts.length, greaterThanOrEqualTo(3));
      expect(worst, lessThan(1e-4));
    });
    await sound.dispose();
  });
}
