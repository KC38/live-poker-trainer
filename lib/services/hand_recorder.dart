/// Buffers one table hand and persists it through [HandHistoryDao].
///
/// `GameController` calls [startHand], [recordAction], [recordStreet],
/// [recordHeroDecision], and [endHand] as the engine replays. Writes are
/// fire-and-forget: the recorder never throws and never blocks the replay
/// loop. Actions are batched per street so a hand costs a handful of SQLite
/// round trips at most.
library;

import 'dart:async';
import 'dart:convert';

import 'package:live_poker_trainer/core/database/hand_history_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';

/// Records hands, actions, and coach decisions for the running table.
class HandRecorder {
  /// Creates a recorder writing through [dao]; [sessionId] links rows to the
  /// current `app_sessions` row.
  HandRecorder(this.dao, {int? Function()? sessionId})
      : _sessionId = sessionId ?? (() => null);

  final HandHistoryDao dao;
  final int? Function() _sessionId;

  Future<int?>? _handId;
  int _seq = 0;
  int _handNumber = 0;
  double _heroStartStack = 0;
  double _evDeltaBb = 0;
  final List<HandActionRecord> _pending = [];
  String _flop = '';
  String _turn = '';
  String _river = '';

  /// Row id of the hand being recorded, once the insert resolves.
  Future<int?> get currentHandId => _handId ?? Future.value(null);

  /// Table-relative hand number of the hand being recorded.
  int get handNumber => _handNumber;

  static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  static String _cards(Iterable<CardModel> cards) =>
      cards.map((c) => c.code).join(' ');

  static double _totalPot(GameState g) =>
      g.mainPot +
      g.sidePots.fold<double>(0, (a, b) => a + b) +
      g.players.fold<double>(0, (a, p) => a + p.currentBet);

  /// Opens a hand row for the freshly dealt [dealt] state.
  ///
  /// [previous] is the resolved state of the prior hand at this table (if
  /// any); stacks that grew between hands are logged as rebuys.
  void startHand(
    GameState dealt,
    GameSettingsModel settings, {
    GameState? previous,
  }) {
    _seq = 0;
    _pending.clear();
    _evDeltaBb = 0;
    _flop = _turn = _river = '';
    _handNumber = dealt.handCount;
    final hero = dealt.hero;
    // Blinds are already posted in `dealt`; recover the pre-blind stack.
    _heroStartStack = hero.stack + hero.currentBet;

    final rebuys = <Map<String, Object?>>[];
    if (previous != null) {
      for (final p in dealt.players) {
        final before = previous.players
            .where((q) => q.id == p.id)
            .map((q) => q.stack)
            .firstOrNull;
        final now = p.stack + p.currentBet;
        if (before != null && now > before + 0.001) {
          rebuys.add({'seat': p.id, 'from': before, 'to': now});
        }
      }
    }

    final record = HandStartRecord(
      sessionId: _sessionId(),
      handNumber: dealt.handCount,
      startedAtMs: _now(),
      settingsJson: jsonEncode(settings.toPrefsMap()),
      seatCount: dealt.players.length,
      smallBlind: dealt.smallBlind,
      bigBlind: dealt.bigBlind,
      stackDepthBb: settings.stackDepthBb,
      dealerSeat: dealt.dealerIndex,
      sbSeat: dealt.sbIndex,
      bbSeat: dealt.bbIndex,
      heroSeat: hero.id,
      lineup: [
        for (final p in dealt.players)
          {
            'seat': p.id,
            'name': p.name,
            'archetype': p.archetype.id,
            'stack': p.stack + p.currentBet,
            'hero': p.isHero,
          },
      ],
      heroCards: _cards(hero.holeCards),
      rebuyEvents: rebuys,
    );
    _handId = _guard(() => dao.startHand(record), 'startHand');
  }

  /// Buffers one action taken by [seat] transitioning [before] → [after].
  void recordAction(
    GameState before,
    GameState after,
    int seat,
    PokerAction action,
  ) {
    if (_handId == null) return;
    final player = after.players.where((p) => p.id == seat).firstOrNull ??
        before.players.where((p) => p.id == seat).firstOrNull;
    if (player == null) return;
    _pending.add(
      HandActionRecord(
        seat: seat,
        playerName: player.name,
        archetype: player.archetype.id,
        isHero: player.isHero,
        street: before.street.name,
        actionType: action.type.name,
        amount: action.amount,
        potBefore: _totalPot(before),
        potAfter: _totalPot(after),
        stackAfter: player.stack,
        atMs: _now(),
      ),
    );
  }

