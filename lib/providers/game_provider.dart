/// Online server-authoritative live training session state.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/models/table_setup.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// Pacing for replayed server actions.
class ReplayPace {
  ReplayPace._();

  static double testScale = 1;

  static Duration _scaled(int milliseconds) =>
      Duration(microseconds: (milliseconds * 1000 * testScale).round());

  static Duration get deal => _scaled(420);
  static Duration get passiveAction => _scaled(420);
  static Duration get chipAction => _scaled(620);
  static Duration get collectPot => _scaled(360);
  static Duration get dealStreet => _scaled(560);
  static Duration get handOver => _scaled(700);
}

/// UI-facing online table snapshot.
@immutable
class TableSession {
  const TableSession({
    this.game,
    this.liveView,
    this.coach = const CoachFeedback(),
    this.loading = false,
    this.error,
    this.replaying = false,
    this.collectingChips = false,
    this.awardingChips = false,
    this.liveActions = const [],
    List<HeroActionEdge> authoredHeroEdges = const [],
    // The public compatibility argument cannot initialize a private named
    // field directly without changing its call-site name.
    // ignore: prefer_initializing_formals
  }) : _authoredHeroEdges = authoredHeroEdges;

  final GameState? game;
  final LiveHandViewModel? liveView;
  final CoachFeedback coach;
  final bool loading;
  final String? error;
  final bool replaying;
  final bool collectingChips;
  final bool awardingChips;
  final List<LiveLegalActionModel> liveActions;
  final List<HeroActionEdge> _authoredHeroEdges;

  /// Compatibility surface retained while legacy graph tests are retired.
  List<HeroActionEdge> get authoredHeroEdges => _authoredHeroEdges;

  bool get heroCanAct {
    final current = game;
    if (current == null ||
        !current.waitingForHero ||
        current.isHandOver ||
        replaying ||
        loading) {
      return false;
    }
    if (liveView != null) return liveActions.isNotEmpty;
    return (liveActions.isNotEmpty ||
        _authoredHeroEdges.isNotEmpty ||
        current.activeSituation == null);
  }

  bool get heroDoneForHand =>
      game != null && !loading && (game!.isHandOver || game!.hero.folded);

  bool get highlightNext => game != null && game!.isHandOver && !loading;

  TableSession copyWith({
    GameState? game,
    LiveHandViewModel? liveView,
    CoachFeedback? coach,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? replaying,
    bool? collectingChips,
    bool? awardingChips,
    List<LiveLegalActionModel>? liveActions,
    List<HeroActionEdge>? authoredHeroEdges,
    bool clearAuthoredHeroEdges = false,
  }) {
    return TableSession(
      game: game ?? this.game,
      liveView: liveView ?? this.liveView,
      coach: coach ?? this.coach,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      replaying: replaying ?? this.replaying,
      collectingChips: collectingChips ?? this.collectingChips,
      awardingChips: awardingChips ?? this.awardingChips,
      liveActions: liveActions ?? this.liveActions,
      authoredHeroEdges:
          clearAuthoredHeroEdges
              ? const []
              : (authoredHeroEdges ?? _authoredHeroEdges),
    );
  }
}

/// Coordinates online hand creation, idempotent Hero actions, and replay.
class GameController extends StateNotifier<TableSession> {
  GameController(this._ref) : super(const TableSession()) {
    if (kDebugMode) {
      _agentSubscription = AgentCommands.stream.listen(_onAgentCommand);
    }
  }

  final Ref _ref;
  StreamSubscription<String>? _agentSubscription;
  int _replayToken = 0;
  int _handCount = 0;
  int _idempotencyCounter = 0;
  bool _disposed = false;

  String get sessionId => state.liveView?.sessionId ?? '';

  /// Compatibility fingerprint used by setup tests.
  static String setupFingerprint(TableSetup setup) =>
      jsonEncode(setup.toCallableMap());

  @override
  void dispose() {
    _disposed = true;
    _replayToken++;
    unawaited(_agentSubscription?.cancel());
    super.dispose();
  }

  void prepareTraining() {
    _replayToken++;
    state = const TableSession(loading: true);
  }

  Future<void> startTraining({bool continueTable = false}) async {
    final token = ++_replayToken;
    state = TableSession(game: state.game, loading: true, replaying: false);
    final uid = _ref.read(authUidProvider);
    if (uid == null || uid.isEmpty) {
      state = state.copyWith(
        loading: false,
        error: 'Sign in required to train.',
      );
      return;
    }
    try {
      final sound = _ref.read(soundServiceProvider);
      await sound.unlock();
      final result = await _ref
          .read(liveHandServiceProvider)
          .startHand(_ref.read(settingsProvider));
      if (_disposed || token != _replayToken) return;
      _handCount++;
      await sound.deal();
      if (_disposed || token != _replayToken) return;
      state = TableSession(
        game: result.view.toGameState(handCount: _handCount),
        liveView: result.view,
        liveActions: result.view.legalActions,
      );
    } catch (error) {
      if (_disposed || token != _replayToken) return;
      state = state.copyWith(loading: false, replaying: false, error: '$error');
    }
  }

