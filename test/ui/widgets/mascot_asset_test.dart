/// The shipped mascot drawings are transparent and distinct from each other.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('idle and celebrate mascots are transparent full-body drawings', () async {
    final idle = await _image('assets/brand/mascot_idle.png');
    final celebrate = await _image('assets/brand/mascot_celebrate.png');

    expect(idle.bytes, isNot(celebrate.bytes));
    expect(idle.cornerAlpha, 0);
    expect(celebrate.cornerAlpha, 0);
    expect(idle.width, greaterThan(200));
    expect(idle.height, greaterThan(idle.width));
  });
}

class _Decoded {
  const _Decoded({
    required this.bytes,
    required this.cornerAlpha,
    required this.width,
    required this.height,
  });

  final List<int> bytes;
  final int cornerAlpha;
  final int width;
  final int height;
}

Future<_Decoded> _image(String asset) async {
  final data = await rootBundle.load(asset);
  final bytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final raw = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final pixels = raw.buffer.asUint8List();
  return _Decoded(
    bytes: bytes,
    cornerAlpha: pixels[3],
    width: image.width,
    height: image.height,
  );
}
