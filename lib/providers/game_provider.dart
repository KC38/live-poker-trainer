/// Table session state: unified full-hand training with live coach.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/bet_sizing.dart';
import 'package:live_poker_trainer/engine/coach_advice_guard.dart';
import 'package:live_poker_trainer/engine/leak_lines.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/hand_recorder.dart';
import 'package:live_poker_trainer/services/mistake_tracker.dart';

/// Pacing for the live-table replay. Slow enough to read, fast enough to play.
class ReplayPace {
  ReplayPace._();

  /// Multiplier for paced delays. Tests set this to `0` to skip sleeps.
  static double testScale = 1;

  static Duration _scaled(int milliseconds) => Duration(
        microseconds: (milliseconds * 1000 * testScale).round(),
      );

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
  });

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
  ///
  /// Used to offer an early **Next** that skips the rest of the replay while
  /// villains finish streets / showdown in the background.
  bool get heroDoneForHand {
    final g = game;
    return g != null && !loading && (g.isHandOver || g.hero.folded);
  }

  /// Gold pulsing Next — only after the hand finishes naturally (or via skip
  /// resolve). Quiet Next is still available while [heroDoneForHand] and the
  /// replay is catching up.
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
    );
  }
}

/// Controls poker table flow, action replay pacing, and coach grading.
class GameController extends StateNotifier<TableSession> {
  GameController(this._ref) : super(const TableSession()) {
    if (kDebugMode) {
      _agentSub = AgentCommands.stream.listen(_onAgentCommand);
    }
  }

  final Ref _ref;
  PokerEngine? _engine;
  StreamSubscription<String>? _agentSub;

  /// Identifies one sitting at a table; mistakes are grouped by it for
  /// "N times this session" copy. Refreshed when a fresh table is started.
  String _sessionId = _newSessionId();

  static String _newSessionId() =>
      's${DateTime.now().toUtc().millisecondsSinceEpoch}';

  /// Current table session id (exposed for tests and future hand logging).
  String get sessionId => _sessionId;

  /// Incremented per deal / hero action so a stale replay loop can bail out.
  int _replayToken = 0;
  bool _disposed = false;

  /// Bumped whenever the shelf switches tip ↔ grade so late Claude replies
  /// cannot overwrite a newer decision's primary message.
  int _coachEpoch = 0;

  GameSettingsModel get _settings => _ref.read(settingsProvider);

  /// Hand-history recorder; every call is best-effort and non-blocking.
  HandRecorder get _recorder => _ref.read(handRecorderProvider);

  /// Resolved state of the previous hand at this table (for rebuy logging).
  GameState? _lastResolved;
  GameState? _lastAwarded;

  @override
  void dispose() {
    _disposed = true;
    _replayToken++;
    unawaited(_agentSub?.cancel());
    super.dispose();
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
    final hero = game.hero;
    final callAmt = game.callAmountFor(hero);
    final freeCheck = callAmt <= 1e-9;
    final range = RaiseRange.forHero(game);

    switch (cmd) {
      case 'fold':
        if (freeCheck) return;
        await heroAct(const PokerAction(type: PokerActionType.fold));
      case 'call':
      case 'check':
        await heroAct(
          freeCheck
              ? const PokerAction(type: PokerActionType.check)
              : PokerAction(type: PokerActionType.call, amount: callAmt),
        );
      case 'raise':
      case 'bet':
        if (!range.allowed) return;
        final unopenedPreflop = game.street == Street.preflop &&
            game.highestBet <= game.bigBlind + Money.epsilon;
        final amount = unopenedPreflop
            ? range.clamp(game.bigBlind * 2.5)
            : range.forFraction(
                0.66,
                pot: game.totalPot,
                heroBet: hero.currentBet,
              );
        await heroAct(
          PokerAction(
            type: range.isAllInOnly
                ? PokerActionType.allIn
                : (freeCheck ? PokerActionType.bet : PokerActionType.raise),
            amount: amount,
          ),
        );
      default:
        break;
    }
  }

