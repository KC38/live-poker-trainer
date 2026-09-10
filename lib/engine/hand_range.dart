/// Weighted combo ranges, and the rules that build and narrow them.
///
/// A range is the 1326 possible two-card combos with a weight each. Building
/// one starts from an archetype's VPIP or PFR read as a top-N% slice of
/// [PreflopChart], adjusted for seat. Narrowing multiplies each combo's weight
/// by how often that archetype takes the observed action with that class of
/// hand, which is what turns "Sammy bet 55% of the pot on Q-3-5" into an
/// actual distribution the hero's equity can be measured against.
library;

import 'dart:math';

import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/preflop_chart.dart';
import 'package:live_poker_trainer/engine/villain_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// What a villain was observed doing on a street.
enum RangeAction {
  /// Bet or raised, at a known size.
  bet,

  /// Had the option and checked.
  checked,

  /// Called a bet at a known price.
  called,

  /// Reached the next street with their action unknown. Applies a deliberately
  /// weak filter: they are still here, but we cannot see whether that took a
  /// call or a free check, so the range only tightens a little.
  survived,
}

/// A weighted set of two-card combos.
///
/// Weights are unnormalised: only their ratios matter, so filters can multiply
/// freely without rescaling. A range whose weights are all zero is [isEmpty]
/// and callers must fall back rather than divide by it.
class HandRange {
  HandRange._(this._a, this._b, this._w);

  /// Builds a range holding every combo of every label in [labels].
  factory HandRange.fromLabels(Iterable<String> labels, {double weight = 1.0}) {
    final a = <int>[];
    final b = <int>[];
    final w = <double>[];
    for (final label in labels) {
      for (final combo in PreflopChart.expand(label)) {
        a.add(combo[0]);
        b.add(combo[1]);
        w.add(weight);
      }
    }
    return HandRange._(a, b, w);
  }

  /// Builds the range of every possible combo, each at [weight].
  factory HandRange.all({double weight = 1.0}) =>
      HandRange.fromLabels(PreflopChart.ranking, weight: weight);

  final List<int> _a;
  final List<int> _b;
  final List<double> _w;

  List<double>? _cumulative;
  List<HandClass>? _classes;
  int _classesKey = -1;

  /// Number of combos tracked, including zero-weighted ones.
  int get length => _a.length;

  /// First card of combo [i].
  int cardA(int i) => _a[i];

  /// Second card of combo [i].
  int cardB(int i) => _b[i];

  /// Weight of combo [i].
  double weightAt(int i) => _w[i];

  /// Sum of all weights.
  double get totalWeight {
    var sum = 0.0;
    for (final w in _w) {
      sum += w;
    }
    return sum;
  }

  /// Whether every combo has been filtered away.
  bool get isEmpty => totalWeight <= 1e-12;

  /// An independent copy, safe to narrow without touching this range.
  ///
  /// The copy inherits the board classification: reweighting changes what each
  /// combo is worth, never what it is, and reclassifying 1326 combos for every
  /// candidate bet size is the single most expensive thing the coach does.
  HandRange copy() {
    final out = HandRange._([..._a], [..._b], [..._w]);
    out._classes = _classes;
    out._classesKey = _classesKey;
    return out;
  }

  /// Each combo's [HandClass] on [board], computed once and reused.
  List<HandClass> classesOn(List<int> board) {
    final key = _boardKey(board);
    final cached = _classes;
    if (cached != null && _classesKey == key) return cached;
    final out = [
      for (var i = 0; i < _a.length; i++)
        HandClassifier.classify(_a[i], _b[i], board),
    ];
    _classes = out;
    _classesKey = key;
    return out;
  }

  static int _boardKey(List<int> board) {
    var key = board.length;
    for (final c in board) {
      key = key * 53 + c + 1;
    }
    return key;
  }

  /// Zeroes every combo that uses a card in [dead].
  ///
  /// Card removal is not cosmetic: without it a villain can be dealt the ace
  /// the hero is holding, which quietly inflates how often the hero loses.
  void removeCards(Set<int> dead) {
    for (var i = 0; i < _w.length; i++) {
      if (_w[i] == 0) continue;
      if (dead.contains(_a[i]) || dead.contains(_b[i])) _w[i] = 0;
    }
    _cumulative = null;
  }

  /// Multiplies every combo's weight by [factor] of that combo.
  void reweight(double Function(int a, int b) factor) {
    for (var i = 0; i < _w.length; i++) {
      if (_w[i] == 0) continue;
      _w[i] *= factor(_a[i], _b[i]);
    }
    _cumulative = null;
  }

  /// Multiplies every combo's weight by [factor] of its index.
  ///
  /// The index form lets callers reuse a cached per-combo classification
  /// rather than recomputing one inside the loop.
  void reweightIndexed(double Function(int index) factor) {
    for (var i = 0; i < _w.length; i++) {
      if (_w[i] == 0) continue;
      _w[i] *= factor(i);
    }
    _cumulative = null;
  }

  /// Share of this range's weight sitting in each [HandClass] on [board].
  ///
  /// Used by coach copy so it can say what the villain's range is actually
  /// made of instead of asserting a tendency.
  Map<HandClass, double> composition(List<int> board) {
    final totals = {for (final c in HandClass.values) c: 0.0};
    final classes = classesOn(board);
    var sum = 0.0;
    for (var i = 0; i < _w.length; i++) {
      final w = _w[i];
      if (w == 0) continue;
      final handClass = classes[i];
      totals[handClass] = totals[handClass]! + w;
      sum += w;
    }
    if (sum <= 0) return totals;
    return {for (final e in totals.entries) e.key: e.value / sum};
  }

