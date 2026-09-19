/// Situation payload parsing and tree traversal tests.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/situation_action_keys.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/models/table_setup.dart';

/// Minimal fold tree matching `functions/src/test_fixtures.ts`.
Map<String, dynamic> _minimalFoldJson() {
  const startingStack = 200.0;
  const sb = 1.0;
  const bb = 2.0;
  return {
    'payloadVersion': 2,
    'schemaVersion': 'situation-v2.2',
    'setupKey': 'random|s2|stack200|sb1|bb2|ante0',
    'setupMode': 'random',
    'seatCount': 2,
    'smallBlind': sb,
    'bigBlind': bb,
    'ante': 0,
    'startingStack': startingStack,
    'buttonSeat': 0,
    'heroSeat': 0,
    'lineup': [
      {
        'seat': 0,
        'archetype': 'HERO',
        'name': 'Hero',
        'startingStack': startingStack,
      },
      {
        'seat': 1,
        'archetype': 'TAG',
        'name': 'Alex',
        'startingStack': startingStack,
      },
    ],
    'holeCards': [
      {
        'seat': 0,
        'cards': ['As', 'Kd'],
      },
      {
        'seat': 1,
        'cards': ['Qc', 'Tc'],
      },
    ],
    'heroHand': ['As', 'Kd'],
    'runouts': [
      {
        'street': 'flop',
        'cards': ['2c', '7d', 'Jh'],
      },
      {
        'street': 'turn',
        'cards': ['9s'],
      },
      {
        'street': 'river',
        'cards': ['3h'],
      },
    ],
    'rootNodeId': 'root',
    'title': 'BTN faces BB raise',
    'nodes': {
      'root': {
        'type': 'scripted',
        'id': 'root',
        'street': 'preflop',
        'pot': 0,
        'stacks': [startingStack, startingStack],
        'streetBets': [0, 0],
        'board': <String>[],
        'foldedSeats': <int>[],
        'actions': [
          {'seat': 0, 'kind': 'POST_SB', 'amountTo': sb},
          {'seat': 1, 'kind': 'POST_BB', 'amountTo': bb},
        ],
        'nextNodeId': 'open',
      },
      'open': {
        'type': 'hero',
        'id': 'open',
        'street': 'preflop',
        'pot': sb + bb,
        'stacks': [startingStack - sb, startingStack - bb],
        'streetBets': [sb, bb],
        'board': <String>[],
        'foldedSeats': <int>[],
        'toAct': 0,
        'callAmount': bb - sb,
        'minRaiseTo': bb * 2,
        'actions': [
          {
            'actionKey': 'FOLD',
            'kind': 'FOLD',
            'coaching': 'Folding forfeits the small blind.',
            'verdict': 'incorrect',
            'evDeltaBb': -1,
            'optimalActionKey': 'RAISE_100',
            'nextNodeId': 'term_check',
          },
          {
            'actionKey': 'CALL',
            'kind': 'CALL',
            'amountTo': bb,
            'coaching': 'Calling completes the small blind.',
            'verdict': 'close',
            'evDeltaBb': -0.3,
            'optimalActionKey': 'RAISE_100',
            'nextNodeId': 'term_call',
          },
          {
            'actionKey': 'RAISE_100',
            'kind': 'RAISE',
            'amountTo': bb * 2.5,
            'sizingBucket': '100',
            'coaching': 'Open to about 2.5x.',
            'verdict': 'correct',
            'evDeltaBb': 0,
            'optimalActionKey': 'RAISE_100',
            'nextNodeId': 'term_shove',
          },
        ],
      },
      'term_check': {
        'type': 'terminal',
        'id': 'term_check',
        'reason': 'fold',
        'street': 'preflop',
        'board': <String>[],
        'foldedSeats': [0],
        'stacks': [startingStack - sb, startingStack - bb],
        'pot': sb + bb,
        'winnerSeats': [1],
        'heroNetChips': -sb,
        'summary': 'Hero folds.',
      },
      'term_shove': {
        'type': 'terminal',
        'id': 'term_shove',
        'reason': 'fold',
        'street': 'preflop',
        'board': <String>[],
        'foldedSeats': [1],
        'stacks': [startingStack - bb * 2.5, startingStack - bb],
        'pot': bb * 2.5 + bb,
        'winnerSeats': [0],
        'heroNetChips': bb,
        'summary': 'Villain folds.',
      },
      'term_call': {
        'type': 'terminal',
        'id': 'term_call',
        'reason': 'showdown',
        'street': 'river',
        'board': ['2c', '7d', 'Jh', '9s', '3h'],
        'foldedSeats': <int>[],
        'stacks': [startingStack - bb, startingStack - bb],
        'pot': bb * 2,
        'winnerSeats': [0],
        'heroNetChips': bb,
        'summary': 'Limped pot reaches showdown.',
      },
      'term_river_split': {
        'type': 'terminal',
        'id': 'term_river_split',
        'reason': 'showdown',
        'street': 'river',
        'board': ['2c', '7d', 'Jh', '9s', '3h'],
        'foldedSeats': <int>[],
        'stacks': [startingStack - bb, startingStack - bb],
        'pot': bb * 2,
        'winnerSeats': [0, 1],
        'heroNetChips': 0,
        'summary': 'Split pot.',
      },
      'hero_river': {
        'type': 'hero',
        'id': 'hero_river',
        'street': 'river',
        'pot': bb * 2,
        'stacks': [startingStack - bb, startingStack - bb],
        'streetBets': [0.0, 0.0],
        'board': ['2c', '7d', 'Jh', '9s', '3h'],
        'foldedSeats': <int>[],
        'toAct': 0,
        'callAmount': 0,
        'minRaiseTo': bb,
        'actions': [
          {
            'actionKey': 'CHECK',
            'kind': 'CHECK',
            'coaching': 'Checking it down.',
            'verdict': 'correct',
            'evDeltaBb': 0,
            'optimalActionKey': 'CHECK',
            'nextNodeId': 'term_river_split',
          },
        ],
      },
    },
  };
}

