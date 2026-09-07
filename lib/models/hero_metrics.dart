/// The hero's own poker statistics, playing-style archetype, and leaks.
///
/// Every number here is a [MetricSample]: a numerator, a denominator, and the
/// sample size needed before the number means anything. A screen must never
/// print a rate whose [MetricSample.hasEnoughData] is false — with eight
/// opportunities a 3-bet percentage is noise, and showing "12.5%" would teach
/// the player something untrue about themselves.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// How a metric should be rendered.
enum MetricFormat {
  /// `0`–`100`, printed with a `%`.
  percent,

  /// An unbounded ratio, printed with one decimal.
  ratio,
}

/// Where a metric sits relative to a healthy live-cash band.
enum MetricVerdict {
  /// Below the healthy band.
  low,

  /// Inside the healthy band.
  healthy,

  /// Above the healthy band.
  high,

  /// Not enough hands to judge.
  unknown,
}

/// The metrics shown on the profile, with beginner-facing teaching copy.
///
/// The healthy bands are live low-stakes full-ring reference points, not GTO
/// solutions — they exist so a new player can see "mine is 46, healthy is
/// 20–32" and know which direction to move.
enum HeroMetricId {
  vpip(
    shortLabel: 'VPIP',
    label: 'Hands played',
    helper: 'How often you put money in preflop instead of folding. Solid '
        'live players sit around 20–30%. Much higher means you are paying to '
        'see flops with hands that cannot win.',
    minSample: 20,
    healthyLow: 20,
    healthyHigh: 32,
  ),
  pfr(
    shortLabel: 'PFR',
    label: 'Preflop raise',
    helper: 'How often you raise first in preflop. Raising takes the lead in '
        'the hand; limping hands it to someone else. Most of your played '
        'hands should be raises.',
    minSample: 20,
    healthyLow: 14,
    healthyHigh: 24,
  ),
  threeBet(
    shortLabel: '3B',
    label: '3-bet',
    helper: 'When someone raises before you, this is how often you raise them '
        'back. Never 3-betting makes you easy to run over.',
    minSample: 12,
    healthyLow: 5,
    healthyHigh: 11,
  ),
  foldToThreeBet(
    shortLabel: 'F3B',
    label: 'Fold to 3-bet',
    helper: 'You raised, someone raised you back, and you folded. Folding '
        'almost always means anyone can re-raise you for free.',
    minSample: 10,
    healthyLow: 40,
    healthyHigh: 65,
  ),
  aggressionFrequency(
    shortLabel: 'AFq',
    label: 'Aggression',
    helper: 'Of all your decisions after the flop, how many were bets or '
        'raises. Passive players drift under 30% and only win small pots.',
    minSample: 25,
    healthyLow: 33,
    healthyHigh: 55,
  ),
  aggressionFactor(
    shortLabel: 'AF',
    label: 'Aggression factor',
    helper: 'Bets and raises divided by calls after the flop. Around 2 is '
        'balanced; under 1 means you call far more than you bet.',
    minSample: 25,
    healthyLow: 1.5,
    healthyHigh: 3.5,
    format: MetricFormat.ratio,
  ),
  wtsd(
    shortLabel: 'WTSD',
    label: 'Went to showdown',
    helper: 'Once you see a flop, how often you pay to see the last card. '
        'Above 35% usually means you are calling down too light.',
    minSample: 15,
    healthyLow: 24,
    healthyHigh: 34,
  ),
  cbet(
    shortLabel: 'CB',
    label: 'Continuation bet',
    helper: 'You raised preflop and then bet the flop. Following through is '
        'how preflop aggression actually wins pots.',
    minSample: 10,
    healthyLow: 50,
    healthyHigh: 75,
  ),
  foldToCbet(
    shortLabel: 'FvCB',
    label: 'Fold to c-bet',
    helper: 'You called preflop, missed, and folded to their flop bet. Over '
        '60% and observant opponents can bet every flop against you.',
    minSample: 10,
    healthyLow: 40,
    healthyHigh: 58,
  ),
  showdownWin(
    shortLabel: r'W$SD',
    label: 'Won at showdown',
    helper: 'How often you win the hands you take to the end. Low numbers '
        'mean you are showing up with the second-best hand too often.',
    minSample: 12,
    healthyLow: 48,
    healthyHigh: 62,
  );

