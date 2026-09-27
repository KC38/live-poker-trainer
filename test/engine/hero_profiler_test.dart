/// Metric computation and style classification over synthetic hand histories.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Hero seat used by every builder below.
const int _heroSeat = 0;

/// Villain seat used by every builder below.
const int _villainSeat = 3;

int _nextHandId = 1;

HandActionSample _hero(
  Street street,
  HandActionKind kind, {
  double amountBb = 0,
}) => HandActionSample(
  seat: _heroSeat,
  street: street,
  kind: kind,
  isHero: true,
  archetype: PlayerArchetype.hero,
  amountBb: amountBb,
);

HandActionSample _villain(
  Street street,
  HandActionKind kind, {
  double amountBb = 0,
  PlayerArchetype archetype = PlayerArchetype.tag,
}) => HandActionSample(
  seat: _villainSeat,
  street: street,
  kind: kind,
  archetype: archetype,
  amountBb: amountBb,
);

HeroHandSample _hand(
  List<HandActionSample> actions, {
  bool showdown = false,
  bool won = false,
  double netBb = 0,
}) {
  final id = _nextHandId++;
  return HeroHandSample(
    handId: id,
    playedAt: DateTime(2026, 1, 1).add(Duration(minutes: id)),
    actions: actions,
    wentToShowdown: showdown,
    heroWon: won,
    heroNetBb: netBb,
  );
}

/// A hand the hero folds preflop without putting money in voluntarily.
HeroHandSample _foldPreflop() => _hand([
  _hero(Street.preflop, HandActionKind.blind, amountBb: 0.5),
  _villain(Street.preflop, HandActionKind.raise, amountBb: 3),
  _hero(Street.preflop, HandActionKind.fold),
], netBb: -0.5);

/// A hand the hero opens preflop and then c-bets an unraised flop.
HeroHandSample _openAndCbet({bool cbet = true}) => _hand([
  _hero(Street.preflop, HandActionKind.raise, amountBb: 3),
  _villain(Street.preflop, HandActionKind.call, amountBb: 3),
  _hero(
    Street.flop,
    cbet ? HandActionKind.bet : HandActionKind.check,
    amountBb: cbet ? 4 : 0,
  ),
  if (cbet) _villain(Street.flop, HandActionKind.fold),
], netBb: cbet ? 4 : 0);

/// A hand the hero limps in and calls down to showdown.
HeroHandSample _callDownToShowdown({required bool won}) => _hand(
  [
    _villain(Street.preflop, HandActionKind.raise, amountBb: 3),
    _hero(Street.preflop, HandActionKind.call, amountBb: 3),
    _villain(Street.flop, HandActionKind.bet, amountBb: 4),
    _hero(Street.flop, HandActionKind.call, amountBb: 4),
    _villain(Street.turn, HandActionKind.bet, amountBb: 8),
    _hero(Street.turn, HandActionKind.call, amountBb: 8),
    _villain(Street.river, HandActionKind.check),
    _hero(Street.river, HandActionKind.check),
  ],
  showdown: true,
  won: won,
  netBb: won ? 15 : -15,
);

