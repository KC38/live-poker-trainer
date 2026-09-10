/// Hero equity against weighted opponent ranges.
///
/// Two strategies, chosen by how much work an exact answer costs:
///
/// * **Exact enumeration** on the turn and river against a single range. Every
///   combo and every runout is evaluated, so the answer has no sampling error
///   at all. River decisions are the ones players scrutinise hardest, and they
///   are also the cheapest to enumerate.
/// * **Seeded Monte Carlo** everywhere else — the flop, preflop, and any
///   multiway spot, where enumeration runs to millions of evaluations.
///
/// The seed is derived from the spot rather than the clock, so grading the
/// same decision twice always produces the same equity. A coach that says 24%
/// once and 27% the next time is not a coach anyone trusts.
library;

import 'dart:math';

import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_range.dart';

/// Hero equity against one or more ranges.
class EquityResult {
  /// Creates an equity result.
  const EquityResult({
    required this.equity,
    required this.samples,
    required this.exact,
  });

  /// Share of the pot hero wins on average, `0..1`. Ties count fractionally.
  final double equity;

  /// Combos-by-runouts enumerated, or Monte Carlo iterations run.
  final int samples;

  /// Whether [equity] came from full enumeration rather than sampling.
  final bool exact;

  /// Equity as a whole-number percentage, for display.
  int get percent => (equity * 100).round();

  /// Roughly how far [equity] could be off, as a fraction.
  ///
  /// Zero when [exact]; otherwise the standard error of the sample mean, which
  /// the grader uses to widen its "too close to call" band so sampling noise
  /// can never be the thing that decides a verdict.
  double get standardError {
    if (exact || samples <= 1) return 0;
    final variance = equity * (1 - equity);
    return sqrt(variance / samples);
  }

  /// A neutral result used when a range has been filtered to nothing.
  static const EquityResult unknown =
      EquityResult(equity: 0.5, samples: 0, exact: false);
}

/// Computes hero equity against opponent ranges.
class EquitySimulator {
  EquitySimulator._();

  /// Monte Carlo iterations for a heads-up spot.
  static const int defaultIterations = 6000;

  /// Iterations for a spot with [villainCount] opponents.
  ///
  /// Each extra opponent multiplies the per-iteration cost, and the decision
  /// being graded gets less sensitive to a point of equity as the pot gets
  /// more contested, so the sample count comes down rather than the grade
  /// moving off the UI thread.
  static int iterationsFor(int villainCount) => switch (villainCount) {
        <= 1 => defaultIterations,
        2 || 3 => 4500,
        _ => 3500,
      };

  /// Enumerating the turn costs about this many evaluations; the flop costs
  /// twenty times more, which is where sampling takes over.
  static const int _maxExactEvaluations = 120000;

  /// Hero's equity holding [heroCards] on [board] against [villains].
  ///
  /// [seed] makes Monte Carlo runs reproducible; pass [spotSeed] of the
  /// decision being graded.
  ///
  /// [allowExact] can be turned off for the many throwaway equities behind a
  /// sizing comparison, where only the ranking matters and enumerating every
  /// runout for each candidate size would cost more than the whole grade is
  /// worth. The equity the player is actually shown always allows it.
  static EquityResult heroEquity({
    required List<int> heroCards,
    required List<int> board,
    required List<HandRange> villains,
    required int seed,
    int? iterations,
    bool allowExact = true,
  }) {
    if (heroCards.length != 2 || villains.isEmpty) {
      return EquityResult.unknown;
    }
    final live = [for (final v in villains) if (!v.isEmpty) v];
    if (live.isEmpty) return EquityResult.unknown;

    if (allowExact && live.length == 1) {
      final exact = _tryExact(heroCards, board, live.first);
      if (exact != null) return exact;
    }
    return _monteCarlo(
      heroCards,
      board,
      live,
      seed,
      iterations ?? iterationsFor(live.length),
    );
  }

  /// A stable seed for one decision, so repeat grades never disagree.
  static int spotSeed({
    required List<int> heroCards,
    required List<int> board,
    required int street,
    required int potCents,
  }) {
    var hash = 0x811c9dc5;
    void mix(int value) {
      hash ^= value & 0xFFFF;
      hash = (hash * 0x01000193) & 0x3FFFFFFF;
    }

    for (final c in heroCards) {
      mix(c);
    }
    for (final c in board) {
      mix(c);
    }
    mix(street);
    mix(potCents);
    return hash;
  }

  // --- exact enumeration ---

