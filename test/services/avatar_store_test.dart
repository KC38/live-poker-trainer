/// Avatar picking, thumbnailing, and on-disk persistence.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/services/avatar_store.dart';

/// An [ImagePicker] that returns a scripted result instead of touching the
/// platform channel.
class _ScriptedPicker extends ImagePicker {
  _ScriptedPicker({this.file, this.error});

  final XFile? file;
  final PlatformException? error;

  /// Arguments the store asked for, so downscaling requests can be asserted.
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
    requestedMaxWidth = maxWidth;
    requestedQuality = imageQuality;
    final failure = error;
    if (failure != null) throw failure;
    return file;
  }
}

/// Encodes a real, decodable PNG of [width] x [height].
///
/// Hand-written PNG literals are easy to get subtly wrong, and a store that
/// silently falls back to the raw bytes would hide the mistake.
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
  // Encoding a thumbnail goes through dart:ui, which needs a binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documents;
  late Uint8List pngBytes;

  /// Builds a store rooted at a scratch documents directory.
  AvatarStore store({ImagePicker? picker}) => AvatarStore(
        picker: picker,
        documentsDirectory: () async => documents,
      );

  Directory avatarDir() =>
      Directory('${documents.path}${Platform.pathSeparator}'
          '${AvatarStore.folderName}');

  setUpAll(() async => pngBytes = await _png());

  setUp(() {
    documents = Directory.systemTemp.createTempSync('avatar_store_test');
  });

  tearDown(() {
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  group('storing an image', () {
    test('writes a prefixed png inside the managed avatars directory',
        () async {
      final avatar = await store().storeImageBytes(pngBytes);

      expect(avatar.kind, AvatarKind.file);
      final path = avatar.filePath!;
      expect(File(path).existsSync(), isTrue);
      expect(path, startsWith(avatarDir().path));
      expect(path.split(Platform.pathSeparator).last,
          startsWith(AvatarStore.filePrefix));
      expect(path, endsWith('.png'));
      expect(AvatarStore.fileExists(avatar), isTrue);
    });

    test('creates the avatars directory on first use', () async {
      expect(avatarDir().existsSync(), isFalse);

      await store().ensureDirectory();

      expect(avatarDir().existsSync(), isTrue);
    });

    test('undecodable bytes are still stored rather than rejected', () async {
      // A HEIC the platform cannot rasterize must not lose the user's pick.
      final avatar = await store().storeImageBytes(
        Uint8List.fromList(List.filled(64, 7)),
      );

      expect(File(avatar.filePath!).existsSync(), isTrue);
    });

    test('a non-square photo is cropped to a square at the target edge',
        () async {
      final wide = await _png(width: 120, height: 30);
      final thumbnail = await AvatarStore.squareThumbnail(wide);

      expect(thumbnail, isNotNull);
      final codec = await ui.instantiateImageCodec(thumbnail!);
      final decoded = (await codec.getNextFrame()).image;
      addTearDown(decoded.dispose);
      expect(decoded.width, AvatarStore.thumbnailSize);
      expect(decoded.height, AvatarStore.thumbnailSize);
    });

    test('a stored avatar is smaller than an unbounded photo would be',
        () async {
      final avatar = await store().storeImageBytes(pngBytes);

      expect(File(avatar.filePath!).lengthSync(), lessThan(400 * 1024));
    });
  });

  group('picking from the library', () {
    test('a cancelled pick changes nothing', () async {
      final result = await store(picker: _ScriptedPicker()).pickFromGallery();

      expect(result.status, AvatarPickStatus.cancelled);
      expect(result.avatar, isNull);
      expect(result.isSaved, isFalse);
      expect(result.message, isNull, reason: 'cancelling is not an error');
    });

    test('a denied permission is reported as such, with actionable copy',
        () async {
      final picker = _ScriptedPicker(
        error: PlatformException(code: 'photo_access_denied'),
      );

      final result = await store(picker: picker).pickFromGallery();

      expect(result.status, AvatarPickStatus.permissionDenied);
      expect(result.avatar, isNull);
      expect(result.message, contains('Settings'));
      expect(result.message, contains('built-in'));
    });

    test('an unexpected platform error degrades to a plain failure', () async {
      final picker = _ScriptedPicker(
        error: PlatformException(code: 'multiple_request'),
      );

      final result = await store(picker: picker).pickFromGallery();

      expect(result.status, AvatarPickStatus.failed);
      expect(result.message, isNotNull);
    });

    test('a successful pick stores the file and asks for a downscale',
        () async {
      final source = File('${documents.path}/source.png')
        ..writeAsBytesSync(pngBytes);
      final picker = _ScriptedPicker(file: XFile(source.path));

      final result = await store(picker: picker).pickFromGallery();

      expect(result.isSaved, isTrue);
      expect(File(result.avatar!.filePath!).existsSync(), isTrue);
      expect(picker.requestedMaxWidth, AvatarStore.pickMaxEdge);
      expect(picker.requestedQuality, AvatarStore.pickQuality);
    });

    test('replacing an avatar deletes the file it replaced', () async {
      final subject = store();
      final previous = await subject.storeImageBytes(pngBytes);
      final source = File('${documents.path}/source.png')
        ..writeAsBytesSync(pngBytes);

      final result = await store(picker: _ScriptedPicker(file: XFile(source.path)))
          .pickFromGallery(replacing: previous);

      expect(result.isSaved, isTrue);
      expect(File(previous.filePath!).existsSync(), isFalse);
      expect(File(result.avatar!.filePath!).existsSync(), isTrue);
    });

    test('an unreadable picked file fails without throwing', () async {
      final picker = _ScriptedPicker(
        file: XFile('${documents.path}/does_not_exist.png'),
      );

      final result = await store(picker: picker).pickFromGallery();

      expect(result.status, AvatarPickStatus.failed);
      expect(result.message, isNotNull);
    });
  });

  group('deleting', () {
    test('a stored avatar is deleted', () async {
      final subject = store();
      final avatar = await subject.storeImageBytes(pngBytes);

      expect(await subject.deleteStoredFile(avatar), isTrue);
      expect(AvatarStore.fileExists(avatar), isFalse);
    });

    test('a path outside the avatars directory is never touched', () async {
      final outsider = File('${documents.path}/precious.png')
        ..writeAsBytesSync(pngBytes);

      final deleted = await store().deleteStoredFile(
        AvatarRef.file(outsider.path),
      );

      expect(deleted, isFalse);
      expect(outsider.existsSync(), isTrue, reason: 'must survive');
    });

    test('a built-in avatar has no file to delete', () async {
      final deleted = await store().deleteStoredFile(
        AvatarRef.builtIn(BuiltInAvatar.values.first),
      );

      expect(deleted, isFalse);
    });

    test('pruning keeps the current avatar and clears the orphans', () async {
      final subject = store();
      final first = await subject.storeImageBytes(pngBytes);
      // Timestamped names, so a second write needs a distinct millisecond.
      await Future<void>.delayed(const Duration(milliseconds: 3));
      final second = await subject.storeImageBytes(pngBytes);
      await Future<void>.delayed(const Duration(milliseconds: 3));
      final keep = await subject.storeImageBytes(pngBytes);

      final removed = await subject.pruneExcept(keep);

      expect(removed, 2);
      expect(AvatarStore.fileExists(keep), isTrue);
      expect(AvatarStore.fileExists(first), isFalse);
      expect(AvatarStore.fileExists(second), isFalse);
    });

    test('a missing file reads as missing rather than throwing', () {
      expect(
        AvatarStore.fileExists(
          const AvatarRef.file('/nowhere/at/all/avatar_1.png'),
        ),
        isFalse,
      );
      expect(AvatarStore.fileExists(const AvatarRef.none()), isFalse);
    });
  });
}
