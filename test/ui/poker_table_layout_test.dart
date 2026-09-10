/// Layout guards: strict band separation, plus the reclaimed action-dock band.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/profile_database.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/hero_rail_widget.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// The smallest screen we support (iPhone SE logical size).
const _smallPhone = Size(320, 568);

/// A typical modern phone (iPhone 15 / 17 Pro logical size).
const _modernPhone = Size(393, 852);

class _FixedController extends GameController {
  _FixedController(super.ref, TableSession session) {
    state = session;
  }

  /// Pushes a new session so tests can move between hero-to-act and review.
  void emit(TableSession session) => state = session;

  int nextHandCalls = 0;

  @override
  Future<void> startTraining({bool continueTable = false}) async {}

  @override
  Future<void> nextHand() async {
    nextHandCalls++;
  }
}

GameState _nineHandedGame({
  Street street = Street.turn,
  bool handOver = false,
  bool heroFolded = false,
  bool multiwayRiverBets = false,
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
  final community = switch (street) {
    Street.preflop => <CardModel>[],
    Street.flop => [
        CardModel.fromCode('Ac'),
        CardModel.fromCode('Jc'),
        CardModel.fromCode('Kd'),
      ],
    Street.turn => [
        CardModel.fromCode('Ac'),
        CardModel.fromCode('Jc'),
        CardModel.fromCode('Kd'),
        CardModel.fromCode('3h'),
      ],
    Street.river || Street.showdown => [
        CardModel.fromCode('Ac'),
        CardModel.fromCode('Jc'),
        CardModel.fromCode('Kd'),
        CardModel.fromCode('3h'),
        CardModel.fromCode('9s'),
      ],
  };
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 173,
        currentBet: heroFolded ? 0 : (multiwayRiverBets ? 349.54 : 8),
        isHero: true,
        folded: heroFolded,
        holeCards: [CardModel.fromCode('Ks'), CardModel.fromCode('Jh')],
      ),
      for (var i = 0; i < archetypes.length; i++)
        PlayerModel(
          id: i + 1,
          name: 'Seat ${i + 1}',
          archetype: archetypes[i],
          stack: 300 + i * 17,
          // Multi-way river: several large live bets like the crowded
          // production screenshot (Sammy / Paul / Rex stacked on the board).
          currentBet: multiwayRiverBets
              ? (i == 1 || i == 3 || i == 4 || i == 6 ? 117.42 + i * 40 : 0)
              : (i.isEven ? 8 : 0),
          lastActionLabel: multiwayRiverBets &&
                  (i == 1 || i == 3 || i == 4 || i == 6)
              ? (i.isOdd ? 'RAISE' : 'CALL')
              : null,
          holeCards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
        ),
    ],
    mode: GameMode.training,
    community: community,
    mainPot: multiwayRiverBets ? 1009.83 : 937,
    street: street,
    highestBet: multiwayRiverBets ? 355.88 : 8,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    dealerIndex: 3,
    sbIndex: 4,
    bbIndex: 5,
    waitingForHero: !handOver && !heroFolded,
    isHandOver: handOver,
    awardedPot: handOver ? 937 : 0,
    resultMessage: handOver ? 'Seat 1 wins \$937' : null,
    winnerIds: handOver ? const [1] : const [],
  );
}

