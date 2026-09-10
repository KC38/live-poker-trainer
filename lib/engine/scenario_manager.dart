/// Serves practice scenarios from the shared Firestore pool.
///
/// Generation is owned by the `ensureScenarioPool` Cloud Function. Clients
/// only read the pool, mark served/played, and fall back to offline templates
/// when Firestore or Functions are unavailable.
library;

import 'dart:async';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/preflop_chart.dart';
import 'package:live_poker_trainer/engine/scenario_grader.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/services/firestore/played_scenarios_repo.dart';
import 'package:live_poker_trainer/services/firestore/scenario_pool_doc.dart';
import 'package:live_poker_trainer/services/firestore/scenario_pool_repo.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';

/// Orchestrates Firestore scenario serve / exhaust / refill and practice grading.
class ScenarioManager {
  /// Creates a scenario manager.
  ///
  /// [uid] defaults to [FirebaseAuth.instance.currentUser]. [functions] is
  /// resolved lazily so unit tests that never call the refill path do not need
  /// Firebase initialized at provider construction time.
  ScenarioManager({
    required this.pool,
    required this.played,
    required this.users,
    String? Function()? uid,
    FirebaseFunctions? functions,
    this.poolPageSize = 50,
    this.functionsRegion = 'us-central1',
    Random? random,
  })  : _uid = uid ?? ScenarioManager._defaultUid,
        _functions = functions,
        _random = random ?? Random();

  final ScenarioPoolRepo pool;
  final PlayedScenariosRepo played;
  final UserRepository users;
  final int poolPageSize;
  final String functionsRegion;

  final String? Function() _uid;
  FirebaseFunctions? _functions;
  final Random _random;

  FirebaseFunctions get _fns =>
      _functions ??= FirebaseFunctions.instanceFor(region: functionsRegion);

  /// Safe for unit tests that never call [Firebase.initializeApp].
  static String? _defaultUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Next unplayed scenario for the signed-in user.
  ///
  /// Flow: recent pool ∩ ¬played → prefer engaging setups → serve + markServed.
  /// If empty, call [ensureScenarioPool] once and retry. Offline template if
  /// uid missing or Firestore / Functions unavailable.
  Future<ScenarioModel> nextScenario() async {
    final uid = _uid();
    if (uid == null || uid.isEmpty) {
      return ScenarioGrader.resolveOptimal(_fallbackScenario());
    }

    try {
      final first = await _pickUnplayed(uid);
      if (first != null) {
        unawaited(_markServed(first.contentHash));
        unawaited(maybePrefetch());
        return ScenarioGrader.resolveOptimal(first.toScenarioModel());
      }

      final refilled = await _ensureScenarioPool(
        count: Config.scenarioPrefetchThreshold,
      );
      if (refilled) {
        final second = await _pickUnplayed(uid);
        if (second != null) {
          unawaited(_markServed(second.contentHash));
          unawaited(maybePrefetch());
          return ScenarioGrader.resolveOptimal(second.toScenarioModel());
        }
      }
    } catch (e, st) {
      DiagnosticsLog.error('ScenarioManager.nextScenario', e, st);
    }

    return ScenarioGrader.resolveOptimal(_fallbackScenario());
  }

  Future<ScenarioPoolDoc?> _pickUnplayed(String uid) async {
    final candidates = await played.unplayedFromPool(
      uid: uid,
      pool: pool,
      poolLimit: poolPageSize,
    );
    if (candidates.isEmpty) return null;

    // Prefer engineered spots that look playable (postflop / strong hands /
    // real decisions) over automatic fold-preflop junk.
    final scored = [
      for (final doc in candidates)
        (doc: doc, score: engagementScore(doc.toScenarioModel())),
    ]..sort((a, b) => b.score.compareTo(a.score));

    final bestScore = scored.first.score;
    final top = scored.where((e) => e.score >= bestScore - 1).toList();
    return top[_random.nextInt(top.length)].doc;
  }

  /// Heuristic how engaging a setup is before EV stamping.
  ///
  /// Higher is better. Fold-preflop trash scores low; postflop and playable
  /// hero hands score high.
  static int engagementScore(ScenarioModel scenario) {
    var score = 0;
    final boardLen = scenario.boardCards.length;
    if (boardLen >= 3) score += 4;
    if (boardLen >= 4) score += 1;
    if (boardLen >= 5) score += 1;

    final handRank = _heroChartRank(scenario);
    // Stronger starting hands (lower chart index) are more trainable.
    if (handRank <= 20) {
      score += 4;
    } else if (handRank <= 45) {
      score += 3;
    } else if (handRank <= 70) {
      score += 1;
    } else if (boardLen == 0) {
      score -= 3;
    }

    // Facing a bet with a playable hand is interesting; facing a raise with
    // junk is usually "just fold".
    if (scenario.callAmount > 0) {
      if (handRank <= 55 || boardLen >= 3) {
        score += 2;
      } else {
        score -= 2;
      }
    } else {
      // Open / check-to spots reward having something to do.
      if (handRank <= 50 || boardLen >= 3) score += 2;
    }

    return score;
  }