  const HeroMetricId({
    required this.shortLabel,
    required this.label,
    required this.helper,
    required this.minSample,
    required this.healthyLow,
    required this.healthyHigh,
    this.format = MetricFormat.percent,
  });

  /// Compact label for a stat tile (`VPIP`).
  final String shortLabel;

  /// Plain-English name (`Hands played`).
  final String label;

  /// Teach-first explanation shown under the number.
  final String helper;

  /// Opportunities required before the rate is shown at all.
  final int minSample;

  /// Inclusive lower edge of the healthy band.
  final double healthyLow;

  /// Inclusive upper edge of the healthy band.
  final double healthyHigh;

  final MetricFormat format;
}

/// A rate plus the sample it was measured over.
@immutable
class MetricSample {
  /// Creates a sample.
  ///
  /// [sampleSizeOverride] defaults to [opportunities] and only needs to be set for
  /// ratio metrics, whose denominator (calls) is not the thing that decides
  /// whether the number is trustworthy — the total decision count is.
  const MetricSample({
    required this.id,
    required this.made,
    required this.opportunities,
    this.sampleSizeOverride,
  });

  /// An empty sample for [id].
  const MetricSample.empty(this.id)
      : made = 0,
        opportunities = 0,
        sampleSizeOverride = null;

  final HeroMetricId id;

  /// Times the tracked thing happened (the numerator).
  final int made;

  /// Times it could have happened (the denominator).
  final int opportunities;

  /// Set only when the ratio denominator is not the trustworthiness signal.
  final int? sampleSizeOverride;

  /// Observations behind this number.
  int get sampleSize => sampleSizeOverride ?? opportunities;

  /// Whether the sample is big enough to quote.
  bool get hasEnoughData => sampleSize >= id.minSample;

  /// Ratio metrics are capped here so a player who never calls does not get an
  /// infinite aggression factor.
  static const double maxRatio = 10;

  /// The raw rate (percent, or a ratio for [MetricFormat.ratio]), or null when
  /// nothing was observed at all.
  double? get value {
    if (sampleSize == 0) return null;
    if (id.format == MetricFormat.ratio) {
      if (made == 0) return 0;
      if (opportunities == 0) return maxRatio;
      return (made / opportunities).clamp(0.0, maxRatio);
    }
    if (opportunities == 0) return null;
    return made / opportunities * 100;
  }

  /// The rate, only when [hasEnoughData].
  double? get reliableValue => hasEnoughData ? value : null;

  /// How many more observations are needed before the rate is shown.
  int get opportunitiesNeeded =>
      (id.minSample - sampleSize).clamp(0, id.minSample);

  /// Position relative to the healthy band.
  MetricVerdict get verdict {
    final v = reliableValue;
    if (v == null) return MetricVerdict.unknown;
    if (v < id.healthyLow) return MetricVerdict.low;
    if (v > id.healthyHigh) return MetricVerdict.high;
    return MetricVerdict.healthy;
  }

  /// Formatted value, or `—` when the sample is too small.
  String get display {
    final v = reliableValue;
    if (v == null) return '—';
    return switch (id.format) {
      MetricFormat.percent => '${v.toStringAsFixed(v >= 100 ? 0 : 1)}%',
      MetricFormat.ratio => v.toStringAsFixed(1),
    };
  }

  /// Sample footnote, e.g. `12 of 48` or `over 31 decisions`.
  String get sampleLabel => switch (id.format) {
        MetricFormat.percent => '$made of $opportunities',
        MetricFormat.ratio => 'over $sampleSize decisions',
      };

  /// Serializes to the snapshot JSON stored on the profile row.
  Map<String, dynamic> toJson() => {
        'made': made,
        'opportunities': opportunities,
        if (sampleSizeOverride != null) 'sampleSize': sampleSizeOverride,
      };

  /// Reads a sample written by [toJson].
  static MetricSample fromJson(HeroMetricId id, Map<String, dynamic> json) {
    return MetricSample(
      id: id,
      made: (json['made'] as num?)?.toInt() ?? 0,
      opportunities: (json['opportunities'] as num?)?.toInt() ?? 0,
      sampleSizeOverride: (json['sampleSize'] as num?)?.toInt(),
    );
  }
}