  Future<void> startPractice() => startTraining();

  Future<void> startCashSim({bool continueTable = false}) =>
      startTraining(continueTable: continueTable);

  Future<void> nextHand() async {
    if (!state.heroDoneForHand) return;
    await startTraining(continueTable: false);
  }

  /// Sends one exact legal action id to the authoritative server.
  Future<void> heroActLive(LiveLegalActionModel action) async {
    final view = state.liveView;
    if (view == null || !state.heroCanAct) return;
    if (!state.liveActions.any(
      (candidate) => candidate.actionId == action.actionId,
    )) {
      return;
    }
    final token = ++_replayToken;
    state = state.copyWith(
      replaying: true,
      liveActions: const [],
      clearError: true,
    );
    try {
      final result = await _ref
          .read(liveHandServiceProvider)
          .submitAction(
            view: view,
            action: action,
            idempotencyKey: _newIdempotencyKey(),
          );
      if (_disposed || token != _replayToken) return;
      final coaching = _feedback(result.coaching, action, view.street);
      state = state.copyWith(coach: coaching, replaying: true);
      await _replayEvents(result.events, result.view, token);
      if (_disposed || token != _replayToken) return;
      final game = result.view.toGameState(handCount: _handCount);
      // Coaching grades the action just played. Keep it through the replay and
      // after the hand ends, but drop it once a new decision is on the dock.
      // Otherwise a turn "INCORRECT" check sits next to river fold/call buttons.
      final nextDecision =
          !game.isHandOver && result.view.legalActions.isNotEmpty;
      state = TableSession(
        game: game,
        liveView: result.view,
        coach: nextDecision ? const CoachFeedback() : coaching,
        liveActions: result.view.legalActions,
        awardingChips: game.isHandOver && game.winnerIds.isNotEmpty,
      );
      if (state.awardingChips) {
        await _ref.read(soundServiceProvider).chip();
        await Future<void>.delayed(ReplayPace.handOver);
        if (!_disposed && token == _replayToken) {
          state = state.copyWith(awardingChips: false);
        }
      }
    } catch (error) {
      if (_disposed || token != _replayToken) return;
      state = state.copyWith(
        replaying: false,
        liveActions: view.legalActions,
        error: '$error',
      );
    }
  }

  /// Compatibility adapter used by keyboard shortcuts and older widget tests.
  Future<void> heroAct(PokerAction action) async {
    final candidates =
        state.liveActions.where((candidate) {
          final expected = switch (action.type) {
            PokerActionType.fold => 'FOLD',
            PokerActionType.check => 'CHECK',
            PokerActionType.call => 'CALL',
            PokerActionType.bet => 'BET',
            PokerActionType.raise => 'RAISE',
            PokerActionType.allIn => 'ALL_IN',
          };
          if (candidate.kind != expected) return false;
          if (candidate.amountTo == null || action.amount <= 0) return true;
          return Money.same(candidate.amountTo!, action.amount);
        }).toList();
    if (candidates.length == 1) await heroActLive(candidates.single);
  }

  Future<void> debugHeroShortcut(String command) async {
    if (!state.heroCanAct) return;
    final kind = switch (command) {
      'fold' => 'FOLD',
      'check' => 'CHECK',
      'call' => 'CALL',
      'bet' => 'BET',
      'raise' => 'RAISE',
      _ => '',
    };
    final matching =
        state.liveActions.where((action) => action.kind == kind).toList();
    if (matching.length == 1) await heroActLive(matching.single);
  }

