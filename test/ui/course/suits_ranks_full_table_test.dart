/// Suits and ranks teaches on the full poker table, not suit/rank tiles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

Widget _frame(Widget child, {void Function(String)? onMiss}) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildPokerTheme().copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId(
            'lesson-01-01-02-suits-and-ranks',
          ),
          child: LessonFrameScope(
            onLocalMiss: onMiss ?? (_) {},
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('explain suits taps one board card per suit on the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-01-02-explain-suits',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Four suits, thirteen ranks. Ace is high here.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Four suits, thirteen ranks. Ace is high here.',
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

    expect(find.byType(LessonSuitBoardTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(SuitTapTile), findsNothing);
    expect(find.byKey(const ValueKey('suits-ranks-felt')), findsNothing);
    expect(find.text('★'), findsNothing);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(ValueKey('lesson-board-card-$i')));
      await tester.pump();
    }
    expect(ack, 1);
  });

  testWidgets('guided suits auto-submits after four board suit taps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-01-02-guided-suits',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap hearts, diamonds, clubs, and spades on the board.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap one community card of each suit.',
      choices: const [
        CourseChoice(
          id: 'suits-full',
          label: 'Hearts, diamonds, clubs, spades',
        ),
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
    expect(find.byType(LessonSuitBoardTable), findsOneWidget);
    expect(find.byType(SuitTapPicker), findsNothing);
    expect(find.text('★'), findsOneWidget);

    // Board is Ah, Kd, 5★, 7c, 2s — skip the star at index 2.
    for (final i in [0, 1, 3]) {
      await tester.tap(find.byKey(ValueKey('lesson-board-card-$i')));
      await tester.pump();
    }
    expect(autoSubmits, 0);

    await tester.tap(find.byKey(const ValueKey('lesson-board-card-4')));
    await tester.pump();
    expect(controller.draft.choiceId, 'suits-full');
    expect(autoSubmits, 1);
  });

  testWidgets('guided suits star distractor is a miss', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-01-02-guided-suits',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap hearts, diamonds, clubs, and spades on the board.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap one community card of each suit.',
      choices: const [
        CourseChoice(
          id: 'suits-full',
          label: 'Hearts, diamonds, clubs, spades',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    final misses = <String>[];

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
        onMiss: misses.add,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('lesson-board-card-2')));
    await tester.pump();
    expect(misses, isNotEmpty);
    expect(controller.draft.choiceId, isNull);
  });

  testWidgets('rank order taps board cards low to high on the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-01-02-scaffolded-ranks',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 50,
      accessibilityText: 'Tap deuce, ten, and ace on the board.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap these ranks from lowest to highest.',
      sequenceItems: const [
        CourseChoice(id: 'rank-2', label: '2'),
        CourseChoice(id: 'rank-T', label: 'T'),
        CourseChoice(id: 'rank-A', label: 'A'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.pumpWidget(
      _frame(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LessonRankOrderTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.text('H'), findsOneWidget);

    final board = lessonRankOrderBoardCodes(
      activityId: activity.id,
      rankLabels: const ['2', 'T', 'A'],
      distractorCode: lessonRankOrderDistractorCode,
    );
    expect(board.length, 4);
    expect(board.contains(lessonRankOrderDistractorCode), isTrue);
    for (final rank in ['2', 'T', 'A']) {
      final index = board.indexWhere((code) => code.startsWith(rank));
      await tester.tap(find.byKey(ValueKey('lesson-board-card-$index')));
      await tester.pump();
    }
    expect(controller.draft.orderedIds, ['rank-2', 'rank-T', 'rank-A']);
    expect(autoSubmits, 1);
  });

  testWidgets('rank order H of spades distractor is a miss', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-01-02-scaffolded-ranks',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 50,
      accessibilityText: 'Tap deuce, ten, and ace on the board.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap these ranks from lowest to highest.',
      sequenceItems: const [
        CourseChoice(id: 'rank-2', label: '2'),
        CourseChoice(id: 'rank-T', label: 'T'),
        CourseChoice(id: 'rank-A', label: 'A'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    final misses = <String>[];

    await tester.pumpWidget(
      _frame(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
        onMiss: misses.add,
      ),
    );
    await tester.pump();

    final board = lessonRankOrderBoardCodes(
      activityId: activity.id,
      rankLabels: const ['2', 'T', 'A'],
      distractorCode: lessonRankOrderDistractorCode,
    );
    final distractorIndex = board.indexOf(lessonRankOrderDistractorCode);
    await tester.tap(
      find.byKey(ValueKey('lesson-board-card-$distractorIndex')),
    );
    await tester.pump();
    expect(misses, isNotEmpty);
    expect(controller.draft.orderedIds, isEmpty);
  });

  testWidgets('suited hole cards are tapped on a face-up seat', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-01-02-unguided-suited',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat whose hole cards share a suit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the suited hole cards.',
      choices: const [
        CourseChoice(id: 'suited-ah-kh', label: 'Ah Kh'),
        CourseChoice(id: 'offsuit-ah-kd', label: 'Ac Kd'),
        CourseChoice(id: 'pair-77', label: '7c 7d'),
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
          showGuidance: false,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LessonHoleHandTable), findsOneWidget);
    expect(find.byKey(const ValueKey('hole-card-bands')), findsNothing);

    await tester.tap(find.text('You'));
    await tester.pump();
    expect(controller.draft.choiceId, 'suited-ah-kh');
    expect(autoSubmits, 1);
  });

  test('rank board shuffle is stable and not authored ascending', () {
    final board = lessonRankOrderBoardCodes(
      activityId: 'act-01-01-02-scaffolded-ranks',
      rankLabels: const ['2', 'T', 'A'],
      distractorCode: lessonRankOrderDistractorCode,
    );
    expect(board.length, 4);
    expect(board.contains(lessonRankOrderDistractorCode), isTrue);
    final real = [
      for (final code in board)
        if (code != lessonRankOrderDistractorCode) code[0],
    ];
    expect(real, isNot(['2', 'T', 'A']));
    expect(
      lessonRankOrderBoardCodes(
        activityId: 'act-01-01-02-scaffolded-ranks',
        rankLabels: const ['2', 'T', 'A'],
        distractorCode: lessonRankOrderDistractorCode,
      ),
      board,
    );
  });
}
