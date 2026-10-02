/// Shared server repositories and audio.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/services/firestore/live_hand_service.dart';
import 'package:live_poker_trainer/services/firestore/progress_repository.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';

/// Firestore `users/{uid}` repository (prefs / stats / profile sync).
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

/// Progress aggregates from Firestore.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(),
);

/// Server-authoritative v3 live-hand callables.
final liveHandServiceProvider = Provider<LiveHandService>(
  (ref) => LiveHandService(),
);

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = _createSoundService();
  ref.onDispose(service.dispose);
  return service;
});

/// Widget tests use the silent service so felt deal SFX never open SoLoud.
SoundService _createSoundService() {
  final binding = WidgetsBinding.instance.runtimeType.toString();
  if (binding.contains('TestWidgetsFlutterBinding')) {
    return SoundService.silent();
  }
  return SoundService();
}
