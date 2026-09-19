/// Table session state: server-authored situations with server coaching.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/situation_action_keys.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/models/table_setup.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// Pacing for the live-table replay. Slow enough to read, fast enough to play.
class ReplayPace {
  ReplayPace._();

  /// Multiplier for paced delays. Tests set this to `0` to skip sleeps.
  static double testScale = 1;

  static Duration _scaled(int milliseconds) =>
      Duration(microseconds: (milliseconds * 1000 * testScale).round());

  /// Pause before the first villain acts after the deal.
  static Duration get deal => _scaled(420);

  /// Pause after a villain checks or folds.
  static Duration get passiveAction => _scaled(520);

  /// Pause after a villain puts chips in (bet / call / raise).
  static Duration get chipAction => _scaled(680);

  /// Time the chips take to slide into the pot.
  static Duration get collectPot => _scaled(420);

  /// Pause after new board cards land.
  static Duration get dealStreet => _scaled(620);

  /// Beat while pot chips fly to the winner(s) at hand end.
  static Duration get handOver => _scaled(720);
}

/// UI-facing table session snapshot.
class TableSession {
  /// Creates a table session.
  const TableSession({
    this.game,
    this.coach = const CoachFeedback(),
    this.loading = false,
    this.error,
    this.lastAction,
    this.replaying = false,
    this.collectingChips = false,
    this.awardingChips = false,
    List<HeroActionEdge> authoredHeroEdges = const [],
  }) : _authoredHeroEdges = authoredHeroEdges;

  final GameState? game;
  final CoachFeedback coach;
  final bool loading;
  final String? error;
  final PokerAction? lastAction;

  /// True while villain actions are being replayed and the hero must wait.
  final bool replaying;

  /// True during the brief window where street bets animate into the pot.
  final bool collectingChips;

  /// True while the pot animates out to the winner seat(s).
  final bool awardingChips;

  final List<HeroActionEdge> _authoredHeroEdges;

  /// Exact server-authored actions available at the current hero node.
  UnmodifiableListView<HeroActionEdge> get authoredHeroEdges =>
      UnmodifiableListView(_authoredHeroEdges);

  /// Whether the hero may act right now.
  bool get heroCanAct {
    final g = game;
    return g != null &&
        g.waitingForHero &&
        !g.isHandOver &&
        !g.hero.folded &&
        !replaying &&
        !loading;
  }

  /// Hero has no further decisions this hand (folded or the hand resolved).
  bool get heroDoneForHand {
    final g = game;
    return g != null && !loading && (g.isHandOver || g.hero.folded);
  }

  /// Gold pulsing Next — only after the hand finishes naturally.
  bool get highlightNext => game != null && game!.isHandOver && !loading;

  TableSession copyWith({
    GameState? game,
    CoachFeedback? coach,
    bool? loading,
    String? error,
    bool clearError = false,
    PokerAction? lastAction,
    bool clearLastAction = false,
    bool? replaying,
    bool? collectingChips,
    bool? awardingChips,
    List<HeroActionEdge>? authoredHeroEdges,
    bool clearAuthoredHeroEdges = false,
  }) {
    return TableSession(
      game: game ?? this.game,
      coach: coach ?? this.coach,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      lastAction: clearLastAction ? null : (lastAction ?? this.lastAction),
      replaying: replaying ?? this.replaying,
      collectingChips: collectingChips ?? this.collectingChips,
      awardingChips: awardingChips ?? this.awardingChips,
      authoredHeroEdges:
          clearAuthoredHeroEdges
              ? const []
              : (authoredHeroEdges ?? _authoredHeroEdges),
    );
  }
}

/// Controls poker table flow, action replay pacing, and server coaching.
class GameController extends StateNotifier<TableSession> {
  GameController(this._ref) : super(const TableSession()) {
    if (kDebugMode) {
      _agentSub = AgentCommands.stream.listen(_onAgentCommand);
    }
  }

  final Ref _ref;
  PokerEngine? _engine;
  StreamSubscription<String>? _agentSub;

  String _sessionId = _newSessionId();

  static String _newSessionId() =>
      's${DateTime.now().toUtc().millisecondsSinceEpoch}';

  /// Current table session id (exposed for tests).
  String get sessionId => _sessionId;

  int _replayToken = 0;
  bool _disposed = false;

  /// Tracks whether progress was already recorded for the current hand.
  bool _progressRecorded = false;

  /// In-flight fetch started by prepare/prefetch (overlaps UI waits).
  Future<FetchedSituation>? _inflightFetch;
  String? _inflightSetupFingerprint;

