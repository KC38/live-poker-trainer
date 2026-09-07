/// Hand history DAO: `hands`, `hand_actions`, and `coach_decisions`.
///
/// `HandRecorder` buffers a hand in memory and calls these helpers at most a
/// few times per hand (start, each hero decision, end), inserting actions in a
/// single batch so replay animation never waits on SQLite.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';

/// One buffered table action before it is written.
class HandActionRecord {
  /// Creates an action record.
  const HandActionRecord({
    required this.seat,
    required this.playerName,
    required this.archetype,
    required this.isHero,
    required this.street,
    required this.actionType,
    required this.amount,
    required this.potBefore,
    required this.potAfter,
    required this.stackAfter,
    required this.atMs,
  });

  final int seat;
  final String playerName;
  final String archetype;
  final bool isHero;
  final String street;
  final String actionType;
  final double amount;
  final double potBefore;
  final double potAfter;
  final double stackAfter;
  final int atMs;
}

/// Everything known about a hand when it is dealt.
class HandStartRecord {
  /// Creates a hand start record.
  const HandStartRecord({
    required this.handNumber,
    required this.startedAtMs,
    required this.settingsJson,
    required this.seatCount,
    required this.smallBlind,
    required this.bigBlind,
    required this.stackDepthBb,
    required this.dealerSeat,
    required this.sbSeat,
    required this.bbSeat,
    required this.heroSeat,
    required this.lineup,
    required this.heroCards,
    this.rebuyEvents = const [],
    this.sessionId,
  });

  final int handNumber;
  final int startedAtMs;
  final String settingsJson;
  final int seatCount;
  final double smallBlind;
  final double bigBlind;
  final int stackDepthBb;
  final int dealerSeat;
  final int sbSeat;
  final int bbSeat;
  final int heroSeat;

  /// Per seat: `{seat, name, archetype, stack}`.
  final List<Map<String, Object?>> lineup;
  final String heroCards;

  /// Per top-up: `{seat, from, to}`.
  final List<Map<String, Object?>> rebuyEvents;
  final int? sessionId;
}

/// Everything known about a hand once it resolves.
class HandEndRecord {
  /// Creates a hand end record.
  const HandEndRecord({
    required this.endedAtMs,
    required this.boardFlop,
    required this.boardTurn,
    required this.boardRiver,
    required this.finalStreet,
    required this.wentToShowdown,
    required this.resultMessage,
    required this.winnerSeats,
    required this.finalPot,
    required this.heroNetDollars,
    required this.heroNetBb,
    required this.heroEvDeltaDollars,
    required this.heroEvDeltaBb,
  });

  final int endedAtMs;
  final String boardFlop;
  final String boardTurn;
  final String boardRiver;
  final String finalStreet;
  final bool wentToShowdown;
  final String? resultMessage;
  final List<int> winnerSeats;
  final double finalPot;
  final double heroNetDollars;
  final double heroNetBb;
  final double heroEvDeltaDollars;
  final double heroEvDeltaBb;
}

/// One graded hero decision.
class CoachDecisionRecord {
  /// Creates a coach decision record.
  const CoachDecisionRecord({
    required this.street,
    required this.heroAction,
    required this.heroAmount,
    required this.bestAction,
    required this.bestSizingBb,
    required this.verdict,
    required this.mismatch,
    required this.evDeltaBb,
    required this.evDeltaDollars,
    required this.villainName,
    required this.villainArchetype,
    required this.adviceText,
    required this.gradedAtMs,
    this.handId,
    this.sessionId,
  });

  final int? handId;
  final int? sessionId;
  final String street;
  final String heroAction;
  final double heroAmount;
  final String? bestAction;
  final double bestSizingBb;
  final String verdict;
  final String mismatch;
  final double evDeltaBb;
  final double evDeltaDollars;
  final String villainName;
  final String villainArchetype;
  final String adviceText;
  final int gradedAtMs;
}

/// Data-access helpers for hands, actions, and coach decisions.
class HandHistoryDao {
  /// Creates a DAO bound to [db].
  HandHistoryDao(this.db);

  final AppDatabase db;

  /// Version written into `hands.payload_version` for the JSON columns.
  static const int payloadVersion = 1;

  static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// Inserts the hand header and returns its id.
  Future<int> startHand(HandStartRecord r) {
    final ts = _now();
    return db.into(db.hands).insert(
          HandsCompanion.insert(
            sessionId: Value(r.sessionId),
            handNumber: r.handNumber,
            startedAtMs: r.startedAtMs,
            settingsJson: r.settingsJson,
            seatCount: r.seatCount,
            smallBlind: r.smallBlind,
            bigBlind: r.bigBlind,
            stackDepthBb: r.stackDepthBb,
            dealerSeat: r.dealerSeat,
            sbSeat: r.sbSeat,
            bbSeat: r.bbSeat,
            heroSeat: r.heroSeat,
            lineupJson: jsonEncode(r.lineup),
            heroCards: Value(r.heroCards),
            rebuyEventsJson: Value(jsonEncode(r.rebuyEvents)),
            payloadVersion: const Value(payloadVersion),
            createdAtMs: ts,
            updatedAtMs: ts,
          ),
        );
  }

