/// Lesson spots that name their opponent's type show it on the table.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activity_registry.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

final _catalog = CourseCatalog.fromJson(
  jsonDecode(File(kCourseCatalogAssetPath).readAsStringSync())
      as Map<String, dynamic>,
);

CourseActivity _activity(String lessonId, String activityId) =>
    _catalog.activitiesForLesson(lessonId).firstWhere((a) => a.id == activityId);

Future<void> _pump(
  WidgetTester tester,
  String lessonId,
  String activityId,
) async {
  tester.view.physicalSize = const Size(375, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final activity = _activity(lessonId, activityId);
  final controller = LessonActivityController(activity: activity);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(lessonId),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              child: const ActivityRegistry().build(
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
  await tester.pump(const Duration(milliseconds: 50));
  expect(find.byType(LessonTableStage), findsOneWidget);
}

const _typeWords = ['STATION', 'NIT', 'MANIAC', 'TAG', 'LAG'];

void main() {
  testWidgets('a Nit spot seats a Nit', (tester) async {
    await _pump(tester, 'lesson-04-07-03-adjust-nit', 'act-04-07-03-guided');
    expect(find.text('NIT'), findsOneWidget);
    expect(find.text('13/10'), findsOneWidget);
  });

  testWidgets('a sticky-caller spot seats a Calling Station', (tester) async {
    await _pump(
      tester,
      'lesson-04-06-03-adjust-calling-station',
      'act-04-06-03-guided',
    );
    expect(find.text('STATION'), findsOneWidget);
  });

  testWidgets('a TAG spot seats a TAG', (tester) async {
    await _pump(tester, 'lesson-06-11-03-adjust-tag', 'act-06-11-03-guided');
    expect(find.text('TAG'), findsOneWidget);
  });

  testWidgets('an unknown opponent stays a plain seat', (tester) async {
    await _pump(tester, 'lesson-04-07-03-adjust-nit', 'act-04-07-03-unguided');
    for (final word in _typeWords) {
      expect(find.text(word), findsNothing, reason: word);
    }
  });

  testWidgets('a spot that names no opponent stays a plain seat', (
    tester,
  ) async {
    await _pump(
      tester,
      'lesson-04-02-01-threebet-squeeze',
      'act-04-02-01-guided',
    );
    for (final word in _typeWords) {
      expect(find.text(word), findsNothing, reason: word);
    }
  });
}
