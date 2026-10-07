/// Opening-batch action badges wait for hole cards, then land in act order.
library;

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/core/deal/felt_action_reveal_controller.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

PlayerModel _seat({
  required int id,
  required String name,
  bool folded = false,
  String? lastActionLabel,
}) {
  return PlayerModel(
    id: id,
    name: name,
    archetype: id == 0 ? PlayerArchetype.hero : PlayerArchetype.tag,
    stack: 200,
    isHero: id == 0,
    folded: folded,
    lastActionLabel: lastActionLabel,
    holeCards: [
      CardModel.fromCode('Ah'),
      CardModel.fromCode('Kd'),
    ],
  );
}

GameState _sixMax({
  List<int> folded = const [],
  Map<int, String> labels = const {},
}) {
  return GameState(
    players: [
      for (var i = 0; i < 6; i++)
        _seat(
          id: i,
          name: const ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'][i],
          folded: folded.contains(i),
          lastActionLabel: labels[i] ?? (folded.contains(i) ? 'FOLD' : null),
        ),
    ],
    mode: GameMode.training,
    dealerIndex: 3,
    sbIndex: 4,
    bbIndex: 5,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  test('post-deal order is UTG then HJ before later seats', () {
    final actions = postDealActionsInOrder(
      _sixMax(folded: const [0, 1]),
    );
    expect(actions.map((action) => action.seat), [0, 1]);
    expect(actions.map((action) => action.label), ['FOLD', 'FOLD']);
  });

  test('blinds are not post-deal actions', () {
    final actions = postDealActionsInOrder(
      _sixMax(labels: const {4: 'BLIND', 5: 'BLIND', 3: 'RAISE'}),
    );
    expect(actions, [(seat: 3, label: 'RAISE')]);
  });

  test('opening folds wait for holes then land UTG before HJ', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      final shown = <String>[];
      final reveal = FeltActionRevealController(
        onRevealed: (seat, label) => shown.add('$seat:$label'),
      );
      final actions = postDealActionsInOrder(_sixMax(folded: const [0, 1]));

      reveal.bind(
        epoch: 'pre-1',
        holesComplete: false,
        actions: actions,
      );
      expect(reveal.isSequencing, isTrue);
      expect(reveal.isRevealed(0), isFalse);
      expect(reveal.isRevealed(1), isFalse);
      expect(reveal.openingBatchComplete, isFalse);

      reveal.bind(
        epoch: 'pre-1',
        holesComplete: true,
        actions: actions,
      );
      async.flushMicrotasks();
      expect(shown, isEmpty);
      expect(reveal.isRevealed(0), isFalse);

      async.elapse(CardDealPace.dealCard);
      expect(shown, ['0:FOLD']);
      expect(reveal.isRevealed(0), isTrue);
      expect(reveal.isRevealed(1), isFalse);

      async.elapse(CardDealPace.dealCard);
      expect(shown, ['0:FOLD', '1:FOLD']);
      expect(reveal.openingBatchComplete, isTrue);
      reveal.dispose();
    });
  });

  test('actions that arrive after the opening batch show immediately', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      final reveal = FeltActionRevealController();
      reveal.bind(
        epoch: 'live-1',
        holesComplete: false,
        actions: const [],
      );
      reveal.bind(
        epoch: 'live-1',
        holesComplete: true,
        actions: const [],
      );
      async.elapse(CardDealPace.dealCard);
      expect(reveal.openingBatchComplete, isTrue);

      reveal.bind(
        epoch: 'live-1',
        holesComplete: true,
        actions: const [(seat: 0, label: 'FOLD')],
      );
      expect(reveal.isRevealed(0), isTrue);
      reveal.dispose();
    });
  });

  test('a flop start with holes already out shows folds immediately', () {
    CardDealPace.debugInstant = false;
    final reveal = FeltActionRevealController();
    reveal.bind(
      epoch: 'flop-1',
      holesComplete: true,
      actions: postDealActionsInOrder(_sixMax(folded: const [0, 1])),
    );
    expect(reveal.isSequencing, isFalse);
    expect(reveal.isRevealed(0), isTrue);
    expect(reveal.isRevealed(1), isTrue);
    reveal.dispose();
  });

  test('folded seats with a blank label still fold before later actions', () {
    final actions = postDealActionsInOrder(
      GameState(
        players: [
          _seat(id: 0, name: 'UTG', folded: true),
          _seat(id: 1, name: 'HJ', folded: true, lastActionLabel: '  '),
          _seat(id: 2, name: 'CO', lastActionLabel: 'raise_to'),
          _seat(id: 3, name: 'BTN', lastActionLabel: ' '),
          _seat(id: 4, name: 'SB', lastActionLabel: 'blind'),
          _seat(id: 5, name: 'BB', lastActionLabel: 'BLIND'),
        ],
        mode: GameMode.training,
        dealerIndex: 3,
        sbIndex: 4,
        bbIndex: 5,
      ),
    );
    expect(actions, [
      (seat: 0, label: 'FOLD'),
      (seat: 1, label: 'FOLD'),
      (seat: 2, label: 'RAISE-TO'),
    ]);
  });

  test('an empty table has no post-deal actions', () {
    expect(
      postDealActionsInOrder(
        const GameState(players: [], mode: GameMode.training),
      ),
      isEmpty,
    );
  });

  test('seats that have not acted stay visible while opening folds wait', () {
    CardDealPace.debugInstant = false;
    final reveal = FeltActionRevealController();
    reveal.bind(
      epoch: 'pre-wait',
      holesComplete: false,
      actions: const [
        (seat: 0, label: 'FOLD'),
        (seat: 1, label: 'FOLD'),
      ],
    );
    expect(reveal.isRevealed(0), isFalse);
    expect(reveal.isRevealed(1), isFalse);
    expect(reveal.isRevealed(3), isTrue);
    reveal.dispose();
  });

  test('instant mode shows opening folds without reveal sfx', () {
    CardDealPace.debugInstant = true;
    final shown = <String>[];
    final reveal = FeltActionRevealController(
      onRevealed: (seat, label) => shown.add('$seat:$label'),
    );
    reveal.bind(
      epoch: 'instant-1',
      holesComplete: false,
      actions: const [
        (seat: 0, label: 'FOLD'),
        (seat: 1, label: 'FOLD'),
      ],
    );
    expect(reveal.isSequencing, isFalse);
    expect(reveal.openingBatchComplete, isTrue);
    expect(reveal.isRevealed(0), isTrue);
    expect(reveal.isRevealed(1), isTrue);
    expect(shown, isEmpty);
    reveal.dispose();
  });

  test('a new epoch cancels a badge that has not landed', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      final shown = <String>[];
      final reveal = FeltActionRevealController(
        onRevealed: (seat, label) => shown.add('$seat:$label'),
      );
      reveal.bind(
        epoch: 'hand-a',
        holesComplete: false,
        actions: const [(seat: 0, label: 'FOLD')],
      );
      reveal.bind(
        epoch: 'hand-a',
        holesComplete: true,
        actions: const [(seat: 0, label: 'FOLD')],
      );
      reveal.bind(
        epoch: 'hand-b',
        holesComplete: false,
        actions: const [(seat: 2, label: 'RAISE')],
      );
      async.elapse(CardDealPace.dealCard);
      expect(shown, isEmpty);
      expect(reveal.isSequencing, isTrue);
      expect(reveal.isRevealed(2), isFalse);
      expect(reveal.isRevealed(0), isTrue);
      reveal.dispose();
    });
  });

  test('dispose cancels a badge that has not landed', () {
    CardDealPace.debugInstant = false;
    fakeAsync((async) {
      final shown = <String>[];
      final reveal = FeltActionRevealController(
        onRevealed: (seat, label) => shown.add('$seat:$label'),
      );
      reveal.bind(
        epoch: 'hand-a',
        holesComplete: false,
        actions: const [(seat: 0, label: 'FOLD')],
      );
      reveal.bind(
        epoch: 'hand-a',
        holesComplete: true,
        actions: const [(seat: 0, label: 'FOLD')],
      );
      reveal.dispose();
      async.elapse(CardDealPace.dealCard);
      expect(shown, isEmpty);
    });
  });
}
