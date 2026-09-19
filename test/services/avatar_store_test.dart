/// Avatar picking, thumbnailing, and Firebase Storage upload behavior.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/services/avatar_store.dart';

class _ScriptedPicker extends ImagePicker {
  _ScriptedPicker({this.file, this.error});

  final XFile? file;
  final PlatformException? error;
  int calls = 0;
  double? requestedMaxWidth;
  int? requestedQuality;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    requestedMaxWidth = maxWidth;
    requestedQuality = imageQuality;
    if (error case final failure?) throw failure;
    return file;
  }
}

Future<Uint8List> _png({int width = 40, int height = 20}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFFCC0022),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  picture.dispose();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List pngBytes;
  setUpAll(() async => pngBytes = await _png());

  test('signed-out selection fails before opening the picker', () async {
    final picker = _ScriptedPicker();
    final result =
        await AvatarStore(
          picker: picker,
          uploader: (_, _) async => 'https://example.com/avatar.jpg',
        ).pickFromGallery();

    expect(result.status, AvatarPickStatus.failed);
    expect(result.message, contains('Sign in'));
    expect(picker.calls, 0);
  });

  test('cancelled selection leaves the profile unchanged', () async {
    final result = await AvatarStore(
      picker: _ScriptedPicker(),
      uploader: (_, _) async => 'https://example.com/avatar.jpg',
    ).pickFromGallery(uploadUid: 'user-1');

    expect(result.status, AvatarPickStatus.cancelled);
    expect(result.avatar, isNull);
  });

  test('permission denial includes actionable copy', () async {
    final result = await AvatarStore(
      picker: _ScriptedPicker(
        error: PlatformException(code: 'photo_access_denied'),
      ),
      uploader: (_, _) async => 'https://example.com/avatar.jpg',
    ).pickFromGallery(uploadUid: 'user-1');

    expect(result.status, AvatarPickStatus.permissionDenied);
    expect(result.message, contains('Settings'));
  });

  test('successful selection uploads and returns a network avatar', () async {
    String? uploadedUid;
    Uint8List? uploadedBytes;
    final picker = _ScriptedPicker(
      file: XFile.fromData(pngBytes, name: 'avatar.png'),
    );
    final result = await AvatarStore(
      picker: picker,
      uploader: (uid, bytes) async {
        uploadedUid = uid;
        uploadedBytes = bytes;
        return 'https://example.com/avatar.jpg';
      },
    ).pickFromGallery(uploadUid: 'user-1');

    expect(result.isSaved, isTrue);
    expect(result.avatar?.kind, AvatarKind.network);
    expect(result.avatar?.networkUrl, 'https://example.com/avatar.jpg');
    expect(uploadedUid, 'user-1');
    expect(uploadedBytes, isNotEmpty);
    expect(picker.requestedMaxWidth, AvatarStore.pickMaxEdge);
    expect(picker.requestedQuality, AvatarStore.pickQuality);
  });

  test('upload failures return a clear failed result', () async {
    final result = await AvatarStore(
      picker: _ScriptedPicker(
        file: XFile.fromData(pngBytes, name: 'avatar.png'),
      ),
      uploader: (_, _) => Future<String>.error(Exception('offline')),
    ).pickFromGallery(uploadUid: 'user-1');

    expect(result.status, AvatarPickStatus.failed);
    expect(result.message, contains('uploaded'));
  });

  test('storeImageBytes rejects an empty uid', () async {
    final store = AvatarStore(
      uploader: (_, _) async => 'https://example.com/avatar.jpg',
    );
    expect(
      () => store.storeImageBytes(pngBytes, uploadUid: ''),
      throwsArgumentError,
    );
  });

  test('non-square photos are cropped to the target square', () async {
    final thumbnail = await AvatarStore.squareThumbnail(
      await _png(width: 120, height: 30),
    );

    expect(thumbnail, isNotNull);
    final codec = await ui.instantiateImageCodec(thumbnail!);
    final decoded = (await codec.getNextFrame()).image;
    addTearDown(decoded.dispose);
    expect(decoded.width, AvatarStore.thumbnailSize);
    expect(decoded.height, AvatarStore.thumbnailSize);
  });
}