  /// Marks the table as preparing so Home can navigate before any deal SFX.
  ///
  /// Cancels an in-flight replay and clears the prior hand so the Training
  /// screen shows an in-table loading state instead of stale cards / audio.
  void prepareTraining() {
    _replayToken++;
    state = const TableSession(loading: true);
  }

  /// Starts (or restarts) training from the Gemini / offline scenario pool.
  ///
  /// Each hand pulls an engineered spot ([ScenarioManager.nextScenario]) and
  /// deals it from preflop via [PokerEngine.dealScenarioHand]. Villain folds /
  /// raises before hero are replayed with [PokerEngine.nextEvent] so the user
  /// sees what happened; after the first hero decision the hand continues
  /// street by street with normal AI.
  ///
  /// Call only after [PokerTableScreen] is mounted and the route transition
  /// has finished — Home must not invoke this before navigation.
  Future<void> startTraining({bool continueTable = false}) async {
    final token = ++_replayToken;

    // Clear prior coach text before the new deal.
    _coachEpoch++;
    state = state.copyWith(
      loading: true,
      clearError: true,
      coach: const CoachFeedback(),
      replaying: false,
      collectingChips: false,
      awardingChips: false,
    );
    try {
      final sound = _ref.read(soundServiceProvider);
      await sound.unlock();
      if (_disposed || token != _replayToken) return;

      final scenario =
          await _ref.read(scenarioManagerProvider).nextScenario();
      if (_disposed || token != _replayToken) return;

      final existing = continueTable ? state.game?.players : null;
      final engine = _engine;
      if (continueTable && engine != null) {
        engine.updateSettings(_settings);
        engine.dealScenarioHand(
          scenario,
          existingPlayers: existing,
        );
      } else {
        _sessionId = _newSessionId();
        _engine = PokerEngine(settings: _settings)
          ..dealScenarioHand(
            scenario,
            existingPlayers: existing,
          );
      }

      final dealt = _engine!.state;
      state = state.copyWith(game: dealt, loading: true);
      _safeRecord(() {
        _recorder.startHand(
          dealt,
          _settings,
          previous: continueTable ? _lastResolved : null,
        );
      });
      await sound.deal();
      if (_disposed || token != _replayToken) return;

      // Coach stays empty until the first post-action grade — no deal intro
      // or pre-action tip that would steal the shelf before advice lands.
      state = TableSession(
        game: _engine!.state,
        loading: false,
      );
      // Replay folds / raises into the hero's first decision.
      await _replayUntilHero(pace: ReplayPace.deal, token: token);
    } catch (e) {
      if (_disposed || token != _replayToken) return;
      // Prefer the engine's deal over the prior UI snapshot when one exists.
      final engineState = _engine?.state;
      state = state.copyWith(
        game: engineState,
        loading: false,
        replaying: false,
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
  ///
  /// When the hero has already folded (or the hand is over), this cancels any
  /// in-flight villain replay, silently finishes stack settlement, then deals.
  /// Refuses to skip while the hero still has decisions left.
  Future<void> nextHand() async {
    final game = state.game;
    if (game != null && !game.isHandOver && !game.hero.folded) {
      return;
    }
    await _forceCompleteSkippedHand();
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
    );
    await _finishHandIfOver(token);
  }

  /// Applies a hero action, coaches it, then replays the villains' responses.
  Future<void> heroAct(PokerAction action) async {
    final engine = _engine;
    final game = state.game;
    if (engine == null || game == null || !state.heroCanAct) return;

    // Lock out double-taps before any await so a second press cannot grade
    // and re-apply against the same spot.
    final token = ++_replayToken;
    final handId = game.handCount;
    final holesBefore =
        game.hero.holeCards.map((c) => c.code).toList(growable: false);
    state = state.copyWith(replaying: true);

    final sound = _ref.read(soundServiceProvider);
    await _playActionSfx(sound, action.type);
    if (_disposed || token != _replayToken) return;
    // Bail if a new hand was dealt while SFX played.
    if (engine.state.handCount != handId || !engine.state.waitingForHero) {
      state = state.copyWith(game: engine.state, replaying: false);
      return;
    }

    // Grade against the pre-action snapshot — replaces any tip as the single
    // primary shelf message (never stacks tip + grade).
    final grade = LiveCoach.grade(state: game, action: action);
    final coachEpoch = ++_coachEpoch;
    state = state.copyWith(
      coach: CoachFeedback(
        verdict: grade.verdict,
        message: grade.message,
        optimalAction: grade.optimalAction,
        optimalSizingBb: grade.optimalSizingBb,
        heroAction: action.label,
        heroSizingBb: grade.heroSizingBb,
        evDeltaBb: grade.evDeltaBb,
        decisionStreet: grade.street,
        isHistorical: false,
      ),
    );

    // Apply the hero action right away so the felt reflects the decision.
    final after = engine.submitHeroAction(action);
    state = state.copyWith(game: after);
    _safeRecord(() => _recorder.recordAction(game, after, game.hero.id, action));
    final decisionId = _recordDecision(grade, game, action);

    // Mid-hand continuations must keep the same hole cards; a new deal here
    // would be the "same spot looping" bug.
    if (!after.isHandOver) {
      final holesAfter = after.hero.holeCards.map((c) => c.code).toList();
      assert(
        holesAfter.join(',') == holesBefore.join(','),
        'hero hole cards changed mid-hand',
      );
    }

    // Leak history (local DB, fast) decides whether this is a repeat or a fix
    // before the coach speaks, so both the offline line and the AI prompt can
    // name it.
    final leak = await _trackLeak(grade, game, action);
    if (_disposed || token != _replayToken) return;
    final localMessage = _applyLeakContext(grade, leak);

    await _recordStats(grade, game, action);
    // Coach narration runs in parallel with the replay so play never stalls
    // waiting on the network.
    final narration = _narrate(
      grade,
      game,
      token,
      leak,
      localMessage,
      decisionId,
      coachEpoch,
    );

    await _replayUntilHero(pace: ReplayPace.passiveAction, token: token);
    await narration;
  }

  /// Persists the graded decision into leak history; never throws.
  Future<LeakCheck> _trackLeak(
    LiveCoachGrade grade,
    GameState game,
    PokerAction action,
  ) async {
    if (!grade.verdict.isGraded) return LeakCheck.none;
    try {
      final tracker = _ref.read(mistakeTrackerProvider);
      return await tracker.track(
        grade: grade,
        sessionId: _sessionId,
        handId: '$_sessionId-h${game.handCount}',
        bigBlind: game.bigBlind,
        heroAmount: action.amount,
      );
    } catch (_) {
      return LeakCheck.none;
    }
  }

  /// Prefixes the local coach line with repeat / improvement copy and sets the
  /// shelf indicators. Returns the message to fall back to offline.
  String _applyLeakContext(LiveCoachGrade grade, LeakCheck leak) {
    var message = grade.message;
    var coach = state.coach;
    final repeat = leak.repeat;
    final improvement = leak.improvement;

    if (repeat != null && repeat.isRepeat) {
      final prefix = LeakLines.repeatPrefix(
        repeat,
        villainName: grade.villainName,
      );
      message = '$prefix. $message';
      coach = coach.copyWith(
        repeatCount: repeat.displayCount,
        patternLabel: repeat.pattern.primaryTag.label,
      );
    } else if (improvement != null) {
      final prefix = LeakLines.improvementPrefix(
        improvement,
        taken: grade.heroAction,
      );
      message = '$prefix. $message';
      coach = coach.copyWith(
        improvementStreak: improvement.streak,
        patternLabel: improvement.tag.label,
      );
    }

    state = state.copyWith(coach: coach.copyWith(message: message));
    if (repeat != null || improvement != null) {
      _ref.invalidate(mistakeStatsProvider);
    }
    return message;
  }

  /// Steps the engine forward with realistic pacing until the hero must act.
  Future<void> _replayUntilHero({
    required Duration pace,
    int? token,
  }) async {
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

    state = state.copyWith(replaying: true);
    await _wait(pace);

    var guard = 0;
    while (guard < 256) {
      guard++;
      if (_disposed || myToken != _replayToken) return;

      final event = engine.nextEvent();
      if (event == null) break;

      switch (event.kind) {
        case TableEventKind.villainAction:
          final before = current;
          final seat = event.seatIndex;
          final villainAction = event.action;
          if (before != null && seat != null && villainAction != null) {
            _safeRecord(() => _recorder.recordAction(
                  before,
                  event.state,
                  seat,
                  villainAction,
                ));
          }
          state = state.copyWith(
            game: event.state,
            collectingChips: false,
            awardingChips: false,
          );
          final type = event.action?.type;
          if (type != null) await _playActionSfx(sound, type);
          await _wait(_isChipAction(type)
              ? ReplayPace.chipAction
              : ReplayPace.passiveAction);
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
          _safeRecord(() => _recorder.recordStreet(event.state));
          // Prior street grades must not read as live flop/turn advice.
          final prior = state.coach;
          final scoped = prior.hasVerdict && !prior.isHistorical
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
    );

    // Keep the last post-action grade on the shelf while hero decides again —
    // no pre-action tip that would replace advice mid-read.
    await _finishHandIfOver(myToken);
  }

  /// Flies the pot to the winner seat(s), then clears the award overlay flag.
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
      _safeRecord(() => _recorder.endHand(game));
    }
    final heroWon = game.resultMessage?.startsWith('Hero') ?? false;
    if (heroWon) await sound.win();
    // Hand review stays in the coach shelf; the header Next CTA is the cue.
    state = state.copyWith(replaying: false);
  }

  Future<void> _recordStats(
    LiveCoachGrade grade,
    GameState game,
    PokerAction action,
  ) async {
    if (!grade.verdict.isGraded) return;
    final archetype = grade.villainArchetype.label;
    try {
      final scenario = game.activeScenario;
      final engine = _engine;
      if (scenario != null && engine != null) {
        // Records playedScenarios + user stats via Firestore (or no-ops when
        // signed out / offline). UI already shows [grade]; ignore returned
        // CoachFeedback to avoid overwriting leak-aware shelf copy.
        await _ref.read(scenarioManagerProvider).gradeAndRecord(
              scenario: scenario,
              action: action,
              engine: engine,
              gradeState: game,
            );
      } else {
        final uid = _ref.read(authUidProvider);
        if (uid != null) {
          await _ref.read(userRepositoryProvider).recordPracticeResult(
                uid: uid,
                wasCorrect: grade.verdict == CoachVerdict.correct,
                evDeltaBb: grade.evDeltaBb,
                street: game.street.label,
                archetype: archetype,
              );
        } else {
          final stats = _ref.read(userStatsDaoProvider);
          await stats.recordPracticeResult(
            wasCorrect: grade.verdict == CoachVerdict.correct,
            evDeltaBb: grade.evDeltaBb,
            street: game.street.label,
            archetype: archetype,
          );
        }
      }
      _ref.invalidate(userStatsProvider);
    } catch (_) {
      // Stats are best-effort; never block or crash play on a DB hiccup.
    }
  }

  /// Fetches a spot-specific coach line (Claude when available) for the shelf.
  ///
  /// [localMessage] is the offline line (already carrying repeat / improvement
  /// copy) used when Anthropic is unavailable. Claude is only asked on graded
  /// spots. Gemini is never used for coach narration.
  Future<void> _narrate(
    LiveCoachGrade grade,
    GameState game,
    int token,
    LeakCheck leak,
    String localMessage,
    Future<int?> decisionId,
    int coachEpoch,
  ) async {
    final anthropic = _ref.read(anthropicServiceProvider);
    var message = localMessage;
    var adviceSource = 'offline';
    int? aiRequestId;

    if (grade.verdict.isGraded) {
      try {
        final result = await anthropic.coach(
          prompt: grade.toPrompt(
            game,
            repeat: leak.repeat,
            improvement: leak.improvement,
          ),
          handId: await _recorder.currentHandId,
        );
        aiRequestId = result.aiRequestId;
        final text = result.text.trim();
        if (text.isNotEmpty) {
          final reconciled = CoachAdviceGuard.reconcile(
            advice: text,
            fallback: localMessage,
            bestAction: grade.optimalAction,
            verdict: grade.verdict,
            street: grade.street,
            equityPercent: grade.equityPercent,
            requiredEquityPercent: grade.requiredEquityPercent,
            villainIsAggressor: grade.villainIsAggressor,
            reasonCodes: grade.reasonCodes,
            villainArchetype: grade.villainArchetype,
            villainAirPercent: (grade.villainAirShare * 100).round(),
          );
          message = reconciled;
          adviceSource = reconciled == text ? 'claude' : 'offline';
        }
      } catch (e, st) {
        DiagnosticsLog.error('GameController.narrate', e, st);
      }
    } else {
      message = CoachAdviceGuard.reconcile(
        advice: localMessage,
        fallback: localMessage,
        bestAction: grade.optimalAction,
        verdict: grade.verdict,
      );
    }

    if (_disposed || token != _replayToken) return;
    // Ignore replies after a newer tip/grade, street advance, or re-decision.
    final stillCurrentDecision = coachEpoch == _coachEpoch &&
        state.coach.isLiveGrade &&
        (state.coach.decisionStreet == null ||
            state.coach.decisionStreet == grade.street);
    if (stillCurrentDecision) {
      state = state.copyWith(
        coach: state.coach.copyWith(
          message: message,
          decisionStreet: grade.street,
          isHistorical: false,
        ),
      );
    }
    if (leak.mistakeId != null && message != grade.message) {
      unawaited(
        _ref.read(mistakeTrackerProvider).saveAdvice(leak.mistakeId, message),
      );
    }

    final resolvedDecision = await decisionId;
    _safeRecord(() => _recorder.completeDecision(
          resolvedDecision,
          adviceText: message,
          adviceSource: adviceSource,
          aiRequestId: aiRequestId,
        ));
  }

  /// Persists the graded decision; resolves to the `coach_decisions` id.
  Future<int?> _recordDecision(
    LiveCoachGrade grade,
    GameState game,
    PokerAction action,
  ) async {
    if (!grade.verdict.isGraded) return null;
    try {
      return await _recorder.recordHeroDecision(grade, game, action);
    } catch (e, st) {
      DiagnosticsLog.error('GameController.recordDecision', e, st);
      return null;
    }
  }

  /// Runs a recorder call; hand logging must never affect play.
  void _safeRecord(void Function() body) {
    try {
      body();
    } catch (e, st) {
      DiagnosticsLog.error('GameController.record', e, st);
    }
  }

  Future<void> _playActionSfx(SoundService sound, PokerActionType type) {
    return switch (type) {
      PokerActionType.fold => sound.fold(),
      PokerActionType.check => sound.knock(),
      PokerActionType.call ||
      PokerActionType.bet ||
      PokerActionType.raise ||
      PokerActionType.allIn =>
        sound.chip(),
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
    StateNotifierProvider<GameController, TableSession>(
  GameController.new,
);

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid != null) {
    // Fresh Firestore read — do not reuse the bootstrap userDoc cache.
    return ref.read(userRepositoryProvider).getStats(uid);
  }
  final dao = ref.watch(userStatsDaoProvider);
  return dao.getStats();
});

/// Leak-finder aggregates for the Stats screen.
final mistakeStatsProvider = FutureProvider<MistakeStats>((ref) async {
  final dao = ref.watch(mistakeDaoProvider);
  return dao.loadStats();
});

final unplayedCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(scenarioManagerProvider).unplayedCount();
});