/// Hero behaviour on one street.
@immutable
class StreetTendency {
  /// Creates a street tendency.
  const StreetTendency({
    required this.street,
    required this.decisions,
    required this.aggressive,
    required this.calls,
    required this.folds,
    required this.checks,
  });

  final Street street;

  /// Total hero decisions on this street.
  final int decisions;
  final int aggressive;
  final int calls;
  final int folds;
  final int checks;

  /// Minimum decisions before a tendency note is shown.
  static const int minDecisions = 12;

  bool get hasEnoughData => decisions >= minDecisions;

  double get aggressionPct => decisions == 0 ? 0 : aggressive / decisions * 100;
  double get callPct => decisions == 0 ? 0 : calls / decisions * 100;
  double get foldPct => decisions == 0 ? 0 : folds / decisions * 100;

  /// Short label such as `over-folding`, or null when balanced / unproven.
  String? get note {
    if (!hasEnoughData) return null;
    if (foldPct > 55) return 'over-folding';
    if (callPct > 48) return 'over-calling';
    if (aggressionPct < 20) return 'too passive';
    if (aggressionPct > 65) return 'over-aggressive';
    return null;
  }
}

/// How the hero plays against one villain archetype.
@immutable
class ArchetypeTendency {
  /// Creates an archetype tendency.
  const ArchetypeTendency({
    required this.archetype,
    required this.decisions,
    required this.aggressive,
    required this.calls,
    required this.folds,
    required this.netBb,
  });

  final PlayerArchetype archetype;
  final int decisions;
  final int aggressive;
  final int calls;
  final int folds;

  /// Hero net result in hands driven by this archetype, in big blinds.
  final double netBb;

  /// Minimum decisions before this row is shown as a read.
  static const int minDecisions = 10;

  bool get hasEnoughData => decisions >= minDecisions;

  double get aggressionPct => decisions == 0 ? 0 : aggressive / decisions * 100;
  double get callPct => decisions == 0 ? 0 : calls / decisions * 100;
  double get foldPct => decisions == 0 ? 0 : folds / decisions * 100;

  /// Exploit-aware read, or null when the sample is too small.
  ///
  /// The advice is the standard counter-strategy: you cannot bluff a station,
  /// you cannot fold to a maniac, and you should attack a nit's checks.
  String? get note {
    if (!hasEnoughData) return null;
    return switch (archetype) {
      PlayerArchetype.callingStation when aggressionPct > 55 =>
        'You keep firing at a player who never folds — bet value, not bluffs.',
      PlayerArchetype.callingStation when aggressionPct < 25 =>
        'Stations pay you off. Value-bet them thinner and bigger.',
      PlayerArchetype.nit when callPct > 45 =>
        'You call a nit down too often. Their bets really are strong.',
      PlayerArchetype.nit when aggressionPct < 25 =>
        'Nits fold constantly. Attack their checks more.',
      PlayerArchetype.maniac when foldPct > 55 =>
        'You fold too much to a maniac. Their range is mostly air.',
      PlayerArchetype.lag when foldPct > 55 =>
        'A LAG is applying pressure and you are giving it up. Defend wider.',
      PlayerArchetype.maniac when callPct > 55 =>
        'Against a maniac, raise your strong hands instead of just calling.',
      PlayerArchetype.tag when foldPct > 60 =>
        'You are avoiding the solid regs. Take your thin edges.',
      _ => null,
    };
  }
}

/// A named leak, ordered by how much it is costing.
@immutable
class ProfileLeak {
  /// Creates a leak.
  const ProfileLeak({
    required this.title,
    required this.detail,
    required this.severity,
  });

  /// Short headline, e.g. `Too many limps`.
  final String title;

  /// One-sentence fix.
  final String detail;

  /// `0`–`1`, used only for ordering.
  final double severity;

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'severity': severity,
      };

  /// Reads a leak written by [toJson].
  static ProfileLeak fromJson(Map<String, dynamic> json) => ProfileLeak(
        title: json['title'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        severity: (json['severity'] as num?)?.toDouble() ?? 0,
      );
}

/// One point on the profile trend chart.
@immutable
class TrendPoint {
  /// Creates a trend point.
  const TrendPoint({required this.handsPlayed, required this.vpipPct});

