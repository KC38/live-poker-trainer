/// Picks, normalizes, and stores the hero's profile picture on device.
///
/// Nothing is uploaded anywhere. A chosen photo is downscaled and
/// centre-cropped to a square [AvatarStore.thumbnailSize] PNG and written into
/// `<app documents>/avatars/`, and only that path is persisted. Files are
/// named with a timestamp for two reasons: it makes replacing an avatar
/// atomic, and it sidesteps Flutter's image cache, which keys `Image.file` by
/// path and would otherwise keep showing the previous picture.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:path_provider/path_provider.dart';

/// Why an avatar pick ended the way it did.
enum AvatarPickStatus {
  /// A new file was written; [AvatarPickResult.avatar] is set.
  saved,

  /// The user backed out of the picker.
  cancelled,

  /// The OS refused photo-library access.
  permissionDenied,

  /// Decoding or writing failed.
  failed,
}

/// Outcome of an avatar pick.
class AvatarPickResult {
  /// Creates a result.
  const AvatarPickResult(this.status, {this.avatar, this.message});

  final AvatarPickStatus status;

  /// The stored reference, only for [AvatarPickStatus.saved].
  final AvatarRef? avatar;

  /// User-facing explanation for the failure cases.
  final String? message;

  bool get isSaved => status == AvatarPickStatus.saved && avatar != null;
}

/// Reads photos from the device and stores normalized avatar thumbnails.
class AvatarStore {
  /// Creates a store. The seams exist for tests: [picker] can be faked and
  /// [documentsDirectory] can point at a temporary folder.
  AvatarStore({
    ImagePicker? picker,
    Future<Directory> Function()? documentsDirectory,
  })  : _picker = picker ?? ImagePicker(),
        _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  final ImagePicker _picker;
  final Future<Directory> Function() _documentsDirectory;

  /// Edge length of the stored square thumbnail, in pixels.
  static const int thumbnailSize = 256;

  /// Longest edge requested from the platform picker. Decoding a 12 MP photo
  /// only to shrink it wastes memory on older phones.
  static const double pickMaxEdge = 1024;

  /// JPEG quality requested from the platform picker.
  static const int pickQuality = 88;

  /// Subdirectory of the app documents directory holding avatar files.
  static const String folderName = 'avatars';

  /// Prefix shared by every stored avatar file.
  static const String filePrefix = 'avatar_';

  /// Opens the photo library and stores the chosen image.
  ///
  /// [replacing] is deleted once the new file is written, so switching avatars
  /// never leaves orphans behind.
  Future<AvatarPickResult> pickFromGallery({AvatarRef? replacing}) async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: pickMaxEdge,
        maxHeight: pickMaxEdge,
        imageQuality: pickQuality,
      );
    } on PlatformException catch (e) {
      return AvatarPickResult(
        _statusForPlatformError(e.code),
        message: _messageForPlatformError(e.code),
      );
    } catch (_) {
      return const AvatarPickResult(
        AvatarPickStatus.failed,
        message: 'Could not open your photo library.',
      );
    }

    if (picked == null) {
      return const AvatarPickResult(AvatarPickStatus.cancelled);
    }

    try {
      final bytes = await picked.readAsBytes();
      final avatar = await storeImageBytes(bytes);
      if (replacing != null) await deleteStoredFile(replacing);
      return AvatarPickResult(AvatarPickStatus.saved, avatar: avatar);
    } catch (_) {
      return const AvatarPickResult(
        AvatarPickStatus.failed,
        message: 'That image could not be read. Try a different photo.',
      );
    }
  }

  /// Normalizes [bytes] to a square thumbnail and writes it to disk.
  ///
  /// Falls back to storing the original bytes when the platform cannot
  /// rasterize them, so a valid photo is never rejected outright.
  Future<AvatarRef> storeImageBytes(Uint8List bytes) async {
    final directory = await ensureDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}$filePrefix'
      '${DateTime.now().toUtc().millisecondsSinceEpoch}.png',
    );
    final square = await squareThumbnail(bytes) ?? bytes;
    await file.writeAsBytes(square, flush: true);
    return AvatarRef.file(file.path);
  }

  /// Centre-crops [bytes] to a square and scales it to [thumbnailSize],
  /// returning PNG bytes, or null when the image could not be decoded.
  static Future<Uint8List?> squareThumbnail(Uint8List bytes) async {
    ui.Image? source;
    ui.Image? output;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      source = frame.image;
      if (source.width <= 0 || source.height <= 0) return null;

      final side = math.min(source.width, source.height).toDouble();
      final srcRect = ui.Rect.fromLTWH(
        (source.width - side) / 2,
        (source.height - side) / 2,
        side,
        side,
      );
      const dstRect = ui.Rect.fromLTWH(
        0,
        0,
        thumbnailSize * 1.0,
        thumbnailSize * 1.0,
      );

      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        source,
        srcRect,
        dstRect,
        ui.Paint()..filterQuality = ui.FilterQuality.medium,
      );
      final picture = recorder.endRecording();
      output = await picture.toImage(thumbnailSize, thumbnailSize);
      picture.dispose();

      final data = await output.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      source?.dispose();
      output?.dispose();
    }
  }

  /// Creates (if needed) and returns the avatar directory.
  Future<Directory> ensureDirectory() async {
    final documents = await _documentsDirectory();
    final directory = Directory(
      '${documents.path}${Platform.pathSeparator}$folderName',
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Deletes the file behind [avatar], if it is a stored photo.
  ///
  /// Only paths inside the managed avatar directory are touched, so a stale or
  /// hostile database value can never delete something else.
  Future<bool> deleteStoredFile(AvatarRef avatar) async {
    final path = avatar.filePath;
    if (path == null || path.isEmpty) return false;
    try {
      final directory = await ensureDirectory();
      if (!_isInside(directory.path, path)) return false;
      final file = File(path);
      if (!file.existsSync()) return false;
      await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes every stored avatar except the one referenced by [keep].
  Future<int> pruneExcept(AvatarRef keep) async {
    try {
      final directory = await ensureDirectory();
      final kept = keep.filePath;
      var removed = 0;
      for (final entity in directory.listSync()) {
        if (entity is! File) continue;
        if (entity.path == kept) continue;
        if (!_fileName(entity.path).startsWith(filePrefix)) continue;
        await entity.delete();
        removed++;
      }
      return removed;
    } catch (_) {
      return 0;
    }
  }

  /// Whether the file behind [avatar] is still on disk.
  ///
  /// A photo can vanish (app data cleared, restored backup), and a missing
  /// file must degrade to initials rather than a broken image box.
  static bool fileExists(AvatarRef avatar) {
    final path = avatar.filePath;
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  static bool _isInside(String directory, String path) {
    final normalized = directory.endsWith(Platform.pathSeparator)
        ? directory
        : '$directory${Platform.pathSeparator}';
    return path.startsWith(normalized);
  }

  static String _fileName(String path) =>
      path.split(Platform.pathSeparator).last;

  static AvatarPickStatus _statusForPlatformError(String code) {
    return switch (code) {
      'photo_access_denied' || 'camera_access_denied' =>
        AvatarPickStatus.permissionDenied,
      _ => AvatarPickStatus.failed,
    };
  }

  static String _messageForPlatformError(String code) {
    return switch (code) {
      'photo_access_denied' || 'camera_access_denied' =>
        'Photo access is off. Turn it on in Settings, or pick one of the '
            'built-in avatars below.',
      _ => 'Could not load that photo. Try a built-in avatar instead.',
    };
  }
}