  /// Completed prefetch ready to deal without another network round-trip.
  FetchedSituation? _readyPrefetch;
  String? _readyPrefetchFingerprint;

  GameSettingsModel get _settings => _ref.read(settingsProvider);

  GameState? _lastResolved;
  GameState? _lastAwarded;

  @override
  void dispose() {
    _disposed = true;
    _replayToken++;
    _clearPendingFetch();
    unawaited(_agentSub?.cancel());
    super.dispose();
  }

  /// Stable fingerprint for matching prefetch to the current table setup.
  static String setupFingerprint(TableSetup setup) =>
      jsonEncode(setup.toCallableMap());

  void _clearPendingFetch() {
    _inflightFetch = null;
    _inflightSetupFingerprint = null;
    _readyPrefetch = null;
    _readyPrefetchFingerprint = null;
  }

  /// Starts a background fetch for the current settings when signed in.
  ///
  /// Reuses an in-flight or ready result for the same setup fingerprint.
  void _ensureFetchInFlight({bool restart = false}) {
    final uid = _ref.read(authUidProvider);
    if (uid == null || uid.isEmpty) return;

    final setup = TableSetup.fromGameSettings(_settings);
    final fingerprint = setupFingerprint(setup);
    if (!restart) {
      if (_readyPrefetch != null &&
          _readyPrefetchFingerprint == fingerprint) {
        return;
      }
      if (_inflightFetch != null &&
          _inflightSetupFingerprint == fingerprint) {
        return;
      }
    }

    if (restart) {
      _readyPrefetch = null;
      _readyPrefetchFingerprint = null;
    }

    final future = _ref.read(situationServiceProvider).fetchSituation(setup);
    _inflightFetch = future;
    _inflightSetupFingerprint = fingerprint;
    unawaited(
      future.then((fetched) {
        if (_disposed || !identical(_inflightFetch, future)) return;
        _readyPrefetch = fetched;
        _readyPrefetchFingerprint = fingerprint;
        _inflightFetch = null;
        _inflightSetupFingerprint = null;
      }).catchError((Object error, StackTrace stackTrace) {
        if (_disposed || !identical(_inflightFetch, future)) return;
        _inflightFetch = null;
        _inflightSetupFingerprint = null;
      }),
    );
  }

  /// Takes a ready/in-flight fetch for [setup], or starts a fresh one.
  Future<FetchedSituation> _takeFetchedSituation(TableSetup setup) {
    final fingerprint = setupFingerprint(setup);
    final ready = _readyPrefetch;
    if (ready != null && _readyPrefetchFingerprint == fingerprint) {
      _readyPrefetch = null;
      _readyPrefetchFingerprint = null;
      return Future<FetchedSituation>.value(ready);
    }

    final inflight = _inflightFetch;
    if (inflight != null && _inflightSetupFingerprint == fingerprint) {
      _inflightFetch = null;
      _inflightSetupFingerprint = null;
      return inflight;
    }

    return _ref.read(situationServiceProvider).fetchSituation(setup);
  }

  void _onAgentCommand(String cmd) {
    switch (cmd) {
      case 'fold':
      case 'call':
      case 'check':
      case 'raise':
      case 'bet':
        unawaited(debugHeroShortcut(cmd));
      case 'next':
        unawaited(nextHand());
      default:
        break;
    }
  }

  /// Maps a debug shortcut to the same action the dock would emit.
  Future<void> debugHeroShortcut(String cmd) async {
    final game = state.game;
    if (game == null || !state.heroCanAct) return;
    final wantedKind = switch (cmd) {
      'fold' => SituationActionKind.fold,
      'check' => SituationActionKind.check,
      'call' => SituationActionKind.call,
      'bet' => SituationActionKind.bet,
      'raise' => SituationActionKind.raise,
      _ => null,
    };
    if (wantedKind == null) return;

    final matches =
        state.authoredHeroEdges
            .where((edge) => edge.kind == wantedKind)
            .toList();
    if (matches.length != 1) return;
    final action = SituationActionKeys.pokerActionForEdge(game, matches.single);
    final node = _engine?.currentHeroNode;
    if (node == null ||
        SituationActionKeys.resolveEdge(
              node: node,
              state: game,
              action: action,
            ) !=
            matches.single) {
      return;
    }
    await heroAct(action);
  }

  /// Marks the table as preparing so Home can navigate before any deal SFX.
  ///
  /// Also starts the network fetch immediately so it overlaps the route fade.
  void prepareTraining() {
    _replayToken++;
    state = const TableSession(loading: true);
    _ensureFetchInFlight(restart: true);
  }

