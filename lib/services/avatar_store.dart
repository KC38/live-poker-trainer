/// Picks, normalizes, and uploads the hero's profile picture.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';

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
  /// Creates a store.
  AvatarStore({ImagePicker? picker, this.storage, this.uploader})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final FirebaseStorage? storage;
  final Future<String> Function(String uid, Uint8List bytes)? uploader;

  FirebaseStorage get _firebaseStorage => storage ?? FirebaseStorage.instance;

  /// Edge length of the stored square thumbnail, in pixels.
  static const int thumbnailSize = 256;

  static const double pickMaxEdge = 1024;
  static const int pickQuality = 88;

  /// Opens the photo library and uploads the chosen image for [uploadUid].
  Future<AvatarPickResult> pickFromGallery({String? uploadUid}) async {
    if (uploadUid == null || uploadUid.trim().isEmpty) {
      return const AvatarPickResult(
        AvatarPickStatus.failed,
        message: 'Sign in before choosing a profile photo.',
      );
    }
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
      final avatar = await storeImageBytes(bytes, uploadUid: uploadUid);
      return AvatarPickResult(AvatarPickStatus.saved, avatar: avatar);
    } catch (_) {
      return const AvatarPickResult(
        AvatarPickStatus.failed,
        message: 'That photo could not be uploaded. Check your connection.',
      );
    }
  }

  /// Normalizes [bytes] and uploads to Firebase Storage.
  Future<AvatarRef> storeImageBytes(
    Uint8List bytes, {
    required String uploadUid,
  }) async {
    if (uploadUid.trim().isEmpty) {
      throw ArgumentError.value(uploadUid, 'uploadUid', 'must not be empty');
    }
    final square = await squareThumbnail(bytes) ?? bytes;
    final upload = uploader;
    if (upload != null) {
      return AvatarRef.network(await upload(uploadUid, square));
    }
    final ref = _firebaseStorage.ref('avatars/$uploadUid/avatar.png');
    await ref.putData(square, SettableMetadata(contentType: 'image/png'));
    return AvatarRef.network(await ref.getDownloadURL());
  }

  /// Centre-crops [bytes] to a square and scales it to [thumbnailSize].
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

  static AvatarPickStatus _statusForPlatformError(String code) {
    return switch (code) {
      'photo_access_denied' ||
      'camera_access_denied' => AvatarPickStatus.permissionDenied,
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
