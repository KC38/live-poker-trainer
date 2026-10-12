/// Streets explain/order hide empty board slot outlines (LPT-80).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'streets explain preflop hides empty board slot outlines at mini size',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId(
                'lesson-01-04-01-streets-and-order',
              ),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                child: LessonScreenLayout(
                  progress: 0.2,
                  livesRemaining: 5,
                  livesMax: 5,
                  onClose: () {},
                  speech:
                      'Four streets: preflop, flop, turn, river. Tap each street.',
                  expression: LessonMascotExpression.thinking,
                  stage: LessonStreetsExplainTable(
                    onAllStreetsTapped: () {},
                  ),
                  onUndo: () {},
                  onRedo: () {},
                  onHint: () {},
                  canUndo: false,
                  canRedo: false,
                  canHint: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(lessonStreetsTableFeatures.boardSlots, isFalse);
      expect(find.byType(TableCardSlot), findsNothing);
      expect(find.byType(FeltTableView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'streets explain flop preview hides empty turn/river outlines',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId(
                'lesson-01-04-01-streets-and-order',
              ),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                child: LessonScreenLayout(
                  progress: 0.2,
                  livesRemaining: 5,
                  livesMax: 5,
                  onClose: () {},
                  speech:
                      'Four streets: preflop, flop, turn, river. Tap each street.',
                  expression: LessonMascotExpression.thinking,
                  stage: LessonStreetsExplainTable(
                    onAllStreetsTapped: () {},
                  ),
                  onUndo: () {},
                  onRedo: () {},
                  onHint: () {},
                  canUndo: false,
                  canRedo: false,
                  canHint: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('PREFLOP'));
      await tester.pump();
      await tester.tap(find.text('FLOP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      // Dealt flop cards may be TableCard widgets; empty street slots must not.
      expect(find.byType(TableCardSlot), findsNothing);
      expect(find.byType(FeltTableView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
