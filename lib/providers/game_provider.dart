/// Table session state: unified full-hand training with live coach.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
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
    this.voiceHintShown = false,
  });

  final GameState? game;
  final CoachFeedback coach;
  final bool loading;
  final String? error;
  final bool showEvAudit;
  final PokerAction? lastAction;
  final bool voiceHintShown;

  TableSession copyWith({
    GameState? game,
    CoachFeedback? coach,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? showEvAudit,
    PokerAction? lastAction,
    bool clearLastAction = false,
    bool? voiceHintShown,
  }) {
    return TableSession(
      game: game ?? this.game,
      coach: coach ?? this.coach,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      showEvAudit: showEvAudit ?? this.showEvAudit,
      lastAction: clearLastAction ? null : (lastAction ?? this.lastAction),
      voiceHintShown: voiceHintShown ?? this.voiceHintShown,
    );
  }
}

/// Controls poker table flow and coach grading.
class GameController extends StateNotifier<TableSession> {
  GameController(this._ref) : super(const TableSession());

  final Ref _ref;
  PokerEngine? _engine;
  bool _voiceHintShown = false;

  GameSettingsModel get _settings => _ref.read(settingsProvider);

  /// Starts (or restarts) unified full-hand training.
  Future<void> startTraining({bool continueTable = false}) async {
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
      final engine = _engine;
      if (continueTable && engine != null) {
        engine.updateSettings(_settings);
        engine.startHand(existingPlayers: existing);
        _engine = engine;
      } else {
        _engine = PokerEngine(settings: _settings)
          ..startHand(existingPlayers: existing);
      }
      await sound.card();
      state = TableSession(
        game: _engine!.state,
        loading: false,
        voiceHintShown: _voiceHintShown,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: '$e');
    }
  }

  /// Legacy alias — same as [startTraining].
  Future<void> startPractice() => startTraining();

  /// Legacy alias — same as [startTraining].
  Future<void> startCashSim({bool continueTable = false}) =>
      startTraining(continueTable: continueTable);

  /// Deals the next hand at the same table.
  Future<void> nextHand() => startTraining(continueTable: true);

  /// Applies a hero action and grades / coaches live.
  Future<void> heroAct(PokerAction action) async {
    final engine = _engine;
    final game = state.game;
    if (engine == null || game == null || !game.waitingForHero) return;
    if (game.hero.folded || game.isHandOver) return;

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

    // Grade against the pre-action snapshot.
    final grade = LiveCoach.grade(state: game, action: action);
    var coach = CoachFeedback(
      verdict: grade.verdict == CoachVerdict.none
          ? CoachVerdict.pending
          : grade.verdict,
      message: grade.message,
      optimalAction: grade.optimalAction,
      optimalSizingBb: grade.optimalSizingBb,
      heroAction: action.label,
      evDeltaBb: grade.evDeltaBb,
    );
    state = state.copyWith(coach: coach);

    final settings = _settings;
    final gemini = _ref.read(geminiServiceProvider);
    final villain = game.players
        .where((p) => !p.isHero && !p.folded)
        .map((p) => p.archetype.label)
        .take(2)
        .join(', ');

    String message = grade.message;
    try {
      final prompt =
          'Street: ${game.street.label}. Pot: ${game.totalPot.toStringAsFixed(0)}. '
          'Hero acted ${action.label}. Villains: ${villain.isEmpty ? 'none' : villain}. '
          'Board: ${game.community.map((c) => c.code).join(' ')}. '
          'Hole: ${game.hero.holeCards.map((c) => c.code).join(' ')}. '
          'Heuristic verdict: ${grade.verdict.name}. '
          '${grade.optimalAction != null ? 'Suggested: ${grade.optimalAction!.label}.' : ''} '
          'Give a punchy coaching line for this decision.';
      final result = await gemini.coach(
        prompt: prompt,
        wantAudio: settings.ttsEnabled,
      );
      if (result.text.trim().isNotEmpty) {
        message = result.text.trim();
      }
      final playback = await sound.playCoachVoice(
        text: message,
        audioBytes: result.audioBytes,
        audioMimeType: result.audioMimeType,
        hasApiKey: Config.hasGeminiKey,
      );
      String? voiceNote = playback.note;
      if (voiceNote != null && _voiceHintShown) {
        // Only surface the missing-key / mute hint once per session.
        if (voiceNote.contains('API key') || voiceNote.contains('muted')) {
          voiceNote = null;
        }
      }
      if (playback.note != null &&
          (playback.note!.contains('API key') ||
              playback.note!.contains('muted'))) {
        _voiceHintShown = true;
      }
      coach = coach.copyWith(
        message: message,
        verdict: grade.verdict,
        voiceNote: voiceNote,
        isSpeaking: playback.spoke,
      );
    } catch (_) {
      final playback = await sound.playCoachVoice(
        text: message,
        hasApiKey: Config.hasGeminiKey,
      );
      coach = coach.copyWith(
        message: message,
        verdict: grade.verdict,
        voiceNote: _voiceHintShown ? null : playback.note,
        isSpeaking: playback.spoke,
      );
      if (playback.note != null) _voiceHintShown = true;
    }

    if (grade.verdict == CoachVerdict.correct ||
        grade.verdict == CoachVerdict.incorrect) {
      final stats = _ref.read(userStatsDaoProvider);
      await stats.recordPracticeResult(
        wasCorrect: grade.verdict == CoachVerdict.correct,
        evDeltaBb: grade.evDeltaBb,
        street: game.street.label,
        archetype: villain.isEmpty ? 'Mixed' : villain.split(',').first.trim(),
      );
      _ref.invalidate(userStatsProvider);
    }

    final next = engine.applyHeroAction(action);
    final showAudit = next.isHandOver && coach.hasVerdict;
    state = state.copyWith(
      game: next,
      coach: coach.copyWith(
        verdict: grade.verdict == CoachVerdict.pending
            ? CoachVerdict.none
            : grade.verdict,
      ),
      lastAction: action,
      showEvAudit: showAudit,
      voiceHintShown: _voiceHintShown,
    );
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