  /// Enumerates every villain combo and runout, or returns null when that
  /// would cost more than [_maxExactEvaluations].
  static EquityResult? _tryExact(
    List<int> heroCards,
    List<int> board,
    HandRange villain,
  ) {
    final missing = 5 - board.length;
    if (missing < 0 || missing > 1) return null;

    var liveCombos = 0;
    for (var i = 0; i < villain.length; i++) {
      if (villain.weightAt(i) > 0) liveCombos++;
    }
    if (liveCombos == 0) return null;
    final runouts = missing == 0 ? 1 : 45;
    if (liveCombos * runouts * 2 > _maxExactEvaluations) return null;

    final used = List<bool>.filled(FastEvaluator.deckSize, false);
    for (final c in heroCards) {
      used[c] = true;
    }
    for (final c in board) {
      used[c] = true;
    }

    final heroHand = <int>[...heroCards, ...board, 0];
    final villainHand = <int>[0, 0, ...board, 0];
    final heroSlot = heroHand.length - 1;
    final villainSlot = villainHand.length - 1;

    // Hero's hand on a given runout does not depend on what the villain
    // holds, so it is worth computing once per river card instead of once per
    // combo-and-river-card pair. That is half of all the work in here.
    final heroScoreByCard = List<int>.filled(FastEvaluator.deckSize, 0);
    final heroScoreNoRunout =
        missing == 0 ? FastEvaluator.score(heroHand.sublist(0, heroSlot)) : 0;
    if (missing == 1) {
      for (var card = 0; card < FastEvaluator.deckSize; card++) {
        if (used[card]) continue;
        heroHand[heroSlot] = card;
        heroScoreByCard[card] = FastEvaluator.score(heroHand);
      }
    }

    var won = 0.0;
    var total = 0.0;
    var evaluated = 0;

    for (var i = 0; i < villain.length; i++) {
      final weight = villain.weightAt(i);
      if (weight == 0) continue;
      final va = villain.cardA(i);
      final vb = villain.cardB(i);
      if (used[va] || used[vb]) continue;

      used[va] = true;
      used[vb] = true;
      villainHand[0] = va;
      villainHand[1] = vb;

      if (missing == 0) {
        won += weight *
            _share(
              heroScoreNoRunout,
              FastEvaluator.score(villainHand.sublist(0, villainSlot)),
            );
        total += weight;
        evaluated++;
      } else {
        for (var card = 0; card < FastEvaluator.deckSize; card++) {
          if (used[card]) continue;
          villainHand[villainSlot] = card;
          won += weight *
              _share(
                heroScoreByCard[card],
                FastEvaluator.score(villainHand),
              );
          total += weight;
          evaluated++;
        }
      }

      used[va] = false;
      used[vb] = false;
    }

    if (total <= 0) return null;
    return EquityResult(
      equity: won / total,
      samples: evaluated,
      exact: true,
    );
  }

  /// Hero's share of the pot in a two-way showdown.
  static double _share(int heroScore, int villainScore) {
    if (heroScore > villainScore) return 1.0;
    if (heroScore == villainScore) return 0.5;
    return 0.0;
  }

  // --- Monte Carlo ---

  static EquityResult _monteCarlo(
    List<int> heroCards,
    List<int> board,
    List<HandRange> villains,
    int seed,
    int iterations,
  ) {
    final rng = Random(seed);
    final used = List<bool>.filled(FastEvaluator.deckSize, false);
    for (final c in heroCards) {
      used[c] = true;
    }
    for (final c in board) {
      used[c] = true;
    }

    final missing = 5 - board.length;
    final villainCount = villains.length;
    final runout = List<int>.filled(missing, 0);
    final villainCards = List<int>.filled(villainCount * 2, 0);

    final heroHand = List<int>.filled(7, 0);
    final villainHand = List<int>.filled(7, 0);
    for (var i = 0; i < 2; i++) {
      heroHand[i] = heroCards[i];
    }
    for (var i = 0; i < board.length; i++) {
      heroHand[2 + i] = board[i];
      villainHand[2 + i] = board[i];
    }

    var won = 0.0;
    var completed = 0;

    for (var iter = 0; iter < iterations; iter++) {
      var dealtVillains = 0;
      var ok = true;

      for (var v = 0; v < villainCount && ok; v++) {
        var placed = false;
        for (var attempt = 0; attempt < 24 && !placed; attempt++) {
          final index = villains[v].sample(rng);
          if (index < 0) break;
          final ca = villains[v].cardA(index);
          final cb = villains[v].cardB(index);
          if (used[ca] || used[cb]) continue;
          used[ca] = true;
          used[cb] = true;
          villainCards[v * 2] = ca;
          villainCards[v * 2 + 1] = cb;
          dealtVillains++;
          placed = true;
        }
        if (!placed) ok = false;
      }

      if (ok) {
        for (var i = 0; i < missing; i++) {
          var card = 0;
          do {
            card = rng.nextInt(FastEvaluator.deckSize);
          } while (used[card]);
          used[card] = true;
          runout[i] = card;
          heroHand[2 + board.length + i] = card;
          villainHand[2 + board.length + i] = card;
        }

        final heroScore = FastEvaluator.score(heroHand);
        var best = heroScore;
        var tied = 1;
        for (var v = 0; v < villainCount; v++) {
          villainHand[0] = villainCards[v * 2];
          villainHand[1] = villainCards[v * 2 + 1];
          final score = FastEvaluator.score(villainHand);
          if (score > best) {
            best = score;
            tied = 1;
          } else if (score == best) {
            tied++;
          }
        }
        if (heroScore == best) won += 1.0 / tied;
        completed++;

        for (var i = 0; i < missing; i++) {
          used[runout[i]] = false;
        }
      }

      for (var v = 0; v < dealtVillains; v++) {
        used[villainCards[v * 2]] = false;
        used[villainCards[v * 2 + 1]] = false;
      }
    }

    if (completed == 0) return EquityResult.unknown;
    return EquityResult(
      equity: won / completed,
      samples: completed,
      exact: false,
    );
  }
}