  /// Hands played at this point in the history.
  final int handsPlayed;

  /// Rolling VPIP over the trailing window.
  final double vpipPct;
}

/// How much the style label can be trusted.
enum StyleConfidence {
  /// Fewer than [StyleThresholds.minHands] hands — no label at all.
  insufficient('Needs more hands'),
  low('Low confidence'),
  medium('Fair confidence'),
  high('High confidence');

  const StyleConfidence(this.label);

  final String label;
}

/// Derived playing-style archetype for the hero.
enum PlayingStyle {
  nit(
    label: 'Nit',
    tagline: 'Very tight — you fold almost everything',
    color: PlayerArchetype.nit,
  ),
  tightPassive(
    label: 'Tight-Passive',
    tagline: 'Tight, but you call instead of raising',
    color: PlayerArchetype.nit,
  ),
  tag(
    label: 'TAG',
    tagline: 'Tight-aggressive — the profitable default',
    color: PlayerArchetype.tag,
  ),
  lag(
    label: 'LAG',
    tagline: 'Loose-aggressive — wide and pushing hard',
    color: PlayerArchetype.lag,
  ),
  loosePassive(
    label: 'Loose-Passive',
    tagline: 'Calling-station tendencies — too many calls',
    color: PlayerArchetype.callingStation,
  ),
  maniac(
    label: 'Maniac',
    tagline: 'Extremely wide and extremely aggressive',
    color: PlayerArchetype.maniac,
  ),
  balanced(
    label: 'Balanced',
    tagline: 'No strong lean either way yet',
    color: PlayerArchetype.hero,
  ),
  forming(
    label: 'Still forming',
    tagline: 'Play more hands to unlock your style',
    color: PlayerArchetype.hero,
  );

  const PlayingStyle({
    required this.label,
    required this.tagline,
    required this.color,
  });

  final String label;

  /// One-line plain-English description.
  final String tagline;

  /// Archetype whose accent color represents this style.
  final PlayerArchetype color;
}

/// Sample-size gates for the style label.
class StyleThresholds {
  StyleThresholds._();

  /// Below this, no style is claimed at all.
  static const int minHands = 20;

  /// Below this, the label is marked [StyleConfidence.low].
  static const int lowConfidenceHands = 60;

  /// Below this, the label is marked [StyleConfidence.medium].
  static const int mediumConfidenceHands = 150;

  /// VPIP below this reads as a nit regardless of aggression.
  static const double nitVpip = 15;

  /// VPIP below this is "tight".
  static const double tightVpip = 22;

  /// VPIP at or above this is "loose".
  static const double looseVpip = 32;

  /// VPIP at or above this is "wild".
  static const double maniacVpip = 42;

  /// PFR / VPIP below this reads as passive.
  static const double passiveRatio = 0.40;

  /// PFR / VPIP at or above this reads as aggressive.
  static const double aggressiveRatio = 0.55;
}

/// Style label with its confidence and the reason behind it.
@immutable
class StyleReadout {
  /// Creates a style readout.
  const StyleReadout({
    required this.style,
    required this.confidence,
    required this.explanation,
    required this.handsPlayed,
  });

  /// The readout shown before any hands exist.
  const StyleReadout.forming()
      : style = PlayingStyle.forming,
        confidence = StyleConfidence.insufficient,
        explanation = 'Play at least ${StyleThresholds.minHands} hands and '
            'your style shows up here.',
        handsPlayed = 0;

  final PlayingStyle style;
  final StyleConfidence confidence;

  /// Why this label was chosen, in the player's own numbers.
  final String explanation;

  final int handsPlayed;

  /// Whether a real label was assigned.
  bool get isKnown => confidence != StyleConfidence.insufficient;

  /// Hands still needed before a label is claimed.
  int get handsNeeded =>
      (StyleThresholds.minHands - handsPlayed).clamp(0, StyleThresholds.minHands);

  Map<String, dynamic> toJson() => {
        'style': style.name,
        'confidence': confidence.name,
        'explanation': explanation,
        'handsPlayed': handsPlayed,
      };

