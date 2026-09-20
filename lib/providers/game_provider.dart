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
import 'package:live_poker_trainer/models/card_model.dart';
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
    this.waitingOnSeat,
    this.awaitingCoach = false,
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

  /// Villain seat whose LLM decision is in flight, if any.
  final int? waitingOnSeat;

  /// True while the server is generating the next coaching rubric.
  final bool awaitingCoach;
  final List<HeroActionEdge> _authoredHeroEdges;

  /// Compatibility surface retained while legacy graph tests are retired.
  List<HeroActionEdge> get authoredHeroEdges => _authoredHeroEdges;

  bool get heroCanAct {
    final current = game;
    if (current == null ||
        !current.waitingForHero ||
        current.isHandOver ||
        replaying ||
        loading ||
        // Hold the dock until the player dismisses coaching for the last act.
        coach.hasAdvice) {
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
    int? waitingOnSeat,
    bool clearWaitingOnSeat = false,
    bool? awaitingCoach,
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
      waitingOnSeat:
          clearWaitingOnSeat ? null : (waitingOnSeat ?? this.waitingOnSeat),
      awaitingCoach: awaitingCoach ?? this.awaitingCoach,
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

  /// Clears coaching so the next decision's action dock can appear.
  void dismissCoach() {
    if (!state.coach.hasAdvice) return;
    state = state.copyWith(coach: const CoachFeedback());
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
    // Coach prep starts immediately so the reviewing shelf can sit beside
    // seat wait timers while villains (and the next rubric) resolve.
    state = state.copyWith(
      replaying: true,
      liveActions: const [],
      awaitingCoach: true,
      clearWaitingOnSeat: true,
      clearError: true,
    );
    var appliedCount = 0;
    Future<void> drain = Future<void>.value();
    Future<void> enqueueReplay(
      List<LiveActionEventModel> events,
      List<String> boardCodes,
    ) {
      drain = drain.then((_) async {
        if (_disposed || token != _replayToken) return;
        if (appliedCount >= events.length) return;
        final slice = events.sublist(appliedCount);
        appliedCount = events.length;
        await _replayEvents(slice, boardCodes, token);
      });
      return drain;
    }

    final feedSubscription = _ref
        .read(liveHandServiceProvider)
        .watchActionFeed(
          sessionId: view.sessionId,
          decisionId: view.decisionId,
        )
        .listen(
          (update) {
            if (_disposed || token != _replayToken) return;
            final heroSeat = state.game?.hero.id;
            final waiting =
                update.isCoaching
                    ? null
                    : (update.waitingOnSeat != null &&
                        update.waitingOnSeat != heroSeat)
                    ? update.waitingOnSeat
                    : null;
            // Keep coach prep sticky through "acting" snapshots so seat timers
            // and the reviewing shelf can show together.
            state = state.copyWith(
              awaitingCoach: state.awaitingCoach || update.isCoaching,
              waitingOnSeat: waiting,
              clearWaitingOnSeat: waiting == null,
            );
            unawaited(enqueueReplay(update.events, update.board));
          },
          // Rules lag / transient denials must not surface as unhandled
          // Crashlytics errors; submitAction still returns the full event list.
          onError: (Object error, StackTrace stack) {
            debugPrint('liveActionFeed error: $error');
          },
          cancelOnError: false,
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
      // Show coaching as soon as the server grades the act; villains may still
      // be animating from the action feed / remaining callable events.
      state = state.copyWith(
        coach: coaching,
        replaying: true,
        awaitingCoach: false,
        clearWaitingOnSeat: true,
      );
      await enqueueReplay(
        result.events,
        result.view.board.map((card) => card.code).toList(growable: false),
      );
      if (_disposed || token != _replayToken) return;
      final game = result.view.toGameState(handCount: _handCount);
      // Keep coaching up until the player dismisses it. The next dock stays
      // gated by [TableSession.heroCanAct] while advice is visible; replay and
      // legal actions are already settled underneath.
      state = TableSession(
        game: game,
        liveView: result.view,
        coach: coaching,
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
        awaitingCoach: false,
        clearWaitingOnSeat: true,
        error: '$error',
      );
    } finally {
      await feedSubscription.cancel();
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
    final parsed = _parseAgentHeroCommand(command);
    if (parsed == null) return;
    var matching =
        state.liveActions.where((action) {
          if (!parsed.kinds.contains(action.kind)) return false;
          if (parsed.amountTo == null) return true;
          if (action.amountTo == null) return false;
          return Money.same(action.amountTo!, parsed.amountTo!);
        }).toList();
    // Facing a shove, the server often exposes "Call all-in $N" as CALL rather
    // than ALL_IN. Let bare `allin` still fire that call.
    if (matching.isEmpty && parsed.kinds.contains('ALL_IN')) {
      matching =
          state.liveActions.where((action) {
            if (action.kind != 'CALL') return false;
            return action.label.toLowerCase().contains('all-in');
          }).toList();
    }
    if (matching.isEmpty) return;
    if (matching.length == 1) {
      await heroActLive(matching.single);
      return;
    }
    // Bare raise/bet with several sizes: pick the middle preset so play-tests
    // can size without knowing the exact chip amount up front.
    await heroActLive(matching[matching.length ~/ 2]);
  }

  /// Parses debug bus tokens like `raise`, `raise:45`, `bet:95`, `allin`.
  ///
  /// `raise` and `bet` both match either BET or RAISE legal actions so the
  /// agent can fire the same verb on an open street or facing a bet.
  ({Set<String> kinds, double? amountTo})? _parseAgentHeroCommand(
    String command,
  ) {
    final raw = command.trim().toLowerCase();
    if (raw.isEmpty) return null;
    final match = RegExp(
      r'^(fold|check|call|bet|raise|allin|all_in|all-in)'
      r'(?:[:_=\s]+\$?([\d.]+))?$',
    ).firstMatch(raw);
    if (match == null) return null;
    final verb = match.group(1)!;
    final amount = double.tryParse(match.group(2) ?? '');
    final kinds = switch (verb) {
      'fold' => {'FOLD'},
      'check' => {'CHECK'},
      'call' => {'CALL'},
      'bet' || 'raise' => {'BET', 'RAISE'},
      'allin' || 'all_in' || 'all-in' => {'ALL_IN'},
      _ => <String>{},
    };
    if (kinds.isEmpty) return null;
    return (kinds: kinds, amountTo: amount);
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
    List<String> boardCodes,
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
          community:
              boardCodes
                  .take(boardCount)
                  .map(CardModel.fromCode)
                  .toList(growable: false),
          highestBet: 0,
          waitingForHero: false,
        );
        state = state.copyWith(game: game, collectingChips: false);
        await sound.deal();
        await Future<void>.delayed(ReplayPace.dealStreet);
      }
      game = applyLiveReplayEvent(game, event);
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
        game.street.index < _streetIndexFromBoard(boardCodes) &&
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
        community:
            boardCodes
                .take(boardCount)
                .map(CardModel.fromCode)
                .toList(growable: false),
        highestBet: 0,
        waitingForHero: false,
      );
      state = state.copyWith(game: game, collectingChips: false);
      await sound.deal();
      await Future<void>.delayed(ReplayPace.dealStreet);
      if (_disposed || token != _replayToken) return;
    }
  }

  static int _streetIndexFromBoard(List<String> boardCodes) {
    return switch (boardCodes.length) {
      0 => Street.preflop.index,
      3 => Street.flop.index,
      4 => Street.turn.index,
      _ => Street.river.index,
    };
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
    return buildLiveCoachFeedback(
      assessment: assessment,
      action: action,
      legalActions: state.liveView?.legalActions ?? const [],
      street: street,
      bigBlind: state.game?.bigBlind ?? 1,
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
    final cmd = command.trim().toLowerCase();
    // Mid-hand coach: Next is hidden in the UI; agent `next`/`dismiss` clears
    // the shelf so the dock can return. Hand-over still advances via nextHand.
    if (cmd == 'next' || cmd == 'dismiss') {
      if (state.coach.hasAdvice && !state.heroDoneForHand) {
        dismissCoach();
        return;
      }
      unawaited(nextHand());
      return;
    }
    // Mirror the table Retry banner: resume mid-hand, next when over, else deal.
    if (cmd == 'retry' || cmd == 'resume') {
      unawaited(_agentRetryOrResume());
      return;
    }
    // HomeScreen owns cold `start` from the lobby. On-table, start a fresh hand.
    if (cmd == 'start') {
      if (state.game != null) {
        unawaited(startTraining(continueTable: false));
      }
      return;
    }
    unawaited(debugHeroShortcut(command));
  }

  /// Test hook for the debug agent command bus.
  @visibleForTesting
  void debugHandleAgentCommand(String command) => _onAgentCommand(command);

  /// Debug-bus counterpart to the server-error / empty-table Retry buttons.
  Future<void> _agentRetryOrResume() async {
    final game = state.game;
    if (game == null) {
      await startTraining();
      return;
    }
    if (game.isHandOver) {
      await nextHand();
      return;
    }
    await resumeCurrentHand();
  }
}

