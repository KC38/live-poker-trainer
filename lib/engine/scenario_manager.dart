/// Fetches, caches, and grades practice scenarios.
library;

import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/scenario_dao.dart';
import 'package:live_poker_trainer/core/database/user_stats_dao.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/services/gemini_service.dart';

/// Orchestrates scenario cache, Gemini prefetch, and practice grading.
class ScenarioManager {
  /// Creates a scenario manager.
  ScenarioManager({
    required this.scenarioDao,
    required this.statsDao,
    required this.gemini,
  });

  final ScenarioDao scenarioDao;
  final UserStatsDao statsDao;
  final GeminiService gemini;

  /// Next unplayed scenario, generating via Gemini if cache is empty.
  Future<ScenarioModel> nextScenario() async {
    final cached = await scenarioDao.unplayed(limit: 1);
    if (cached.isNotEmpty) {
      await maybePrefetch();
      return cached.first;
    }

    final generated = await gemini.generateScenarios(count: 3);
    if (generated.isEmpty) {
      return _fallbackScenario();
    }
    ScenarioModel? first;
    for (final s in generated) {
      final id = await scenarioDao.upsert(s);
      first ??= s.copyWith(id: id);
    }
    await maybePrefetch();
    return first!;
  }

  /// Prefetches when unplayed count is below threshold.
  Future<void> maybePrefetch() async {
    final count = await scenarioDao.unplayedCount();
    if (count >= Config.scenarioPrefetchThreshold) return;
    if (!gemini.hasApiKey) return;

    final needed = Config.scenarioPrefetchThreshold - count + 2;
    try {
      final batch = await gemini.generateScenarios(count: needed);
      for (final s in batch) {
        await scenarioDao.upsert(s);
      }
    } catch (_) {
      // Prefetch is best-effort; gameplay can continue offline.
    }
  }

  /// Grades hero action, persists played + stats, returns coach feedback.
  Future<CoachFeedback> gradeAndRecord({
    required ScenarioModel scenario,
    required PokerAction action,
    required PokerEngine engine,
    String? coachMessage,
  }) async {
    final grade = engine.gradeHeroAction(action);
    final correct = grade.correct;
    final bb = engine.state.bigBlind;
    final invested = engine.state.heroInvestedThisHand;
    // Rough EV delta: reward correct lines, penalize misses in BB terms.
    final evDeltaBb = correct
        ? maxEv(0.25, scenario.optimalSizingBb * 0.05)
        : -maxEv(0.5, invested / bb * 0.15);

    if (scenario.id != null) {
      await scenarioDao.markPlayed(
        scenarioId: scenario.id!,
        wasCorrect: correct,
        evDeltaBb: evDeltaBb,
        street: scenario.street,
        archetype: scenario.villainArchetype.label,
      );
    }
    await statsDao.recordPracticeResult(
      wasCorrect: correct,
      evDeltaBb: evDeltaBb,
      street: scenario.street,
      archetype: scenario.villainArchetype.label,
    );

    final message = coachMessage?.trim().isNotEmpty == true
        ? coachMessage!.trim()
        : (correct
            ? scenario.exploitReasoning
            : 'Optimal was ${scenario.optimalExploitAction.label}. '
                '${scenario.exploitReasoning}');

    return CoachFeedback(
      verdict: correct ? CoachVerdict.correct : CoachVerdict.incorrect,
      message: message,
      optimalAction: scenario.optimalExploitAction,
      heroAction: action.label,
      evDeltaBb: evDeltaBb,
    );
  }

  double maxEv(double a, double b) => a > b ? a : b;

  ScenarioModel _fallbackScenario() {
    return ScenarioModel.fromGeminiJson({
      'name': 'Offline Nit River Probe',
      'table_size': 6,
      'hero_position': 'BTN',
      'hero_hand': ['As', '5s'],
      'board_cards': ['Js', 'Tc', '4s', '2d', 'Ac'],
      'pot_size': 45,
      'villain_seat': 2,
      'villain_archetype': 'Nit',
      'previous_action_narrative':
          'Nit checks river after calling two barrels.',
      'villain_action': 'CHECK',
      'call_amount': 0,
      'min_raise': 2,
      'max_raise': 200,
      'optimal_exploit_action': 'RAISE',
      'optimal_sizing_bb': 35,
      'theoretical_ev_explanation':
          'Nits overfold rivers; thin value + bluff with blockers prints.',
      'exploit_reasoning':
          'Stan folds second pair to river aggression — fire a probe raise.',
    });
  }
}