  /// Reads a readout written by [toJson].
  static StyleReadout fromJson(Map<String, dynamic> json) => StyleReadout(
        style: PlayingStyle.values.firstWhere(
          (s) => s.name == json['style'],
          orElse: () => PlayingStyle.forming,
        ),
        confidence: StyleConfidence.values.firstWhere(
          (c) => c.name == json['confidence'],
          orElse: () => StyleConfidence.insufficient,
        ),
        explanation: json['explanation'] as String? ?? '',
        handsPlayed: (json['handsPlayed'] as num?)?.toInt() ?? 0,
      );
}

/// The hero's complete computed profile.
@immutable
class HeroMetrics {
  /// Creates a metrics snapshot.
  const HeroMetrics({
    required this.handsPlayed,
    required this.samples,
    required this.style,
    this.streetTendencies = const [],
    this.archetypeTendencies = const [],
    this.leaks = const [],
    this.trend = const [],
    this.netBb = 0,
    this.showdowns = 0,
    this.computedAt,
  });

  /// The empty profile.
  factory HeroMetrics.empty() => HeroMetrics(
        handsPlayed: 0,
        samples: {
          for (final id in HeroMetricId.values) id: MetricSample.empty(id),
        },
        style: const StyleReadout.forming(),
      );

  /// Hands the hero was dealt into.
  final int handsPlayed;

  final Map<HeroMetricId, MetricSample> samples;
  final StyleReadout style;
  final List<StreetTendency> streetTendencies;
  final List<ArchetypeTendency> archetypeTendencies;

  /// Leaks worth coaching, most severe first.
  final List<ProfileLeak> leaks;

  /// Rolling-VPIP trend, oldest first.
  final List<TrendPoint> trend;

  /// Lifetime hero result in big blinds.
  final double netBb;

  /// Hands taken to showdown.
  final int showdowns;

  final DateTime? computedAt;

  bool get isEmpty => handsPlayed == 0;

  /// The sample for [id] (never null).
  MetricSample sample(HeroMetricId id) =>
      samples[id] ?? MetricSample.empty(id);

  /// Compact `24/19` VPIP-over-PFR string, or null when unproven.
  String? get vpipPfrLabel {
    final vpip = sample(HeroMetricId.vpip).reliableValue;
    final pfr = sample(HeroMetricId.pfr).reliableValue;
    if (vpip == null || pfr == null) return null;
    return '${vpip.toStringAsFixed(0)}/${pfr.toStringAsFixed(0)}';
  }

  /// Snapshot JSON persisted on the profile row.
  ///
  /// Street and archetype tendencies are intentionally left out: they are
  /// cheap to recompute from the hand log and would bloat the row. The
  /// snapshot exists so the screen can paint real numbers on first frame and
  /// so the cached AI summary can be invalidated against the hand count.
  Map<String, dynamic> toJson() => {
        'handsPlayed': handsPlayed,
        'netBb': netBb,
        'showdowns': showdowns,
        'style': style.toJson(),
        'samples': {
          for (final entry in samples.entries)
            entry.key.name: entry.value.toJson(),
        },
        'leaks': [for (final leak in leaks) leak.toJson()],
      };

  /// Reads a snapshot written by [toJson].
  static HeroMetrics fromJson(Map<String, dynamic> json) {
    final rawSamples = json['samples'];
    final samples = <HeroMetricId, MetricSample>{};
    for (final id in HeroMetricId.values) {
      final raw = rawSamples is Map ? rawSamples[id.name] : null;
      samples[id] = raw is Map
          ? MetricSample.fromJson(id, Map<String, dynamic>.from(raw))
          : MetricSample.empty(id);
    }
    final rawLeaks = json['leaks'];
    return HeroMetrics(
      handsPlayed: (json['handsPlayed'] as num?)?.toInt() ?? 0,
      samples: samples,
      style: json['style'] is Map
          ? StyleReadout.fromJson(Map<String, dynamic>.from(json['style'] as Map))
          : const StyleReadout.forming(),
      leaks: rawLeaks is List
          ? [
              for (final leak in rawLeaks)
                if (leak is Map)
                  ProfileLeak.fromJson(Map<String, dynamic>.from(leak)),
            ]
          : const [],
      netBb: (json['netBb'] as num?)?.toDouble() ?? 0,
      showdowns: (json['showdowns'] as num?)?.toInt() ?? 0,
    );
  }
}
