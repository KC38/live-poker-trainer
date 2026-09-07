/// User-configurable gameplay and audio preferences.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Lineup selection mode on the Home screen.
enum LineupMode { randomPool, custom }

/// Persistent settings for blinds, stack, rebuy, SFX, music, and TTS.
@immutable
class GameSettingsModel {
  /// Creates game settings with plan defaults.
  const GameSettingsModel({
    this.smallBlind = PokerConstants.defaultSmallBlind,
    this.bigBlind = PokerConstants.defaultBigBlind,
    this.seatCount = PokerConstants.defaultSeatCount,
    this.stackDepthBb = PokerConstants.defaultStackBb,
    this.autoRebuy = PokerConstants.defaultAutoRebuy,
    this.rebuyThresholdBb = PokerConstants.defaultRebuyThresholdBb,
    this.sfxEnabled = PokerConstants.defaultSfxEnabled,
    this.ttsEnabled = PokerConstants.defaultTtsEnabled,
    this.musicEnabled = PokerConstants.defaultMusicEnabled,
    this.chipDisplayMode = ChipDisplayMode.both,
    this.lineupMode = LineupMode.randomPool,
    this.customArchetypes = const [],
  });

  final double smallBlind;
  final double bigBlind;
  final int seatCount;
  final int stackDepthBb;
  final bool autoRebuy;
  final int rebuyThresholdBb;
  final bool sfxEnabled;
  final bool ttsEnabled;

  /// Home / lounge ambient loop; independent of table SFX.
  final bool musicEnabled;
  final ChipDisplayMode chipDisplayMode;
  final LineupMode lineupMode;
  final List<PlayerArchetype> customArchetypes;

  double get startingStack => stackDepthBb * bigBlind;

  /// Villain seat count (excludes Hero at seat 0).
  int get villainSeatCount => (seatCount - 1).clamp(1, 8);

  /// Ensures [customArchetypes] has one entry per villain seat.
  GameSettingsModel withNormalizedCustomLineup() {
    final needed = villainSeatCount;
    if (customArchetypes.length == needed) return this;
    final pool = ArchetypeRoster.villainPool;
    final next = <PlayerArchetype>[
      for (var i = 0; i < needed; i++)
        i < customArchetypes.length
            ? customArchetypes[i]
            : pool[i % pool.length],
    ];
    return copyWith(customArchetypes: next);
  }

  GameSettingsModel copyWith({
    double? smallBlind,
    double? bigBlind,
    int? seatCount,
    int? stackDepthBb,
    bool? autoRebuy,
    int? rebuyThresholdBb,
    bool? sfxEnabled,
    bool? ttsEnabled,
    bool? musicEnabled,
    ChipDisplayMode? chipDisplayMode,
    LineupMode? lineupMode,
    List<PlayerArchetype>? customArchetypes,
  }) {
    final nextSeats = seatCount ?? this.seatCount;
    var nextCustom = customArchetypes ?? this.customArchetypes;
    // Keep custom lineup length in sync when seat count changes.
    if (seatCount != null && customArchetypes == null) {
      final needed = (nextSeats - 1).clamp(1, 8);
      final pool = ArchetypeRoster.villainPool;
      nextCustom = [
        for (var i = 0; i < needed; i++)
          i < this.customArchetypes.length
              ? this.customArchetypes[i]
              : pool[i % pool.length],
      ];
    }
    return GameSettingsModel(
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      seatCount: nextSeats,
      stackDepthBb: stackDepthBb ?? this.stackDepthBb,
      autoRebuy: autoRebuy ?? this.autoRebuy,
      rebuyThresholdBb: rebuyThresholdBb ?? this.rebuyThresholdBb,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      chipDisplayMode: chipDisplayMode ?? this.chipDisplayMode,
      lineupMode: lineupMode ?? this.lineupMode,
      customArchetypes: nextCustom,
    );
  }

  Map<String, Object?> toPrefsMap() => {
        'smallBlind': smallBlind,
        'bigBlind': bigBlind,
        'seatCount': seatCount,
        'stackDepthBb': stackDepthBb,
        'autoRebuy': autoRebuy,
        'rebuyThresholdBb': rebuyThresholdBb,
        'sfxEnabled': sfxEnabled,
        'ttsEnabled': ttsEnabled,
        'musicEnabled': musicEnabled,
        'chipDisplayMode': chipDisplayMode.name,
        'lineupMode': lineupMode.name,
        'customArchetypes':
            customArchetypes.map((a) => a.id).join(','),
      };

  static GameSettingsModel fromPrefs(Map<String, Object?> prefs) {
    final lineup = prefs['lineupMode'] as String?;
    final chipMode = prefs['chipDisplayMode'] as String?;
    final archetypesRaw = prefs['customArchetypes'] as String? ?? '';
    final archetypes = archetypesRaw.isEmpty
        ? <PlayerArchetype>[]
        : archetypesRaw
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(PlayerArchetype.fromLabel)
            .toList();
    return GameSettingsModel(
      smallBlind: (prefs['smallBlind'] as num?)?.toDouble() ??
          PokerConstants.defaultSmallBlind,
      bigBlind: (prefs['bigBlind'] as num?)?.toDouble() ??
          PokerConstants.defaultBigBlind,
      seatCount:
          prefs['seatCount'] as int? ?? PokerConstants.defaultSeatCount,
      stackDepthBb:
          prefs['stackDepthBb'] as int? ?? PokerConstants.defaultStackBb,
      autoRebuy:
          prefs['autoRebuy'] as bool? ?? PokerConstants.defaultAutoRebuy,
      rebuyThresholdBb: prefs['rebuyThresholdBb'] as int? ??
          PokerConstants.defaultRebuyThresholdBb,
      sfxEnabled:
          prefs['sfxEnabled'] as bool? ?? PokerConstants.defaultSfxEnabled,
      ttsEnabled:
          prefs['ttsEnabled'] as bool? ?? PokerConstants.defaultTtsEnabled,
      musicEnabled:
          prefs['musicEnabled'] as bool? ?? PokerConstants.defaultMusicEnabled,
      chipDisplayMode: ChipDisplayMode.values.firstWhere(
        (m) => m.name == chipMode,
        orElse: () => ChipDisplayMode.both,
      ),
      lineupMode: lineup == LineupMode.custom.name
          ? LineupMode.custom
          : LineupMode.randomPool,
      customArchetypes: archetypes,
    );
  }
}
