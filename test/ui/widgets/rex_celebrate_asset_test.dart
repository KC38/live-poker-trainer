/// Locks the celebrate drawing to the same coach as the calm figure.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('celebrate drawing is the same coach with a different pose', () async {
    final calm = await _portrait(RexMascot.asset);
    final celebrate = await _portrait(RexMascot.celebrateAsset);

    expect(_isGreen(calm.sweater), isTrue, reason: 'calm sweater');
    expect(_isGreen(celebrate.sweater), isTrue, reason: 'celebrate sweater');
    expect(_isSkin(calm.cheek), isTrue, reason: 'calm cheek');
    expect(_isSkin(celebrate.cheek), isTrue, reason: 'celebrate cheek');
    expect((celebrate.cheek.r - calm.cheek.r).abs(), lessThan(40));
    expect((celebrate.cheek.g - calm.cheek.g).abs(), lessThan(40));
    expect((celebrate.cheek.b - calm.cheek.b).abs(), lessThan(40));
    expect(celebrate.bytes, isNot(calm.bytes));
  });
}

class _Rgb {
  const _Rgb(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;
}

class _Portrait {
  const _Portrait({
    required this.cheek,
    required this.sweater,
    required this.bytes,
  });

  final _Rgb cheek;
  final _Rgb sweater;
  final List<int> bytes;
}

/// Cheek and sweater means, plus the file bytes so the moods stay distinct.
Future<_Portrait> _portrait(String asset) async {
  final data = await rootBundle.load(asset);
  final bytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final raw = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final pixels = raw.buffer.asUint8List();
  return _Portrait(
    cheek: _mean(pixels, image.width, image.height, 0.42, 0.22, 0.16, 0.08),
    sweater: _mean(pixels, image.width, image.height, 0.38, 0.48, 0.24, 0.10),
    bytes: bytes,
  );
}

_Rgb _mean(
  List<int> pixels,
  int width,
  int height,
  double fx,
  double fy,
  double fw,
  double fh,
) {
  final x0 = (width * fx).floor();
  final y0 = (height * fy).floor();
  final x1 = (width * (fx + fw)).floor();
  final y1 = (height * (fy + fh)).floor();
  var r = 0;
  var g = 0;
  var b = 0;
  var n = 0;
  for (var y = y0; y < y1; y += 8) {
    for (var x = x0; x < x1; x += 8) {
      final i = (y * width + x) * 4;
      r += pixels[i];
      g += pixels[i + 1];
      b += pixels[i + 2];
      n++;
    }
  }
  return _Rgb(r ~/ n, g ~/ n, b ~/ n);
}

bool _isGreen(_Rgb color) =>
    color.g > color.r + 20 && color.g > color.b && color.g > 70;

bool _isSkin(_Rgb color) =>
    color.r > 140 && color.r > color.g && color.g > color.b && color.g > 70;