  Future<void> resumeCurrentHand() async {
    final sessionId = state.liveView?.sessionId;
    if (sessionId == null || sessionId.isEmpty) return;
    final token = ++_replayToken;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _ref
          .read(liveHandServiceProvider)
          .resumeHand(sessionId);
      if (_disposed || token != _replayToken) return;
      state = TableSession(
        game: result.view.toGameState(handCount: _handCount),
        liveView: result.view,
        liveActions: result.view.legalActions,
      );
    } catch (error) {
      if (_disposed || token != _replayToken) return;
      state = state.copyWith(loading: false, error: '$error');
    }
  }

  Future<void> _replayEvents(
    List<LiveActionEventModel> events,
    LiveHandViewModel finalView,
    int token,
  ) async {
    final sound = _ref.read(soundServiceProvider);
    for (final event in events) {
      if (_disposed || token != _replayToken) return;
      var game = state.game;
      if (game == null) return;
      final eventStreet = Street.values.firstWhere(
        (street) => street.name == event.street,
        orElse: () => game!.street,
      );
      if (eventStreet != game.street) {
        state = state.copyWith(collectingChips: true);
        await sound.chip();
        await Future<void>.delayed(ReplayPace.collectPot);
        if (_disposed || token != _replayToken) return;
        final collected = game.players.fold<double>(
          0,
          (total, player) => total + player.currentBet,
        );
        final boardCount = switch (eventStreet) {
          Street.preflop => 0,
          Street.flop => 3,
          Street.turn => 4,
          Street.river || Street.showdown => 5,
        };
        game = game.copyWith(
          players: [
            for (final player in game.players)
              player.copyWith(
                currentBet: 0,
                hasActedThisRound: false,
                clearLastAction: true,
              ),
          ],
          mainPot: game.mainPot + collected,
          street: eventStreet,
          community: finalView.board.take(boardCount).toList(growable: false),
          highestBet: 0,
          waitingForHero: false,
        );
        state = state.copyWith(game: game, collectingChips: false);
        await sound.deal();
        await Future<void>.delayed(ReplayPace.dealStreet);
      }
      game = _applyReplayEvent(game, event);
      state = state.copyWith(game: game);
      await _playActionSound(sound, event.kind);
      await Future<void>.delayed(
        event.kind == 'CHECK' || event.kind == 'FOLD'
            ? ReplayPace.passiveAction
            : ReplayPace.chipAction,
      );
    }
    var game = state.game;
    while (game != null &&
        game.street.index < finalView.street.index &&
        game.street != Street.showdown) {
      final nextStreet = game.street.next;
      if (nextStreet == null || nextStreet == Street.showdown) break;
      final collected = game.players.fold<double>(
        0,
        (total, player) => total + player.currentBet,
      );
      final boardCount = switch (nextStreet) {
        Street.preflop => 0,
        Street.flop => 3,
        Street.turn => 4,
        Street.river || Street.showdown => 5,
      };
      game = game.copyWith(
        players: [
          for (final player in game.players)
            player.copyWith(currentBet: 0, clearLastAction: true),
        ],
        mainPot: game.mainPot + collected,
        street: nextStreet,
        community: finalView.board.take(boardCount).toList(growable: false),
        highestBet: 0,
        waitingForHero: false,
      );
      state = state.copyWith(game: game, collectingChips: false);
      await sound.deal();
      await Future<void>.delayed(ReplayPace.dealStreet);
      if (_disposed || token != _replayToken) return;
    }
  }

  static GameState _applyReplayEvent(
    GameState game,
    LiveActionEventModel event,
  ) {
    if (event.seat < 0 || event.seat >= game.players.length) return game;
    final players = [...game.players];
    final player = players[event.seat];
    final target = event.amountTo ?? player.currentBet;
    final added = Money.roundNonNegative(
      target - player.currentBet,
    ).clamp(0, player.stack);
    players[event.seat] = player.copyWith(
      stack: Money.roundNonNegative(player.stack - added),
      currentBet: Money.round(player.currentBet + added),
      folded: event.kind == 'FOLD' || player.folded,
      allIn: event.kind == 'ALL_IN' || player.stack - added <= Money.epsilon,
      hasActedThisRound: true,
      lastActionLabel: event.kind.replaceAll('_', '-'),
    );
    final highest = players.fold<double>(
      0,
      (value, seat) => seat.currentBet > value ? seat.currentBet : value,
    );
    return game.copyWith(
      players: players,
      activePlayerIndex: event.seat,
      highestBet: highest,
      waitingForHero: false,
    );
  }

  static Future<void> _playActionSound(SoundService sound, String kind) async {
    switch (kind) {
      case 'BET':
      case 'RAISE':
      case 'CALL':
      case 'ALL_IN':
        return sound.chip();
      case 'FOLD':
        return sound.fold();
      case 'CHECK':
        return;
    }
  }

  CoachFeedback _feedback(
    LiveCoachingAssessment assessment,
    LiveLegalActionModel action,
    Street street,
  ) {
    final verdict = switch (assessment.rating) {
      'recommended' || 'strong' => CoachVerdict.correct,
      'reasonable' => CoachVerdict.close,
      _ => CoachVerdict.incorrect,
    };
    final playedLabel = action.label.toUpperCase();
    final betterLabel =
        viewActionLabel(
          state.liveView?.legalActions ?? const [],
          assessment.betterActionId,
        ) ??
        // The recommended line omits betterActionId; it is the action played.
        (assessment.rating == 'recommended' ? playedLabel : null);
    return CoachFeedback(
      verdict: verdict,
      message: assessment.message,
      optimalActionLabel: betterLabel,
      heroAction: action.label,
      heroSizingBb:
          action.amountTo == null
              ? 0
              : action.amountTo! / (state.game?.bigBlind ?? 1),
      decisionStreet: street,
      confidence: assessment.confidence,
    );
  }

  static String? viewActionLabel(
    List<LiveLegalActionModel> actions,
    String? actionId,
  ) {
    if (actionId == null) return null;
    for (final action in actions) {
      if (action.actionId == actionId) return action.label.toUpperCase();
    }
    return null;
  }

  String _newIdempotencyKey() {
    _idempotencyCounter++;
    return 'd${DateTime.now().microsecondsSinceEpoch}_$_idempotencyCounter';
  }

  void _onAgentCommand(String command) {
    if (command == 'next') {
      unawaited(nextHand());
    } else {
      unawaited(debugHeroShortcut(command));
    }
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, TableSession>(GameController.new);

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return const UserStatsModel();
  return ref.read(progressRepositoryProvider).loadStats(uid);
});
