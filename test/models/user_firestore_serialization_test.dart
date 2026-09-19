/// Serialization coverage for Firestore user prefs / stats maps.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
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
      chipDisplayMode: ChipDisplayMode.bb,
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
    expect(remote['smallBlind'], 1);
    expect(remote['bigBlind'], 2);
    expect(remote['stackDepthBb'], 100);
    expect(remote['autoRebuy'], isFalse);
    expect(remote['rebuyThresholdBb'], 40);
    expect(remote['chipDisplayMode'], ChipDisplayMode.bb.name);
    expect(remote['lineupMode'], LineupMode.custom.name);
    expect(remote['customArchetypes'], isA<String>());

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
    expect(hydrated.smallBlind, 1);
    expect(hydrated.bigBlind, 2);
    expect(hydrated.stackDepthBb, 100);
    expect(hydrated.autoRebuy, isFalse);
    expect(hydrated.rebuyThresholdBb, 40);
    expect(hydrated.chipDisplayMode, ChipDisplayMode.bb);
    expect(hydrated.lineupMode, LineupMode.custom);
    expect(hydrated.customArchetypes.length, 2);
  });

  test('Firestore prefs accept list-shaped customArchetypes from server', () {
    final hydrated = GameSettingsModel.fromFirestorePreferences(
      {
        'seatCount': 4,
        'smallBlind': 0.5,
        'bigBlind': 1,
        'stackDepthBb': 50,
        'lineupMode': 'custom',
        'customArchetypes': ['Maniac', 'Nit', 'TAG'],
      },
      localAudio: const GameSettingsModel(sfxEnabled: false),
    );
    expect(hydrated.seatCount, 4);
    expect(hydrated.customArchetypes.map((a) => a.id).toList(), [
      'MANIAC',
      'NIT',
      'TAG',
    ]);
    expect(hydrated.sfxEnabled, isFalse);
  });

  test('mergeRemotePreferences keeps local audio over remote gameplay', () {
    const local = GameSettingsModel(
      seatCount: 9,
      sfxEnabled: false,
      musicEnabled: true,
    );
    const remote = GameSettingsModel(
      seatCount: 6,
      smallBlind: 2,
      bigBlind: 5,
      stackDepthBb: 200,
      sfxEnabled: true,
      musicEnabled: false,
      lineupMode: LineupMode.custom,
    );
    final merged = local.mergeRemotePreferences(remote);
    expect(merged.seatCount, 6);
    expect(merged.smallBlind, 2);
    expect(merged.bigBlind, 5);
    expect(merged.stackDepthBb, 200);
    expect(merged.lineupMode, LineupMode.custom);
    expect(merged.sfxEnabled, isFalse);
    expect(merged.musicEnabled, isTrue);
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
