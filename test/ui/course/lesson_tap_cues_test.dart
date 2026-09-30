/// Every lesson step says what to tap, and the table cue bounces on it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

CourseCatalog _catalog() {
  final raw = File('assets/course/v2/catalog.json').readAsStringSync();
  return CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(390, 560));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(theme: buildPokerTheme(), home: Scaffold(body: child)),
  );
  await tester.pump();
}

double _arrowDy(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byKey(const ValueKey<String>('felt-cue-arrows')),
          matching: find.byType(Transform),
        )
        .first,
  );
  return transform.transform.storage[13];
}

void main() {
  test('every step and hand street tells the learner what to tap', () {
    final missing = <String>[];
    for (final section in _catalog().sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            final streets =
                activity.handSteps.isEmpty ? 1 : activity.handSteps.length;
            for (var i = 0; i < streets; i++) {
              final speech = lessonFrameSpeech(activity, handStepIndex: i);
              if (!RegExp(r'\btap\b', caseSensitive: false).hasMatch(speech)) {
                missing.add('${activity.id}#$i: $speech');
              }
            }
          }
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('suits and ranks explain asks for one board card per suit', () {
    final activity = _catalog().sections
        .expand((s) => s.units)
        .expand((u) => u.lessons)
        .expand((l) => l.activities)
        .firstWhere((a) => a.id == 'act-01-01-02-explain-suits');
    expect(
      lessonFrameSpeech(activity),
      'Four suits, thirteen ranks. Ace is high here. '
      'Tap one board card of each suit.',
    );
  });

  test('scene-only copy gains the step instruction', () {
    const dock = 'Tap your action below the table.';
    expect(
      withLessonTapInstruction('UTG with QQ at 1/2. Action?', dock),
      'UTG with QQ at 1/2. Tap your action below the table.',
    );
    expect(
      withLessonTapInstruction('Button with A9s. Folds to you.', dock),
      'Button with A9s. Folds to you. Tap your action below the table.',
    );
    expect(
      withLessonTapInstruction('A bet is out — pick how you continue.', dock),
      'A bet is out — tap how you continue.',
    );
    expect(
      withLessonTapInstruction('Name the family for your holes.', dock),
      'Tap the family for your holes.',
    );
    expect(
      withLessonTapInstruction('Tap the pocket pair.', dock),
      'Tap the pocket pair.',
    );
    expect(withLessonTapInstruction('Four suits.', ''), 'Four suits.');
  });

  testWidgets('next suit card bounces an arrow and pulses', (tester) async {
    await _pump(tester, LessonSuitBoardTable(onAllSuitsSelected: () {}));

    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('cue-pulse')), findsOneWidget);
    final start = _arrowDy(tester);
    await tester.pump(const Duration(milliseconds: 450));
    expect(_arrowDy(tester), isNot(closeTo(start, 0.5)));

    await tester.tap(find.byKey(const ValueKey<String>('lesson-board-card-0')));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('cue-pulse')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blinds clockwise arrow walks button, small, then big blind', (
    tester,
  ) async {
    await _pump(tester, LessonBlindsClockwiseTable(onComplete: () {}));

    Finder cue(int seat) => find.byKey(ValueKey<String>('seat-cue-$seat'));
    expect(cue(lessonBlindsButtonIndex), findsOneWidget);
    expect(cue(lessonBlindsSmallBlindIndex), findsNothing);

    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsButtonIndex')),
    );
    await tester.pump();
    expect(cue(lessonBlindsButtonIndex), findsNothing);
    expect(cue(lessonBlindsSmallBlindIndex), findsOneWidget);

    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsSmallBlindIndex')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsBigBlindIndex')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