/// Applies one live-table action event onto a client [GameState] for replay.
GameState applyLiveReplayEvent(
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
  // Match the server: a bet/raise reopens seats that still owe chips, so
  // their CHECK (or call) pill must clear during client-side replay too.
  final aggressive =
      event.kind == 'BET' ||
      event.kind == 'RAISE' ||
      event.kind == 'ALL_IN';
  if (aggressive && highest > game.highestBet + Money.epsilon) {
    for (var i = 0; i < players.length; i++) {
      if (i == event.seat) continue;
      final other = players[i];
      if (other.folded || other.allIn) continue;
      if (other.currentBet + Money.epsilon >= highest) continue;
      players[i] = other.copyWith(
        hasActedThisRound: false,
        clearLastAction: true,
      );
    }
  }
  return game.copyWith(
    players: players,
    activePlayerIndex: event.seat,
    highestBet: highest,
    waitingForHero: false,
  );
}

/// Maps a live coaching assessment onto shelf feedback.
CoachFeedback buildLiveCoachFeedback({
  required LiveCoachingAssessment assessment,
  required LiveLegalActionModel action,
  required List<LiveLegalActionModel> legalActions,
  required Street street,
  required double bigBlind,
}) {
  final verdict = switch (assessment.rating) {
    // Only the single recommended line is CORRECT; strong is a good
    // non-best alternative and should read as CLOSE like reasonable.
    'recommended' => CoachVerdict.correct,
    'strong' || 'reasonable' => CoachVerdict.close,
    _ => CoachVerdict.incorrect,
  };
  final bb = bigBlind <= 0 ? 1.0 : bigBlind;
  LiveLegalActionModel? betterAction;
  final betterId = assessment.betterActionId;
  if (betterId != null) {
    for (final candidate in legalActions) {
      if (candidate.actionId == betterId) {
        betterAction = candidate;
        break;
      }
    }
  }
  final playedLabel = action.label.toUpperCase();
  final betterLabel =
      betterAction?.label.toUpperCase() ??
      // The recommended line omits betterActionId; it is the action played.
      (assessment.rating == 'recommended' ? playedLabel : null);
  final optimalAction =
      betterAction ?? (assessment.rating == 'recommended' ? action : null);
  return CoachFeedback(
    verdict: verdict,
    message: assessment.message,
    optimalActionLabel: betterLabel,
    heroAction: action.label,
    heroSizingBb: action.amountTo == null ? 0 : action.amountTo! / bb,
    optimalSizingBb:
        optimalAction?.amountTo == null ? 0 : optimalAction!.amountTo! / bb,
    decisionStreet: street,
    confidence: assessment.confidence,
  );
}

final gameControllerProvider =
    StateNotifierProvider<GameController, TableSession>(GameController.new);

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return const UserStatsModel();
  return ref.read(progressRepositoryProvider).loadStats(uid);
});
