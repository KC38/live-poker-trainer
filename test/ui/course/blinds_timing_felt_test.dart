/// Locks the Button and blinds phase columns so cards stay inside the felt.
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

  testWidgets('flop cards and showdown backs stack inside the phase columns', (
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

    _expectStackedInside(
      tester,
      columnOf: find.text('After flop'),
      items: find.byType(MiniCard),
    );
    _expectStackedInside(
      tester,
      columnOf: find.text('Showdown'),
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

void _expectStackedInside(
  WidgetTester tester, {
  required Finder columnOf,
  required Finder items,
}) {
  final column = find
      .ancestor(of: columnOf, matching: find.byType(Expanded))
      .first;
  final bounds = tester.getRect(column);
  final count = tester.widgetList(items).length;
  final rects = [for (var i = 0; i < count; i++) tester.getRect(items.at(i))];
  expect(rects.length, greaterThan(1));
  for (final rect in rects) {
    expect(rect.left, greaterThanOrEqualTo(bounds.left - 0.5));
    expect(rect.right, lessThanOrEqualTo(bounds.right + 0.5));
    expect(rect.top, greaterThanOrEqualTo(bounds.top - 0.5));
    expect(rect.bottom, lessThanOrEqualTo(bounds.bottom + 0.5));
  }
  final sorted = [...rects]..sort((a, b) => a.top.compareTo(b.top));
  for (var i = 1; i < sorted.length; i++) {
    expect(sorted[i].top, greaterThan(sorted[i - 1].bottom - 0.5));
    expect((sorted[i].left - sorted.first.left).abs(), lessThan(1));
  }
}