void main() {
  group('SituationModel.fromJson', () {
    test('parses camelCase payloadVersion 2 graph', () {
      final s = SituationModel.fromJson(_minimalFoldJson());
      expect(s.payloadVersion, 2);
      expect(s.setupMode, SetupMode.random);
      expect(s.seatCount, 2);
      expect(s.heroHand.map((c) => c.code), ['As', 'Kd']);
      expect(s.holeCards[1].cards.map((c) => c.code), ['Qc', 'Tc']);
      expect(s.rootNode, isA<ScriptedNode>());
      final open = s.node('open');
      expect(open, isA<HeroDecisionNode>());
      final hero = open! as HeroDecisionNode;
      expect(hero.actions.length, 3);
      final bestEdge = hero.edgeForKey('RAISE_100')!;
      expect(bestEdge.coaching, contains('2.5x'));
      expect(bestEdge.verdict, HeroActionVerdict.correct);
      expect(bestEdge.evDeltaBb, 0);
      expect(bestEdge.optimalActionKey, 'RAISE_100');
      expect(bestEdge.toJson(), containsPair('verdict', 'correct'));
      expect(bestEdge.toJson(), containsPair('evDeltaBb', 0.0));
      expect(bestEdge.toJson(), containsPair('optimalActionKey', 'RAISE_100'));
      final terminal = s.node('term_check')! as TerminalNode;
      expect(terminal.stacks, [199, 198]);
      expect(terminal.winnerSeats, [1]);
      expect(terminal.toJson(), containsPair('winnerSeats', [1]));
    });

    test('tolerates snake_case aliases', () {
      final s = SituationModel.fromJson({
        'payload_version': 2,
        'schema_version': 'situation-v2.1',
        'setup_key': 'random|s2|stack100|sb1|bb2|ante0',
        'setup_mode': 'random',
        'seat_count': 2,
        'small_blind': 1,
        'big_blind': 2,
        'ante': 0,
        'starting_stack': 100,
        'button_seat': 0,
        'hero_seat': 0,
        'lineup': [
          {
            'seat': 0,
            'archetype': 'HERO',
            'name': 'Hero',
            'starting_stack': 100,
          },
          {
            'seat': 1,
            'archetype': 'NIT',
            'name': 'Stan',
            'starting_stack': 100,
          },
        ],
        'hero_hand': ['Ah', 'Ad'],
        'hole_cards': [
          {
            'seat': 0,
            'cards': ['Ah', 'Ad'],
          },
          {
            'seat': 1,
            'cards': ['Ks', 'Kd'],
          },
        ],
        'runouts': <dynamic>[],
        'root_node_id': 'h1',
        'nodes': {
          'h1': {
            'type': 'hero',
            'id': 'h1',
            'street': 'preflop',
            'pot': 3,
            'stacks': [99.0, 98.0],
            'street_bets': [1.0, 2.0],
            'board': <String>[],
            'folded_seats': <int>[],
            'to_act': 0,
            'call_amount': 1,
            'min_raise_to': 4,
            'actions': [
              {
                'action_key': 'FOLD',
                'kind': 'FOLD',
                'coaching': 'Fold.',
                'verdict': 'incorrect',
                'ev_delta_bb': -1.25,
                'optimal_action_key': 'FOLD',
                'next_node_id': 't1',
              },
            ],
          },
          't1': {
            'type': 'terminal',
            'id': 't1',
            'reason': 'fold',
            'street': 'preflop',
            'board': <String>[],
            'folded_seats': [0],
            'stacks': [99, 98],
            'pot': 3,
            'winner_seats': [1],
            'hero_net_chips': -1,
          },
        },
      });
      expect(s.rootNodeId, 'h1');
      final edge = (s.rootNode as HeroDecisionNode).actions.single;
      expect(edge.verdict, HeroActionVerdict.incorrect);
      expect(edge.evDeltaBb, -1.25);
      expect(edge.optimalActionKey, 'FOLD');
      expect((s.node('t1') as TerminalNode).heroNetChips, -1);
    });

    test('rejects missing required hero grading fields', () {
      final json = _minimalFoldJson();
      final nodes = json['nodes']! as Map<String, dynamic>;
      final open = nodes['open']! as Map<String, dynamic>;
      final actions = open['actions']! as List<dynamic>;
      (actions.first as Map<String, dynamic>).remove('verdict');

      expect(
        () => SituationModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing required terminal payout fields', () {
      final json = _minimalFoldJson();
      final nodes = json['nodes']! as Map<String, dynamic>;
      final terminal = nodes['term_check']! as Map<String, dynamic>;
      terminal.remove('winnerSeats');

      expect(
        () => SituationModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TableSetup', () {
    test('random mode omits lineup', () {
      final setup = TableSetup.fromGameSettings(
        const GameSettingsModel(seatCount: 6, stackDepthBb: 100),
      );
      final map = setup.toCallableMap();
      expect(map['mode'], 'random');
      expect(map['startingStack'], 200); // 100bb * 2
      expect(map.containsKey('lineup'), isFalse);
    });

    test('custom mode includes HERO lineup', () {
      final setup = TableSetup.fromGameSettings(
        const GameSettingsModel(
          seatCount: 3,
          lineupMode: LineupMode.custom,
          customArchetypes: [PlayerArchetype.tag, PlayerArchetype.nit],
        ),
      );
      final map = setup.toCallableMap();
      expect(map['mode'], 'custom');
      final lineup = map['lineup'] as List;
      expect(lineup.length, 3);
      expect(lineup.first['archetype'], 'HERO');
    });
  });

  group('PokerEngine.dealSituationHand', () {
    test('replays scripted blinds then waits on hero', () {
      final situation = SituationModel.fromJson(_minimalFoldJson());
      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
        random: Random(1),
      );
      engine.dealSituationHand(situation);
      expect(engine.state.waitingForHero, isFalse);
      expect(engine.state.dealerIndex, 0);
      expect(engine.state.sbIndex, 0);
      expect(engine.state.bbIndex, 1);
      expect(
        engine.state.players.map(
          (player) => player.holeCards.map((c) => c.code),
        ),
        [
          ['As', 'Kd'],
          ['Qc', 'Tc'],
        ],
      );

      engine.runToHeroOrEnd();

      expect(engine.state.waitingForHero, isTrue);
      expect(engine.currentHeroNode?.id, 'open');
      expect(engine.pathNodeIds, isEmpty);
    });

    test('uses the authored hero seat as the only hero', () {
      final json = _minimalFoldJson();
      json['setupKey'] = 'random|s3|stack200|sb1|bb2|ante0';
      json['seatCount'] = 3;
      json['heroSeat'] = 2;
      json['lineup'] = [
        {
          'seat': 0,
          'archetype': 'TAG',
          'name': 'Charlie',
          'startingStack': 200,
        },
        {'seat': 1, 'archetype': 'LAG', 'name': 'Diana', 'startingStack': 200},
        {'seat': 2, 'archetype': 'HERO', 'name': 'Hero', 'startingStack': 200},
      ];
      json['holeCards'] = [
        {
          'seat': 0,
          'cards': ['As', 'Kd'],
        },
        {
          'seat': 1,
          'cards': ['Qc', 'Tc'],
        },
        {
          'seat': 2,
          'cards': ['Qh', 'Qd'],
        },
      ];
      json['heroHand'] = ['Qh', 'Qd'];
      final nodes = json['nodes']! as Map<String, dynamic>;
      final root = nodes['root']! as Map<String, dynamic>;
      root['stacks'] = [200, 200, 200];
      root['streetBets'] = [0, 0, 0];
      root['actions'] = [
        {'seat': 1, 'kind': 'POST_SB', 'amountTo': 1},
        {'seat': 2, 'kind': 'POST_BB', 'amountTo': 2},
      ];

      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 3, stackDepthBb: 100),
        random: Random(9),
      );
      engine.dealSituationHand(SituationModel.fromJson(json));

      expect(
        engine.state.players.where((player) => player.isHero).map((p) => p.id),
        [2],
      );
      expect(engine.state.hero.id, 2);
      expect(engine.state.hero.holeCards.map((card) => card.code), [
        'Qh',
        'Qd',
      ]);
      expect(engine.state.dealerIndex, 0);
      expect(engine.state.bbIndex, 2);
    });

    test(
      'replays canonical ante and blind ledger without inserted actions',
      () {
        final json = _minimalFoldJson();
        json['ante'] = 1;
        final nodes = json['nodes']! as Map<String, dynamic>;
        final root = nodes['root']! as Map<String, dynamic>;
        root['actions'] = [
          {'seat': 0, 'kind': 'POST_ANTE', 'amountTo': 1},
          {'seat': 1, 'kind': 'POST_ANTE', 'amountTo': 1},
          {'seat': 0, 'kind': 'POST_SB', 'amountTo': 2},
          {'seat': 1, 'kind': 'POST_BB', 'amountTo': 3},
        ];
        final open = nodes['open']! as Map<String, dynamic>;
        open['pot'] = 5;
        open['stacks'] = [198, 197];
        open['streetBets'] = [2, 3];

        final engine = PokerEngine(
          settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
          random: Random(5),
        );
        engine.dealSituationHand(SituationModel.fromJson(json));
        expect(engine.state.players.map((p) => p.stack), [200, 200]);
        expect(engine.state.players.map((p) => p.currentBet), [0, 0]);

        engine.nextEvent();
        expect(engine.state.players.map((p) => p.currentBet), [1, 0]);
        engine.nextEvent();
        expect(engine.state.players.map((p) => p.currentBet), [1, 1]);
        engine.nextEvent();
        expect(engine.state.players.map((p) => p.currentBet), [2, 1]);
        engine.nextEvent();
        expect(engine.state.players.map((p) => p.currentBet), [2, 3]);
        expect(engine.currentHeroNode?.id, 'open');
        expect(engine.state.waitingForHero, isTrue);
      },
    );

    test('hero FOLD records path and reaches terminal', () {
      final situation = SituationModel.fromJson(_minimalFoldJson());
      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
        random: Random(2),
      );
      engine.dealSituationHand(situation);
      engine.runToHeroOrEnd();

      final node = engine.currentHeroNode!;
      final edge = node.edgeForKey('FOLD')!;
      final action = SituationActionKeys.pokerActionForEdge(engine.state, edge);
      engine.applySituationHeroChoice(edge: edge, action: action);

      expect(engine.pathNodeIds, ['open']);
      expect(engine.chosenActionKeys, ['FOLD']);
      expect(engine.terminalNodeId, 'term_check');
      expect(engine.state.isHandOver, isTrue);
      expect(engine.terminalHeroNetChips, -1);
      expect(engine.state.winnerIds, [1]);
      expect(engine.state.players[0].folded, isTrue);
      expect(engine.state.players.map((p) => p.stack), [199, 201]);
    });

    test('hero RAISE_100 reaches fold terminal', () {
      final situation = SituationModel.fromJson(_minimalFoldJson());
      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
        random: Random(3),
      );
      engine.dealSituationHand(situation);
      engine.runToHeroOrEnd();

      final node = engine.currentHeroNode!;
      final edge =
          SituationActionKeys.resolveEdge(
            node: node,
            state: engine.state,
            action: PokerAction(type: PokerActionType.raise, amount: 5),
          )!;
      expect(edge.actionKey, 'RAISE_100');
      engine.applySituationHeroChoice(
        edge: edge,
        action: SituationActionKeys.pokerActionForEdge(engine.state, edge),
      );

      expect(engine.terminalNodeId, 'term_shove');
      expect(engine.terminalHeroNetChips, 2);
      expect(engine.state.winnerIds, [0]);
      expect(engine.state.players.map((p) => p.stack), [202, 198]);
    });

    test('premature showdown never falls back to generic street play', () {
      final situation = SituationModel.fromJson(_minimalFoldJson());
      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
        random: Random(4),
      );
      engine.dealSituationHand(situation);
      engine.runToHeroOrEnd();

      final edge = engine.currentHeroNode!.edgeForKey('CALL')!;
      engine.applySituationHeroChoice(
        edge: edge,
        action: SituationActionKeys.pokerActionForEdge(engine.state, edge),
      );

      expect(engine.terminalNodeId, 'term_call');
      expect(engine.state.isHandOver, isTrue);
      expect(engine.state.waitingForHero, isFalse);
      expect(engine.state.community.length, 5);
      expect(engine.currentHeroNode, isNull);
      expect(engine.nextEvent(), isNull);
    });

    test('terminal split uses authored winners and pre-award stacks', () {
      final json = _minimalFoldJson();
      final nodes = json['nodes']! as Map<String, dynamic>;
      final river = Map<String, dynamic>.from(
        nodes['hero_river']! as Map<String, dynamic>,
      );
      final terminal = Map<String, dynamic>.from(
        nodes['term_river_split']! as Map<String, dynamic>,
      );
      terminal['winnerSeats'] = [0, 1];
      terminal['heroNetChips'] = 0;
      final riverActions = List<dynamic>.from(river['actions']! as List);
      final check = Map<String, dynamic>.from(
        riverActions.first as Map<String, dynamic>,
      );
      check['nextNodeId'] = 'term_river_split';
      river['actions'] = [check];

      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
        random: Random(4),
      );
      engine.dealSituationHand(
        SituationModel.fromJson({
          ...json,
          'rootNodeId': 'hero_river',
          'nodes': {
            'hero_river': river,
            'term_river_split': terminal,
          },
        }),
      );

      final edge = engine.currentHeroNode!.edgeForKey('CHECK')!;
      engine.applySituationHeroChoice(
        edge: edge,
        action: SituationActionKeys.pokerActionForEdge(engine.state, edge),
      );

      expect(engine.state.isHandOver, isTrue);
      expect(engine.state.winnerIds, [0, 1]);
      expect(engine.state.players.map((p) => p.stack), [200, 200]);
      expect(engine.terminalHeroNetChips, 0);
    });

    test('terminal split assigns an odd cent by ascending seat id', () {
      final json = _minimalFoldJson();
      final nodes = json['nodes']! as Map<String, dynamic>;
      final river = Map<String, dynamic>.from(
        nodes['hero_river']! as Map<String, dynamic>,
      );
      final terminal = Map<String, dynamic>.from(
        nodes['term_river_split']! as Map<String, dynamic>,
      );
      terminal['pot'] = 10.01;
      terminal['stacks'] = [194.99, 195.0];
      terminal['winnerSeats'] = [1, 0];
      terminal['heroNetChips'] = 0;
      final riverActions = List<dynamic>.from(river['actions']! as List);
      final check = Map<String, dynamic>.from(
        riverActions.first as Map<String, dynamic>,
      );
      check['nextNodeId'] = 'term_river_split';
      river['actions'] = [check];

      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 2, stackDepthBb: 100),
        random: Random(6),
      );
      engine.dealSituationHand(
        SituationModel.fromJson({
          ...json,
          'rootNodeId': 'hero_river',
          'nodes': {
            'hero_river': river,
            'term_river_split': terminal,
          },
        }),
      );

      final edge = engine.currentHeroNode!.edgeForKey('CHECK')!;
      engine.applySituationHeroChoice(
        edge: edge,
        action: SituationActionKeys.pokerActionForEdge(engine.state, edge),
      );

      expect(engine.state.players.map((p) => p.stack), [200, 200]);
      expect(engine.state.awardShareFor(0), 5.01);
      expect(engine.state.awardShareFor(1), 5);
      expect(engine.terminalHeroNetChips, 0);
    });
  });
}
