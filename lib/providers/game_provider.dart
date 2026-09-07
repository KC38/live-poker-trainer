/// Table session state: unified full-hand training with live coach.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/leak_lines.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/mistake_tracker.dart';

/// Pacing for the live-table replay. Slow enough to read, fast enough to play.
class ReplayPace {
  ReplayPace._();

  /// Pause before the first villain acts after the deal.
  static const Duration deal = Duration(milliseconds: 420);

  /// Pause after a villain checks or folds.
  static const Duration passiveAction = Duration(milliseconds: 520);

  /// Pause after a villain puts chips in (bet / call / raise).
  static const Duration chipAction = Duration(milliseconds: 680);

  /// Time the chips take to slide into the pot.
  static const Duration collectPot = Duration(milliseconds: 420);

  /// Pause after new board cards land.
  static const Duration dealStreet = Duration(milliseconds: 620);

  /// Beat after the hand resolves before the Next CTA is actionable.
  static const Duration handOver = Duration(milliseconds: 560);
}

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
    this.replaying = false,
    this.collectingChips = false,
  });

  final GameState? game;
  final CoachFeedback coach;
  final bool loading;
  final String? error;
  final bool showEvAudit;
  final PokerAction? lastAction;
  final bool voiceHintShown;

  /// True while villain actions are being replayed and the hero must wait.
  final bool replaying;

  /// True during the brief window where street bets animate into the pot.
  final bool collectingChips;

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
    bool? replaying,
    bool? collectingChips,
  }) {
    return TableSession(
      game: game ?? this.game,
      coach: coach ?? this.coach,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      showEvAudit: showEvAudit ?? this.showEvAudit,
      lastAction: clearLastAction ? null : (lastAction ?? this.lastAction),
      voiceHintShown: voiceHintShown ?? this.voiceHintShown,
      replaying: replaying ?? this.replaying,
      collectingChips: collectingChips ?? this.collectingChips,
    );
  }
}

/// Controls poker table flow, action replay pacing, and coach grading.
class GameController extends StateNotifier<TableSession> {
  GameController(this._ref) : super(const TableSession());

  final Ref _ref;
  PokerEngine? _engine;

  /// Identifies one sitting at a table; mistakes are grouped by it for
  /// "N times this session" copy. Refreshed when a fresh table is started.
  String _sessionId = _newSessionId();

  static String _newSessionId() =>
      's${DateTime.now().toUtc().millisecondsSinceEpoch}';

  /// Current table session id (exposed for tests and future hand logging).
  String get sessionId => _sessionId;
  bool _voiceHintShown = false;

  /// Incremented per deal / hero action so a stale replay loop can bail out.
  int _replayToken = 0;
  bool _disposed = false;

  GameSettingsModel get _settings => _ref.read(settingsProvider);

  @override
  void dispose() {
    _disposed = true;
    _replayToken++;
    super.dispose();
  }

  /// Marks the table as preparing so Home can navigate before any deal SFX.
  ///
  /// Cancels an in-flight replay and clears the prior hand so the Training
  /// screen shows an in-table loading state instead of stale cards / audio.
  void prepareTraining() {
    _replayToken++;
    state = TableSession(
      loading: true,
      voiceHintShown: _voiceHintShown,
    );
  }