  /// Starts training by fetching a server-authored situation.
  ///
  /// Requires a signed-in user. On failure the table shows an error with the
  /// prior engine state (if any) so the user can retry via Next / restart.
  Future<void> startTraining({bool continueTable = false}) async {
    final token = ++_replayToken;
    _progressRecorded = false;
    state = state.copyWith(
      loading: true,
      clearError: true,
      coach: const CoachFeedback(),
      replaying: false,
      collectingChips: false,
      awardingChips: false,
      clearAuthoredHeroEdges: true,
    );

    final uid = _ref.read(authUidProvider);
    if (uid == null || uid.isEmpty) {
      _clearPendingFetch();
      state = state.copyWith(
        loading: false,
        error: 'Sign in required to train.',
      );
      return;
    }

    try {
      final sound = _ref.read(soundServiceProvider);
      await sound.unlock();
      if (_disposed || token != _replayToken) return;

      final setup = TableSetup.fromGameSettings(_settings);
      // Prefer the fetch started in [prepareTraining] / end-of-hand prefetch.
      _ensureFetchInFlight();
      final fetched = await _takeFetchedSituation(setup);
      if (_disposed || token != _replayToken) return;

      final situation = fetched.situation.copyWith(
        situationId: fetched.situationId,
        setupKey: fetched.setupKey,
      );

      unawaited(
        _ref.read(analyticsServiceProvider).logSituationFetched(
          seatCount: setup.seatCount,
          stackDepthBb: _settings.stackDepthBb,
          continueTable: continueTable,
        ),
      );

      final existing = continueTable ? state.game?.players : null;
      final engine = _engine;
      if (continueTable && engine != null) {
        engine.updateSettings(_settings);
        engine.dealSituationHand(situation, existingPlayers: existing);
      } else {
        _sessionId = _newSessionId();
        _engine = PokerEngine(settings: _settings)
          ..dealSituationHand(situation, existingPlayers: existing);
      }

      final dealt = _engine!.state;
      state = state.copyWith(
        game: dealt,
        loading: true,
        clearAuthoredHeroEdges: true,
      );
      await sound.deal();
      if (_disposed || token != _replayToken) return;

      state = TableSession(game: _engine!.state, loading: false);
      await _replayUntilHero(pace: ReplayPace.deal, token: token);
    } catch (e) {
      if (_disposed || token != _replayToken) return;
      _clearPendingFetch();
      unawaited(
        _ref.read(analyticsServiceProvider).logTrainingError(stage: 'fetch'),
      );
      final engineState = _engine?.state;
      state = state.copyWith(
        game: engineState,
        loading: false,
        replaying: false,
        clearAuthoredHeroEdges: true,
        error: '$e',
      );
    }
  }

  /// Legacy alias — same as [startTraining].
  Future<void> startPractice() => startTraining();

  /// Legacy alias — same as [startTraining].
  Future<void> startCashSim({bool continueTable = false}) =>
      startTraining(continueTable: continueTable);

  /// Deals the next hand at the same table.
  Future<void> nextHand() async {
    final game = state.game;
    if (game != null && !game.isHandOver && !game.hero.folded) {
      return;
    }
    // Overlap progress recording with the next-hand network fetch.
    _ensureFetchInFlight();
    final recordFuture = (game?.isHandOver ?? false)
        ? _recordSituationProgress()
        : Future<bool>.value(true);
    await _forceCompleteSkippedHand();
    final recorded = await recordFuture;
    if (!recorded) return;
    await startTraining(continueTable: true);
  }

  /// Cancels paced replay and resolves the current hand so stacks stay honest.
  Future<void> _forceCompleteSkippedHand() async {
    final engine = _engine;
    final game = state.game;
    if (engine == null || game == null || game.isHandOver) return;

    final token = ++_replayToken;
    if (!engine.state.isHandOver) {
      engine.runToHeroOrEnd();
    }
    if (_disposed || token != _replayToken) return;
    state = state.copyWith(
      game: engine.state,
      replaying: false,
      collectingChips: false,
      awardingChips: false,
      clearAuthoredHeroEdges: true,
    );
    await _finishHandIfOver(token);
  }

