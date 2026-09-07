/// Fetches, caches, and grades practice scenarios.
library;

import 'dart:async';

import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/scenario_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
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
      final id = cached.first.id;
      if (id != null) unawaited(_markServed(id));
      await maybePrefetch();
      return cached.first;
    }

    final generated = await gemini.generateScenarios(count: 3);
    if (generated.isEmpty) {
      final fallback = _fallbackScenario();
      // Persist the offline scenario too so its play history is queryable.
      final id = await scenarioDao.upsert(fallback, source: 'offline');
      unawaited(_markServed(id));
      return fallback.copyWith(id: id);
    }
    ScenarioModel? first;
    for (final s in generated) {
      final id = await scenarioDao.upsert(s, modelId: Config.geminiModel);
      if (first == null) {
        first = s.copyWith(id: id);
        unawaited(_markServed(id));
      }
    }
    await maybePrefetch();
    return first!;
  }

  Future<void> _markServed(int id) async {
    try {
      await scenarioDao.markServed(id);
    } catch (e, st) {
      DiagnosticsLog.error('ScenarioManager.markServed', e, st);
    }
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
        await scenarioDao.upsert(s, modelId: Config.geminiModel);
      }
    } catch (e, st) {
      // Prefetch is best-effort; gameplay can continue offline.
      DiagnosticsLog.error('ScenarioManager.prefetch', e, st);
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
    _fallbackRotation++;
    final variants = <Map<String, dynamic>>[
      {
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
      },
      {
        'name': 'Offline Station Value Barrel',
        'table_size': 6,
        'hero_position': 'CO',
        'hero_hand': ['Kh', 'Kd'],
        'board_cards': ['Ks', '8c', '2d', '9h'],
        'pot_size': 32,
        'villain_seat': 3,
        'villain_archetype': 'Calling Station',
        'previous_action_narrative':
            'Station called flop; turn completes a weak draw.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
        'optimal_exploit_action': 'RAISE',
        'optimal_sizing_bb': 22,
        'theoretical_ev_explanation':
            'Stations call down too wide — size up for thin value.',
        'exploit_reasoning':
            'Fred peels light; bet bigger for value, never bluff.',
      },
      {
        'name': 'Offline Maniac Flop Continue',
        'table_size': 8,
        'hero_position': 'BB',
        'hero_hand': ['Ah', 'Td'],
        'board_cards': ['Tc', '7s', '2h'],
        'pot_size': 18,
        'villain_seat': 1,
        'villain_archetype': 'Maniac',
        'previous_action_narrative': 'Maniac open-raised; you defended BB.',
        'villain_action': 'RAISE',
        'call_amount': 12,
        'min_raise': 24,
        'max_raise': 200,
        'optimal_exploit_action': 'CALL',
        'optimal_sizing_bb': 0,
        'theoretical_ev_explanation':
            'Maniacs barrel wide; call top pair and let them bluff.',
        'exploit_reasoning':
            'Viktor will keep firing — flatting top pair prints.',
      },
    ];
    final raw = variants[_fallbackRotation % variants.length];
    return ScenarioModel.fromGeminiJson(raw);
  }

  static int _fallbackRotation = 0;
}
