/// Computes the hero's own poker statistics and playing-style archetype.
///
/// This engine is deliberately pure: it takes [HeroHandSample]s and returns a
/// [HeroMetrics] snapshot, with no database, clock, or network involved. The
/// two rules it enforces everywhere:
///
/// * a rate is only ever reported alongside the sample it came from, and
/// * below [StyleThresholds.minHands] the hero gets no style label at all,
///   because a confident "you are a calling station" after nine hands is
///   worse than saying nothing.
library;

import 'dart:math' as math;

import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Streets on which the hero can make a betting decision.
const List<Street> _bettingStreets = [
  Street.preflop,
  Street.flop,
  Street.turn,
  Street.river,
];

const List<Street> _postflopStreets = [
  Street.flop,
  Street.turn,
  Street.river,
];

/// Derives hero metrics, style, and leaks from a hand history.
class HeroProfiler {
  HeroProfiler._();

  /// Hands needed before the trend chart is drawn.
  static const int minTrendHands = 10;

  /// Rolling window used by the VPIP trend.
  static const int trendWindow = 20;

  /// Maximum points plotted on the trend chart.
  static const int maxTrendPoints = 24;

  /// Number of leaks surfaced to the UI and the AI prompt.
  static const int maxLeaks = 5;

  /// Computes the full profile for [hands].
  ///
  /// [hands] may arrive in any order; they are sorted oldest-first internally
  /// so the trend line always reads left to right.
  static HeroMetrics compute(
    List<HeroHandSample> hands, {
    DateTime? computedAt,
  }) {
    if (hands.isEmpty) return HeroMetrics.empty();

    final ordered = [...hands]..sort((a, b) {
      final byTime = a.playedAt.compareTo(b.playedAt);
      return byTime != 0 ? byTime : a.handId.compareTo(b.handId);
    });

    final counts = _Counters();
    for (final hand in ordered) {
      _accumulate(hand, counts);
    }

    final samples = counts.toSamples(ordered.length);
    final streets = counts.streetTendencies();
    final archetypes = counts.archetypeTendencies();
    final style = classify(
      handsPlayed: ordered.length,
      vpip: samples[HeroMetricId.vpip]!,
      pfr: samples[HeroMetricId.pfr]!,
      aggressionFrequency: samples[HeroMetricId.aggressionFrequency]!,
    );

    return HeroMetrics(
      handsPlayed: ordered.length,
      samples: samples,
      style: style,
      streetTendencies: streets,
      archetypeTendencies: archetypes,
      leaks: leaksFor(
        samples: samples,
        streets: streets,
        archetypes: archetypes,
      ),
      trend: trendFor(ordered),
      netBb: ordered.fold<double>(0, (sum, h) => sum + h.heroNetBb),
      showdowns: counts.showdowns,
      computedAt: computedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Per-hand accumulation
  // ---------------------------------------------------------------------------

  static void _accumulate(HeroHandSample hand, _Counters counts) {
    if (hand.heroVpip) counts.vpip++;
    if (hand.heroRaisedPreflop) counts.pfr++;

    _accumulatePreflop(hand, counts);
    _accumulateStreets(hand, counts);
    _accumulateFlopFlow(hand, counts);
    _accumulateShowdown(hand, counts);
    _accumulateArchetypes(hand, counts);
  }

  static void _accumulatePreflop(HeroHandSample hand, _Counters counts) {
    final preflop = hand.actions
        .where((a) => a.street == Street.preflop)
        .toList(growable: false);

    // 3-bet: the hero's first preflop decision faced exactly one raise.
    var raisesBeforeHero = 0;
    for (final action in preflop) {
      if (action.isHero) {
        if (!action.kind.isDecision) continue;
        if (raisesBeforeHero == 1) {
          counts.threeBetChances++;
          if (action.kind.isAggressive) counts.threeBets++;
        }
        break;
      }
      if (action.kind.isAggressive) raisesBeforeHero++;
    }

    // Fold to 3-bet: the hero raised, got raised back, and had to decide.
    final heroOpen = preflop.indexWhere(
      (a) => a.isHero && a.kind.isAggressive,
    );
    if (heroOpen < 0) return;
    final villainReraise = preflop.indexWhere(
      (a) => !a.isHero && a.kind.isAggressive,
      heroOpen + 1,
    );
    if (villainReraise < 0) return;
    final heroResponse = preflop.indexWhere(
      (a) => a.isHero && a.kind.isDecision,
      villainReraise + 1,
    );
    if (heroResponse < 0) return;
    counts.threeBetFacedChances++;
    if (preflop[heroResponse].kind == HandActionKind.fold) {
      counts.threeBetFolds++;
    }
  }

  static void _accumulateStreets(HeroHandSample hand, _Counters counts) {
    for (final street in _bettingStreets) {
      for (final action in hand.heroActionsOn(street)) {
        if (!action.kind.isDecision) continue;
        counts.street(street).add(action.kind);
      }
    }
  }

  static void _accumulateFlopFlow(HeroHandSample hand, _Counters counts) {
    if (!hand.heroSawFlop) return;
    final flop = hand.actions
        .where((a) => a.street == Street.flop)
        .toList(growable: false);
    final heroFirst = flop.indexWhere((a) => a.isHero && a.kind.isDecision);
    if (heroFirst < 0) return;

    final villainBetFirst = flop
        .take(heroFirst)
        .any((a) => !a.isHero && a.kind.isAggressive);
    final heroWasAggressor = _heroIsPreflopAggressor(hand);

    if (heroWasAggressor && !villainBetFirst) {
      counts.cbetChances++;
      if (flop[heroFirst].kind.isAggressive) counts.cbets++;
    } else if (!heroWasAggressor && villainBetFirst) {
      counts.faceCbetChances++;
      if (flop[heroFirst].kind == HandActionKind.fold) counts.foldToCbets++;
    }
  }

  static void _accumulateShowdown(HeroHandSample hand, _Counters counts) {
    if (!hand.heroSawFlop) return;
    counts.sawFlop++;
    final heroShowedDown = hand.wentToShowdown &&
        !hand.heroDecisions.any((a) => a.kind == HandActionKind.fold);
    if (!heroShowedDown) return;
    counts.showdowns++;
    if (hand.heroWon) counts.showdownWins++;
  }

  static void _accumulateArchetypes(HeroHandSample hand, _Counters counts) {
    for (var i = 0; i < hand.actions.length; i++) {
      final action = hand.actions[i];
      if (!action.isHero || !action.kind.isDecision) continue;
      final villain = hand.villainArchetypeFor(i);
      if (villain == null || villain == PlayerArchetype.hero) continue;
      counts.archetype(villain).add(action.kind);
    }

    // Attribute the hand's result to whoever was driving it.
    final driver = hand.villainArchetypeFor(hand.actions.length);
    if (driver != null && driver != PlayerArchetype.hero) {
      counts.archetype(driver).netBb += hand.heroNetBb;
    }
  }

  /// Whether the hero made the last aggressive preflop action.
  static bool _heroIsPreflopAggressor(HeroHandSample hand) {
    HandActionSample? last;
    for (final action in hand.actions) {
      if (action.street != Street.preflop) break;
      if (action.kind.isAggressive) last = action;
    }
    return last?.isHero ?? false;
  }

  // ---------------------------------------------------------------------------
  // Style classification
  // ---------------------------------------------------------------------------

  /// Assigns a playing style from VPIP, PFR, and postflop aggression.
  ///
  /// The rules run in order and the first match wins; looseness dominates at
  /// the extremes (a 13/10 player is a nit, not a TAG) and the PFR-to-VPIP
  /// ratio decides passive from aggressive everywhere else.
  static StyleReadout classify({
    required int handsPlayed,
    required MetricSample vpip,
    required MetricSample pfr,
    required MetricSample aggressionFrequency,
  }) {
    if (handsPlayed < StyleThresholds.minHands) {
      return StyleReadout(
        style: PlayingStyle.forming,
        confidence: StyleConfidence.insufficient,
        explanation: handsPlayed == 0
            ? 'Play at least ${StyleThresholds.minHands} hands and your '
                'style shows up here.'
            : 'Only $handsPlayed ${handsPlayed == 1 ? 'hand' : 'hands'} '
                'logged. ${StyleThresholds.minHands - handsPlayed} more and '
                'we can name your style.',
        handsPlayed: handsPlayed,
      );
    }

    final vpipPct = vpip.value ?? 0;
    final pfrPct = pfr.value ?? 0;
    final ratio = vpipPct <= 0 ? 0.0 : (pfrPct / vpipPct).clamp(0.0, 1.0);

    final style = _styleFor(vpipPct, ratio);
    final confidence = confidenceFor(handsPlayed);

    return StyleReadout(
      style: style,
      confidence: confidence,
      explanation: _explain(
        style: style,
        vpipPct: vpipPct,
        pfrPct: pfrPct,
        ratio: ratio,
        aggressionFrequency: aggressionFrequency,
      ),
      handsPlayed: handsPlayed,
    );
  }

  static PlayingStyle _styleFor(double vpipPct, double ratio) {
    if (vpipPct < StyleThresholds.nitVpip) return PlayingStyle.nit;
    if (vpipPct < StyleThresholds.tightVpip &&
        ratio < StyleThresholds.passiveRatio) {
      return PlayingStyle.tightPassive;
    }
    if (vpipPct < 28 && ratio >= StyleThresholds.aggressiveRatio) {
      return PlayingStyle.tag;
    }
    if (vpipPct >= StyleThresholds.maniacVpip &&
        ratio >= StyleThresholds.aggressiveRatio) {
      return PlayingStyle.maniac;
    }
    if (vpipPct >= StyleThresholds.looseVpip &&
        ratio >= StyleThresholds.aggressiveRatio) {
      return PlayingStyle.lag;
    }
    if (vpipPct >= 30 && ratio < 0.45) return PlayingStyle.loosePassive;
    if (ratio < StyleThresholds.passiveRatio) return PlayingStyle.loosePassive;
    return PlayingStyle.balanced;
  }

  /// Confidence band for [handsPlayed].
  static StyleConfidence confidenceFor(int handsPlayed) {
    if (handsPlayed < StyleThresholds.minHands) {
      return StyleConfidence.insufficient;
    }
    if (handsPlayed < StyleThresholds.lowConfidenceHands) {
      return StyleConfidence.low;
    }
    if (handsPlayed < StyleThresholds.mediumConfidenceHands) {
      return StyleConfidence.medium;
    }
    return StyleConfidence.high;
  }

  static String _explain({
    required PlayingStyle style,
    required double vpipPct,
    required double pfrPct,
    required double ratio,
    required MetricSample aggressionFrequency,
  }) {
    final v = vpipPct.toStringAsFixed(0);
    final p = pfrPct.toStringAsFixed(0);
    final raisedShare = (ratio * 100).toStringAsFixed(0);
    final afq = aggressionFrequency.reliableValue;
    final afqNote = afq == null
        ? ''
        : ' After the flop you bet or raise ${afq.toStringAsFixed(0)}% of the '
            'time.';

    final core = switch (style) {
      PlayingStyle.nit =>
        'You play only $v% of your hands, so almost every spot is a fold. '
            'That is safe but you are folding away money in position.',
      PlayingStyle.tightPassive =>
        'You play a tight $v% of hands but raise just $p%, so you enter most '
            'pots by calling instead of taking the lead.',
      PlayingStyle.tag =>
        'You play a disciplined $v% of hands and raise $p% of them — '
            '$raisedShare% of the hands you play, you play aggressively.',
      PlayingStyle.lag =>
        'You play a wide $v% of hands and raise $p%, so you are applying real '
            'pressure with a loose range.',
      PlayingStyle.loosePassive =>
        'You play $v% of hands but raise only $p%, so $raisedShare% of the '
            'hands you play come in raising — the rest are limps and calls.',
      PlayingStyle.maniac =>
        'You play $v% of hands and raise $p%. That is close to every hand, '
            'with maximum aggression behind it.',
      PlayingStyle.balanced =>
        'You play $v% of hands and raise $p%, which sits in the middle of '
            'every band — no strong lean yet.',
      PlayingStyle.forming =>
        'Play more hands and your style shows up here.',
    };
    return '$core$afqNote';
  }

  // ---------------------------------------------------------------------------
  // Leaks
  // ---------------------------------------------------------------------------

  /// Ranks the hero's leaks, most severe first, capped at [maxLeaks].
  static List<ProfileLeak> leaksFor({
    required Map<HeroMetricId, MetricSample> samples,
    required List<StreetTendency> streets,
    required List<ArchetypeTendency> archetypes,
  }) {
    final leaks = <ProfileLeak>[];

    void add(String title, String detail, double severity) {
      leaks.add(
        ProfileLeak(
          title: title,
          detail: detail,
          severity: severity.clamp(0.0, 1.0),
        ),
      );
    }

    double? reliable(HeroMetricId id) => samples[id]?.reliableValue;

    final vpip = reliable(HeroMetricId.vpip);
    final pfr = reliable(HeroMetricId.pfr);
    final afq = reliable(HeroMetricId.aggressionFrequency);
    final wtsd = reliable(HeroMetricId.wtsd);
    final foldCbet = reliable(HeroMetricId.foldToCbet);
    final cbet = reliable(HeroMetricId.cbet);
    final foldThreeBet = reliable(HeroMetricId.foldToThreeBet);
    final threeBet = reliable(HeroMetricId.threeBet);
    final wsd = reliable(HeroMetricId.showdownWin);

    if (vpip != null && vpip > 34) {
      add(
        'Playing too many hands',
        'You are voluntarily in ${vpip.toStringAsFixed(0)}% of pots. Fold the '
            'weak suited gappers and offsuit broadways from early seats.',
        0.55 + (vpip - 34) / 60,
      );
    }
    if (vpip != null && vpip < 16) {
      add(
        'Folding too much preflop',
        'At ${vpip.toStringAsFixed(0)}% VPIP you are waiting for premiums. '
            'Open more suited connectors and broadways from late position.',
        0.45 + (16 - vpip) / 40,
      );
    }
    if (vpip != null && pfr != null && vpip >= 18 && pfr / vpip < 0.45) {
      add(
        'Too many limps and calls',
        'Only ${(pfr / vpip * 100).toStringAsFixed(0)}% of the hands you play '
            'come in raising. Raise or fold — limping gives away the lead.',
        0.6 + (0.45 - pfr / vpip),
      );
    }
    if (afq != null && afq < 28) {
      add(
        'Passive after the flop',
        'You bet or raise only ${afq.toStringAsFixed(0)}% of postflop '
            'decisions, so you win small pots and lose big ones.',
        0.5 + (28 - afq) / 50,
      );
    }
    if (wtsd != null && wtsd > 38) {
      add(
        'Calling down too light',
        'You take ${wtsd.toStringAsFixed(0)}% of flops to showdown. Let go of '
            'weak pairs when the story says you are beaten.',
        0.5 + (wtsd - 38) / 45,
      );
    }
    if (wsd != null && wsd < 45 && (wtsd ?? 0) > 30) {
      add(
        'Showing up with second best',
        'You win only ${wsd.toStringAsFixed(0)}% of showdowns. The hands you '
            'are calling with are not strong enough to get to the river.',
        0.5 + (45 - wsd) / 60,
      );
    }
    if (foldCbet != null && foldCbet > 62) {
      add(
        'Folding the flop too often',
        'You fold ${foldCbet.toStringAsFixed(0)}% of flop bets. Float with '
            'backdoor equity so opponents cannot bet every board.',
        0.4 + (foldCbet - 62) / 60,
      );
    }
    if (cbet != null && cbet < 45) {
      add(
        'Not following through',
        'You raise preflop then bet only ${cbet.toStringAsFixed(0)}% of '
            'flops. Take the initiative you paid for.',
        0.35 + (45 - cbet) / 70,
      );
    }
    if (foldThreeBet != null && foldThreeBet > 70) {
      add(
        'Giving up to 3-bets',
        'You fold ${foldThreeBet.toStringAsFixed(0)}% of the time when raised '
            'back. Defend your best opens instead of folding for free.',
        0.35 + (foldThreeBet - 70) / 70,
      );
    }
    if (threeBet != null && threeBet < 3) {
      add(
        'Never 3-betting',
        'You 3-bet just ${threeBet.toStringAsFixed(1)}%. Without re-raises '
            'the table can open into you all night.',
        0.35,
      );
    }

    for (final street in streets) {
      final note = street.note;
      if (note == null || street.street == Street.preflop) continue;
      add(
        '${_streetLabel(street.street)}: $note',
        _streetLeakDetail(street, note),
        0.3 + street.decisions / 400,
      );
    }

    for (final tendency in archetypes) {
      final note = tendency.note;
      if (note == null) continue;
      add('vs ${tendency.archetype.label}', note, 0.32);
    }

    leaks.sort((a, b) => b.severity.compareTo(a.severity));
    return List.unmodifiable(leaks.take(maxLeaks));
  }

  static String _streetLeakDetail(StreetTendency street, String note) {
    final label = _streetLabel(street.street).toLowerCase();
    return switch (note) {
      'over-folding' =>
        'You fold ${street.foldPct.toStringAsFixed(0)}% of your $label '
            'decisions. Pick a few more hands to continue with.',
      'over-calling' =>
        'You call ${street.callPct.toStringAsFixed(0)}% of your $label '
            'decisions. Turn the strong ones into raises.',
      'too passive' =>
        'Only ${street.aggressionPct.toStringAsFixed(0)}% of your $label '
            'decisions are bets or raises.',
      _ =>
        '${street.aggressionPct.toStringAsFixed(0)}% of your $label decisions '
            'are bets or raises, which is more than the board supports.',
    };
  }

  static String _streetLabel(Street street) =>
      street.name[0].toUpperCase() + street.name.substring(1);

  // ---------------------------------------------------------------------------
  // Trend
  // ---------------------------------------------------------------------------

  /// Rolling-VPIP trend over [ordered] (oldest first).
  static List<TrendPoint> trendFor(List<HeroHandSample> ordered) {
    if (ordered.length < minTrendHands) return const [];
    final flags = ordered
        .map((h) => h.heroVpip ? 1 : 0)
        .toList(growable: false);

    final firstEnd = math.min(trendWindow, flags.length);
    final remaining = flags.length - firstEnd;
    final step = remaining <= 0
        ? 1
        : math.max(1, (remaining / (maxTrendPoints - 1)).ceil());

    final points = <TrendPoint>[];
    for (var end = firstEnd; end <= flags.length; end += step) {
      points.add(_trendPoint(flags, end));
    }
    if (points.last.handsPlayed != flags.length) {
      points.add(_trendPoint(flags, flags.length));
    }
    return List.unmodifiable(points);
  }

  static TrendPoint _trendPoint(List<int> flags, int end) {
    final start = math.max(0, end - trendWindow);
    var sum = 0;
    for (var i = start; i < end; i++) {
      sum += flags[i];
    }
    return TrendPoint(
      handsPlayed: end,
      vpipPct: sum / (end - start) * 100,
    );
  }
}

/// Mutable tally used while walking the hand history.
class _Counters {
  int vpip = 0;
  int pfr = 0;
  int threeBets = 0;
  int threeBetChances = 0;
  int threeBetFolds = 0;
  int threeBetFacedChances = 0;
  int cbets = 0;
  int cbetChances = 0;
  int foldToCbets = 0;
  int faceCbetChances = 0;
  int sawFlop = 0;
  int showdowns = 0;
  int showdownWins = 0;

  final Map<Street, _ActionTally> _streets = {};
  final Map<PlayerArchetype, _ActionTally> _archetypes = {};

  _ActionTally street(Street street) =>
      _streets.putIfAbsent(street, _ActionTally.new);

  _ActionTally archetype(PlayerArchetype archetype) =>
      _archetypes.putIfAbsent(archetype, _ActionTally.new);

  /// Postflop bets and raises.
  int get postflopAggressive => _postflop((t) => t.aggressive);

  /// Postflop calls.
  int get postflopCalls => _postflop((t) => t.calls);

  /// Postflop folds.
  int get postflopFolds => _postflop((t) => t.folds);

  /// Aggression-frequency denominator: bets, raises, calls, and folds.
  /// Checks are excluded because a check is usually the board's decision, not
  /// the player's.
  int get postflopWeighted =>
      postflopAggressive + postflopCalls + postflopFolds;

  int _postflop(int Function(_ActionTally) read) {
    var total = 0;
    for (final street in _postflopStreets) {
      final tally = _streets[street];
      if (tally != null) total += read(tally);
    }
    return total;
  }

  Map<HeroMetricId, MetricSample> toSamples(int handsPlayed) {
    return {
      HeroMetricId.vpip: MetricSample(
        id: HeroMetricId.vpip,
        made: vpip,
        opportunities: handsPlayed,
      ),
      HeroMetricId.pfr: MetricSample(
        id: HeroMetricId.pfr,
        made: pfr,
        opportunities: handsPlayed,
      ),
      HeroMetricId.threeBet: MetricSample(
        id: HeroMetricId.threeBet,
        made: threeBets,
        opportunities: threeBetChances,
      ),
      HeroMetricId.foldToThreeBet: MetricSample(
        id: HeroMetricId.foldToThreeBet,
        made: threeBetFolds,
        opportunities: threeBetFacedChances,
      ),
      HeroMetricId.aggressionFrequency: MetricSample(
        id: HeroMetricId.aggressionFrequency,
        made: postflopAggressive,
        opportunities: postflopWeighted,
      ),
      HeroMetricId.aggressionFactor: MetricSample(
        id: HeroMetricId.aggressionFactor,
        made: postflopAggressive,
        opportunities: postflopCalls,
        sampleSizeOverride: postflopWeighted,
      ),
      HeroMetricId.wtsd: MetricSample(
        id: HeroMetricId.wtsd,
        made: showdowns,
        opportunities: sawFlop,
      ),
      HeroMetricId.cbet: MetricSample(
        id: HeroMetricId.cbet,
        made: cbets,
        opportunities: cbetChances,
      ),
      HeroMetricId.foldToCbet: MetricSample(
        id: HeroMetricId.foldToCbet,
        made: foldToCbets,
        opportunities: faceCbetChances,
      ),
      HeroMetricId.showdownWin: MetricSample(
        id: HeroMetricId.showdownWin,
        made: showdownWins,
        opportunities: showdowns,
      ),
    };
  }

  List<StreetTendency> streetTendencies() {
    return List.unmodifiable([
      for (final street in _bettingStreets)
        if (_streets[street] case final tally?)
          StreetTendency(
            street: street,
            decisions: tally.decisions,
            aggressive: tally.aggressive,
            calls: tally.calls,
            folds: tally.folds,
            checks: tally.checks,
          ),
    ]);
  }

  List<ArchetypeTendency> archetypeTendencies() {
    final rows = [
      for (final entry in _archetypes.entries)
        ArchetypeTendency(
          archetype: entry.key,
          decisions: entry.value.decisions,
          aggressive: entry.value.aggressive,
          calls: entry.value.calls,
          folds: entry.value.folds,
          netBb: entry.value.netBb,
        ),
    ]..sort((a, b) => b.decisions.compareTo(a.decisions));
    return List.unmodifiable(rows);
  }
}

class _ActionTally {
  int decisions = 0;
  int aggressive = 0;
  int calls = 0;
  int folds = 0;
  int checks = 0;
  double netBb = 0;

  void add(HandActionKind kind) {
    decisions++;
    switch (kind) {
      case HandActionKind.bet:
      case HandActionKind.raise:
      case HandActionKind.allIn:
        aggressive++;
      case HandActionKind.call:
        calls++;
      case HandActionKind.fold:
        folds++;
      case HandActionKind.check:
        checks++;
      case HandActionKind.blind:
        decisions--;
    }
  }
}
