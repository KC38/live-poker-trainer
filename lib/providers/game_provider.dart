/// Table session state: practice / cash sim, coach verdict, prefetch.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// UI-facing table session snapshot.
class TableSession {
  /// Creates a table session.
  const TableSession({
    this.game,
    this.coach = const CoachFeedback(),
    this.loading = false,
    this.error,
    this.showEvAudit = false,
    this.lastAction,
  });

  final GameState? game;
  final CoachFeedback coach;
  final bool loading;
  final String? error;
  final bool showEvAudit;
  final PokerAction? lastAction;

  TableSession copyWith({
    GameState? game,
    CoachFeedback? coach,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? showEvAudit,
    PokerAction? lastAction,
    bool clearLastAction = false,
  }) {
    return TableSession(
      game: game ?? this.game,
      coach: coach ?? this.coach,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      showEvAudit: showEvAudit ?? this.showEvAudit,
      lastAction: clearLastAction ? null : (lastAction ?? this.lastAction),
    );
  }
}

/// Controls poker table flow and coach grading.
class GameController extends StateNotifier<TableSession> {
  GameController(this._ref) : super(const TableSession());

  final Ref _ref;
  PokerEngine? _engine;

  GameSettingsModel get _settings => _ref.read(settingsProvider);

  /// Starts Practice mode with a cached / generated scenario.
  Future<void> startPractice() async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      coach: const CoachFeedback(),
      showEvAudit: false,
    );
    try {
      final manager = _ref.read(scenarioManagerProvider);
      final sound = _ref.read(soundServiceProvider);
      await sound.unlock();

      final scenario = await manager.nextScenario();
      _engine = PokerEngine(settings: _settings)
        ..startPracticeScenario(scenario);
      await sound.card();
      state = TableSession(game: _engine!.state, loading: false);

      // Fire-and-forget prefetch.
      // ignore: unawaited_futures
      manager.maybePrefetch();
    } catch (e) {
      state = state.copyWith(loading: false, error: '$e');
    }
  }

  /// Starts a cash game simulation hand.
  Future<void> startCashSim({bool continueTable = false}) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      coach: const CoachFeedback(),
      showEvAudit: false,
    );
    try {
      final sound = _ref.read(soundServiceProvider);
      await sound.unlock();
      final existing = continueTable ? state.game?.players : null;
      _engine = PokerEngine(settings: _settings)
        ..startCashHand(existingPlayers: existing);
      await sound.card();
      state = TableSession(game: _engine!.state, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: '$e');
    }
  }

  /// Applies a hero action; grades in Practice mode.
  Future<void> heroAct(PokerAction action) async {
    final engine = _engine;
    final game = state.game;
    if (engine == null || game == null || !game.waitingForHero) return;

    final sound = _ref.read(soundServiceProvider);
    switch (action.type) {
      case PokerActionType.fold:
        await sound.fold();
      case PokerActionType.check:
        await sound.knock();
      case PokerActionType.call:
      case PokerActionType.bet:
      case PokerActionType.raise:
      case PokerActionType.allIn:
        await sound.chip();
    }

    var coach = state.coach;
    if (game.mode == GameMode.practice && game.activeScenario != null) {
      coach = coach.copyWith(verdict: CoachVerdict.pending);
      state = state.copyWith(coach: coach);

      final manager = _ref.read(scenarioManagerProvider);
      final gemini = _ref.read(geminiServiceProvider);
      final settings = _settings;

      final gradeFeedback = await manager.gradeAndRecord(
        scenario: game.activeScenario!,
        action: action,
        engine: engine,
      );

      String message = gradeFeedback.message;
      try {
        final prompt =
            'Hero acted ${action.label} vs ${game.activeScenario!.villainArchetype.label}. '
            'Verdict: ${gradeFeedback.verdict.name}. '
            'Spot: ${game.activeScenario!.previousActionNarrative}. '
            'Optimal: ${game.activeScenario!.optimalExploitAction.label}. '
            'Give a punchy coaching line.';
        final result = await gemini.coach(
          prompt: prompt,
          wantAudio: settings.ttsEnabled,
        );
        if (result.text.trim().isNotEmpty) {
          message = result.text.trim();
        }
        if (result.audioBytes != null) {
          await sound.playCoachAudio(result.audioBytes!);
        }
      } catch (_) {
        // Keep offline exploit reasoning.
      }

      coach = gradeFeedback.copyWith(message: message);
    }

    final next = engine.applyHeroAction(action);
    state = state.copyWith(
      game: next,
      coach: coach,
      lastAction: action,
      showEvAudit: next.isHandOver && next.mode == GameMode.practice,
    );

    // Refresh stats cache.
    _ref.invalidate(userStatsProvider);
  }

  void dismissEvAudit() {
    state = state.copyWith(showEvAudit: false);
  }

  void clearCoach() {
    state = state.copyWith(coach: const CoachFeedback());
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, TableSession>(
  GameController.new,
);

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final dao = ref.watch(userStatsDaoProvider);
  return dao.getStats();
});

final unplayedCountProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(scenarioDaoProvider);
  return dao.unplayedCount();
});
