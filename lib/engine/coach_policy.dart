/// Plain-language description of how the coach actually decides.
///
/// The Leak Finder shows the player the rule their mistakes were graded
/// against. That promise only holds if the text is derived from the same
/// numbers the grader uses, so everything here is computed from
/// [VillainModel] and [LiveCoach] rather than written out separately and left
/// to drift.
///
/// It replaced a table of fixed hand-class thresholds. Those read as arbitrary
/// because they were: they named a minimum hand to call with and never
/// mentioned the price, so two correct gradings against the same opponent
/// could look like contradictory advice.
library;

import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/villain_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Describes the grading policy in the player's language.
class CoachPolicy {
  CoachPolicy._();

  /// The rule mistakes against [archetype] were graded under.
  ///
  /// Two halves: what this opponent's bets are worth as evidence, and the
  /// price arithmetic that decides the call either way.
  static String ruleFor(PlayerArchetype archetype) {
    final bluffs = _percent(
      VillainModel.betFrequency(archetype, HandClass.air),
    );
    final foldsTopPair = _percent(
      VillainModel.foldFrequency(archetype, HandClass.topPair),
    );
    final callsWide = _percent(
      VillainModel.continueFrequency(archetype, HandClass.weakPair),
    );

    return 'Their bets: ${archetype.label} fires with nothing about $bluffs of '
        'the time, keeps a weak pair $callsWide of the time facing half pot, '
        'and lets top pair go only $foldsTopPair. '
        'Your calls: a half-pot bet needs 33% equity, two-thirds pot needs '
        '40%, a pot-sized bet needs 50%. Call when your equity against that '
        'range beats the price — the hand class alone is never the reason.';
  }

  /// How near-miss decisions are treated.
  static String get closeSpotNote =>
      'Too close to grade: anything within '
      '${LiveCoach.minGradedLossBb.toStringAsFixed(2)} BB or '
      '${(LiveCoach.minGradedLossPotFraction * 100).round()}% of the pot of '
      'the best line is marked correct, not wrong. That band is the coach\'s '
      'own margin of error, so a coin flip never scores as a mistake.';

  /// Shown when the same archetype holds mistakes in both directions.
  static const String twoSidedNote =
      'Folding and calling both cost you here. That is not opposite advice — '
      'the same hand against the same opponent is a call at 30% of the pot '
      'and a fold at 80%. Price and equity decide it, never the read alone.';

  static String _percent(double fraction) => '${(fraction * 100).round()}%';
}