  /// Draws a combo index at random, proportional to weight.
  ///
  /// Returns `-1` when the range is empty.
  int sample(Random rng) {
    final cumulative = _cumulativeWeights();
    final total = cumulative.isEmpty ? 0.0 : cumulative[cumulative.length - 1];
    if (total <= 0) return -1;
    final target = rng.nextDouble() * total;
    var low = 0;
    var high = cumulative.length - 1;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (cumulative[mid] < target) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  List<double> _cumulativeWeights() {
    final cached = _cumulative;
    if (cached != null) return cached;
    final out = List<double>.filled(_w.length, 0);
    var running = 0.0;
    for (var i = 0; i < _w.length; i++) {
      running += _w[i];
      out[i] = running;
    }
    _cumulative = out;
    return out;
  }
}

/// Builds and narrows opponent ranges.
class RangeBuilder {
  RangeBuilder._();

  /// How much wider or tighter a seat plays than the archetype's baseline.
  ///
  /// The blinds are wide because they are defending a discount, not because
  /// they choose good hands; the button is wide because position lets it.
  static double positionFactor(String positionLabel) =>
      switch (positionLabel) {
        'UTG' || 'UTG+1' => 0.72,
        'MP' || 'MP+1' => 0.85,
        'HJ' => 0.95,
        'CO' => 1.10,
        'BTN' => 1.30,
        'SB' => 1.05,
        'BB' => 1.25,
        _ => 1.0,
      };

  /// The range [archetype] enters a pot with from [positionLabel].
  ///
  /// [asAggressor] selects the raising range (PFR) rather than the full
  /// voluntary range (VPIP).
  static HandRange preflop({
    required PlayerArchetype archetype,
    String positionLabel = '',
    bool asAggressor = false,
  }) {
    final base = asAggressor ? archetype.pfr : archetype.vpip;
    final adjusted =
        (base * positionFactor(positionLabel)).clamp(3.0, 92.0).toDouble();
    return HandRange.fromLabels(PreflopChart.topPercent(adjusted));
  }

  /// Narrows [range] in place by an observed [action] on [board].
  ///
  /// [sizeToPot] is the bet or call size as a fraction of the pot at the time,
  /// and only matters for [RangeAction.bet] and [RangeAction.called].
  static void narrow({
    required HandRange range,
    required PlayerArchetype archetype,
    required List<int> board,
    required RangeAction action,
    double sizeToPot = VillainModel.referenceBetToPot,
  }) {
    if (board.length < 3) return;

    final classes = range.classesOn(board);
    range.reweightIndexed((i) {
      final handClass = classes[i];
      return switch (action) {
        RangeAction.bet => VillainModel.betFrequency(
            archetype,
            handClass,
            betToPot: sizeToPot,
          ),
        RangeAction.checked => 1.0 -
            VillainModel.betFrequency(
              archetype,
              handClass,
              betToPot: VillainModel.referenceBetToPot,
            ),
        RangeAction.called => VillainModel.callFrequency(
            archetype,
            handClass,
            priceToPot: sizeToPot,
          ),
        // Damped: surviving a street where we could not see the action is
        // weak evidence, so it must not tighten the range like a called bet.
        RangeAction.survived => 0.45 +
            0.55 *
                VillainModel.continueFrequency(
                  archetype,
                  handClass,
                  priceToPot: VillainModel.referenceBetToPot,
                ),
      };
    });
  }

  /// The subset of [range] that continues against a bet of [priceToPot].
  ///
  /// Used to answer "what am I actually up against if they call my raise",
  /// which is a different and much stronger range than the one that faced it.
  static HandRange continuingAgainst({
    required HandRange range,
    required PlayerArchetype archetype,
    required List<int> board,
    required double priceToPot,
  }) {
    final out = range.copy();
    if (board.length < 3) {
      // Preflop, strong hands continue and the rest folds; approximate with
      // the archetype's raising range rather than inventing a board read.
      return out;
    }
    final classes = out.classesOn(board);
    out.reweightIndexed(
      (i) => VillainModel.continueFrequency(
        archetype,
        classes[i],
        priceToPot: priceToPot,
      ),
    );
    return out;
  }

  /// How often [range] folds to a bet of [priceToPot] on [board].
  ///
  /// This is the fold equity a hero bet or raise actually has, computed from
  /// the range in front of it rather than assumed.
  static double foldEquity({
    required HandRange range,
    required PlayerArchetype archetype,
    required List<int> board,
    required double priceToPot,
  }) {
    if (board.length < 3) return 0.0;
    final classes = range.classesOn(board);
    var folding = 0.0;
    var total = 0.0;
    for (var i = 0; i < range.length; i++) {
      final w = range.weightAt(i);
      if (w == 0) continue;
      final handClass = classes[i];
      folding += w *
          VillainModel.foldFrequency(
            archetype,
            handClass,
            priceToPot: priceToPot,
          );
      total += w;
    }
    if (total <= 0) return 0.0;
    return (folding / total).clamp(0.0, 1.0);
  }
}
