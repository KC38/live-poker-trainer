/// Button and blinds explain hides empty board slot outlines (LPT-50).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'blinds explain hides empty board slot outlines at mini size',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final blinds = TableFeatures.forLessonId(
        'lesson-01-01-03-blinds-and-button',
      );
      expect(blinds.boardSlots, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: blinds,
              child: LessonBlindsClockwiseTable(onComplete: () {}),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(TableCardSlot), findsNothing);
      expect(find.byType(FeltTableView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
