/// Best five teaches on the full poker table, not a mini felt picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

Widget _frame(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildPokerTheme().copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId(
            'lesson-01-02-02-best-five-kickers',
          ),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    debugFreezeLessonSuitRemap = true;
    lessonDealAttemptSalt = '';
  });
  tearDown(() {
    debugFreezeLessonSuitRemap = false;
    lessonDealAttemptSalt = '';
    debugLessonCardDealRandom = null;
  });

  testWidgets('explain taps playing cards on the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-explain-five',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Only five of seven cards play.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'You use five cards. Two are leftovers.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var ack = 0;
    await tester.pumpWidget(
      _frame(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => ack += 1,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonBestFiveExplainTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(BestFiveDemo), findsNothing);
    expect(find.byKey(const ValueKey('best-five-table')), findsOneWidget);

    for (final code in const ['Ah', 'Kd', 'As', '7c', '9h']) {
      final heroIdx = BestFiveDemo.hero.indexOf(code);
      if (heroIdx >= 0) {
        await tester.tap(find.byKey(ValueKey<String>('lesson-hero-card-$heroIdx')));
      } else {
        final boardIdx = BestFiveDemo.board.indexOf(code);
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-board-card-$boardIdx')),
        );
      }
      await tester.pump();
    }
    expect(ack, 1);
  });

  testWidgets('explain does not dim leftovers before playing cards are tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-explain-five',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Only five of seven cards play.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'You use five cards. Two are leftovers.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _frame(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () {},
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byWidgetPredicate((w) => w is TableCard && w.dimmed),
      findsNothing,
    );

    for (final code in const ['Ah', 'Kd', 'As', '7c', '9h']) {
      final heroIdx = BestFiveDemo.hero.indexOf(code);
      if (heroIdx >= 0) {
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-hero-card-$heroIdx')),
        );
      } else {
        final boardIdx = BestFiveDemo.board.indexOf(code);
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-board-card-$boardIdx')),
        );
      }
      await tester.pump();
    }

    expect(
      find.byWidgetPredicate((w) => w is TableCard && w.dimmed),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('explain SoftPulse is one next card, not both holes or You', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-explain-five',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Only five of seven cards play.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'You use five cards. Two are leftovers.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _frame(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () {},
        ),
      ),
    );
    await tester.pump();

    // One gold SoftPulse on playOrder next (Ah) — never both holes or You.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);

    final ah = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-0')),
    );
    final kd = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-1')),
    );
    final you = tester.getCenter(
      find.byKey(const ValueKey<String>('seat-box-0')),
    );
    final glow = tester.getCenter(
      find.byKey(const ValueKey<String>('glow-highlight')),
    );
    expect(glow.dx, closeTo(ah.dx, 8));
    expect(glow.dy, lessThan(you.dy - 8));
    expect((glow.dx - kd.dx).abs(), greaterThan(8));

    await tester.tap(find.byKey(const ValueKey<String>('lesson-hero-card-0')));
    await tester.pump();

    // Ah keeps a cyan selected ring; gold SoftPulse advances to Kd.
    expect(
      find.byKey(const ValueKey<String>('selection-highlight')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey<String>('selection-highlight'))).dx,
      closeTo(ah.dx, 8),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey<String>('glow-highlight'))).dx,
      closeTo(kd.dx, 8),
    );
  });

  testWidgets('guided picker SoftPulse rings one recommended card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Aces with king'),
        CourseChoice(id: 'weak-kickers', label: 'Aces with nine'),
        CourseChoice(id: 'ignore-ace', label: 'King high'),
      ],
      coachMedia: const [
        CoachMediaRef(
          id: 'h',
          kind: 'hint',
          text: 'Use your pair plus the strongest kickers.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    controller.releaseFeltDealIfUntracked();

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Recommended set starts Ah (hero 0) — one gold SoftPulse, not You.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    final ah = tester.getCenter(
      find.byKey(const ValueKey<String>('lesson-hero-card-0')),
    );
    final you = tester.getCenter(
      find.byKey(const ValueKey<String>('seat-box-0')),
    );
    final glow = tester.getCenter(
      find.byKey(const ValueKey<String>('glow-highlight')),
    );
    expect(glow.dx, closeTo(ah.dx, 8));
    expect(glow.dy, lessThan(you.dy - 8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('guided picker selects five on the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Aces with king'),
        CourseChoice(id: 'weak-kickers', label: 'Aces with nine'),
        CourseChoice(id: 'ignore-ace', label: 'King high'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonBestFivePickerTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(BestFiveCardPicker), findsNothing);
    expect(find.text('0/5 selected'), findsOneWidget);

    final spot = resolveBestFiveSpot(activity)!;
    for (final code in ['Ah', 'As', 'Kd', '9h', '7c']) {
      final heroIdx = spot.heroCodes.indexOf(code);
      if (heroIdx >= 0) {
        await tester.tap(find.byKey(ValueKey<String>('lesson-hero-card-$heroIdx')));
      } else {
        final boardIdx = spot.boardCodes.indexOf(code);
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-board-card-$boardIdx')),
        );
      }
      await tester.pump();
    }
    expect(controller.draft.choiceId, 'best-pair-k');
    expect(autoSubmits, 1);
  });

  testWidgets('invalid five enables Undo and clears local picks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Aces with king'),
        CourseChoice(id: 'weak-kickers', label: 'Aces with nine'),
        CourseChoice(id: 'ignore-ace', label: 'King high'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    final spot = resolveBestFiveSpot(activity)!;
    // Five cards that are not a catalog choice set.
    for (final code in ['Ah', '9h', '7c', '3s', '2d']) {
      final heroIdx = spot.heroCodes.indexOf(code);
      if (heroIdx >= 0) {
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-hero-card-$heroIdx')),
        );
      } else {
        final boardIdx = spot.boardCodes.indexOf(code);
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-board-card-$boardIdx')),
        );
      }
      await tester.pump();
    }

    expect(find.text('Five tapped — try a stronger five.'), findsOneWidget);
    expect(controller.draft.choiceId, isNull);
    expect(controller.draft.orderedIds, hasLength(5));
    expect(controller.canUndo, isTrue);

    controller.undoDraft();
    await tester.pump();

    expect(controller.draft.orderedIds, isEmpty);
    expect(controller.canUndo, isFalse);
    expect(find.text('0/5 selected'), findsOneWidget);
    expect(find.text('Five tapped — try a stronger five.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missed picker keeps cyan picks without multi SoftPulse', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Aces with king'),
        CourseChoice(id: 'weak-kickers', label: 'Aces with nine'),
        CourseChoice(id: 'ignore-ace', label: 'King high'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    final spot = resolveBestFiveSpot(activity)!;
    for (final code in ['Ah', 'As', '9h', '7c', '3s']) {
      final heroIdx = spot.heroCodes.indexOf(code);
      if (heroIdx >= 0) {
        await tester.tap(find.byKey(ValueKey<String>('lesson-hero-card-$heroIdx')));
      } else {
        final boardIdx = spot.boardCodes.indexOf(code);
        await tester.tap(
          find.byKey(ValueKey<String>('lesson-board-card-$boardIdx')),
        );
      }
      await tester.pump();
    }

    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.clearMistake,
        feedback: 'King plays over the leftover three.',
        accepted: false,
        lifeLost: true,
        livesRemaining: 2,
        xpAwarded: 0,
        remediationRequired: false,
        resume: CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-02-02-best-five-kickers',
          activityId: activity.id,
          activityIndex: 0,
        ),
        duplicate: false,
        betterChoiceId: 'best-pair-k',
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('selection-highlight')),
      findsNWidgets(5),
    );
    // Post-grade answer reveal must not SoftPulse all five correct cards
    // (LPT-61). Cyan selection is enough; leftovers dim on the table.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
