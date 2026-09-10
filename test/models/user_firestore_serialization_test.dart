/// Serialization coverage for Firestore user prefs / stats maps.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

void main() {
  test('GameSettingsModel Firestore prefs omit audio and round-trip', () {
    final settings = GameSettingsModel(
      smallBlind: 1,
      bigBlind: 2,
      seatCount: 6,
      stackDepthBb: 100,
      autoRebuy: false,
      rebuyThresholdBb: 40,
      sfxEnabled: false,
      musicEnabled: false,
      lineupMode: LineupMode.custom,
      customArchetypes: const [
        PlayerArchetype.maniac,
        PlayerArchetype.nit,
      ],
    );

    final remote = settings.toFirestorePreferences();
    expect(remote.containsKey('sfxEnabled'), isFalse);
    expect(remote.containsKey('musicEnabled'), isFalse);
    expect(remote['seatCount'], 6);

    final localAudio = const GameSettingsModel(
      sfxEnabled: true,
      musicEnabled: true,
    );
    final hydrated = GameSettingsModel.fromFirestorePreferences(
      Map<String, dynamic>.from(remote),
      localAudio: localAudio,
    );
    expect(hydrated.sfxEnabled, isTrue);
    expect(hydrated.musicEnabled, isTrue);
    expect(hydrated.seatCount, 6);
    expect(hydrated.lineupMode, LineupMode.custom);
    expect(hydrated.customArchetypes.length, 2);
  });

  test('UserStatsModel Firestore map round-trips', () {
    const stats = UserStatsModel(
      totalSpots: 10,
      correctSpots: 7,
      netEvBb: 3.5,
      archetypeAccuracy: {
        'Maniac': ArchetypeStat(
          archetype: 'Maniac',
          played: 4,
          correct: 3,
          evBb: 1.2,
        ),
      },
      streetAccuracy: {
        'Flop': StreetStat(street: 'Flop', played: 5, correct: 4),
      },
      recentEvDeltas: [0.5, -0.2],
    );

    final restored = UserStatsModel.fromFirestoreMap(
      Map<String, dynamic>.from(stats.toFirestoreMap()),
    );
    expect(restored.totalSpots, 10);
    expect(restored.correctSpots, 7);
    expect(restored.netEvBb, 3.5);
    expect(restored.archetypeAccuracy['Maniac']?.correct, 3);
    expect(restored.streetAccuracy['Flop']?.played, 5);
    expect(restored.recentEvDeltas, [0.5, -0.2]);
  });
}