  /// Applies a hero action, shows server coaching, then replays scripted seats.
  Future<void> heroAct(PokerAction action) async {
    final engine = _engine;
    final game = state.game;
    if (engine == null || game == null || !state.heroCanAct) return;

    final heroNode = engine.currentHeroNode;
    final edge =
        heroNode == null
            ? null
            : SituationActionKeys.resolveEdge(
              node: heroNode,
              state: game,
              action: action,
            );
    if (engine.situation != null && edge == null) {
      state = state.copyWith(
        error: 'That action is not one of the authored choices for this spot.',
      );
      return;
    }

    final token = ++_replayToken;
    final handId = game.handCount;
    final holesBefore = game.hero.holeCards
        .map((c) => c.code)
        .toList(growable: false);
    state = state.copyWith(
      replaying: true,
      clearError: true,
      clearAuthoredHeroEdges: true,
    );

    final sound = _ref.read(soundServiceProvider);
    await _playActionSfx(sound, action.type);
    if (_disposed || token != _replayToken) return;
    if (engine.state.handCount != handId || !engine.state.waitingForHero) {
      state = state.copyWith(
        game: engine.state,
        replaying: false,
        authoredHeroEdges: _authoredEdgesForCurrentHero(engine.state),
      );
      return;
    }

    final heroSizingBb =
        game.bigBlind > Money.epsilon ? action.amount / game.bigBlind : 0.0;

    HeroActionEdge? chosen;
    if (engine.situation != null) {
      // Authored situations were rejected above unless [edge] is exact.
      chosen = engine.applySituationHeroChoice(edge: edge!, action: action);
    } else if (edge != null) {
      chosen = engine.applySituationHeroChoice(edge: edge, action: action);
    } else {
      engine.submitHeroAction(action);
    }

    final after = engine.state;
    if (chosen != null) {
      state = state.copyWith(
        game: after,
        coach: CoachFeedback.fromHeroEdge(
          edge: chosen,
          street: game.street,
          node: heroNode,
          bigBlind: game.bigBlind,
        ),
      );
      unawaited(
        _ref.read(analyticsServiceProvider).logHeroDecision(
          street: game.street.name,
          actionType: action.type.name,
          verdict: chosen.verdict.name,
        ),
      );
    } else {
      state = state.copyWith(
        game: after,
        coach: CoachFeedback(
          message:
              edge == null
                  ? 'No legal coaching edge for that action.'
                  : 'Could not apply that action.',
          heroAction: action.label,
          heroSizingBb: heroSizingBb,
          decisionStreet: game.street,
        ),
      );
    }

    if (!after.isHandOver) {
      final holesAfter = after.hero.holeCards.map((c) => c.code).toList();
      assert(
        holesAfter.join(',') == holesBefore.join(','),
        'hero hole cards changed mid-hand',
      );
    }

    // Prefetch while coaching is shown (fold / terminal decisions).
    if (after.hero.folded || after.isHandOver) {
      _ensureFetchInFlight();
    }

    await _replayUntilHero(pace: ReplayPace.passiveAction, token: token);
  }

  /// Steps the engine forward with realistic pacing until the hero must act.
  Future<void> _replayUntilHero({required Duration pace, int? token}) async {
    final engine = _engine;
    if (engine == null) return;
    final myToken = token ?? _replayToken;
    final sound = _ref.read(soundServiceProvider);

    var current = state.game;
    if (current == null || current.isHandOver) {
      if (current != null && current.isHandOver) {
        await _playAwardAnimation(current, sound, myToken);
      }
      await _finishHandIfOver(myToken);
      return;
    }

    state = state.copyWith(replaying: true, clearAuthoredHeroEdges: true);
    await _wait(pace);

    var guard = 0;
    while (guard < 256) {
      guard++;
      if (_disposed || myToken != _replayToken) return;

      final event = engine.nextEvent();
      if (event == null) break;

      switch (event.kind) {
        case TableEventKind.villainAction:
          state = state.copyWith(
            game: event.state,
            collectingChips: false,
            awardingChips: false,
          );
          final type = event.action?.type;
          if (type != null) await _playActionSfx(sound, type);
          await _wait(
            _isChipAction(type)
                ? ReplayPace.chipAction
                : ReplayPace.passiveAction,
          );
        case TableEventKind.collectPot:
          state = state.copyWith(
            game: event.state,
            collectingChips: true,
            awardingChips: false,
          );
          await sound.chip();
          await _wait(ReplayPace.collectPot);
          state = state.copyWith(collectingChips: false);
        case TableEventKind.dealStreet:
          final prior = state.coach;
          final scoped =
              prior.hasVerdict && !prior.isHistorical
                  ? prior.asHistorical()
                  : prior;
          state = state.copyWith(
            game: event.state,
            collectingChips: false,
            awardingChips: false,
            coach: scoped,
          );
          await sound.deal();
          await _wait(ReplayPace.dealStreet);
        case TableEventKind.handOver:
          await _playAwardAnimation(event.state, sound, myToken);
      }

      current = event.state;
      if (current.isHandOver) break;
    }

    if (_disposed || myToken != _replayToken) return;

    final resolved = engine.state;
    state = state.copyWith(
      game: resolved,
      replaying: false,
      collectingChips: false,
      awardingChips: false,
      authoredHeroEdges: _authoredEdgesForCurrentHero(resolved),
    );

    await _finishHandIfOver(myToken);
  }