  /// Starts (or restarts) unified full-hand training.
  ///
  /// Call only after [PokerTableScreen] is mounted and the route transition
  /// has finished — Home must not invoke this before navigation.
  Future<void> startTraining({bool continueTable = false}) async {
    final token = ++_replayToken;
    final previousFingerprint = _engine == null
        ? null
        : PokerEngine.dealFingerprint(_engine!.state);

    state = state.copyWith(
      loading: true,
      clearError: true,
      coach: const CoachFeedback(),
      showEvAudit: false,
      replaying: false,
      collectingChips: false,
    );
    try {
      final sound = _ref.read(soundServiceProvider);
      await sound.unlock();
      if (_disposed || token != _replayToken) return;

      final existing = continueTable ? state.game?.players : null;
      final engine = _engine;
      if (continueTable && engine != null) {
        engine.updateSettings(_settings);
        engine.startHand(existingPlayers: existing, resolve: false);
      } else {
        _sessionId = _newSessionId();
        _engine = PokerEngine(settings: _settings)
          ..startHand(existingPlayers: existing, resolve: false);
      }

      // Publish the new deal immediately so a later failure cannot leave the
      // UI stuck on the previous hand's cards.
      var dealt = _engine!.state;
      if (previousFingerprint != null &&
          PokerEngine.dealFingerprint(dealt) == previousFingerprint) {
        // Defensive: rebuild the engine and deal once more.
        _engine = PokerEngine(settings: _settings)
          ..startHand(
            existingPlayers: dealt.players,
            dealerIndex: dealt.dealerIndex,
            resolve: false,
          );
        dealt = _engine!.state;
      }

      state = state.copyWith(game: dealt, loading: true);
      await sound.deal();
      if (_disposed || token != _replayToken) return;

      state = TableSession(
        game: _engine!.state,
        loading: false,
        voiceHintShown: _voiceHintShown,
        coach: CoachFeedback(message: CoachLines.dealIntro(_engine!.state)),
      );
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
  Future<void> nextHand() => startTraining(continueTable: true);

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

    // Grade against the pre-action snapshot.
    final grade = LiveCoach.grade(state: game, action: action);
    state = state.copyWith(
      coach: CoachFeedback(
        verdict: grade.verdict,
        message: grade.message,
        optimalAction: grade.optimalAction,
        optimalSizingBb: grade.optimalSizingBb,
        heroAction: action.label,
        evDeltaBb: grade.evDeltaBb,
      ),
    );

    // Apply the hero action right away so the felt reflects the decision.
    final after = engine.submitHeroAction(action);
    state = state.copyWith(game: after);

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

    await _recordStats(grade, game);
    // Coach narration runs in parallel with the replay so play never stalls
    // waiting on the network.
    final narration = _narrate(grade, game, token, leak, localMessage);

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
          state = state.copyWith(game: event.state, collectingChips: false);
          final type = event.action?.type;
          if (type != null) await _playActionSfx(sound, type);
          await _wait(_isChipAction(type)
              ? ReplayPace.chipAction
              : ReplayPace.passiveAction);
        case TableEventKind.collectPot:
          state = state.copyWith(game: event.state, collectingChips: true);
          await sound.chip();
          await _wait(ReplayPace.collectPot);
          state = state.copyWith(collectingChips: false);
        case TableEventKind.dealStreet:
          state = state.copyWith(game: event.state, collectingChips: false);
          await sound.deal();
          await _wait(ReplayPace.dealStreet);
        case TableEventKind.handOver:
          state = state.copyWith(game: event.state, collectingChips: false);
          await _wait(ReplayPace.handOver);
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
    );
    await _finishHandIfOver(myToken);
  }

  Future<void> _finishHandIfOver(int token) async {
    final game = state.game;
    if (game == null || !game.isHandOver) return;
    if (_disposed || token != _replayToken) return;
    final sound = _ref.read(soundServiceProvider);
    final heroWon = game.resultMessage?.startsWith('Hero') ?? false;
    if (heroWon) await sound.win();
    // Hand review stays in the coach shelf; the header Next CTA is the cue.
    state = state.copyWith(showEvAudit: false, replaying: false);
  }

  Future<void> _recordStats(LiveCoachGrade grade, GameState game) async {
    if (!grade.verdict.isGraded) return;
    final archetype = grade.villainArchetype.label;
    try {
      final stats = _ref.read(userStatsDaoProvider);
      await stats.recordPracticeResult(
        wasCorrect: grade.verdict == CoachVerdict.correct,
        evDeltaBb: grade.evDeltaBb,
        street: game.street.label,
        archetype: archetype,
      );
      _ref.invalidate(userStatsProvider);
    } catch (_) {
      // Stats are best-effort; never block or crash play on a DB hiccup.
    }
  }

  /// Fetches a spot-specific coach line (Gemini when available) and speaks it.
  ///
  /// [localMessage] is the offline line (already carrying repeat / improvement
  /// copy) used when Gemini is unavailable.
  Future<void> _narrate(
    LiveCoachGrade grade,
    GameState game,
    int token,
    LeakCheck leak,
    String localMessage,
  ) async {
    final settings = _settings;
    final gemini = _ref.read(geminiServiceProvider);
    final sound = _ref.read(soundServiceProvider);
    var message = localMessage;

    try {
      final result = await gemini.coach(
        prompt: grade.toPrompt(
          game,
          repeat: leak.repeat,
          improvement: leak.improvement,
        ),
      );
      final text = result.text.trim();
      if (text.isNotEmpty) message = text;
    } catch (_) {
      // Keep the local, spot-specific line.
    }

    if (_disposed || token != _replayToken) return;
    state = state.copyWith(coach: state.coach.copyWith(message: message));
    if (leak.mistakeId != null && message != grade.message) {
      // Store the advice the player actually saw.
      unawaited(
        _ref.read(mistakeTrackerProvider).saveAdvice(leak.mistakeId, message),
      );
    }

    final playback = await sound.speakCoachLine(
      text: message,
      enabled: settings.ttsEnabled,
    );
    if (_disposed || token != _replayToken) return;

    // Voice diagnostics stay in logs only — never surface config hints on the
    // coach shelf (see SoundService / CoachVoicePlayback.diagnostic).
    state = state.copyWith(
      coach: state.coach.copyWith(isSpeaking: playback.spoke),
    );
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

/// Leak-finder aggregates for the Stats screen.
final mistakeStatsProvider = FutureProvider<MistakeStats>((ref) async {
  final dao = ref.watch(mistakeDaoProvider);
  return dao.loadStats();
});

final unplayedCountProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(scenarioDaoProvider);
  return dao.unplayedCount();
});
