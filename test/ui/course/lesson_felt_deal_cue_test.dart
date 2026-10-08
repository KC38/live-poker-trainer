/// SoftPulse stays off while the felt is still dealing.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CourseActivity activity({
    required String id,
    required ActivityStage stage,
    ActivityRenderer renderer = ActivityRenderer.selectIdentify,
  }) {
    return CourseActivity(
      id: id,
      order: 1,
      stage: stage,
      renderer: renderer,
      estimatedSeconds: 30,
      accessibilityText: 'Tap the felt.',
      acceptedGrades: const [SoftGrade.recommended],
    );
  }

  test('guided SoftPulse stays off until the felt deal lands', () async {
    final controller = LessonActivityController(
      activity: activity(
        id: 'act-guided-open',
        stage: ActivityStage.guided,
      ),
    );
    var notices = 0;
    controller.addListener(() => notices++);
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);

    controller.notifyFeltDealReady(false);
    expect(controller.feltDealReady, isFalse);
    expect(controller.showTargetCue, isFalse);
    expect(notices, 0);
    await Future<void>.delayed(Duration.zero);
    expect(notices, 1);

    controller.notifyFeltDealReady(false);
    await Future<void>.delayed(Duration.zero);
    expect(notices, 1);

    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    expect(controller.showTargetCue, isFalse);

    controller.notifyFeltDealReady(true);
    await Future<void>.delayed(Duration.zero);
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);
    controller.dispose();
  });

  test('a review Hint does not show cues while cards are still dealing', () {
    final controller = LessonActivityController(
      activity: activity(
        id: 'act-01-01-01-guided-find-holes',
        stage: ActivityStage.guided,
      ),
      isReview: true,
    );
    expect(controller.showTargetCue, isFalse);
    controller.notifyFeltDealReady(false);
    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    expect(controller.showTargetCue, isFalse);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    controller.dispose();
  });

  test('binding the next step turns cues back on after an unfinished deal', () {
    final guided = activity(
      id: 'act-guided-open',
      stage: ActivityStage.guided,
    );
    final controller = LessonActivityController(activity: guided);
    controller.notifyFeltDealReady(false);
    expect(controller.showTargetCue, isFalse);

    controller.bindActivity(guided);
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);

    controller.notifyFeltDealReady(false);
    controller.advanceToNextHandStep();
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);
    expect(controller.draft.handStepIndex, 1);
    controller.dispose();
  });

  test('scaffolded teaching cues return after the deal, not during it', () {
    final controller = LessonActivityController(
      activity: activity(
        id: 'act-01-04-01-scaffolded-order',
        stage: ActivityStage.scaffolded,
        renderer: ActivityRenderer.orderSequence,
      ),
    );
    expect(controller.showTargetCue, isTrue);
    controller.notifySequentialPressProgress(remainingPressCount: 4);
    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isTrue);

    controller.notifyFeltDealReady(false);
    expect(controller.showTargetCue, isFalse);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    controller.dispose();
  });

  test('disposing during a deal-ready notification does not notify', () async {
    final controller = LessonActivityController(
      activity: activity(
        id: 'act-guided-open',
        stage: ActivityStage.guided,
      ),
    );
    var notices = 0;
    controller.addListener(() => notices++);
    controller.notifyFeltDealReady(false);
    controller.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(notices, 0);
    expect(controller.showTargetCue, isFalse);
  });
}
