/// Stamps practice-scenario optimal from the live EV coach.
///
/// Gemini (or offline templates) may invent the *setup* — cards, pot, villain
/// archetype, action to face — but [LiveCoach.recommend] / [DecisionModel]
/// owns `optimal_exploit_action` and sizing, same stack as full-hand training.
library;

import 'dart:math';

import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Resolves scenario optimal lines via [LiveCoach].
class ScenarioGrader {
  ScenarioGrader._();

  /// Returns [scenario] with EV-backed optimal fields when the spot grades.
  ///
  /// When the spot cannot be priced (empty ranges, missing cards), the input
  /// is returned unchanged so callers keep any fallback labels.
  static ScenarioModel resolveOptimal(
    ScenarioModel scenario, {
    GameSettingsModel? settings,
    Random? random,
  }) {
    final seats = scenario.tableSize.clamp(2, 9);
    final engine = PokerEngine(
      settings: (settings ?? const GameSettingsModel()).copyWith(
        seatCount: seats,
      ),
      random: random ?? Random(0),
    );
    engine.startPracticeScenario(scenario);
    final rec = LiveCoach.recommend(engine.state);
    if (rec == null) return scenario;

    return scenario.copyWith(
      optimalExploitAction: rec.optimalAction,
      optimalSizingBb: rec.optimalSizingBb,
      theoreticalEvExplanation: rec.explanation,
      exploitReasoning: rec.explanation,
    );
  }
}
