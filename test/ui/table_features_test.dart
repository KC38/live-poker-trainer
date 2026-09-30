/// Table layers: section presets, per-step overrides, and dynamic blinds.
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
  group('presets', () {
    test('sections 1 to 3 leave out player types and stats', () {
      for (final section in [1, 2, 3]) {
        final f = TableFeatures.forSection(section);
        expect(f.playerTypes, isFalse, reason: 'section $section');
        expect(f.stats, isFalse, reason: 'section $section');
        expect(f.stacks && f.pot && f.blinds && f.positions, isTrue);
        expect(f.bets && f.actions && f.opponentCards, isTrue);
      }
    });

    test('section 4 on draws every layer', () {
      for (final section in [4, 5, 6, 7]) {
        expect(TableFeatures.forSection(section), TableFeatures.full);
      }
    });

    test('a lesson id picks its section preset', () {
      expect(
        TableFeatures.forLessonId('lesson-01-01-01-your-two-cards'),
        TableFeatures.fundamentals,
      );
      expect(
        TableFeatures.forLessonId('lesson-03-08-01'),
        TableFeatures.fundamentals,
      );
      expect(
        TableFeatures.forLessonId('lesson-04-06-02-meet-calling-station'),
        TableFeatures.full,
      );
      expect(TableFeatures.forLessonId('warmup'), TableFeatures.full);
    });

    test('copyWith changes only the named layers', () {
      final f = TableFeatures.full.copyWith(blinds: false, bets: false);
      expect(f.blinds, isFalse);
      expect(f.bets, isFalse);
      expect(f.copyWith(blinds: true, bets: true), TableFeatures.full);
    });
  });

  group('lesson stage', () {
    testWidgets('an early lesson draws plain seats', (tester) async {
      await tester.pumpWidget(
        _frame(
          const LessonTableStage(villainArchetypes: [PlayerArchetype.nit]),
          scope: TableFeatures.forSection(1),
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
        _frame(const LessonTableStage(), scope: TableFeatures.forSection(4)),
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
          scope: TableFeatures.forSection(4),
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
