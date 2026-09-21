/// Learning feature flags from Firestore `appConfig/featureFlags`.
///
/// Defaults remain all-false when the document is missing or unreadable so
/// production continues to use the existing auth → Home path.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/curriculum/learning_feature_flags.dart';

/// Firestore path for app-wide feature flags.
const String featureFlagsDocPath = 'appConfig/featureFlags';

/// Stream of learning feature flags (defaults on error/missing).
final learningFeatureFlagsProvider =
    StreamProvider<LearningFeatureFlags>((ref) {
  return FirebaseFirestore.instance
      .doc(featureFlagsDocPath)
      .snapshots()
      .map((snap) {
    final data = snap.data();
    return LearningFeatureFlags.fromJson(data);
  }).handleError((_) => LearningFeatureFlags.defaults);
});

/// Synchronous view for widgets that already watched the stream.
final learningFeatureFlagsValueProvider = Provider<LearningFeatureFlags>((ref) {
  return ref.watch(learningFeatureFlagsProvider).maybeWhen(
        data: (flags) => flags,
        orElse: () => LearningFeatureFlags.defaults,
      );
});
