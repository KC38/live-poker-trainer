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
    // No-felt unit steps release the gate the same way the runner does.
    controller.releaseFeltDealIfUntracked();
    await Future<void>.delayed(Duration.zero);
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);
    final noticesAfterRelease = notices;

    controller.notifyFeltDealReady(false);
    expect(controller.feltDealReady, isFalse);
    expect(controller.showTargetCue, isFalse);
    expect(notices, noticesAfterRelease);
    await Future<void>.delayed(Duration.zero);
    expect(notices, noticesAfterRelease + 1);

    controller.notifyFeltDealReady(false);
    await Future<void>.delayed(Duration.zero);
    expect(notices, noticesAfterRelease + 1);

    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    expect(controller.showTargetCue, isFalse);
    // Hint must stay tappable until SoftPulse can paint (LPT-678).
    expect(controller.canRequestHint, isTrue);

    controller.notifyFeltDealReady(true);
    await Future<void>.delayed(Duration.zero);
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);
    controller.dispose();
  });

  test('scaffolded Hint keeps Hint enabled while the deal is unsettled', () {
    final controller = LessonActivityController(
      activity: activity(
        id: 'act-02-03-01-scaffolded-qq',
        stage: ActivityStage.scaffolded,
        renderer: ActivityRenderer.pokerActionSizing,
      ),
    );
    controller.notifyFeltDealReady(false);
    expect(controller.showTargetCue, isFalse);
    expect(controller.canRequestHint, isTrue);
    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    expect(controller.showTargetCue, isFalse);
    expect(controller.canRequestHint, isTrue);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);
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
    // Rebind resets the deal gate; no-felt unit steps release it.
    controller.releaseFeltDealIfUntracked();
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);

    controller.notifyFeltDealReady(false);
    controller.advanceToNextHandStep();
    controller.releaseFeltDealIfUntracked();
    expect(controller.feltDealReady, isTrue);
    expect(controller.showTargetCue, isTrue);
    expect(controller.draft.handStepIndex, 1);
    controller.dispose();
  });

  test('scaffolded SoftPulse returns after Hint once the deal lands', () {
    final controller = LessonActivityController(
      activity: activity(
        id: 'act-01-04-01-scaffolded-order',
        stage: ActivityStage.scaffolded,
        renderer: ActivityRenderer.orderSequence,
      ),
    );
    controller.releaseFeltDealIfUntracked();
    // Scaffolded SoftPulse stays off until Hint.
    expect(controller.showTargetCue, isFalse);
    controller.revealHint();
    expect(controller.showTargetCue, isTrue);
    controller.notifySequentialPressProgress(remainingPressCount: 4);
    controller.consumeSequentialSoftPulse();
    // Wave closed with Hint able to reopen — SoftPulse off until next Hint.
    expect(controller.showTargetCue, isFalse);

    controller.notifyFeltDealReady(false);
    expect(controller.showTargetCue, isFalse);
    controller.revealHint();
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
