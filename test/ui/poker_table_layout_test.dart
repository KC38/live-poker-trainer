/// Layout guards: the coach shelf must never cover the hero's hole cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/hero_rail_widget.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// The smallest screen we support (iPhone SE logical size).
const _smallPhone = Size(320, 568);

/// A typical modern phone (iPhone 15 / 17 Pro logical size).
const _modernPhone = Size(393, 852);

class _FixedController extends GameController {
  _FixedController(super.ref, TableSession session) {
    state = session;
  }

  @override
  Future<void> startTraining({bool continueTable = false}) async {}
}

GameState _nineHandedGame({
  Street street = Street.turn,
  bool handOver = false,
}) {
  final archetypes = [
    PlayerArchetype.nit,
    PlayerArchetype.callingStation,
    PlayerArchetype.maniac,
    PlayerArchetype.tag,
    PlayerArchetype.lag,
    PlayerArchetype.nit,
    PlayerArchetype.tag,
    PlayerArchetype.callingStation,
  ];
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 173,
        currentBet: 8,
        isHero: true,
        holeCards: [CardModel.fromCode('Ks'), CardModel.fromCode('Jh')],
      ),
      for (var i = 0; i < archetypes.length; i++)
        PlayerModel(
          id: i + 1,
          name: 'Seat ${i + 1}',
          archetype: archetypes[i],
          stack: 300 + i * 17,
          currentBet: i.isEven ? 8 : 0,
          holeCards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
        ),
    ],
    mode: GameMode.training,
    community: [
      CardModel.fromCode('Ac'),
      CardModel.fromCode('Jc'),
      CardModel.fromCode('Kd'),
      CardModel.fromCode('3h'),
    ],
    mainPot: 937,
    street: street,
    highestBet: 8,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    dealerIndex: 3,
    sbIndex: 4,
    bbIndex: 5,
    waitingForHero: !handOver,
    isHandOver: handOver,
  );
}

Future<void> _pumpTable(
  WidgetTester tester, {
  required Size size,
  required TableSession session,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameControllerProvider.overrideWith(
          (ref) => _FixedController(ref, session),
        ),
      ],
      child: const MaterialApp(home: PokerTableScreen()),
    ),
  );
  await tester.pump();
}

/// The union of every hero hole-card rect on screen.
Rect _heroCardsRect(WidgetTester tester) {
  final cards = find.descendant(
    of: find.byType(HeroRailWidget),
    matching: find.byType(MiniCard),
  );
  expect(cards, findsNWidgets(2));
  Rect? union;
  for (final element in cards.evaluate()) {
    final box = element.renderObject! as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero);
    final rect = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      box.size.width,
      box.size.height,
    );
    union = union == null ? rect : union.expandToInclude(rect);
  }
  return union!;
}

Rect _rectOf(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  final topLeft = box.localToGlobal(Offset.zero);
  return Rect.fromLTWH(
    topLeft.dx,
    topLeft.dy,
    box.size.width,
    box.size.height,
  );
}

void main() {
  const longCoach = CoachFeedback(
    verdict: CoachVerdict.incorrect,
    message: 'Raising here bloats the pot against a station who calls with '
        'any pair and never folds to pressure. On the turn with king-high you '
        'have showdown value but no fold equity, so take the cheap price, '
        'keep the pot small, and let them pay you off when you improve.',
    optimalAction: ExploitAction.call,
    optimalSizingBb: 4,
    heroAction: 'RAISE',
    evDeltaBb: -3.84,
  );

  final sizes = <String, Size>{
    'small phone': _smallPhone,
    'modern phone': _modernPhone,
  };

  sizes.forEach((label, size) {
    group(label, () {
      testWidgets('coach shelf never overlaps the hero hole cards',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: const TableSession(coach: longCoach).copyWith(
            game: _nineHandedGame(),
          ),
        );
        expect(tester.takeException(), isNull);

        final heroCards = _heroCardsRect(tester);
        final coach = _rectOf(tester, find.byType(CoachShelfWidget));

        expect(
          heroCards.overlaps(coach),
          isFalse,
          reason: 'coach $coach covers hero cards $heroCards',
        );
        expect(
          coach.top,
          greaterThanOrEqualTo(heroCards.bottom - 0.5),
          reason: 'coach shelf must sit below the hero rail',
        );
      });

      testWidgets('hero hole cards stay fully inside the viewport',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: const TableSession(coach: longCoach).copyWith(
            game: _nineHandedGame(),
          ),
        );
        final heroCards = _heroCardsRect(tester);
        expect(heroCards.top, greaterThanOrEqualTo(0));
        expect(heroCards.left, greaterThanOrEqualTo(0));
        expect(heroCards.bottom, lessThanOrEqualTo(size.height));
        expect(heroCards.right, lessThanOrEqualTo(size.width));
        expect(heroCards.height, greaterThan(20));
      });

      testWidgets('renders no overflow across every street', (tester) async {
        for (final street in Street.values) {
          await _pumpTable(
            tester,
            size: size,
            session: const TableSession(coach: longCoach).copyWith(
              game: _nineHandedGame(
                street: street,
                handOver: street == Street.showdown,
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'table threw on ${street.label}',
          );
        }
      });

      testWidgets('felt shows currency only — no BB on the live table',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: const TableSession().copyWith(game: _nineHandedGame()),
        );
        final amounts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .where((t) => t.contains(r'$'))
            .toList();
        expect(amounts, isNotEmpty);
        expect(
          amounts.where((t) => t.contains('BB')),
          isEmpty,
          reason: 'dual amounts leaked onto the felt: $amounts',
        );
      });

      testWidgets('villain archetypes are legible words, not single letters',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: const TableSession().copyWith(game: _nineHandedGame()),
        );
        final labels = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => (t.data ?? '').toUpperCase())
            .toSet();
        for (final word in ['NIT', 'STATION', 'MANIAC', 'TAG', 'LAG']) {
          expect(
            labels.contains(word),
            isTrue,
            reason: 'archetype "$word" is not shown as a word on the felt',
          );
        }
      });

      testWidgets('hand over highlights Next without opening Hand review',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: TableSession(
            coach: longCoach,
          ).copyWith(
            game: _nineHandedGame(
              street: Street.showdown,
              handOver: true,
            ),
          ),
        );

        expect(find.text('Next'), findsOneWidget);
        expect(find.text('Review'), findsOneWidget);
        expect(find.text('Hand review'), findsNothing);
        expect(find.text('Next hand'), findsNothing);
      });
    });
  });
}
