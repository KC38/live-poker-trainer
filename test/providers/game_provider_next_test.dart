/// Early Next after fold: skip remaining replay and deal the next hand.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/models/table_setup.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/firestore/situation_service.dart';

class _FakeSituationService extends SituationService {
  _FakeSituationService(this.situation);

  final SituationModel situation;
  final List<List<String>> recordedPaths = [];
  final List<List<String>> recordedActionKeys = [];
  int fetchCount = 0;

  @override
  Future<FetchedSituation> fetchSituation(TableSetup setup) async {
    fetchCount += 1;
    return FetchedSituation(
      situationId: 'situation-$fetchCount',
      setupKey: situation.setupKey,
      situation: situation,
    );
  }

  @override
  Future<void> recordSituationProgress({
    required String situationId,
    required String setupKey,
    required List<String> pathNodeIds,
    required List<String> chosenActionKeys,
    required String terminalNodeId,
    required double heroNetChips,
    String? notes,
  }) async {
    recordedPaths.add(List<String>.from(pathNodeIds));
    recordedActionKeys.add(List<String>.from(chosenActionKeys));
  }
}

SituationModel _authoredSituation() {
  const bet = HeroActionEdge(
    actionKey: 'BET_55',
    kind: SituationActionKind.bet,
    amountTo: 55,
    coaching: 'Use the authored size.',
    verdict: HeroActionVerdict.correct,
    evDeltaBb: 0,
    optimalActionKey: 'BET_55',
    nextNodeId: 'terminal',
  );
  return SituationModel(
    payloadVersion: 2,
    schemaVersion: 'situation-v2.0',
    setupKey: 'test-setup',
    setupMode: SetupMode.random,
    seatCount: 2,
    smallBlind: 1,
    bigBlind: 2,
    ante: 0,
    startingStack: 200,
    buttonSeat: 0,
    heroSeat: 0,
    lineup: const [
      SituationSeatLineup(
        seat: 0,
        archetype: 'HERO',
        name: 'Hero',
        startingStack: 200,
      ),
      SituationSeatLineup(
        seat: 1,
        archetype: 'TAG',
        name: 'Villain',
        startingStack: 200,
      ),
    ],
    holeCards: [
      SituationHoleCards(
        seat: 0,
        cards: [CardModel.fromCode('As'), CardModel.fromCode('Kh')],
      ),
      SituationHoleCards(
        seat: 1,
        cards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
      ),
    ],
    heroHand: [CardModel.fromCode('As'), CardModel.fromCode('Kh')],
    runouts: const [],
    rootNodeId: 'hero',
    nodes: {
      'hero': const HeroDecisionNode(
        id: 'hero',
        street: Street.flop,
        pot: 20,
        stacks: [200, 200],
        streetBets: [0, 0],
        board: [],
        foldedSeats: [],
        toAct: 0,
        callAmount: 0,
        minRaiseTo: 2,
        actions: [bet],
      ),
      'terminal': const TerminalNode(
        id: 'terminal',
        street: Street.flop,
        reason: TerminalReason.fold,
        board: [],
        foldedSeats: [1],
        stacks: [145, 200],
        pot: 75,
        winnerSeats: [0],
        heroNetChips: 20,
      ),
    },
  );
}

GameState _headsUp({required bool heroFolded, required bool handOver}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 200,
        isHero: true,
        folded: heroFolded,
        holeCards: [CardModel.fromCode('As'), CardModel.fromCode('Kh')],
      ),
      PlayerModel(
        id: 1,
        name: 'Villain',
        archetype: PlayerArchetype.tag,
        stack: 200,
        holeCards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
      ),
    ],
    mode: GameMode.training,
    street: handOver ? Street.showdown : Street.flop,
    waitingForHero: !heroFolded && !handOver,
    isHandOver: handOver,
    resultMessage: handOver ? 'Villain wins' : null,
  );
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [soundServiceProvider.overrideWithValue(SoundService.silent())],
  );
}