  static int _heroChartRank(ScenarioModel scenario) {
    if (scenario.heroHand.length < 2) return PreflopChart.ranking.length;
    final codes = FastEvaluator.encodeAll(scenario.heroHand);
    final label = PreflopChart.labelFor(codes[0], codes[1]);
    return PreflopChart.rankOf(label);
  }

  Future<void> _markServed(String contentHash) async {
    try {
      await pool.markServed(contentHash);
    } catch (e, st) {
      DiagnosticsLog.error('ScenarioManager.markServed', e, st);
    }
  }

  /// Prefetches via Cloud Function when unplayed-for-user is below threshold.
  Future<void> maybePrefetch() async {
    final uid = _uid();
    if (uid == null || uid.isEmpty) return;

    try {
      final unplayed = await played.unplayedFromPool(
        uid: uid,
        pool: pool,
        poolLimit: poolPageSize,
      );
      if (unplayed.length >= Config.scenarioPrefetchThreshold) return;

      final needed =
          Config.scenarioPrefetchThreshold - unplayed.length + 2;
      await _ensureScenarioPool(count: needed.clamp(1, 20));
    } catch (e, st) {
      DiagnosticsLog.error('ScenarioManager.prefetch', e, st);
    }
  }

  /// Invokes `ensureScenarioPool`. Returns false when undeployed / offline.
  Future<bool> _ensureScenarioPool({required int count}) async {
    try {
      final callable = _fns.httpsCallable('ensureScenarioPool');
      await callable.call(<String, dynamic>{'count': count});
      return true;
    } on FirebaseFunctionsException catch (e, st) {
      // not-found / unavailable / failed-precondition are expected before
      // Blaze deploy or while offline — fall back silently.
      DiagnosticsLog.error('ScenarioManager.ensureScenarioPool', e, st, {
        'code': e.code,
        'message': e.message,
      });
      return false;
    } catch (e, st) {
      DiagnosticsLog.error('ScenarioManager.ensureScenarioPool', e, st);
      return false;
    }
  }

  /// Approximate unplayed count among the recent pool page (for UI badges).
  Future<int> unplayedCount() async {
    final uid = _uid();
    if (uid == null || uid.isEmpty) return 0;
    try {
      final unplayed = await played.unplayedFromPool(
        uid: uid,
        pool: pool,
        poolLimit: poolPageSize,
      );
      return unplayed.length;
    } catch (e, st) {
      DiagnosticsLog.error('ScenarioManager.unplayedCount', e, st);
      return 0;
    }
  }

  /// Grades hero action via [LiveCoach], writes played + stats, returns feedback.
  ///
  /// Pass [gradeState] as the pre-action snapshot when the engine has already
  /// advanced (e.g. after [PokerEngine.submitHeroAction]).
  Future<CoachFeedback> gradeAndRecord({
    required ScenarioModel scenario,
    required PokerAction action,
    required PokerEngine engine,
    GameState? gradeState,
    String? coachMessage,
  }) async {
    final spot = gradeState ?? engine.state;
    final live = LiveCoach.grade(state: spot, action: action);
    final correct = live.verdict.isGraded
        ? live.verdict == CoachVerdict.correct
        : engine.gradeHeroAction(action).correct;
    final optimal = live.optimalAction ?? scenario.optimalExploitAction;
    final optimalSizing = live.optimalAction != null
        ? live.optimalSizingBb
        : scenario.optimalSizingBb;
    final evDeltaBb = live.verdict.isGraded
        ? live.evDeltaBb
        : (correct
            ? maxEv(0.25, optimalSizing * 0.05)
            : -maxEv(
                0.5,
                spot.heroInvestedThisHand /
                    (spot.bigBlind < 1 ? 1.0 : spot.bigBlind) *
                    0.15,
              ));

    final uid = _uid();
    if (uid != null && uid.isNotEmpty && scenario.contentHash.isNotEmpty) {
      try {
        await played.markPlayed(
          uid: uid,
          scenarioId: scenario.contentHash,
          wasCorrect: correct,
          evDeltaBb: evDeltaBb,
          street: scenario.street,
          archetype: scenario.villainArchetype.label,
        );
        await users.recordPracticeResult(
          uid: uid,
          wasCorrect: correct,
          evDeltaBb: evDeltaBb,
          street: scenario.street,
          archetype: scenario.villainArchetype.label,
        );
      } catch (e, st) {
        DiagnosticsLog.error('ScenarioManager.gradeAndRecord', e, st);
      }
    }

    final message = coachMessage?.trim().isNotEmpty == true
        ? coachMessage!.trim()
        : (live.message.trim().isNotEmpty
            ? live.message
            : (correct
                ? scenario.exploitReasoning
                : 'Optimal was ${optimal.label}. '
                    '${scenario.exploitReasoning}'));

    final bb = spot.bigBlind;
    return CoachFeedback(
      verdict: correct ? CoachVerdict.correct : CoachVerdict.incorrect,
      message: message,
      optimalAction: optimal,
      optimalSizingBb: optimalSizing,
      heroAction: action.label,
      heroSizingBb: bb > 0 ? action.amount / bb : 0,
      evDeltaBb: evDeltaBb,
      decisionStreet: live.street,
    );
  }