void main() {
  setUp(() => _nextHandId = 1);

  group('preflop rates', () {
    test('VPIP and PFR count voluntary money and raises separately', () {
      // 10 folds, 5 limp-calls, 5 opens => VPIP 50%, PFR 25%.
      final hands = [
        for (var i = 0; i < 10; i++) _foldPreflop(),
        for (var i = 0; i < 5; i++)
          _hand([
            _hero(Street.preflop, HandActionKind.call, amountBb: 1),
            _villain(Street.preflop, HandActionKind.check),
          ]),
        for (var i = 0; i < 5; i++) _openAndCbet(),
      ];

      final metrics = HeroProfiler.compute(hands);

      expect(metrics.handsPlayed, 20);
      expect(metrics.sample(HeroMetricId.vpip).value, closeTo(50, 0.01));
      expect(metrics.sample(HeroMetricId.pfr).value, closeTo(25, 0.01));
    });

    test('posting a blind is not voluntary money', () {
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 20; i++) _foldPreflop(),
      ]);

      expect(metrics.sample(HeroMetricId.vpip).value, 0);
      expect(metrics.sample(HeroMetricId.pfr).value, 0);
    });

    test('3-bet counts only re-raises over an opener', () {
      final threeBets = [
        for (var i = 0; i < 6; i++)
          _hand([
            _villain(Street.preflop, HandActionKind.raise, amountBb: 3),
            _hero(Street.preflop, HandActionKind.raise, amountBb: 10),
            _villain(Street.preflop, HandActionKind.fold),
          ]),
      ];
      // Open-raises facing no opener must not inflate the 3-bet rate.
      final opens = [for (var i = 0; i < 6; i++) _openAndCbet()];

      final metrics = HeroProfiler.compute([...threeBets, ...opens]);
      final threeBet = metrics.sample(HeroMetricId.threeBet);

      expect(threeBet.made, 6);
      expect(threeBet.opportunities, 6, reason: 'only the faced opens count');
      expect(threeBet.value, closeTo(100, 0.01));
    });
  });

  group('postflop rates', () {
    test('c-bet needs the hero to be the preflop aggressor', () {
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 8; i++) _openAndCbet(),
        for (var i = 0; i < 2; i++) _openAndCbet(cbet: false),
        // Hero called preflop here, so the flop bet is not a c-bet spot.
        for (var i = 0; i < 5; i++) _callDownToShowdown(won: false),
      ]);

      final cbet = metrics.sample(HeroMetricId.cbet);
      expect(cbet.opportunities, 10);
      expect(cbet.made, 8);
      expect(cbet.value, closeTo(80, 0.01));
    });

    test('WTSD and showdown win rate use flops seen and showdowns', () {
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 8; i++) _callDownToShowdown(won: true),
        for (var i = 0; i < 7; i++) _callDownToShowdown(won: false),
        // Saw a flop, took down the pot without showdown.
        for (var i = 0; i < 5; i++) _openAndCbet(),
      ]);

      expect(metrics.showdowns, 15);
      expect(metrics.sample(HeroMetricId.wtsd).opportunities, 20);
      expect(metrics.sample(HeroMetricId.wtsd).value, closeTo(75, 0.01));
      expect(
        metrics.sample(HeroMetricId.showdownWin).value,
        closeTo(8 / 15 * 100, 0.01),
      );
    });

    test('aggression factor divides bets and raises by calls', () {
      // Each call-down hand is 2 postflop calls and no aggression; each
      // c-bet hand is 1 postflop bet.
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 10; i++) _openAndCbet(),
        for (var i = 0; i < 10; i++) _callDownToShowdown(won: false),
      ]);

      final factor = metrics.sample(HeroMetricId.aggressionFactor);
      expect(factor.made, 10, reason: '10 flop bets');
      expect(factor.opportunities, 20, reason: '20 postflop calls');
      expect(factor.value, closeTo(0.5, 0.01));
    });
  });

  group('small samples', () {
    test('a rate under its minimum is withheld even though it is computed', () {
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 4; i++) _openAndCbet(),
      ]);

      final vpip = metrics.sample(HeroMetricId.vpip);
      expect(vpip.value, closeTo(100, 0.01));
      expect(vpip.hasEnoughData, isFalse);
      expect(vpip.reliableValue, isNull);
      expect(vpip.display, '—');
      expect(vpip.opportunitiesNeeded, HeroMetricId.vpip.minSample - 4);
      expect(vpip.verdict, MetricVerdict.unknown);
    });

    test('an empty history is empty rather than zeroed-out confidence', () {
      final metrics = HeroProfiler.compute([]);

      expect(metrics.isEmpty, isTrue);
      expect(metrics.style.style, PlayingStyle.forming);
      expect(metrics.style.isKnown, isFalse);
      expect(metrics.leaks, isEmpty);
      expect(metrics.trend, isEmpty);
    });
  });

  group('style classification', () {
    StyleReadout classify({
      required int hands,
      required double vpipPct,
      required double pfrPct,
      double aggressionPct = 40,
    }) {
      return HeroProfiler.classify(
        handsPlayed: hands,
        vpip: MetricSample(
          id: HeroMetricId.vpip,
          made: (vpipPct * hands / 100).round(),
          opportunities: hands,
        ),
        pfr: MetricSample(
          id: HeroMetricId.pfr,
          made: (pfrPct * hands / 100).round(),
          opportunities: hands,
        ),
        aggressionFrequency: MetricSample(
          id: HeroMetricId.aggressionFrequency,
          made: (aggressionPct * hands / 100).round(),
          opportunities: hands,
        ),
      );
    }

    test('no style is claimed below the minimum hand count', () {
      final readout = classify(hands: 19, vpipPct: 50, pfrPct: 5);

      expect(readout.style, PlayingStyle.forming);
      expect(readout.confidence, StyleConfidence.insufficient);
      expect(readout.isKnown, isFalse);
      expect(readout.explanation, contains('1 more'));
    });

    test('a nit is called a nit on VPIP alone', () {
      expect(
        classify(hands: 200, vpipPct: 10, pfrPct: 9).style,
        PlayingStyle.nit,
      );
    });

    test('tight and aggressive reads as TAG', () {
      expect(
        classify(hands: 200, vpipPct: 20, pfrPct: 16).style,
        PlayingStyle.tag,
      );
    });

    test('tight and passive is separated from a nit', () {
      expect(
        classify(hands: 200, vpipPct: 18, pfrPct: 4).style,
        PlayingStyle.tightPassive,
      );
    });

    test('loose and passive is the classic beginner leak', () {
      final readout = classify(hands: 200, vpipPct: 55, pfrPct: 8);

      expect(readout.style, PlayingStyle.loosePassive);
      expect(readout.explanation, contains('55'));
    });

    test('loose and aggressive reads as LAG, and wilder still as a maniac', () {
      expect(
        classify(hands: 200, vpipPct: 35, pfrPct: 25).style,
        PlayingStyle.lag,
      );
      expect(
        classify(hands: 200, vpipPct: 50, pfrPct: 40).style,
        PlayingStyle.maniac,
      );
    });

    test('the middle band stays balanced', () {
      expect(
        classify(hands: 200, vpipPct: 26, pfrPct: 13).style,
        PlayingStyle.balanced,
      );
    });

    test('confidence climbs with the hand count', () {
      expect(HeroProfiler.confidenceFor(0), StyleConfidence.insufficient);
      expect(HeroProfiler.confidenceFor(19), StyleConfidence.insufficient);
      expect(HeroProfiler.confidenceFor(20), StyleConfidence.low);
      expect(HeroProfiler.confidenceFor(59), StyleConfidence.low);
      expect(HeroProfiler.confidenceFor(60), StyleConfidence.medium);
      expect(HeroProfiler.confidenceFor(149), StyleConfidence.medium);
      expect(HeroProfiler.confidenceFor(150), StyleConfidence.high);
    });
  });

  group('tendencies and leaks', () {
    test('per-archetype net result and mix follow the villain faced', () {
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 10; i++)
          _hand([
            _villain(
              Street.preflop,
              HandActionKind.raise,
              amountBb: 3,
              archetype: PlayerArchetype.maniac,
            ),
            _hero(Street.preflop, HandActionKind.call, amountBb: 3),
            _villain(
              Street.flop,
              HandActionKind.bet,
              amountBb: 6,
              archetype: PlayerArchetype.maniac,
            ),
            _hero(Street.flop, HandActionKind.fold),
          ], netBb: -3),
      ]);

      final vsManiac = metrics.archetypeTendencies.firstWhere(
        (t) => t.archetype == PlayerArchetype.maniac,
      );

      expect(vsManiac.decisions, 20, reason: '10 calls + 10 folds');
      expect(vsManiac.netBb, closeTo(-30, 0.01));
      expect(vsManiac.foldPct, closeTo(50, 0.01));
      expect(vsManiac.aggressionPct, 0);
    });

    test('a passive call-down history surfaces leaks worth naming', () {
      final metrics = HeroProfiler.compute([
        for (var i = 0; i < 40; i++) _callDownToShowdown(won: false),
      ]);

      expect(metrics.leaks, isNotEmpty);
      expect(metrics.leaks.length, lessThanOrEqualTo(HeroProfiler.maxLeaks));
      for (final leak in metrics.leaks) {
        expect(leak.title, isNotEmpty);
        expect(leak.detail, isNotEmpty);
      }
    });

    test('the trend only appears once there are enough hands', () {
      final few = HeroProfiler.compute([
        for (var i = 0; i < HeroProfiler.minTrendHands - 1; i++) _openAndCbet(),
      ]);
      final many = HeroProfiler.compute([
        for (var i = 0; i < 60; i++) _openAndCbet(),
      ]);

      expect(few.trend, isEmpty);
      expect(many.trend.length, greaterThan(1));
      expect(many.trend.length, lessThanOrEqualTo(HeroProfiler.maxTrendPoints));
      // Every one of these hands was voluntarily played.
      expect(many.trend.last.vpipPct, closeTo(100, 0.01));
    });

    test('hands are ordered by time before the trend is cut', () {
      final shuffled = [
        HeroHandSample(
          handId: 2,
          playedAt: DateTime(2026, 2, 2),
          actions: [_hero(Street.preflop, HandActionKind.raise, amountBb: 3)],
        ),
        HeroHandSample(
          handId: 1,
          playedAt: DateTime(2026, 1, 1),
          actions: [
            _hero(Street.preflop, HandActionKind.blind, amountBb: 0.5),
            _hero(Street.preflop, HandActionKind.fold),
          ],
        ),
      ];

      final metrics = HeroProfiler.compute(shuffled);

      expect(metrics.handsPlayed, 2);
      expect(metrics.sample(HeroMetricId.vpip).made, 1);
    });
  });

  group('street and archetype notes', () {
    StreetTendency street({
      Street name = Street.flop,
      required int decisions,
      int aggressive = 0,
      int calls = 0,
      int folds = 0,
      int checks = 0,
    }) {
      return StreetTendency(
        street: name,
        decisions: decisions,
        aggressive: aggressive,
        calls: calls,
        folds: folds,
        checks: checks,
      );
    }

    test('notes stay quiet under the sample gate and on exact boundaries', () {
      expect(street(decisions: 11, folds: 11).note, isNull);
      expect(
        street(decisions: 20, folds: 10, aggressive: 6, calls: 4).note,
        isNull,
      );
      expect(
        street(decisions: 20, folds: 11, aggressive: 5, calls: 4).note,
        'over-folding',
        reason: '11/20 is slightly above 55% in floating point',
      );
      expect(street(decisions: 20, folds: 12, calls: 8).note, 'over-folding');
      expect(street(decisions: 20, calls: 10, checks: 10).note, 'over-calling');
      expect(
        street(decisions: 20, aggressive: 3, checks: 17).note,
        'too passive',
      );
      expect(
        street(decisions: 20, aggressive: 4, checks: 16).note,
        isNull,
        reason: '20% aggression is the passive floor',
      );
      expect(
        street(decisions: 20, aggressive: 13, checks: 7).note,
        isNull,
        reason: '65% aggression is not yet over-aggressive',
      );
      expect(
        street(decisions: 20, aggressive: 14, checks: 6).note,
        'over-aggressive',
      );
    });

    test('preflop over-folding is a note but not a surfaced leak', () {
      final preflop = street(
        name: Street.preflop,
        decisions: 20,
        folds: 16,
        checks: 4,
      );
      expect(preflop.note, 'over-folding');
      expect(
        HeroProfiler.leaksFor(
          samples: const <HeroMetricId, MetricSample>{},
          streets: [preflop],
          archetypes: const <ArchetypeTendency>[],
        ),
        isEmpty,
      );
    });

    test('exploit notes follow the archetype that was actually faced', () {
      ArchetypeTendency vs(
        PlayerArchetype archetype, {
        required int decisions,
        int aggressive = 0,
        int calls = 0,
        int folds = 0,
      }) {
        return ArchetypeTendency(
          archetype: archetype,
          decisions: decisions,
          aggressive: aggressive,
          calls: calls,
          folds: folds,
          netBb: 0,
        );
      }

      expect(
        vs(PlayerArchetype.callingStation, decisions: 9, aggressive: 9).note,
        isNull,
      );
      expect(
        vs(PlayerArchetype.callingStation, decisions: 20, aggressive: 12).note,
        contains('bet value, not bluffs'),
      );
      expect(
        vs(PlayerArchetype.callingStation, decisions: 20, aggressive: 10).note,
        isNull,
        reason: '50% aggression is not a bluff leak',
      );
      expect(
        vs(PlayerArchetype.callingStation, decisions: 20, aggressive: 11).note,
        contains('bet value, not bluffs'),
        reason: '11/20 is slightly above 55% in floating point',
      );
      expect(
        vs(PlayerArchetype.callingStation, decisions: 25, aggressive: 6).note,
        contains('Value-bet them thinner'),
      );
      expect(
        vs(PlayerArchetype.nit, decisions: 10, calls: 6, aggressive: 2).note,
        contains('call a nit down too often'),
      );
      expect(
        vs(PlayerArchetype.nit, decisions: 10, calls: 4, aggressive: 2).note,
        contains('Attack their checks'),
      );
      expect(
        vs(PlayerArchetype.maniac, decisions: 10, folds: 6).note,
        contains('fold too much to a maniac'),
      );
      expect(
        vs(PlayerArchetype.maniac, decisions: 10, calls: 6, folds: 2).note,
        contains('raise your strong hands'),
      );
      expect(
        vs(PlayerArchetype.lag, decisions: 10, folds: 6).note,
        contains('Defend wider'),
      );
      expect(
        vs(PlayerArchetype.tag, decisions: 10, folds: 6).note,
        isNull,
        reason: '60% folds is not yet avoiding the regs',
      );
      expect(
        vs(PlayerArchetype.tag, decisions: 10, folds: 7).note,
        contains('thin edges'),
      );
    });
  });

  group('snapshot parsing', () {
    test('unknown style names fall back instead of throwing', () {
      final metrics = HeroMetrics.fromJson({
        'handsPlayed': 40,
        'netBb': 12.5,
        'showdowns': 3,
        'style': {
          'style': 'shark',
          'confidence': 'certain',
          'explanation': 'nope',
          'handsPlayed': 40,
        },
        'samples': {
          'vpip': {'made': 10, 'opportunities': 40},
        },
        'leaks': [
          {'title': 'Limp', 'detail': 'Raise', 'severity': 0.4},
          'not-a-map',
        ],
      });

      expect(metrics.style.style, PlayingStyle.forming);
      expect(metrics.style.confidence, StyleConfidence.insufficient);
      expect(metrics.handsPlayed, 40);
      expect(metrics.netBb, 12.5);
      expect(metrics.leaks, hasLength(1));
      expect(metrics.leaks.single.title, 'Limp');
      expect(metrics.sample(HeroMetricId.vpip).made, 10);
      expect(metrics.sample(HeroMetricId.pfr).made, 0);
    });
  });
}
