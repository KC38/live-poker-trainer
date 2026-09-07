/// User-configurable gameplay and audio preferences.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Lineup selection mode on the Home screen.
enum LineupMode { randomPool, custom }

/// Persistent settings for blinds, stack, rebuy, SFX, and TTS.
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
    this.lineupMode = LineupMode.randomPool,
    this.customArchetypes = const [],
    this.geminiKeyOverride = '',
  });

  final double smallBlind;
  final double bigBlind;
  final int seatCount;
  final int stackDepthBb;
  final bool autoRebuy;
  final int rebuyThresholdBb;
  final bool sfxEnabled;
  final bool ttsEnabled;
  final LineupMode lineupMode;
  final List<PlayerArchetype> customArchetypes;
  final String geminiKeyOverride;

  double get startingStack => stackDepthBb * bigBlind;

  GameSettingsModel copyWith({
    double? smallBlind,
    double? bigBlind,
    int? seatCount,
    int? stackDepthBb,
    bool? autoRebuy,
    int? rebuyThresholdBb,
    bool? sfxEnabled,
    bool? ttsEnabled,
    LineupMode? lineupMode,
    List<PlayerArchetype>? customArchetypes,
    String? geminiKeyOverride,
  }) {
    return GameSettingsModel(
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      seatCount: seatCount ?? this.seatCount,
      stackDepthBb: stackDepthBb ?? this.stackDepthBb,
      autoRebuy: autoRebuy ?? this.autoRebuy,
      rebuyThresholdBb: rebuyThresholdBb ?? this.rebuyThresholdBb,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      lineupMode: lineupMode ?? this.lineupMode,
      customArchetypes: customArchetypes ?? this.customArchetypes,
      geminiKeyOverride: geminiKeyOverride ?? this.geminiKeyOverride,
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
        'lineupMode': lineupMode.name,
        'customArchetypes':
            customArchetypes.map((a) => a.id).join(','),
        'geminiKeyOverride': geminiKeyOverride,
      };

  static GameSettingsModel fromPrefs(Map<String, Object?> prefs) {
    final lineup = prefs['lineupMode'] as String?;
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
      lineupMode: lineup == LineupMode.custom.name
          ? LineupMode.custom
          : LineupMode.randomPool,
      customArchetypes: archetypes,
      geminiKeyOverride: prefs['geminiKeyOverride'] as String? ?? '',
    );
  }
}
