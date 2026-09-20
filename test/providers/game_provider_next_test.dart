/// Controller coverage for server-authoritative live hand sessions.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/firestore/live_hand_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLiveHandService extends LiveHandService {
  _FakeLiveHandService(this.initial, this.afterAction, {this.undoResult});

  final LiveHandStartResult initial;
  final LiveActionResult afterAction;
  final LiveHandStartResult? undoResult;
  int startCalls = 0;
  int actionCalls = 0;
  int undoCalls = 0;
  String? lastActionId;

  @override
  Future<LiveHandStartResult> startHand(settings) async {
    startCalls++;
    return initial;
  }

  @override
  Future<LiveActionResult> submitAction({
    required LiveHandViewModel view,
    required LiveLegalActionModel action,
    required String idempotencyKey,
  }) async {
    actionCalls++;
    lastActionId = action.actionId;
    return afterAction;
  }

  @override
  Future<LiveHandStartResult> resumeHand(String sessionId) async => initial;

  @override
  Future<LiveHandStartResult> undoAction({
    required LiveHandViewModel view,
  }) async {
    undoCalls++;
    return undoResult ?? initial;
  }

  @override
  Stream<LiveActionFeedUpdate> watchActionFeed({
    required String sessionId,
    required String decisionId,
  }) =>
      const Stream.empty();
}

Map<String, dynamic> _viewJson({
  String status = 'playing',
  int stateVersion = 0,
  List<Map<String, dynamic>>? actions,
  String? street,
}) {
  final playing = status == 'playing';
  return {
    'sessionId': 'session-1',
    'handId': 'hand-1',
    'setupKey': 'live-v3|random|s2|max200bb|sb1|bb2',
    'decisionId': stateVersion == 0 ? 'node-root' : 'node-next',
    'stateVersion': stateVersion,
    'smallBlind': 1,
    'bigBlind': 2,
    'street': street ?? (playing ? 'preflop' : 'river'),
    'board':
        (street ?? (playing ? 'preflop' : 'river')) == 'preflop'
            ? <String>[]
            : ['2c', '3d', '4h', '8s', 'Kd'],
    'pot': status == 'playing' ? 3 : 24,
    'buttonSeat': 0,
    'heroSeat': 0,
    'actorSeat': status == 'playing' ? 0 : null,
    'status': status,
    'seats': [
      {
        'seat': 0,
        'name': 'Hero',
        'archetype': 'HERO',
        'stack': status == 'playing' ? 399 : 412,
        'streetBet': status == 'playing' ? 1 : 0,
        'folded': false,
        'allIn': false,
        'holeCards': ['Ah', 'Qd'],
      },
      {
        'seat': 1,
        'name': 'Alex',
        'archetype': 'TAG',
        'stack': status == 'playing' ? 398 : 388,
        'streetBet': status == 'playing' ? 2 : 0,
        'folded': false,
        'allIn': false,
        if (status != 'playing') 'holeCards': ['Ks', 'Kh'],
        'tendency': {
          'profileVersion': 'tendencies-v1',
          'archetype': 'TAG',
          'vpip': 23,
          'pfr': 19,
          'threeBet': 8,
          'aggression': 52,
          'foldToFlopBet': 45,
          'foldToTurnBet': 48,
          'foldToRiverBet': 52,
          'bluffRiver': 26,
          'showdownCall': 46,
          'sizingTellStrength': 25,
          'confidence': 'high',
          'reads': ['Disciplined ranges.', 'Position-aware aggression.'],
        },
      },
    ],
    'legalActions': actions ?? const <Map<String, dynamic>>[],
    'winnerSeats': status == 'complete' ? [0] : <int>[],
    'pots':
        status == 'complete'
            ? [
              {
                'amount': 24,
                'eligibleSeats': [0, 1],
                'winnerSeats': [0],
              },
            ]
            : <Map<String, dynamic>>[],
  };
}

const _call = {
  'actionId': 'CALL:200',
  'kind': 'CALL',
  'bucket': 'CALL',
  'amountTo': 2,
  'label': r'Call $1',
};

