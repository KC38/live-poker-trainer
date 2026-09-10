/// Scenario optimal must come from LiveCoach / DecisionModel, not Gemini.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/scenario_grader.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

ScenarioModel _stationValueSetup() => ScenarioModel.fromGeminiJson(const {
      'name': 'Station value',
      'table_size': 6,
      'hero_position': 'CO',
      'hero_hand': ['Kh', 'Kd'],
      'board_cards': ['Ks', '8c', '2d', '9h'],
      'pot_size': 32,
      'villain_seat': 3,
      'villain_archetype': 'Calling Station',
      'previous_action_narrative': 'Station checked turn.',
      'villain_action': 'CHECK',
      'call_amount': 0,
      'min_raise': 2,
      'max_raise': 200,
      // Deliberately wrong Gemini "answer" — grader must overwrite.
      'optimal_exploit_action': 'FOLD',
      'optimal_sizing_bb': 0,
      'theoretical_ev_explanation': 'Gemini said fold (should be ignored).',
      'exploit_reasoning': 'Gemini fiction.',
    });

ScenarioModel _nitPayoffSetup() => ScenarioModel.fromGeminiJson(const {
      'name': 'Nit river bet',
      'table_size': 6,
      'hero_position': 'BB',
      'hero_hand': ['7h', '6h'],
      'board_cards': ['As', 'Kd', '2c', '9s', '3d'],
      'pot_size': 40,
      'villain_seat': 1,
      'villain_archetype': 'Nit',
      'previous_action_narrative': 'Nit bets river.',
      'villain_action': 'RAISE',
      'call_amount': 30,
      'min_raise': 60,
      'max_raise': 200,
      'optimal_exploit_action': 'CALL',
      'optimal_sizing_bb': 0,
    });

void main() {
  group('ScenarioModel setup hash', () {
    test('ignores Gemini optimal fields so identical setups collide', () {
      final a = ScenarioModel.fromGeminiJson(const {
        'table_size': 6,
        'hero_position': 'BTN',
        'hero_hand': ['As', 'Kh'],
        'board_cards': ['2c', '2d', '9h'],
        'pot_size': 20,
        'villain_seat': 1,
        'villain_archetype': 'TAG',
        'previous_action_narrative': 'Checked.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
        'optimal_exploit_action': 'RAISE',
      });
      final b = ScenarioModel.fromGeminiJson(const {
        'table_size': 6,
        'hero_position': 'BTN',
        'hero_hand': ['As', 'Kh'],
        'board_cards': ['2c', '2d', '9h'],
        'pot_size': 20,
        'villain_seat': 1,
        'villain_archetype': 'TAG',
        'previous_action_narrative': 'Checked.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
        'optimal_exploit_action': 'FOLD',
      });
      expect(a.contentHash, b.contentHash);
    });
  });

  group('ScenarioGrader.resolveOptimal', () {
    test('overwrites Gemini optimal with LiveCoach recommend', () {
      final setup = _stationValueSetup();
      expect(setup.optimalExploitAction, ExploitAction.fold);

      final resolved = ScenarioGrader.resolveOptimal(setup);
      expect(resolved.optimalExploitAction, isNot(ExploitAction.fold));
      expect(
        resolved.exploitReasoning,
        isNot(contains('Gemini fiction')),
      );

      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 6),
      );
      engine.startPracticeScenario(setup);
      final rec = LiveCoach.recommend(engine.state);
      expect(rec, isNotNull);
      expect(resolved.optimalExploitAction, rec!.optimalAction);
      expect(resolved.optimalSizingBb, rec.optimalSizingBb);
    });

    test('matches LiveCoach.grade optimal on the stamped action', () {
      final resolved = ScenarioGrader.resolveOptimal(_nitPayoffSetup());
      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 6),
      );
      engine.startPracticeScenario(resolved);

      final probe = switch (resolved.optimalExploitAction) {
        ExploitAction.fold => const PokerAction(type: PokerActionType.fold),
        ExploitAction.check => const PokerAction(type: PokerActionType.check),
        ExploitAction.call => PokerAction(
            type: PokerActionType.call,
            amount: engine.state.callAmountFor(engine.state.hero),
          ),
        ExploitAction.raise => PokerAction(
            type: PokerActionType.raise,
            amount: engine.state.hero.currentBet +
                resolved.optimalSizingBb * engine.state.bigBlind,
          ),
      };

      final grade = LiveCoach.grade(state: engine.state, action: probe);
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, resolved.optimalExploitAction);
    });
  });
}
