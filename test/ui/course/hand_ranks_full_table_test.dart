/// Hand ranks teaches multiway showdown seat order on the full poker table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/compare_rank_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
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
          features: TableFeatures.forLessonId('lesson-01-02-01-hand-ranks'),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

Future<void> _tapShowdownInCorrectOrder(WidgetTester tester) async {
  final table = tester.widget<LessonShowdownOrderTable>(
    find.byType(LessonShowdownOrderTable),
  );
  for (final id in table.spot.correctOrder) {
    final seat = table.spot.seatIds.indexOf(id);
    final key = seat == 0
        ? const ValueKey<String>('lesson-seat-hero')
        : ValueKey<String>('lesson-seat-$seat');
    await tester.tap(find.byKey(key));
    await tester.pump();
  }
}

void main() {
  testWidgets('explain showdown taps seats weak to strong on the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-01-explain-ladder',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Pair beats high card.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Pair beats high card. Flush beats straight.',
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

    expect(find.byType(LessonShowdownOrderExplainTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(HandRankLadderDemo), findsNothing);
    expect(find.byType(LessonHandLadderExplainTable), findsNothing);

    await _tapShowdownInCorrectOrder(tester);
    expect(ack, 1);
  });

  testWidgets('guided showdown orders seats on the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-02-01-guided-ladder',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.compareRank,
      estimatedSeconds: 50,
      accessibilityText: 'Showdown — tap You, Sam, then Jo.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap weakest to strongest.',
      sequenceItems: const [
        CourseChoice(id: 'you', label: 'You'),
        CourseChoice(id: 'sam', label: 'Sam'),
        CourseChoice(id: 'jo', label: 'Jo'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.pumpWidget(
      _frame(
        CompareRankActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LessonShowdownOrderTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byKey(const ValueKey('hand-order-felt')), findsNothing);

    await _tapShowdownInCorrectOrder(tester);
    expect(controller.draft.orderedIds, ['you', 'sam', 'jo']);
    expect(autoSubmits, 1);
  });

  testWidgets(
    'unguided compare SoftPulse rejects a wrong seat (LPT-707)',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-01-02-01-unguided-compare',
        order: 4,
        stage: ActivityStage.scaffolded,
        renderer: ActivityRenderer.compareRank,
        estimatedSeconds: 40,
        accessibilityText: 'Showdown — tap highest to lowest.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap highest to lowest.',
        sequenceItems: const [
          CourseChoice(id: 'you', label: 'You'),
          CourseChoice(id: 'sam', label: 'Sam'),
          CourseChoice(id: 'jo', label: 'Jo'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);
      final misses = <String>[];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildPokerTheme().copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            home: Scaffold(
              body: TableFeaturesScope(
                features: TableFeatures.forLessonId(
                  'lesson-01-02-01-hand-ranks',
                ),
                child: LessonFrameScope(
                  onLocalMiss: misses.add,
                  child: CompareRankActivity(
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

      final table = tester.widget<LessonShowdownOrderTable>(
        find.byType(LessonShowdownOrderTable),
      );
      expect(table.strictOrder, isTrue);
      final nextId = table.spot.correctOrder.first;
      final wrongId = table.spot.correctOrder.firstWhere((id) => id != nextId);
      final wrongSeat = table.spot.seatIds.indexOf(wrongId);
      final wrongKey = wrongSeat == 0
          ? const ValueKey<String>('lesson-seat-hero')
          : ValueKey<String>('lesson-seat-$wrongSeat');

      await tester.tap(find.byKey(wrongKey));
      await tester.pump();

      expect(controller.draft.orderedIds, isEmpty);
      expect(misses, isNotEmpty);
      expect(
        misses.first,
        contains('SoftPulse marks'),
      );
    },
  );

  testWidgets(
    'jump ranks SoftPulse-off miss copy does not mention SoftPulse (LPT-1028)',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-01-06-02-jump-ranks',
        order: 1,
        stage: ActivityStage.scaffolded,
        assessmentRole: AssessmentRole.jumpTest,
        renderer: ActivityRenderer.compareRank,
        estimatedSeconds: 40,
        accessibilityText:
            'Jump test: tap showdown seats strongest to weakest.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap the hands from strongest to weakest.',
        sequenceItems: const [
          CourseChoice(id: 'you', label: 'You'),
          CourseChoice(id: 'sam', label: 'Sam'),
          CourseChoice(id: 'jo', label: 'Jo'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);
      final misses = <String>[];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildPokerTheme().copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            home: Scaffold(
              body: TableFeaturesScope(
                features: TableFeatures.forLessonId(
                  'lesson-01-06-02-section-one-jump',
                ),
                child: LessonFrameScope(
                  onLocalMiss: misses.add,
                  child: CompareRankActivity(
                    activity: activity,
                    controller: controller,
                    showGuidance: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final table = tester.widget<LessonShowdownOrderTable>(
        find.byType(LessonShowdownOrderTable),
      );
      expect(table.strictOrder, isTrue);
      expect(table.showGuidance, isFalse);
      final nextId = table.spot.correctOrder.first;
      final wrongId = table.spot.correctOrder.firstWhere((id) => id != nextId);
      final wrongSeat = table.spot.seatIds.indexOf(wrongId);
      final wrongKey = wrongSeat == 0
          ? const ValueKey<String>('lesson-seat-hero')
          : ValueKey<String>('lesson-seat-$wrongSeat');

      await tester.tap(find.byKey(wrongKey));
      await tester.pump();

      expect(controller.draft.orderedIds, isEmpty);
      expect(misses, isNotEmpty);
      expect(misses.first, isNot(contains('SoftPulse')));
      expect(misses.first, contains('strongest to weakest'));
    },
  );
}
