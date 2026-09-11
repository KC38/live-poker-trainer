/// Real Firebase configuration for Live Poker Trainer.
///
/// Sourced from Firebase Console project `live-poker-trainer` (2026-09-11).
/// Replace placeholders only; do not invent keys.
library;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
class DefaultFirebaseOptions {
  /// Returns the [FirebaseOptions] for the running platform.
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpb9UiqCq7nH5yr2_JBrotLkwQyBuDkS8',
    appId: '1:584262608034:android:66dd75d06f90534b2a23fb',
    messagingSenderId: '584262608034',
    projectId: 'live-poker-trainer',
    storageBucket: 'live-poker-trainer.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTi0Yzk7Ak_UvtRM2JzaTMCIeR-ca1XsI',
    appId: '1:584262608034:ios:c7c61ae4b74ea7ce2a23fb',
    messagingSenderId: '584262608034',
    projectId: 'live-poker-trainer',
    storageBucket: 'live-poker-trainer.firebasestorage.app',
    iosBundleId: 'com.pokerlab.livePokerTrainer',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCIMph-Ed8fBZz0HiycEllMACvU9kOheHM',
    appId: '1:584262608034:web:a70f70ff1309110b2a23fb',
    messagingSenderId: '584262608034',
    projectId: 'live-poker-trainer',
    storageBucket: 'live-poker-trainer.firebasestorage.app',
    authDomain: 'live-poker-trainer.firebaseapp.com',
  );
}
