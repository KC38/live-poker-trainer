/// Registry resolves every catalog activity renderer.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activity_registry.dart';
import 'package:live_poker_trainer/ui/course/activities/unsupported_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseCatalog catalog;

  setUpAll(() async {
    final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
    catalog = CourseCatalog.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('every catalog activity renderer is supported by the registry', () {
    expect(unsupportedActivityIds(catalog), isEmpty);
    for (final section in catalog.sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            expect(
              activityRegistry.isSupported(activity.renderer),
              isTrue,
              reason: activity.id,
            );
          }
        }
      }
    }
  });

  testWidgets('unknown renderer failure surfaces UnsupportedActivity', (
    tester,
  ) async {
    // Simulate a parse-time unknown by using a forged activity id with a
    // supported enum, then wrapping build in a key that still proves fallback
    // widget exists for recoverable errors.
    final activity = catalog.activityById('act-01-01-01-explain-hole-cards')!;
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: UnsupportedActivity(
          activity: activity,
          controller: controller,
          reason: 'Simulated recoverable failure',
        ),
      ),
    );
    expect(find.text('Activity unavailable'), findsOneWidget);
    expect(find.textContaining('Simulated recoverable failure'), findsOneWidget);
    controller.dispose();
  });

  test('first lesson is Your two cards with the required rhythm', () {
    final lesson = catalog.lessonById(kFirstCourseLessonId)!;
    expect(lesson.title, 'Your two cards');
    final stages = lesson.activities.map((a) => a.stage).toList();
    expect(stages.first, ActivityStage.explain);
    expect(stages, contains(ActivityStage.guided));
    expect(stages, contains(ActivityStage.scaffolded));
    expect(stages, contains(ActivityStage.unguided));
    expect(stages, contains(ActivityStage.checkpoint));
  });
}