  double maxEv(double a, double b) => a > b ? a : b;

  ScenarioModel _fallbackScenario() {
    _fallbackRotation++;
    // Diverse offline templates — mix streets and playable decisions so Training
    // stays engaging when Firestore / Gemini are unavailable.
    final variants = <Map<String, dynamic>>[
      {
        'name': 'BTN Open vs Nit',
        'table_size': 6,
        'hero_position': 'BTN',
        'hero_hand': ['As', '5s'],
        'board_cards': <String>[],
        'pot_size': 3,
        'villain_seat': 2,
        'villain_archetype': 'Nit',
        'previous_action_narrative':
            'Folds to you on the button; nit in the blinds.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
      },
      {
        'name': 'CO Value Open',
        'table_size': 6,
        'hero_position': 'CO',
        'hero_hand': ['Kh', 'Kd'],
        'board_cards': <String>[],
        'pot_size': 3,
        'villain_seat': 3,
        'villain_archetype': 'Calling Station',
        'previous_action_narrative':
            'Action folds to you in CO; station on the button.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
      },
      {
        'name': 'BB Defend vs Maniac',
        'table_size': 6,
        'hero_position': 'BB',
        'hero_hand': ['Ah', 'Td'],
        'board_cards': <String>[],
        'pot_size': 7,
        'villain_seat': 1,
        'villain_archetype': 'Maniac',
        'previous_action_narrative':
            'Maniac open-raises to 5 from the button; you are in the BB.',
        'villain_action': 'RAISE',
        'call_amount': 3,
        'min_raise': 8,
        'max_raise': 200,
      },
      {
        'name': 'Station Flop Value',
        'table_size': 6,
        'hero_position': 'CO',
        'hero_hand': ['Ah', 'Ad'],
        'board_cards': ['As', '8c', '2d'],
        'pot_size': 24,
        'villain_seat': 3,
        'villain_archetype': 'Calling Station',
        'previous_action_narrative':
            'You raised preflop; station called. Flop checks to you.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
      },
      {
        'name': 'TAG Turn Barrel',
        'table_size': 6,
        'hero_position': 'BTN',
        'hero_hand': ['Qh', 'Jh'],
        'board_cards': ['Th', '9c', '2d', '3h'],
        'pot_size': 36,
        'villain_seat': 2,
        'villain_archetype': 'TAG',
        'previous_action_narrative':
            'You c-bet flop; TAG called. Turn completes flush draw.',
        'villain_action': 'CHECK',
        'call_amount': 0,
        'min_raise': 2,
        'max_raise': 200,
      },
      {
        'name': 'Nit River Overbet',
        'table_size': 6,
        'hero_position': 'BB',
        'hero_hand': ['Kc', 'Qd'],
        'board_cards': ['Kh', '7s', '2c', '9d', '3h'],
        'pot_size': 40,
        'villain_seat': 1,
        'villain_archetype': 'Nit',
        'previous_action_narrative':
            'Nit bets river for 30 into 40 after a passive line.',
        'villain_action': 'RAISE',
        'call_amount': 30,
        'min_raise': 60,
        'max_raise': 200,
      },
      {
        'name': 'LAG Flop Probe',
        'table_size': 6,
        'hero_position': 'BB',
        'hero_hand': ['9s', '9d'],
        'board_cards': ['Tc', '6h', '2s'],
        'pot_size': 18,
        'villain_seat': 4,
        'villain_archetype': 'LAG',
        'previous_action_narrative':
            'LAG opened; you defended BB. Flop LAG bets half pot.',
        'villain_action': 'RAISE',
        'call_amount': 9,
        'min_raise': 18,
        'max_raise': 200,
      },
      {
        'name': 'HJ 3-Bet Pot',
        'table_size': 6,
        'hero_position': 'HJ',
        'hero_hand': ['Ac', 'Kc'],
        'board_cards': <String>[],
        'pot_size': 15,
        'villain_seat': 2,
        'villain_archetype': 'LAG',
        'previous_action_narrative':
            'You open HJ to 5; LAG 3-bets to 15 from the button.',
        'villain_action': 'RAISE',
        'call_amount': 10,
        'min_raise': 25,
        'max_raise': 200,
      },
    ];
    final raw = variants[_fallbackRotation % variants.length];
    return ScenarioModel.fromGeminiJson(raw);
  }

  static int _fallbackRotation = 0;
}
