/// Every lesson step says what to tap, and the table cue bounces on it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/cue_arrows.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

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

  testWidgets('framed find-holes shows CueArrows on face-up hero holes', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-guided-find-holes',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap your hole cards',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [
        CourseChoice(id: 'choice-hero-holes', label: 'Ah Kd in front of you'),
        CourseChoice(id: 'choice-board', label: 'The flop cards in the middle'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFrameScope(
            onLocalMiss: (_) {},
            child: SizedBox(
              height: 520,
              child: SelectIdentifyActivity(
                activity: activity,
                controller: controller,
                showGuidance: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('lesson-table-stage')),
      findsOneWidget,
    );
    // One arrow above each face-up hole card (not a centered pair).
    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsNWidgets(2));
    expect(find.byKey(const ValueKey<String>('hero-cue-arrow-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('hero-cue-arrow-1')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNWidgets(2));
    expect(find.byKey(const ValueKey<String>('cue-pulse')), findsWidgets);
    controller.dispose();
  });

  testWidgets('hint restores CueArrows on quieter hole-card frame steps', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-scaffolded-private',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap your private cards',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'h',
          kind: 'hint',
          text: 'Your two cards sit at your seat — not the board.',
        ),
      ],
      choices: const [
        CourseChoice(id: 'choice-only-you', label: 'Only you'),
        CourseChoice(id: 'choice-everyone', label: 'Everyone'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFrameScope(
            onLocalMiss: (_) {},
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return SizedBox(
                  height: 520,
                  child: SelectIdentifyActivity(
                    activity: activity,
                    controller: controller,
                    showGuidance: controller.showTargetCue,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // Scaffolded scene clears highlight — no arrows until Hint.
    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsNothing);

    controller.revealHint();
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('felt-cue-arrows')), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNWidgets(2));
    expect(find.byType(CuePulse), findsWidgets);
    controller.dispose();
  });

  testWidgets('scaffolded blinds posts BB chips only after a correct tap', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-03-scaffolded-blinds',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat that posts the big blind.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blinds are 1/2. Tap who posts the big blind.',
      choices: const [
        CourseChoice(id: 'bb-two', label: 'The seat two left of the button'),
        CourseChoice(id: 'sb-one', label: 'The seat immediately left'),
        CourseChoice(id: 'btn-posts', label: 'The button posts both'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(
              'lesson-01-01-03-blinds-and-button',
            ),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              child: SizedBox(
                height: 560,
                child: SelectIdentifyActivity(
                  activity: activity,
                  controller: controller,
                  showGuidance: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey<String>('lesson-table-stage')),
      findsOneWidget,
    );
    // SB is already out; BB chip and puck wait for the correct tap.
    expect(find.text(r'$1'), findsOneWidget);
    expect(find.text(r'$2'), findsNothing);
    expect(find.byKey(const ValueKey<String>('puck-BB')), findsNothing);
    expect(find.byKey(const ValueKey<String>('puck-SB')), findsOneWidget);
    expect(find.textContaining(r'POT $1'), findsOneWidget);

    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsBigBlindIndex')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(controller.draft.choiceId, 'bb-two');
    expect(find.text(r'$2'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('puck-BB')), findsOneWidget);
    expect(find.textContaining(r'POT $3'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