  /// Appends [actions] to [handId] in one batch, numbering from [firstSeq].
  Future<void> appendActions(
    int handId,
    List<HandActionRecord> actions, {
    int firstSeq = 0,
  }) async {
    if (actions.isEmpty) return;
    await db.batch((b) {
      var seq = firstSeq;
      for (final a in actions) {
        b.insert(
          db.handActions,
          HandActionsCompanion.insert(
            handId: handId,
            sequence: seq++,
            seat: a.seat,
            playerName: a.playerName,
            archetype: a.archetype,
            isHero: Value(a.isHero),
            street: a.street,
            actionType: a.actionType,
            amount: Value(a.amount),
            potBefore: Value(a.potBefore),
            potAfter: Value(a.potAfter),
            stackAfter: Value(a.stackAfter),
            atMs: a.atMs,
          ),
        );
      }
    });
  }

  /// Writes the board as it is revealed (safe to call per street).
  Future<void> updateBoard(
    int handId, {
    String? flop,
    String? turn,
    String? river,
  }) {
    return (db.update(db.hands)..where((t) => t.id.equals(handId))).write(
      HandsCompanion(
        boardFlop: flop == null ? const Value.absent() : Value(flop),
        boardTurn: turn == null ? const Value.absent() : Value(turn),
        boardRiver: river == null ? const Value.absent() : Value(river),
        updatedAtMs: Value(_now()),
      ),
    );
  }

  /// Finalizes the hand row.
  Future<void> endHand(int handId, HandEndRecord r) {
    return (db.update(db.hands)..where((t) => t.id.equals(handId))).write(
      HandsCompanion(
        endedAtMs: Value(r.endedAtMs),
        boardFlop: Value(r.boardFlop),
        boardTurn: Value(r.boardTurn),
        boardRiver: Value(r.boardRiver),
        finalStreet: Value(r.finalStreet),
        wentToShowdown: Value(r.wentToShowdown),
        resultMessage: Value(r.resultMessage),
        winnerSeatsJson: Value(jsonEncode(r.winnerSeats)),
        finalPot: Value(r.finalPot),
        heroNetDollars: Value(r.heroNetDollars),
        heroNetBb: Value(r.heroNetBb),
        heroEvDeltaDollars: Value(r.heroEvDeltaDollars),
        heroEvDeltaBb: Value(r.heroEvDeltaBb),
        updatedAtMs: Value(_now()),
      ),
    );
  }

  /// Inserts a coach decision and returns its id.
  Future<int> recordDecision(CoachDecisionRecord r) {
    final ts = _now();
    return db.into(db.coachDecisions).insert(
          CoachDecisionsCompanion.insert(
            handId: Value(r.handId),
            sessionId: Value(r.sessionId),
            street: r.street,
            heroAction: r.heroAction,
            heroAmount: Value(r.heroAmount),
            bestAction: Value(r.bestAction),
            bestSizingBb: Value(r.bestSizingBb),
            verdict: r.verdict,
            mismatch: Value(r.mismatch),
            evDeltaBb: Value(r.evDeltaBb),
            evDeltaDollars: Value(r.evDeltaDollars),
            villainName: Value(r.villainName),
            villainArchetype: Value(r.villainArchetype),
            adviceText: r.adviceText,
            gradedAtMs: r.gradedAtMs,
            createdAtMs: ts,
            updatedAtMs: ts,
          ),
        );
  }

  /// Fills in the narration outcome once the coach line and voice resolve.
  Future<void> completeDecision(
    int decisionId, {
    required String adviceText,
    required String adviceSource,
    int? aiRequestId,
    required bool voicePlayed,
    required bool voiceFromCache,
    required bool voiceUsedDevice,
    int? narratedAtMs,
  }) {
    final ts = _now();
    return (db.update(db.coachDecisions)
          ..where((t) => t.id.equals(decisionId)))
        .write(
      CoachDecisionsCompanion(
        adviceText: Value(adviceText),
        adviceSource: Value(adviceSource),
        aiRequestId: Value(aiRequestId),
        voicePlayed: Value(voicePlayed),
        voiceFromCache: Value(voiceFromCache),
        voiceUsedDevice: Value(voiceUsedDevice),
        narratedAtMs: Value(narratedAtMs ?? ts),
        updatedAtMs: Value(ts),
      ),
    );
  }

  // --- Reads -------------------------------------------------------------

  /// Hands newest first, optionally scoped to a session.
  Future<List<Hand>> recentHands({int limit = 50, int? sessionId}) {
    final q = db.select(db.hands)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(limit);
    if (sessionId != null) q.where((t) => t.sessionId.equals(sessionId));
    return q.get();
  }

  /// Ordered actions for one hand.
  Future<List<HandAction>> actionsFor(int handId) => (db.select(db.handActions)
        ..where((t) => t.handId.equals(handId))
        ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
      .get();

  /// Coach decisions for one hand, in order.
  Future<List<CoachDecision>> decisionsFor(int handId) =>
      (db.select(db.coachDecisions)
            ..where((t) => t.handId.equals(handId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  /// Coach decisions newest first.
  Future<List<CoachDecision>> recentDecisions({int limit = 100}) =>
      (db.select(db.coachDecisions)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(limit))
          .get();
}