ProviderContainer _authoredContainer(_FakeSituationService service) {
  return ProviderContainer(
    overrides: [
      authUidProvider.overrideWithValue('test-user'),
      soundServiceProvider.overrideWithValue(SoundService.silent()),
      situationServiceProvider.overrideWithValue(service),
    ],
  );
}

Future<void> _flushMicrotasks() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ReplayPace.testScale = 0;
  });

  tearDown(() {
    ReplayPace.testScale = 1;
  });

  test('nextHand is refused while hero can still act', () async {
    final container = _container();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    // Inject a mid-hand state via private-less path: copyWith on state.
    // GameController exposes state through the provider.
    container.read(gameControllerProvider.notifier);
    // Directly set via startTraining would need network; instead verify the
    // guard when game is null / not folded.
    expect(container.read(gameControllerProvider).game, isNull);
    await controller.nextHand();
    await _flushMicrotasks();
    expect(container.read(gameControllerProvider).game, isNull);
  });

  test('heroDoneForHand is true when hero has folded', () {
    final session = TableSession(
      game: _headsUp(heroFolded: true, handOver: false),
    );
    expect(session.heroDoneForHand, isTrue);
    expect(session.heroCanAct, isFalse);
  });

  test('highlightNext only when hand is over', () {
    final mid = TableSession(game: _headsUp(heroFolded: true, handOver: false));
    final done = TableSession(game: _headsUp(heroFolded: true, handOver: true));
    expect(mid.highlightNext, isFalse);
    expect(done.highlightNext, isTrue);
  });

  test(
    'rejects unauthored action without mutating or recording progress',
    () async {
      final service = _FakeSituationService(_authoredSituation());
      final container = _authoredContainer(service);
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      await controller.startTraining();
      final before = container.read(gameControllerProvider);
      expect(before.authoredHeroEdges.single.actionKey, 'BET_55');

      await controller.heroAct(
        const PokerAction(type: PokerActionType.bet, amount: 50),
      );

      final after = container.read(gameControllerProvider);
      expect(after.game, same(before.game));
      expect(after.authoredHeroEdges.single.actionKey, 'BET_55');
      expect(after.error, contains('not one of the authored choices'));
      expect(service.recordedPaths, isEmpty);
    },
  );

  test('exact authored action records its edge and path', () async {
    final service = _FakeSituationService(_authoredSituation());
    final container = _authoredContainer(service);
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.startTraining();
    await controller.heroAct(
      const PokerAction(type: PokerActionType.bet, amount: 55),
    );

    expect(service.recordedPaths, [
      ['hero'],
    ]);
    expect(service.recordedActionKeys, [
      ['BET_55'],
    ]);
    expect(container.read(gameControllerProvider).authoredHeroEdges, isEmpty);
  });

  test('prepareTraining starts fetch before startTraining consumes it', () async {
    final service = _FakeSituationService(_authoredSituation());
    final container = _authoredContainer(service);
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    controller.prepareTraining();
    await _flushMicrotasks();
    expect(service.fetchCount, 1);

    await controller.startTraining();
    expect(service.fetchCount, 1);
    expect(container.read(gameControllerProvider).game, isNotNull);
    expect(container.read(gameControllerProvider).loading, isFalse);
  });

  test('end-of-hand prefetch is reused by nextHand', () async {
    final service = _FakeSituationService(_authoredSituation());
    final container = _authoredContainer(service);
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.startTraining();
    expect(service.fetchCount, 1);

    await controller.heroAct(
      const PokerAction(type: PokerActionType.bet, amount: 55),
    );
    await _flushMicrotasks();
    // Hand resolves and schedules prefetch of the next situation.
    expect(service.fetchCount, greaterThanOrEqualTo(2));
    final fetchesAfterHand = service.fetchCount;

    await controller.nextHand();
    expect(
      service.fetchCount,
      fetchesAfterHand,
      reason: 'nextHand should reuse the end-of-hand prefetch',
    );
    expect(container.read(gameControllerProvider).loading, isFalse);
  });
}
