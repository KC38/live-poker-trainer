/// Six-max vs heads-up seating for action teaching spots.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_felt_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  group('resolveLessonActionFeltLayout', () {
    test('folds to you on the button shows six-max with early folds', () {
      const spot = LessonActionSpot(
        heroCodes: ['Qh', '8h'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button · 1/2',
        openPot: true,
      );

      final layout = resolveLessonActionFeltLayout(spot);

      expect(layout.headsUp, isFalse);
      expect(layout.villainCount, lessonBlindsVillainCount);
      expect(layout.seatCount, 6);
      expect(layout.dealerIndex, 0);
      expect(layout.foldedSeatIndexes.toSet(), {3, 4, 5});
    });

    test('UTG first-in keeps six-max with no early folds', () {
      const spot = LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · UTG · 1/2',
        openPot: true,
      );

      final layout = resolveLessonActionFeltLayout(spot);

      expect(layout.dealerIndex, 3);
      expect(layout.foldedSeatIndexes, isEmpty);
    });

    test('facing UTG open in the BB folds the middle seats', () {
      const spot = LessonActionSpot(
        heroCodes: ['Jh', '3d'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'UTG opens to 6',
        streetLabel: 'Preflop · Big blind · 1/2',
        facingBet: true,
      );

      final layout = resolveLessonActionFeltLayout(spot);

      expect(layout.dealerIndex, 4);
      expect(layout.villainSeatIndex, 1);
      expect(layout.foldedSeatIndexes.toSet(), {2, 3, 4, 5});
      expect(layout.seatActionLabels[1], 'RAISE');
    });

    test('explicit heads-up spots stay two-seat', () {
      const spot = LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 10',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · Heads-up',
        openPot: true,
      );

      final layout = resolveLessonActionFeltLayout(spot);

      expect(layout.headsUp, isTrue);
      expect(layout.villainCount, 1);
      expect(layout.seatCount, 2);
      expect(layout.foldedSeatIndexes, isEmpty);
    });
  });

  testWidgets('button open-fold dock renders folded early seats', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-02-03-01-unguided-btn',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Button open decision',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Folds to you on the button — pick Fold, Open, or Limp.',
      choices: const [
        CourseChoice(id: 'open-k9s', label: 'Open to 6', action: 'RAISE'),
        CourseChoice(id: 'fold-k9s', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'limp-k9s', label: 'Limp', action: 'CALL'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          heroIdentityProvider.overrideWithValue(const HeroIdentity()),
        ],
        child: MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId('lesson-02-03-01-open-fold'),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                child: PokerActionSizingActivity(
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

    final table = tester.widget<LessonTableStage>(
      find.byType(LessonTableStage),
    );
    expect(table.villainCount, lessonBlindsVillainCount);
    expect(table.foldedSeatIndexes.toSet(), {3, 4, 5});
    expect(find.byType(PlayerSeatWidget), findsNWidgets(6));
    // Three seat badges + the dock "Fold" choice share the same label.
    expect(find.text('FOLD'), findsAtLeastNWidgets(3));
    final foldedSeats = tester
        .widgetList<PlayerSeatWidget>(find.byType(PlayerSeatWidget))
        .where((seat) => seat.player.folded)
        .length;
    expect(foldedSeats, 3);
  });
}