  /// Records a newly dealt street (board so far) and flushes buffered actions.
  void recordStreet(GameState state) {
    if (_handId == null) return;
    final board = state.community;
    if (board.length >= 3) _flop = _cards(board.take(3));
    if (board.length >= 4) _turn = board[3].code;
    if (board.length >= 5) _river = board[4].code;
    _flush();
    unawaited(_withHand((id) => dao.updateBoard(
          id,
          flop: _flop.isEmpty ? null : _flop,
          turn: _turn.isEmpty ? null : _turn,
          river: _river.isEmpty ? null : _river,
        )));
  }

  /// Persists a graded hero decision; resolves to the `coach_decisions` id.
  Future<int?> recordHeroDecision(
    LiveCoachGrade grade,
    GameState before,
    PokerAction action,
  ) async {
    _flush();
    _evDeltaBb += grade.evDeltaBb;
    final handId = await currentHandId;
    final record = CoachDecisionRecord(
      handId: handId,
      sessionId: _sessionId(),
      street: before.street.name,
      heroAction: action.type.name,
      heroAmount: action.amount,
      bestAction: grade.optimalAction?.name,
      bestSizingBb: grade.optimalSizingBb,
      verdict: grade.verdict.name,
      mismatch: grade.mismatch.name,
      evDeltaBb: grade.evDeltaBb,
      evDeltaDollars: grade.evDeltaBb * before.bigBlind,
      villainName: grade.villainName,
      villainArchetype: grade.villainArchetype.id,
      adviceText: grade.message,
      gradedAtMs: _now(),
    );
    return _guard(() => dao.recordDecision(record), 'recordDecision');
  }

  /// Stores what the coach finally said (text only).
  void completeDecision(
    int? decisionId, {
    required String adviceText,
    required String adviceSource,
    int? aiRequestId,
  }) {
    if (decisionId == null) return;
    unawaited(_guard(
      () => dao.completeDecision(
        decisionId,
        adviceText: adviceText,
        adviceSource: adviceSource,
        aiRequestId: aiRequestId,
        voicePlayed: false,
        voiceFromCache: false,
        voiceUsedDevice: false,
      ),
      'completeDecision',
    ));
  }

  /// Finalizes the hand from its resolved [state].
  void endHand(GameState state) {
    if (_handId == null) return;
    recordStreet(state);
    final hero = state.hero;
    final net = hero.stack - _heroStartStack;
    final message = state.resultMessage;
    final winners = <int>[
      for (final p in state.players)
        if (message != null && message.contains(p.name)) p.id,
    ];
    final record = HandEndRecord(
      endedAtMs: _now(),
      boardFlop: _flop,
      boardTurn: _turn,
      boardRiver: _river,
      finalStreet: state.street.name,
      wentToShowdown: state.players.where((p) => !p.folded).length > 1 &&
          state.community.length == 5,
      resultMessage: message,
      winnerSeats: winners,
      finalPot: _totalPot(state),
      heroNetDollars: net,
      heroNetBb: state.bigBlind == 0 ? 0 : net / state.bigBlind,
      heroEvDeltaDollars: _evDeltaBb * state.bigBlind,
      heroEvDeltaBb: _evDeltaBb,
    );
    unawaited(_withHand((id) => dao.endHand(id, record)));
    _handId = null;
  }

  void _flush() {
    if (_pending.isEmpty) return;
    final batch = List<HandActionRecord>.of(_pending);
    final first = _seq;
    _seq += batch.length;
    _pending.clear();
    unawaited(
      _withHand((id) => dao.appendActions(id, batch, firstSeq: first)),
    );
  }

  Future<void> _withHand(Future<void> Function(int id) body) async {
    final id = await currentHandId;
    if (id == null) return;
    await _guard(() => body(id), 'write');
  }

  Future<T?> _guard<T>(Future<T> Function() body, String op) async {
    try {
      return await body();
    } catch (e, st) {
      DiagnosticsLog.error('HandRecorder.$op', e, st);
      return null;
    }
  }
}
