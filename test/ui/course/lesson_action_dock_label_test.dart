/// Tests for [compactLessonActionDockLabel] and three-wide mini dock chrome.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

void main() {
  group('compactLessonActionDockLabel', () {
    test('keeps short sizing chrome intact', () {
      expect(compactLessonActionDockLabel('Raise to 6'), 'RAISE TO 6');
      expect(compactLessonActionDockLabel('Jam for stacks'), 'JAM FOR STACKS');
      expect(compactLessonActionDockLabel('Fold'), 'FOLD');
    });

    test('compacts Weak top pair silent call-down before ellipsis', () {
      // Pre-LPT-1011 catalog label (and shortened sibling) must not paint
      // "SILENT CALL-DOWN FORE…" on a three-wide mini dock.
      expect(
        compactLessonActionDockLabel('Silent call-down forever'),
        'SILENT CALL-DOWN',
      );
      expect(
        compactLessonActionDockLabel('Silent call-down'),
        'SILENT CALL-DOWN',
      );
    });

    test('compacts long bluff teaching labels to two content words', () {
      expect(
        compactLessonActionDockLabel('Raise as a bluff candidate'),
        'RAISE BLUFF',
      );
    });

    test('blank, filler-only, and over-wide pairs do not blank the button', () {
      expect(compactLessonActionDockLabel('   '), '');
      expect(
        compactLessonActionDockLabel('for the of a on in as an the to'),
        'FOR THE OF A ON IN AS AN THE TO',
      );
      expect(
        compactLessonActionDockLabel('Antidisestablishment'),
        'ANTIDISESTABLISHMENT',
      );
      expect(
        compactLessonActionDockLabel('Antidisappointment supercalifragilistic'),
        'ANTIDISAPPOINTMENT',
      );
    });
  });

  testWidgets('LessonActionDock shows compacted silent call-down at 375×812', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(375, 812);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LessonActionDock(
                choices: const [
                  CourseChoice(
                    id: 'call-down',
                    label: 'Silent call-down forever',
                    action: 'CALL',
                  ),
                  CourseChoice(
                    id: 'stack',
                    label: 'Jam for stacks',
                    action: 'ALL_IN',
                  ),
                  CourseChoice(
                    id: 'careful',
                    label: 'Fold or keep the pot small',
                    action: 'FOLD',
                  ),
                ],
                selectedId: null,
                enabled: true,
                onSelect: (_) {},
                // Facing a bet — Call teaching chrome must stay on (not CALL
                // (off) open-pot look) so compact labels are what paint.
                facingBet: true,
                pulseChoiceId: 'careful',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SILENT CALL-DOWN'), findsOneWidget);
    expect(find.textContaining('FORE'), findsNothing);
    expect(find.text('JAM FOR STACKS'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
