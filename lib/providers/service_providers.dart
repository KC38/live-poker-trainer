/// Shared server repositories, situation callables, and audio.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/services/firestore/live_hand_service.dart';
import 'package:live_poker_trainer/services/firestore/progress_repository.dart';
import 'package:live_poker_trainer/services/firestore/situation_service.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';

/// Firestore `users/{uid}` repository (prefs / stats / profile sync).
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

/// Progress aggregates from Firestore.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(),
);

/// Server-authored situation callables.
final situationServiceProvider = Provider<SituationService>(
  (ref) => SituationService(),
);

/// Server-authoritative v3 live-hand callables.
final liveHandServiceProvider = Provider<LiveHandService>(
  (ref) => LiveHandService(),
);

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});