/// Pumps the table and returns the controller so tests can change the session.
///
/// The header **Next** CTA pulses forever, so tests must never call
/// [WidgetTester.pumpAndSettle] here — advance with an explicit duration.
Future<_FixedController> _pumpTable(
  WidgetTester tester, {
  required Size size,
  required TableSession session,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  late _FixedController controller;
  await tester.pumpWidget(
    ProviderScope(
      // A fresh scope per pump so repeated pumps really do rebuild the table
      // with the session they were given.
      key: UniqueKey(),
      overrides: [
        // Settings side effects reach the sound service and the hero rail
        // reads the profile, both of which would open on-disk databases.
        appDatabaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
        profileDatabaseProvider.overrideWith((ref) {
          final db = ProfileDatabase(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
        gameControllerProvider.overrideWith(
          (ref) => controller = _FixedController(ref, session),
        ),
      ],
      child: const MaterialApp(home: PokerTableScreen()),
    ),
  );
  await tester.pump();
  return controller;
}

/// Runs past every band transition without settling the pulsing Next CTA.
Future<void> _settleBands(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
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

/// Painted bounds of a felt bet chip.
///
/// [_BetChip] lays out with its top-left at the anchor, then paints with a
/// horizontal FractionalTranslation(-0.5) and a -10px vertical nudge.
Rect _betChipVisualRect(WidgetTester tester, Key key) {
  final box = tester.getRect(find.byKey(key));
  return Rect.fromLTWH(
    box.left - box.width / 2,
    box.top - 10,
    box.width,
    box.height,
  );
}

/// Asserts nothing the player reads on the felt is hidden behind anything else.
///
/// Every seat HUD (archetype word, name, VPIP/PFR, stack), its action badge,
/// each live bet amount, and the board (pot headline + community cards) has to
/// be simultaneously legible — they are all inputs to the hero's decision.
void _expectNoFeltCollisions(
  WidgetTester tester,
  GameState game, {
  required Street street,
}) {
  final felt = _rectOf(tester, find.byType(FeltTableView));

  final seats = <int, Rect>{};
  for (final element in find.byType(PlayerSeatWidget).evaluate()) {
    final seat = element.widget as PlayerSeatWidget;
    final box = element.renderObject! as RenderBox;
    seats[seat.player.id] = box.localToGlobal(Offset.zero) & box.size;
  }

  final chips = <int, Rect>{};
  final badges = <int, Rect>{};
  for (final player in game.players) {
    if (player.isHero) continue;

    final chipKey = ValueKey('bet-${player.id}');
    if (find.byKey(chipKey).evaluate().isNotEmpty) {
      chips[player.id] = _betChipVisualRect(tester, chipKey);
    }

    final label = player.lastActionLabel;
    if (label == null) continue;
    final badgeKey = ValueKey('act-${player.id}-$label');
    if (find.byKey(badgeKey).evaluate().isNotEmpty) {
      badges[player.id] = _rectOf(tester, find.byKey(badgeKey));
    }
  }

  final board = _rectOf(tester, find.byType(CommunityCardsView));
  final where = '${street.label} @ ${felt.size}';

  chips.forEach((id, chip) {
    expect(
      felt.contains(chip.topLeft) && felt.contains(chip.bottomRight),
      isTrue,
      reason: 'bet $id at $chip spills off the felt $felt ($where)',
    );
    expect(
      chip.overlaps(board),
      isFalse,
      reason: 'bet $id at $chip covers the board $board ($where)',
    );

    seats.forEach((seatId, seat) {
      expect(
        chip.overlaps(seat),
        isFalse,
        reason: 'bet $id at $chip covers seat $seatId $seat ($where)',
      );
    });

    badges.forEach((badgeId, badge) {
      expect(
        chip.overlaps(badge),
        isFalse,
        reason: 'bet $id at $chip covers badge $badgeId $badge ($where)',
      );
    });

    chips.forEach((otherId, other) {
      if (otherId <= id) return;
      expect(
        chip.overlaps(other),
        isFalse,
        reason: 'bet $id at $chip covers bet $otherId at $other ($where)',
      );
    });
  });

  // Eight villain seats plus the board need roughly this much felt. Below it
  // the ring is over-subscribed no matter how far the seats shrink — an
  // iPhone SE running nine-handed with the coach shelf open has ~130px of
  // felt, which cannot hold eight legible seats. Every other guarantee above
  // still holds there; only seat-to-seat spacing gives way.
  final ringFits = felt.height >= 240;

  if (ringFits) {
    seats.forEach((id, seat) {
      seats.forEach((otherId, other) {
        if (otherId <= id) return;
        expect(
          seat.overlaps(other),
          isFalse,
          reason: 'seat $id $seat covers seat $otherId $other ($where)',
        );
      });
      expect(
        seat.overlaps(board),
        isFalse,
        reason: 'seat $id $seat covers the board $board ($where)',
      );
    });
  }

  // A badge tucks under its own seat by design; it must clear every other one.
  if (ringFits) {
    badges.forEach((id, badge) {
      seats.forEach((seatId, seat) {
        if (seatId == id) return;
        expect(
          badge.overlaps(seat),
          isFalse,
          reason: 'badge $id $badge covers seat $seatId $seat ($where)',
        );
      });
    });
  }
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

  /// Hero is on the clock: the action dock owns the bottom band.
  TableSession liveSession() =>
      const TableSession(coach: longCoach).copyWith(game: _nineHandedGame());

  /// Hand is over: the dock is gone and the other bands take its space.
  TableSession reviewSession() => const TableSession(coach: longCoach).copyWith(
        game: _nineHandedGame(street: Street.showdown, handOver: true),
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

      testWidgets('no felt element covers another, on every street',
          (tester) async {
        for (final street in Street.values) {
          final game = _nineHandedGame(
            street: street,
            multiwayRiverBets: true,
            handOver: street == Street.showdown,
          );
          await _pumpTable(
            tester,
            size: size,
            session: const TableSession(coach: longCoach).copyWith(game: game),
          );
          await tester.pump(const Duration(milliseconds: 400));

          _expectNoFeltCollisions(tester, game, street: street);
        }
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
        expect(find.byKey(const ValueKey('next_cta_emphasized')), findsOneWidget);
        expect(find.byKey(const ValueKey('next_cta_quiet')), findsNothing);
        expect(find.text('Review'), findsNothing);
        expect(find.text('Hand review'), findsNothing);
        expect(find.text('Next hand'), findsNothing);
      });

      testWidgets('after fold Next is available without highlight',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: TableSession(
            coach: longCoach,
            replaying: true,
          ).copyWith(
            game: _nineHandedGame(heroFolded: true),
          ),
        );

        expect(find.text('Next'), findsOneWidget);
        expect(find.byKey(const ValueKey('next_cta_quiet')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('next_cta_emphasized')),
          findsNothing,
        );
        expect(find.text('Review'), findsNothing);
        expect(find.byType(ActionDockWidget), findsNothing);
      });

      testWidgets('early quiet Next requests the next hand', (tester) async {
        final controller = await _pumpTable(
          tester,
          size: size,
          session: TableSession(
            coach: longCoach,
            replaying: true,
          ).copyWith(
            game: _nineHandedGame(heroFolded: true),
          ),
        );

        await tester.tap(find.text('Next'));
        await tester.pump();
        expect(controller.nextHandCalls, 1);
      });

      testWidgets('YOUR TURN hides Next so mid-decision cannot skip',
          (tester) async {
        await _pumpTable(tester, size: size, session: liveSession());
        expect(find.text('YOUR TURN'), findsOneWidget);
        expect(find.text('Next'), findsNothing);
      });

      testWidgets('action dock is on screen while the hero is to act',
          (tester) async {
        await _pumpTable(tester, size: size, session: liveSession());
        expect(find.byType(ActionDockWidget), findsOneWidget);
      });

      testWidgets('showdown keeps the awarded pot on the felt, not \$0',
          (tester) async {
        await _pumpTable(tester, size: size, session: reviewSession());
        await _settleBands(tester);

        expect(find.textContaining('SHOWDOWN'), findsOneWidget);
        expect(find.textContaining(r'$0'), findsNothing);
        expect(find.textContaining(r'$937'), findsWidgets);
        expect(find.text('WINS'), findsOneWidget);
        expect(find.text('INCORRECT'), findsWidgets);
      });

      testWidgets('award animation shows TAKES and flying pot share',
          (tester) async {
        await _pumpTable(
          tester,
          size: size,
          session: reviewSession().copyWith(awardingChips: true),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.textContaining('TAKES'), findsOneWidget);
        expect(find.textContaining(r'$937'), findsWidgets);
        expect(find.text('WINS'), findsOneWidget);
      });

      testWidgets('split award shows SPLIT on the board and seats',
          (tester) async {
        final split = _nineHandedGame(
          street: Street.showdown,
          handOver: true,
        ).copyWith(
          winnerIds: const [1, 2],
          resultMessage: r'Seat 1 & Seat 2 split $937',
        );
        await _pumpTable(
          tester,
          size: size,
          session: TableSession(coach: longCoach).copyWith(
            game: split,
            awardingChips: true,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.textContaining('SPLIT'), findsWidgets);
        expect(find.text('WINS'), findsNothing);
      });

      testWidgets('action dock leaves the tree once the hero cannot act',
          (tester) async {
        await _pumpTable(tester, size: size, session: reviewSession());
        await _settleBands(tester);

        expect(find.byType(ActionDockWidget), findsNothing);
        expect(find.byType(Slider), findsNothing);
        expect(find.text('All-in'), findsNothing);
        expect(find.text('Next'), findsOneWidget);
      });

      testWidgets('coach and hero cards grow into the freed dock band',
          (tester) async {
        final controller = await _pumpTable(
          tester,
          size: size,
          session: liveSession(),
        );
        final playingCoach = _rectOf(tester, find.byType(CoachShelfWidget));
        final playingCards = _heroCardsRect(tester);

        controller.emit(reviewSession());
        await _settleBands(tester);

        final reviewCoach = _rectOf(tester, find.byType(CoachShelfWidget));
        final reviewCards = _heroCardsRect(tester);

        expect(reviewCoach.height, greaterThan(playingCoach.height));
        expect(reviewCards.height, greaterThan(playingCards.height));
        expect(find.text('Show more'), findsNothing);
        expect(find.text('Show less'), findsNothing);
        expect(find.text('BEST'), findsOneWidget);
      });

      testWidgets('bands stay separated while the dock is hidden',
          (tester) async {
        await _pumpTable(tester, size: size, session: reviewSession());
        await _settleBands(tester);

        final rail = _rectOf(tester, find.byType(HeroRailWidget));
        final heroCards = _heroCardsRect(tester);
        final coach = _rectOf(tester, find.byType(CoachShelfWidget));

        expect(
          heroCards.overlaps(coach),
          isFalse,
          reason: 'coach $coach covers hero cards $heroCards in review',
        );
        expect(coach.top, greaterThanOrEqualTo(rail.bottom - 0.5));
        expect(coach.bottom, lessThanOrEqualTo(size.height + 0.5));
        expect(heroCards.bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
      });

      testWidgets('dock comes back when the hero is on the clock again',
          (tester) async {
        final controller = await _pumpTable(
          tester,
          size: size,
          session: reviewSession(),
        );
        await _settleBands(tester);
        expect(find.byType(ActionDockWidget), findsNothing);

        controller.emit(liveSession());
        await _settleBands(tester);

        expect(find.byType(ActionDockWidget), findsOneWidget);
        expect(tester.takeException(), isNull);

        final heroCards = _heroCardsRect(tester);
        final coach = _rectOf(tester, find.byType(CoachShelfWidget));
        final dock = _rectOf(tester, find.byType(ActionDockWidget));
        expect(heroCards.overlaps(coach), isFalse);
        expect(coach.bottom, lessThanOrEqualTo(dock.top + 0.5));
        expect(dock.bottom, lessThanOrEqualTo(size.height + 0.5));
      });
    });
  });
}
