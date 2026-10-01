/// Locks blinds-timing option rows so flop / showdown visuals stay on the felt.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('flop cards and showdown backs sit in horizontal option rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const activity = CourseActivity(
      id: 'act-01-01-03-unguided-when',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the hand phase when blinds are posted.',
      acceptedGrades: [SoftGrade.recommended],
      prompt: 'When do those forced bets go in?',
      choices: [
        CourseChoice(
          id: 'before-deal',
          label: 'Before any hole cards are dealt',
        ),
        CourseChoice(id: 'after-flop', label: 'After the flop'),
        CourseChoice(
          id: 'only-showdown',
          label: 'Only if the hand reaches showdown',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Before deal'), findsOneWidget);
    expect(find.text('After flop'), findsOneWidget);
    expect(find.text('Showdown'), findsOneWidget);
    expect(find.text('When do those forced bets go in?'), findsOneWidget);

    final before = tester.getCenter(find.text('Before deal'));
    final after = tester.getCenter(find.text('After flop'));
    final showdown = tester.getCenter(find.text('Showdown'));
    // Horizontal options stack top → bottom (timeline order).
    expect(before.dy, lessThan(after.dy));
    expect(after.dy, lessThan(showdown.dy));

    final felt = tester.getRect(
      find.byKey(const ValueKey('blinds-timing-felt')),
    );
    _expectSideBySideInsideFelt(
      tester,
      felt: felt,
      nearLabel: find.text('After flop'),
      items: find.byType(MiniCard),
    );
    _expectSideBySideInsideFelt(
      tester,
      felt: felt,
      nearLabel: find.text('Showdown'),
      items: find.byType(CardBack),
    );
  });
}

Widget _wrap(Widget child) {
  final base = buildPokerTheme();
  return ProviderScope(
    overrides: [heroIdentityProvider.overrideWithValue(const HeroIdentity())],
    child: MaterialApp(
      theme: base.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(body: child),
    ),
  );
}

void _expectSideBySideInsideFelt(
  WidgetTester tester, {
  required Rect felt,
  required Finder nearLabel,
  required Finder items,
}) {
  final labelCenter = tester.getCenter(nearLabel);
  final count = tester.widgetList(items).length;
  final rects = <Rect>[];
  for (var i = 0; i < count; i++) {
    final rect = tester.getRect(items.at(i));
    // Keep visuals that share the option row's vertical band with the label.
    if ((rect.center.dy - labelCenter.dy).abs() < 48) {
      rects.add(rect);
    }
  }
  expect(rects.length, greaterThan(1));
  for (final rect in rects) {
    expect(rect.left, greaterThanOrEqualTo(felt.left - 0.5));
    expect(rect.right, lessThanOrEqualTo(felt.right + 0.5));
    expect(rect.top, greaterThanOrEqualTo(felt.top - 0.5));
    expect(rect.bottom, lessThanOrEqualTo(felt.bottom + 0.5));
  }
  final sorted = [...rects]..sort((a, b) => a.left.compareTo(b.left));
  for (var i = 1; i < sorted.length; i++) {
    expect(sorted[i].left, greaterThan(sorted[i - 1].right - 0.5));
    expect((sorted[i].top - sorted.first.top).abs(), lessThan(2));
  }
}
