/// Visible bounded tendency data for one modeled live opponent.
library;

import 'package:flutter/foundation.dart';

/// Modeled statistics and plain-language reads shown on villain profile tap.
@immutable
class TendencyProfileModel {
  /// Creates a visible tendency profile.
  const TendencyProfileModel({
    required this.profileVersion,
    required this.archetype,
    required this.vpip,
    required this.pfr,
    required this.threeBet,
    required this.aggression,
    required this.foldToFlopBet,
    required this.foldToTurnBet,
    required this.foldToRiverBet,
    required this.bluffRiver,
    required this.showdownCall,
    required this.sizingTellStrength,
    required this.confidence,
    required this.reads,
  });

  final String profileVersion;
  final String archetype;
  final double vpip;
  final double pfr;
  final double threeBet;
  final double aggression;
  final double foldToFlopBet;
  final double foldToTurnBet;
  final double foldToRiverBet;
  final double bluffRiver;
  final double showdownCall;
  final double sizingTellStrength;
  final String confidence;
  final List<String> reads;

  /// Parses a server-authored bounded profile.
  factory TendencyProfileModel.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return TendencyProfileModel(
      profileVersion: json['profileVersion'] as String? ?? '',
      archetype: json['archetype'] as String? ?? '',
      vpip: number('vpip'),
      pfr: number('pfr'),
      threeBet: number('threeBet'),
      aggression: number('aggression'),
      foldToFlopBet: number('foldToFlopBet'),
      foldToTurnBet: number('foldToTurnBet'),
      foldToRiverBet: number('foldToRiverBet'),
      bluffRiver: number('bluffRiver'),
      showdownCall: number('showdownCall'),
      sizingTellStrength: number('sizingTellStrength'),
      confidence: json['confidence'] as String? ?? 'medium',
      reads: (json['reads'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }
}
