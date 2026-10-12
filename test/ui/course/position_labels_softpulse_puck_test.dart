/// Position labels SoftPulse prefers D / SB puck over seat boxes (LPT-118).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LessonTargetGlow puckGlow(WidgetTester tester, String label) {
    return tester.widget<LessonTargetGlow>(
      find.byKey(ValueKey<String>('puck-cue-$label')),
    );
  }

  LessonTargetGlow? seatGlowOrNull(WidgetTester tester, int seatIndex) {
    final seat = find.byKey(ValueKey<String>('lesson-seat-$seatIndex'));
    final glow = find.descendant(
      of: seat,
      matching: find.byType(LessonTargetGlow),
    );
    if (glow.evaluate().isEmpty) return null;
    return tester.widget<LessonTargetGlow>(glow);
  }

  testWidgets(
    'position labels guided SoftPulse rings D puck, not BTN seat',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-02-01-01-guided-btn',
        order: 2,
        stage: ActivityStage.guided,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 40,
        accessibilityText: 'Tap who acts last postflop.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap who acts last postflop.',
        choices: const [
          CourseChoice(id: 'pos-btn', label: 'BTN'),
          CourseChoice(id: 'pos-bb', label: 'BB'),
          CourseChoice(id: 'pos-ep', label: 'EP'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);
      controller.notifyFeltDealReady(true);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId(
                'lesson-02-01-01-position-labels',
              ),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                activityController: controller,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return SizedBox(
                      width: 375,
                      height: 560,
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
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(controller.showTargetCue, isTrue);
      expect(puckGlow(tester, 'D').highlighted, isTrue);
      expect(
        seatGlowOrNull(tester, lessonBlindsButtonIndex)?.highlighted ?? false,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'position labels scaffolded SoftPulse rings SB puck after Hint',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-02-01-01-scaffolded-blinds',
        order: 3,
        stage: ActivityStage.scaffolded,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 40,
        accessibilityText: 'Tap the small blind or big blind seat.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap a seat that posts a forced bet every hand.',
        choices: const [
          CourseChoice(id: 'sb-bb', label: 'SB or BB'),
          CourseChoice(id: 'btn-bb', label: 'BTN'),
          CourseChoice(id: 'ep-only', label: 'EP'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);
      controller.notifyFeltDealReady(true);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId(
                'lesson-02-01-01-position-labels',
              ),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                activityController: controller,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return SizedBox(
                      width: 375,
                      height: 560,
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
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.showTargetCue, isFalse);
      expect(controller.canRequestHint, isTrue);
      // puck-cue-* keys always wrap posted pucks; SoftPulse is the highlight.
      expect(puckGlow(tester, 'SB').highlighted, isFalse);

      controller.revealHint();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(controller.showTargetCue, isTrue);
      expect(controller.canRequestHint, isFalse);
      expect(puckGlow(tester, 'SB').highlighted, isTrue);
      expect(
        seatGlowOrNull(
              tester,
              lessonBlindsSmallBlindIndex,
            )?.highlighted ??
            false,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
