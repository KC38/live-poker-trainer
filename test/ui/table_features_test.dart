/// Table layers: the lesson switch-on schedule, named opponent types,
/// per-step overrides, and dynamic blinds.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

Widget _frame(Widget child, {TableFeatures? scope}) {
  final table = SizedBox(width: 375, height: 560, child: child);
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child:
            scope == null
                ? table
                : TableFeaturesScope(features: scope, child: table),
      ),
    ),
  );
}

void main() {
  group('switch-on schedule', () {
    TableFeatures at(String id) => TableFeatures.forLessonId(id);

    test('the first lessons show only cards, seats, and the board', () {
      for (final id in [
        'lesson-01-01-01-your-two-cards',
        'lesson-01-01-02-suits-and-ranks',
      ]) {
        final f = at(id);
        expect(f.opponentCards && f.boardSlots, isTrue, reason: id);
        expect(
          [
            f.pot,
            f.blinds,
            f.positions,
            f.bets,
            f.actions,
            f.stacks,
            f.street,
            f.playerTypes,
            f.stats,
          ],
          everyElement(isFalse),
          reason: id,
        );
      }
    });

    test('Button and blinds turns on pucks, blinds, chips, and the pot', () {
      final f = at('lesson-01-01-03-blinds-and-button');
      expect(f.positions && f.blinds && f.bets && f.pot, isTrue);
      expect(f.actions || f.stacks || f.street, isFalse);
    });

    test('actions, stacks, and the street each start at their lesson', () {
      expect(at('lesson-01-02-02-best-five-kickers').actions, isFalse);
      expect(at('lesson-01-03-01-fold-check-call').actions, isTrue);
      expect(at('lesson-01-03-01-fold-check-call').stacks, isFalse);
      expect(at('lesson-01-03-02-bet-raise-allin').stacks, isTrue);
      expect(at('lesson-01-03-02-bet-raise-allin').street, isFalse);
      expect(at('lesson-01-04-01-streets-and-order').street, isTrue);
    });

    test('player types and stats start at Observe sticky callers', () {
      final before = at('lesson-04-05-01-spr-commitment');
      final from = at('lesson-04-06-01-observe-sticky-caller');
      expect(before.playerTypes || before.stats, isFalse);
      expect(before, TableFeatures.full.copyWith(playerTypes: false, stats: false));
      expect(from, TableFeatures.full);
      expect(at('lesson-07-12-01-five-type-final'), TableFeatures.full);
    });

    test('a layer stays on once it is taught', () {
      expect(at('lesson-02-01-01').stacks, isTrue);
      expect(at('lesson-03-08-02-section-three-jump-test').pot, isTrue);
    });

    test('short ids parse; other ids get every layer', () {
      expect(at('lesson-01-01-01'), at('lesson-01-01-01-your-two-cards'));
      expect(at('warmup'), TableFeatures.full);
      expect(at('lesson-x'), TableFeatures.full);
      expect(
        parseLessonPosition('lesson-04-06-02-meet-calling-station'),
        (section: 4, unit: 6, lesson: 2),
      );
    });

    test('copyWith changes only the named layers', () {
      final f = TableFeatures.full.copyWith(blinds: false, bets: false);
      expect(f.blinds, isFalse);
      expect(f.bets, isFalse);
      expect(f.copyWith(blinds: true, bets: true), TableFeatures.full);
    });
  });

  group('named opponent type', () {
    test('reads the table label, then the prompt', () {
      expect(
        lessonNamedVillainType(['Nit in BB · folds often', null]),
        PlayerArchetype.nit,
      );
      expect(
        lessonNamedVillainType([null, 'River second pair. Versus Calling Station.']),
        PlayerArchetype.callingStation,
      );
      expect(
        lessonNamedVillainType(['Sticky caller · checked to you']),
        PlayerArchetype.callingStation,
      );
      expect(
        lessonNamedVillainType(['Calling station · checked']),
        PlayerArchetype.callingStation,
      );
      expect(
        lessonNamedVillainType(['Maniac barrels river']),
        PlayerArchetype.maniac,
      );
      expect(lessonNamedVillainType(['TAG check-raises']), PlayerArchetype.tag);
      expect(lessonNamedVillainType(['LAG barrels turn']), PlayerArchetype.lag);
    });

    test('unknown or unnamed opponents stay plain', () {
      expect(lessonNamedVillainType(['Unknown · no maniac samples']), isNull);
      expect(
        lessonNamedVillainType(['Unknown BB · no samples', 'Nit in BB']),
        isNull,
      );
      expect(lessonNamedVillainType(['Checked to you', 'Pot 30.']), isNull);
      expect(lessonNamedVillainType(['CO opens to 6', 'Unit test stage']), isNull);
    });
  });

  group('lesson stage', () {
    testWidgets('an early lesson draws plain seats', (tester) async {
      await tester.pumpWidget(
        _frame(
          const LessonTableStage(villainArchetypes: [PlayerArchetype.nit]),
          scope: TableFeatures.forLessonId('lesson-01-01-03'),
        ),
      );
      expect(find.text('NIT'), findsNothing);
      expect(find.text('13/10'), findsNothing);
      expect(find.text(r'Blinds $1/$2 NLH'), findsOneWidget);
    });

    testWidgets('a later lesson shows the types it names, and only those', (
      tester,
    ) async {
      await tester.pumpWidget(
        _frame(const LessonTableStage(), scope: TableFeatures.full),
      );
      expect(find.text('TAG'), findsNothing, reason: 'no fake types');

      await tester.pumpWidget(
        _frame(
          const LessonTableStage(
            villainCount: 2,
            villainArchetypes: [
              PlayerArchetype.nit,
              PlayerArchetype.callingStation,
            ],
          ),
          scope: TableFeatures.full,
        ),
      );
      expect(find.text('NIT'), findsOneWidget);
      expect(find.text('STATION'), findsOneWidget);
    });

    testWidgets('a step sets its own stakes and posts them', (tester) async {
      await tester.pumpWidget(
        _frame(const LessonTableStage(smallBlind: 0.5, bigBlind: 1)),
      );
      expect(find.text(r'Blinds $0.50/$1 NLH'), findsOneWidget);
      expect(find.byKey(const ValueKey('bet-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('bet-2')), findsOneWidget);
      expect(find.textContaining(r'POT $1.50'), findsOneWidget);
    });

    testWidgets('a step override hides layers the section would show', (
      tester,
    ) async {
      await tester.pumpWidget(
        _frame(
          const LessonTableStage(
            features: TableFeatures(
              pot: false,
              blinds: false,
              positions: false,
              bets: false,
              stacks: false,
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('felt-pot')), findsNothing);
      expect(find.byKey(const ValueKey('felt-blinds')), findsNothing);
      expect(find.byKey(const ValueKey('puck-D')), findsNothing);
      expect(find.byKey(const ValueKey('bet-1')), findsNothing);
      expect(find.text(r'$200'), findsNothing);
      expect(find.byKey(const ValueKey('felt-board-row')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the felt reads the nearest scope when no features are passed', (
    tester,
  ) async {
    final game = lessonTableStageGame(
      villainArchetypes: const [PlayerArchetype.maniac],
    );
    await tester.pumpWidget(
      _frame(
        FeltTableView(game: game, chipDisplayMode: ChipDisplayMode.dollars),
        scope: const TableFeatures(opponentCards: false),
      ),
    );
    expect(find.text('MANIAC'), findsWidgets);
    expect(find.byKey(const ValueKey('seat-backs-1')), findsNothing);

    await tester.pumpWidget(
      _frame(
        FeltTableView(game: game, chipDisplayMode: ChipDisplayMode.dollars),
      ),
    );
    expect(find.byKey(const ValueKey('seat-backs-1')), findsOneWidget);
  });
}