Future<(ProviderContainer, _FakeLiveHandService)> _container() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final initial = LiveHandStartResult.fromJson({
    'view': _viewJson(actions: [_call]),
    'events': <Map<String, dynamic>>[],
  });
  final after = LiveActionResult.fromJson({
    'view': _viewJson(status: 'complete', stateVersion: 1),
    'events': [
      {'sequence': 0, 'seat': 0, 'street': 'preflop', ..._call},
    ],
    'coaching': {
      'actionId': 'CALL:200',
      'rating': 'recommended',
      'confidence': 'high',
      'summary': 'Calling keeps weaker hands in.',
      'playerTypeReason': 'This TAG can continue with disciplined ranges.',
      'sizingNote': 'The price is acceptable.',
      'tendencyKeys': ['pfr'],
    },
    'replayed': false,
  });
  final service = _FakeLiveHandService(initial, after);
  final container = ProviderContainer(
    overrides: [
      authUidProvider.overrideWithValue('uid-1'),
      liveHandServiceProvider.overrideWithValue(service),
      soundServiceProvider.overrideWithValue(SoundService.silent()),
      settingsProvider.overrideWith((ref) => SettingsNotifier(preferences)),
    ],
  );
  return (container, service);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => ReplayPace.testScale = 0);

  tearDown(() => ReplayPace.testScale = 1);

  test('starts an online hand with exact fixed actions', () async {
    final (container, service) = await _container();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.startTraining();

    final session = container.read(gameControllerProvider);
    expect(service.startCalls, 1);
    expect(session.heroCanAct, isTrue);
    expect(session.liveActions.single.actionId, 'CALL:200');
    expect(session.game!.hero.holeCards.map((card) => card.code), ['Ah', 'Qd']);
    expect(session.game!.players[1].holeCards, isEmpty);
    expect(session.game!.players[1].tendency, isNotNull);
  });

  test(
    'submits the exact action id and displays qualitative coaching',
    () async {
      final (container, service) = await _container();
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      await controller.startTraining();

      await controller.heroActLive(
        container.read(gameControllerProvider).liveActions.single,
      );

      var session = container.read(gameControllerProvider);
      expect(service.actionCalls, 1);
      expect(service.lastActionId, 'CALL:200');
      // Hand-ending board/showdown stays hidden until coach Continue.
      expect(session.game!.isHandOver, isFalse);
      expect(session.game!.street.name, 'preflop');
      expect(session.game!.players[1].holeCards, isEmpty);
      expect(session.coach.message, contains('Calling keeps weaker hands in.'));
      expect(session.coach.optimalActionLabel, r'CALL $1');
      expect(session.coach.confidence, 'high');

      controller.dismissCoach();
      session = container.read(gameControllerProvider);
      expect(session.game!.isHandOver, isTrue);
      expect(session.game!.players[1].holeCards.map((card) => card.code), [
        'Ks',
        'Kh',
      ]);
    },
  );

  test('keeps coaching until dismissed when the next decision is ready', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const check = {
      'actionId': 'CHECK:0',
      'kind': 'CHECK',
      'bucket': 'CHECK',
      'label': 'Check',
    };
    final initial = LiveHandStartResult.fromJson({
      'view': _viewJson(actions: [check]),
      'events': <Map<String, dynamic>>[],
    });
    final after = LiveActionResult.fromJson({
      'view': _viewJson(stateVersion: 1, street: 'river', actions: [_call]),
      'events': [
        {'sequence': 0, 'seat': 0, 'street': 'preflop', ...check},
        {
          'sequence': 1,
          'seat': 1,
          'street': 'river',
          'actionId': 'BET:400',
          'kind': 'BET',
          'bucket': 'BET_67',
          'amountTo': 4,
          'label': r'Bet $4',
        },
      ],
      'coaching': {
        'actionId': 'CHECK:0',
        'rating': 'mistake',
        'confidence': 'high',
        'summary': 'Checking the turn gives a free river card.',
        'playerTypeReason': 'Paul calls too wide.',
        'sizingNote': '',
        'tendencyKeys': ['foldToTurnBet'],
      },
      'replayed': false,
    });
    final service = _FakeLiveHandService(initial, after);
    final container = ProviderContainer(
      overrides: [
        authUidProvider.overrideWithValue('uid-1'),
        liveHandServiceProvider.overrideWithValue(service),
        soundServiceProvider.overrideWithValue(SoundService.silent()),
        settingsProvider.overrideWith((ref) => SettingsNotifier(preferences)),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.startTraining();

    await controller.heroActLive(
      container.read(gameControllerProvider).liveActions.single,
    );

    var session = container.read(gameControllerProvider);
    expect(session.heroCanAct, isFalse);
    expect(session.game!.street.name, 'preflop');
    expect(session.game!.community, isEmpty);
    expect(session.liveActions, isEmpty);
    expect(session.coach.hasAdvice, isTrue);
    expect(session.coach.message, contains('Checking the turn'));

    controller.dismissCoach();
    session = container.read(gameControllerProvider);
    expect(session.coach.hasAdvice, isFalse);
    expect(session.game!.street.name, 'river');
    expect(session.liveActions.single.actionId, 'CALL:200');
    expect(session.heroCanAct, isTrue);
  });

  test('undoCoachAction restores the prior decision and clears coach', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const check = {
      'actionId': 'CHECK:0',
      'kind': 'CHECK',
      'bucket': 'CHECK',
      'label': 'Check',
    };
    final initial = LiveHandStartResult.fromJson({
      'view': _viewJson(actions: [check]),
      'events': <Map<String, dynamic>>[],
    });
    final after = LiveActionResult.fromJson({
      'view': _viewJson(stateVersion: 1, street: 'river', actions: [_call]),
      'events': [
        {'sequence': 0, 'seat': 0, 'street': 'preflop', ...check},
        {
          'sequence': 1,
          'seat': 1,
          'street': 'river',
          'actionId': 'BET:400',
          'kind': 'BET',
          'bucket': 'BET_67',
          'amountTo': 4,
          'label': r'Bet $4',
        },
      ],
      'coaching': {
        'actionId': 'CHECK:0',
        'rating': 'mistake',
        'confidence': 'high',
        'summary': 'Checking the turn gives a free river card.',
        'playerTypeReason': 'Paul calls too wide.',
        'sizingNote': '',
        'tendencyKeys': ['foldToTurnBet'],
      },
      'replayed': false,
    });
    final service = _FakeLiveHandService(initial, after, undoResult: initial);
    final container = ProviderContainer(
      overrides: [
        authUidProvider.overrideWithValue('uid-1'),
        liveHandServiceProvider.overrideWithValue(service),
        soundServiceProvider.overrideWithValue(SoundService.silent()),
        settingsProvider.overrideWith((ref) => SettingsNotifier(preferences)),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.startTraining();
    await controller.heroActLive(
      container.read(gameControllerProvider).liveActions.single,
    );

    expect(container.read(gameControllerProvider).coach.hasAdvice, isTrue);

    await controller.undoCoachAction();

    final session = container.read(gameControllerProvider);
    expect(service.undoCalls, 1);
    expect(session.coach.hasAdvice, isFalse);
    expect(session.game!.street.name, 'preflop');
    expect(session.liveActions.single.actionId, 'CHECK:0');
    expect(session.heroCanAct, isTrue);
    expect(session.liveView!.stateVersion, 0);
  });

  test('agent next dismisses mid-hand coach instead of no-op', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const check = {
      'actionId': 'CHECK:0',
      'kind': 'CHECK',
      'bucket': 'CHECK',
      'label': 'Check',
    };
    final initial = LiveHandStartResult.fromJson({
      'view': _viewJson(actions: [check]),
      'events': <Map<String, dynamic>>[],
    });
    final after = LiveActionResult.fromJson({
      'view': _viewJson(stateVersion: 1, street: 'river', actions: [_call]),
      'events': [
        {'sequence': 0, 'seat': 0, 'street': 'preflop', ...check},
        {
          'sequence': 1,
          'seat': 1,
          'street': 'river',
          'actionId': 'BET:400',
          'kind': 'BET',
          'bucket': 'BET_67',
          'amountTo': 4,
          'label': r'Bet $4',
        },
      ],
      'coaching': {
        'actionId': 'CHECK:0',
        'rating': 'mistake',
        'confidence': 'high',
        'summary': 'Checking the turn gives a free river card.',
        'playerTypeReason': 'Paul calls too wide.',
        'sizingNote': '',
        'tendencyKeys': ['foldToTurnBet'],
      },
      'replayed': false,
    });
    final service = _FakeLiveHandService(initial, after);
    final container = ProviderContainer(
      overrides: [
        authUidProvider.overrideWithValue('uid-1'),
        liveHandServiceProvider.overrideWithValue(service),
        soundServiceProvider.overrideWithValue(SoundService.silent()),
        settingsProvider.overrideWith((ref) => SettingsNotifier(preferences)),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.startTraining();

    await controller.heroActLive(
      container.read(gameControllerProvider).liveActions.single,
    );

    var session = container.read(gameControllerProvider);
    expect(session.coach.hasAdvice, isTrue);
    expect(session.heroDoneForHand, isFalse);
    expect(session.game!.street.name, 'preflop');
    final startCallsBefore = service.startCalls;

    controller.debugHandleAgentCommand('next');
    session = container.read(gameControllerProvider);
    expect(session.coach.hasAdvice, isFalse);
    expect(session.game!.street.name, 'river');
    expect(session.heroCanAct, isTrue);
    // Must not deal a new hand while the current one is still live.
    expect(service.startCalls, startCallsBefore);
  });

  test('rejects an action that is not in the current fixed set', () async {
    final (container, service) = await _container();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.startTraining();

    await controller.heroActLive(
      const LiveLegalActionModel(
        actionId: 'ALL_IN:40000',
        kind: 'ALL_IN',
        bucket: 'ALL_IN',
        label: 'All-in',
      ),
    );

    expect(service.actionCalls, 0);
    expect(container.read(gameControllerProvider).heroCanAct, isTrue);
  });

  test('a folded legacy snapshot still exposes quiet Next', () async {
    final (container, _) = await _container();
    addTearDown(container.dispose);
    final started = LiveHandViewModel.fromJson(_viewJson(actions: [_call]));
    final game = started.toGameState(handCount: 1);
    final foldedPlayers = [
      game.hero.copyWith(folded: true),
      ...game.players.where((player) => !player.isHero),
    ];
    final session = TableSession(
      game: game.copyWith(players: foldedPlayers),
      replaying: true,
    );
    expect(session.heroDoneForHand, isTrue);
    expect(session.highlightNext, isFalse);
  });
}
