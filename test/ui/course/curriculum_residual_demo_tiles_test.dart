/// Curriculum residuals (LPT-724..LPT-750): a reused first-child SoftPulse
/// explain shows and counts only the tiles its authored cues name, so the
/// split siblings keep their own concepts.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_authored_demo_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Explain id -> (tiles the learner taps, leftover tiles that must be gone).
const _residuals = <String, (List<String>, List<String>)>{
  'act-01-03-01-explain-passive': (['FOLD'], ['CHECK', 'CALL']),
  'act-01-03-02-explain-aggro': (['BET'], ['RAISE', 'ALL-IN']),
  'act-01-05-01-explain-win': (['FOLD WIN'], ['SHOWDOWN', 'SIDE POT']),
  'act-02-02-01-explain-families': (
    ['Pairs'],
    ['Broadways', 'Suited aces', 'Connectors'],
  ),
  'act-02-03-01-explain-open': (['EARLY'], ['BUTTON', 'LIVE 3x']),
  'act-02-04-01-explain-vs': (['FOLD'], ['CALL', '3-BET']),
  'act-02-05-01-explain-bb': (['CHIPS→BB'], ['SHORTER', 'DEPTH']),
  'act-02-06-01-explain-habits': (['WATCH'], ['SAY', 'COVER', 'WAIT']),
};

Widget _frame(String lessonId, Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildPokerTheme().copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId(lessonId),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  late CourseCatalog catalog;
  setUpAll(() {
    catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  String lessonOf(String activityId) {
    for (final s in catalog.sections) {
      for (final u in s.units) {
        for (final l in u.lessons) {
          if (l.activities.any((a) => a.id == activityId)) return l.id;
        }
      }
    }
    throw StateError('no lesson for $activityId');
  }

  test('subset helper keeps the full ladder unless cues name a subset', () {
    const tiles = ['A', 'B', 'C'];
    String id(String s) => s;
    expect(lessonAuthoredDemoSubset(const [], tiles, id), tiles);
    expect(lessonAuthoredDemoSubset(const ['a', 'b', 'c'], tiles, id), tiles);
    expect(lessonAuthoredDemoSubset(const ['B', 'Z'], tiles, id), tiles);
    expect(lessonAuthoredDemoSubset(const ['c', 'a'], tiles, id), ['A', 'C']);
  });

  for (final entry in _residuals.entries) {
    testWidgets('${entry.key} shows only ${entry.value.$1.join(', ')}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = catalog.activityById(entry.key)!;
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);
      var ack = 0;
      await tester.pumpWidget(
        _frame(
          lessonOf(entry.key),
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => ack += 1,
          ),
        ),
      );
      await tester.pump();

      for (final gone in entry.value.$2) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      for (final tile in entry.value.$1) {
        expect(ack, 0, reason: 'completed before $tile');
        await tester.tap(find.text(tile).first);
        await tester.pump();
      }
      expect(ack, 1);
    });
  }

  testWidgets('Dealer button explain completes on the D chip alone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = catalog.activityById('act-01-01-03-explain-button')!;
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var ack = 0;
    await tester.pumpWidget(
      _frame(
        'lesson-01-01-03-01-dealer-button',
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => ack += 1,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('D').first);
    await tester.pump();
    expect(ack, 1);
  });
}
