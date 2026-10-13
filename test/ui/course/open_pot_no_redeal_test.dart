/// Framed open-pot math must not remount dealt cards under Nice!/Oops!.
///
/// LPT-642: dropping the Rex coach slot when `locked` shifts the Column and
/// remounts [LessonTableStage] / [DealtCardReveal] (redeal animation).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_open_pot_deal.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/dealt_card_reveal.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets(
    'open-pot finishSubmit keeps DealtCardReveal states (accepted + miss)',
    (tester) async {
      CardDealPace.debugInstant = true;
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final deal = dealLessonOpenPot(
        activityId: kOpenPotActivityId,
        generation: 0,
      );
      final activity = CourseActivity(
        id: kOpenPotActivityId,
        order: 4,
        stage: ActivityStage.scaffolded,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 40,
        accessibilityText:
            'Tap the pot total — blinds plus the open. Open size varies.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Blinds 1/2. BTN opens. Tap the pot before blinds act.',
        choices: const [
          CourseChoice(id: kOpenPotCorrectChoiceId, label: 'Correct pot'),
          CourseChoice(id: kOpenPotMissBlindChoiceId, label: 'Miss a blind'),
          CourseChoice(id: kOpenPotTooBigChoiceId, label: 'Too big'),
        ],
      );

      Future<void> assertNoRedeal({required bool accepted}) async {
        final controller = LessonActivityController(activity: activity);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_framedOpenPot(activity, controller));
        await tester.pumpAndSettle();

        // Open-pot deals backs only for live seats (BTN/SB/BB) — not hero 0.
        final back = find.byKey(const ValueKey<String>('dealt-back-3-0'));
        expect(back, findsOneWidget);
        expect(find.byType(DealtCardReveal), findsWidgets);
        // Element identity — tester.state needs a State subtype (LPT-97).
        final before = tester.element(back);

        controller.selectChoice(
          accepted ? kOpenPotCorrectChoiceId : kOpenPotMissBlindChoiceId,
          autoSubmit: false,
        );
        controller.finishSubmit(
          SubmitCourseStepResult(
            attemptId: 'attempt',
            activityId: activity.id,
            grade: accepted ? SoftGrade.recommended : SoftGrade.questionable,
            feedback: accepted
                ? 'Blinds plus the open — that is the pot.'
                : 'Add both blinds and the open.',
            accepted: accepted,
            lifeLost: !accepted,
            livesRemaining: accepted ? 5 : 4,
            xpAwarded: accepted ? 10 : 0,
            remediationRequired: false,
            resume: CourseResumePointer(
              attemptId: 'attempt',
              lessonId: 'lesson-01-05-01-winning-pots',
              activityId: activity.id,
              activityIndex: 3,
            ),
            duplicate: false,
          ),
        );
        await tester.pump();

        expect(back, findsOneWidget);
        expect(
          identical(before, tester.element(back)),
          isTrue,
          reason:
              'open-pot ${accepted ? 'Nice!' : 'Oops!'} remounted '
              'DealtCardReveal (redeal); openTo=${deal.openTo}',
        );
      }

      await assertNoRedeal(accepted: true);
      await assertNoRedeal(accepted: false);
    },
  );
}

Widget _framedOpenPot(
  CourseActivity activity,
  LessonActivityController controller,
) {
  final base = buildPokerTheme();
  return ProviderScope(
    overrides: [heroIdentityProvider.overrideWithValue(const HeroIdentity())],
    child: MaterialApp(
      theme: base.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId('lesson-01-05-01-winning-pots'),
          child: LessonFrameScope(
            onLocalMiss: (_) {},
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
}
