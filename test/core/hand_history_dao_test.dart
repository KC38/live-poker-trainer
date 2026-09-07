/// HandHistoryDao: hand / action / decision writes, reads, and pruning.
library;

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/diagnostics_dao.dart';
import 'package:live_poker_trainer/core/database/hand_history_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/retention_policy.dart';

HandStartRecord _start(int n, {int? sessionId}) => HandStartRecord(
      sessionId: sessionId,
      handNumber: n,
      startedAtMs: 1000 + n,
      settingsJson: '{"seatCount":6}',
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      stackDepthBb: 100,
      dealerSeat: 0,
      sbSeat: 1,
      bbSeat: 2,
      heroSeat: 3,
      lineup: const [
        {'seat': 0, 'name': 'Nit Nate', 'archetype': 'nit', 'stack': 200.0},
      ],
      heroCards: 'As Kd',
      rebuyEvents: const [
        {'seat': 4, 'from': 30.0, 'to': 200.0},
      ],
    );

HandActionRecord _action(int seat, String type, double amt) => HandActionRecord(
      seat: seat,
      playerName: 'P$seat',
      archetype: 'tag',
      isHero: seat == 3,
      street: 'preflop',
      actionType: type,
      amount: amt,
      potBefore: 3,
      potAfter: 3 + amt,
      stackAfter: 200 - amt,
      atMs: 5,
    );

void main() {
  late AppDatabase db;
  late HandHistoryDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = HandHistoryDao(db);
  });

  tearDown(() => db.close());

  test('full hand lifecycle round-trips', () async {
    final handId = await dao.startHand(_start(1, sessionId: 42));

    await dao.appendActions(handId, [_action(1, 'call', 2), _action(3, 'raise', 8)]);
    await dao.appendActions(handId, [_action(1, 'fold', 0)], firstSeq: 2);
    await dao.updateBoard(handId, flop: 'Ah 7c 2d');

    final decisionId = await dao.recordDecision(
      CoachDecisionRecord(
        handId: handId,
        sessionId: 42,
        street: 'preflop',
        heroAction: 'raise',
        heroAmount: 8,
        bestAction: 'raise',
        bestSizingBb: 3.5,
        verdict: 'correct',
        mismatch: 'none',
        evDeltaBb: 0,
        evDeltaDollars: 0,
        villainName: 'Nit Nate',
        villainArchetype: 'nit',
        adviceText: 'Good raise.',
        gradedAtMs: 7,
      ),
    );
    await dao.completeDecision(
      decisionId,
      adviceText: 'Nice iso against the Nit.',
      adviceSource: 'gemini',
      aiRequestId: 99,
      voicePlayed: true,
      voiceFromCache: false,
      voiceUsedDevice: false,
    );

    await dao.endHand(
      handId,
      const HandEndRecord(
        endedAtMs: 9000,
        boardFlop: 'Ah 7c 2d',
        boardTurn: '',
        boardRiver: '',
        finalStreet: 'flop',
        wentToShowdown: false,
        resultMessage: 'Hero wins \$11',
        winnerSeats: [3],
        finalPot: 11,
        heroNetDollars: 3,
        heroNetBb: 1.5,
        heroEvDeltaDollars: 0,
        heroEvDeltaBb: 0,
      ),
    );

    final hand = (await dao.recentHands()).single;
    expect(hand.id, handId);
    expect(hand.sessionId, 42);
    expect(hand.handNumber, 1);
    expect(hand.heroCards, 'As Kd');
    expect(hand.boardFlop, 'Ah 7c 2d');
    expect(hand.finalStreet, 'flop');
    expect(hand.endedAtMs, 9000);
    expect(hand.heroNetBb, 1.5);
    expect(jsonDecode(hand.winnerSeatsJson), [3]);
    expect(jsonDecode(hand.rebuyEventsJson), hasLength(1));
    expect(jsonDecode(hand.lineupJson), hasLength(1));
    expect(hand.payloadVersion, HandHistoryDao.payloadVersion);
    expect(hand.updatedAtMs, greaterThanOrEqualTo(hand.createdAtMs));

    final actions = await dao.actionsFor(handId);
    expect(actions.map((a) => a.sequence), [0, 1, 2]);
    expect(actions.map((a) => a.actionType), ['call', 'raise', 'fold']);
    expect(actions[1].isHero, isTrue);

    final decision = (await dao.decisionsFor(handId)).single;
    expect(decision.adviceSource, 'gemini');
    expect(decision.adviceText, contains('Nit'));
    expect(decision.aiRequestId, 99);
    expect(decision.voicePlayed, isTrue);
    expect(decision.narratedAtMs, isNotNull);
    expect(await dao.recentHands(sessionId: 1), isEmpty);
  });

  test('pruning hands cascades to their actions', () async {
    final diagnostics = DiagnosticsDao(
      db,
      retention: const RetentionPolicy(maxHands: 2, maxCoachDecisions: 1),
    );
    final ids = <int>[];
    for (var n = 1; n <= 4; n++) {
      final id = await dao.startHand(_start(n));
      ids.add(id);
      await dao.appendActions(id, [_action(1, 'call', 2)]);
      await dao.recordDecision(
        CoachDecisionRecord(
          handId: id,
          street: 'preflop',
          heroAction: 'call',
          heroAmount: 2,
          bestAction: 'raise',
          bestSizingBb: 3,
          verdict: 'mistake',
          mismatch: 'tooPassive',
          evDeltaBb: -1,
          evDeltaDollars: -2,
          villainName: 'v',
          villainArchetype: 'nit',
          adviceText: 'raise',
          gradedAtMs: n,
        ),
      );
    }

    final deleted = await diagnostics.prune();
    expect(deleted['hands'], 2);
    expect(deleted['hand_actions'], 2);
    expect(deleted['coach_decisions'], 3);

    final remaining = await dao.recentHands();
    expect(remaining.map((h) => h.id), [ids[3], ids[2]]);
    expect(await dao.actionsFor(ids[0]), isEmpty);
    expect(await dao.actionsFor(ids[3]), hasLength(1));
    expect(await dao.recentDecisions(), hasLength(1));
  });
}