  Future<void> _playAwardAnimation(
    GameState game,
    SoundService sound,
    int token,
  ) async {
    if (_disposed || token != _replayToken) return;
    if (identical(_lastAwarded, game)) {
      state = state.copyWith(
        game: game,
        collectingChips: false,
        awardingChips: false,
      );
      return;
    }
    _lastAwarded = game;
    state = state.copyWith(
      game: game,
      collectingChips: false,
      awardingChips: game.winnerIds.isNotEmpty,
    );
    if (game.winnerIds.isNotEmpty) {
      await sound.chip();
    }
    await _wait(ReplayPace.handOver);
    if (_disposed || token != _replayToken) return;
    state = state.copyWith(awardingChips: false);
  }

  Future<void> _finishHandIfOver(int token) async {
    final game = state.game;
    if (game == null || !game.isHandOver) return;
    if (_disposed || token != _replayToken) return;
    final sound = _ref.read(soundServiceProvider);
    if (!identical(_lastResolved, game)) {
      _lastResolved = game;
      await _recordSituationProgress();
    }
    final heroWon = game.resultMessage?.startsWith('Hero') ?? false;
    if (heroWon) await sound.win();
    state = state.copyWith(replaying: false, clearAuthoredHeroEdges: true);
    // Prefetch the next situation while coaching / Next is visible.
    _ensureFetchInFlight();
  }

  List<HeroActionEdge> _authoredEdgesForCurrentHero(GameState game) {
    final node = _engine?.currentHeroNode;
    if (!game.waitingForHero || game.isHandOver || node == null) {
      return const [];
    }
    return List<HeroActionEdge>.unmodifiable(node.actions);
  }

  Future<bool> _recordSituationProgress() async {
    if (_progressRecorded) return true;
    final engine = _engine;
    final situation = engine?.situation;
    if (engine == null || situation == null) return false;

    final path = List<String>.from(engine.pathNodeIds);
    final keys = List<String>.from(engine.chosenActionKeys);
    final terminalId = engine.terminalNodeId;
    if (path.isEmpty || terminalId == null || terminalId.isEmpty) {
      state = state.copyWith(
        error: 'This hand could not be validated. Retry before continuing.',
      );
      return false;
    }
    if (path.length != keys.length) {
      state = state.copyWith(
        error: 'This hand path is incomplete. Retry before continuing.',
      );
      return false;
    }

    final heroNet = engine.terminalHeroNetChips ?? 0;

    try {
      await _ref
          .read(situationServiceProvider)
          .recordSituationProgress(
            situationId: situation.situationId ?? '',
            setupKey: situation.setupKey,
            pathNodeIds: path,
            chosenActionKeys: keys,
            terminalNodeId: terminalId,
            heroNetChips: heroNet,
          );
      _progressRecorded = true;
      _ref.invalidate(userStatsProvider);
      state = state.copyWith(clearError: true);
      unawaited(
        _ref
            .read(analyticsServiceProvider)
            .logHandCompleted(heroNetChips: heroNet),
      );
      return true;
    } catch (e, st) {
      DiagnosticsLog.error('GameController.recordSituationProgress', e, st);
      unawaited(_ref.read(analyticsServiceProvider).logHandRecordFailed());
      state = state.copyWith(
        error: 'Could not save this hand. Check your connection and retry.',
      );
      return false;
    }
  }

  Future<void> _playActionSfx(SoundService sound, PokerActionType type) {
    return switch (type) {
      PokerActionType.fold => sound.fold(),
      PokerActionType.check => sound.knock(),
      PokerActionType.call ||
      PokerActionType.bet ||
      PokerActionType.raise ||
      PokerActionType.allIn => sound.chip(),
    };
  }

  static bool _isChipAction(PokerActionType? type) {
    return type == PokerActionType.call ||
        type == PokerActionType.bet ||
        type == PokerActionType.raise ||
        type == PokerActionType.allIn;
  }

  Future<void> _wait(Duration duration) => Future<void>.delayed(duration);

  void clearCoach() {
    state = state.copyWith(coach: const CoachFeedback());
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, TableSession>(GameController.new);

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid == null) {
    return const UserStatsModel();
  }
  return ref.read(progressRepositoryProvider).loadStats(uid);
});
