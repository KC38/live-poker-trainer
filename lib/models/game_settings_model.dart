/// User-configurable gameplay and audio preferences.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Lineup selection mode on the Home screen.
enum LineupMode { randomPool, custom }

/// Persistent settings for live table setup, display, SFX, and music.
@immutable
class GameSettingsModel {
  /// Creates game settings with plan defaults.
  const GameSettingsModel({
    this.smallBlind = PokerConstants.defaultSmallBlind,
    this.bigBlind = PokerConstants.defaultBigBlind,
    this.seatCount = PokerConstants.defaultSeatCount,
    int? maxStackDepthBb,
    @Deprecated('Use maxStackDepthBb') int? stackDepthBb,
    this.sfxEnabled = PokerConstants.defaultSfxEnabled,
    this.musicEnabled = PokerConstants.defaultMusicEnabled,
    this.chipDisplayMode = ChipDisplayMode.both,
    this.lineupMode = LineupMode.randomPool,
    this.customArchetypes = const [],
  }) : maxStackDepthBb =
           maxStackDepthBb ?? stackDepthBb ?? PokerConstants.defaultStackBb;

  final double smallBlind;
  final double bigBlind;
  final int seatCount;
  final int maxStackDepthBb;
  final bool sfxEnabled;

  /// Home / lounge ambient loop; independent of table SFX.
  final bool musicEnabled;
  final ChipDisplayMode chipDisplayMode;
  final LineupMode lineupMode;
  final List<PlayerArchetype> customArchetypes;

  double get startingStack => maxStackDepthBb * bigBlind;

  /// Legacy compatibility for the dormant local poker engine.
  @Deprecated('Use maxStackDepthBb')
  int get stackDepthBb => maxStackDepthBb;

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
    int? maxStackDepthBb,
    @Deprecated('Use maxStackDepthBb') int? stackDepthBb,
    bool? sfxEnabled,
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
      maxStackDepthBb: maxStackDepthBb ?? stackDepthBb ?? this.maxStackDepthBb,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
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
    'maxStackDepthBb': maxStackDepthBb,
    'sfxEnabled': sfxEnabled,
    'musicEnabled': musicEnabled,
    'chipDisplayMode': chipDisplayMode.name,
    'lineupMode': lineupMode.name,
    'customArchetypes': customArchetypes.map((a) => a.id).join(','),
  };

  static GameSettingsModel fromPrefs(Map<String, Object?> prefs) {
    final lineup = prefs['lineupMode'] as String?;
    final chipMode = prefs['chipDisplayMode'] as String?;
    final archetypesRaw = prefs['customArchetypes'] as String? ?? '';
    final archetypes =
        archetypesRaw.isEmpty
            ? <PlayerArchetype>[]
            : archetypesRaw
                .split(',')
                .where((s) => s.isNotEmpty)
                .map(PlayerArchetype.fromLabel)
                .toList();
    return GameSettingsModel(
      smallBlind:
          (prefs['smallBlind'] as num?)?.toDouble() ??
          PokerConstants.defaultSmallBlind,
      bigBlind:
          (prefs['bigBlind'] as num?)?.toDouble() ??
          PokerConstants.defaultBigBlind,
      seatCount:
          (prefs['seatCount'] as num?)?.toInt() ??
          PokerConstants.defaultSeatCount,
      maxStackDepthBb:
          (prefs['maxStackDepthBb'] as num?)?.toInt() ??
          (prefs['stackDepthBb'] as num?)?.toInt() ??
          PokerConstants.defaultStackBb,
      sfxEnabled:
          prefs['sfxEnabled'] as bool? ?? PokerConstants.defaultSfxEnabled,
      musicEnabled:
          prefs['musicEnabled'] as bool? ?? PokerConstants.defaultMusicEnabled,
      chipDisplayMode: ChipDisplayMode.values.firstWhere(
        (m) => m.name == chipMode,
        orElse: () => ChipDisplayMode.both,
      ),
      lineupMode:
          lineup == LineupMode.custom.name
              ? LineupMode.custom
              : LineupMode.randomPool,
      customArchetypes: archetypes,
    );
  }

  /// Prefs keys that stay device-local (SharedPreferences only).
  static const Set<String> audioPrefKeys = {'sfxEnabled', 'musicEnabled'};

  /// Firestore `preferences` map — gameplay only; audio stays on-device.
  Map<String, Object?> toFirestorePreferences() {
    final map = Map<String, Object?>.from(toPrefsMap());
    for (final key in audioPrefKeys) {
      map.remove(key);
    }
    return map;
  }

  /// Hydrates gameplay prefs from Firestore, keeping [localAudio] SFX/music.
  static GameSettingsModel fromFirestorePreferences(
    Map<String, dynamic> data, {
    GameSettingsModel localAudio = const GameSettingsModel(),
  }) {
    final merged = <String, Object?>{
      ...data,
      'sfxEnabled': localAudio.sfxEnabled,
      'musicEnabled': localAudio.musicEnabled,
    };
    // Firestore may store customArchetypes as a List.
    final rawArch = data['customArchetypes'];
    if (rawArch is List) {
      merged['customArchetypes'] = rawArch.map((e) => e.toString()).join(',');
    }
    return GameSettingsModel.fromPrefs(merged);
  }

  /// Merges remote gameplay prefs onto this instance (audio unchanged).
  GameSettingsModel mergeRemotePreferences(GameSettingsModel remote) {
    return remote.copyWith(sfxEnabled: sfxEnabled, musicEnabled: musicEnabled);
  }
}
