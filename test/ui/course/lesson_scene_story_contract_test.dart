/// Every drill felt tells the story its copy and answers describe.
///
/// Pumps each choice / number drill at 375×812 inside the lesson frame and
/// checks the speech bubble, hint, and seat-named answers against what the
/// felt plays out (see `scene_story_rules.dart`):
///
/// * every action, street, board feature, size, seat, table size, and player
///   type they name happens on the felt, in seat order, before the question;
/// * the speech never restates a stack / pot / bet number the felt shows;
/// * a type badge never spoils a type answer.
///
/// `SCENE_STORY_REPORT=<path>` writes the full inventory as JSON.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activity_registry.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_drill_stories.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_drill_story.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_drill_scene.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

import 'scene_story_rules.dart';

/// Facts for a drill with no story (the parsed generic felt).
SceneFacts _factsFromSpec(LessonTableDrillSpec spec) {
  final story = spec.story;
  if (story != null) return SceneFacts.fromStory(story);
  final street = !spec.postflop
      ? 'pre'
      : switch (spec.boardCodes.length) {
          5 => 'river',
          4 => 'turn',
          _ => 'flop',
        };
  final streets = <String>{
    if (spec.postflop) ...[
      'flop',
      if (street != 'flop') 'turn',
      if (street == 'river') 'river',
    ] else
      'pre',
  };
  final pot = spec.potChips ?? 0;
  return SceneFacts(
    streets: streets,
    board: spec.boardCodes,
    actions: [
      for (final e in spec.actionsByPosition.entries)
        LessonDrillAction(
          street: street,
          position: e.key == 'You' ? spec.heroPosition : e.key,
          label: e.value,
          toChips: spec.betsByPosition[e.key] ?? 0,
          potBeforeChips: pot - (spec.betsByPosition[e.key] ?? 0),
        ),
    ],
    liveCount: 6 - spec.foldedSeatIndexes.length,
    types: spec.seatTypes,
    focus: spec.focusPosition,
    heroPosition: spec.heroPosition,
    shownHoles: spec.villainCodes.isNotEmpty || spec.holesByPosition.isNotEmpty,
  );
}

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final violations = <String>[];
  final report = <Map<String, Object?>>[];
  var drills = 0;

  test('every authored story parses (seat order, betting, board)', () {
    final bad = <String>[];
    for (final id in lessonDrillStorySources.keys) {
      try {
        lessonDrillStoryFor(id);
      } on FormatException catch (e) {
        bad.add('$id: ${e.message}');
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        for (final a in lesson.activities) {
          testWidgets('scene story: ${a.id}', (tester) async {
            tester.view.physicalSize = const Size(375, 812);
            tester.view.devicePixelRatio = 1;
            final controller = LessonActivityController(activity: a);
            await tester.pumpWidget(
              ProviderScope(
                child: MaterialApp(
                  theme: buildPokerTheme(),
                  home: Scaffold(
                    body: TableFeaturesScope(
                      features: TableFeatures.forLessonId(lesson.id),
                      child: LessonFrameScope(
                        onLocalMiss: (_) {},
                        activityController: controller,
                        child: Column(
                          children: [
                            Expanded(
                              child: activityRegistry.build(
                                activity: a,
                                controller: controller,
                                showGuidance: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 50));
            final scene = find.byType(LessonTableDrillScene);
            if (scene.evaluate().isNotEmpty) {
              drills += 1;
              final spec = tester
                  .widget<LessonTableDrillScene>(scene.first)
                  .spec;
              final speech = lessonFrameSpeech(a);
              final hints = <String>[
                for (final h
                    in (a.teachSpec?['pressHints'] as List? ?? const []))
                  if (h is Map && h['text'] is String) h['text'] as String,
              ];
              final options = <String>[
                for (final t in tester.widgetList<Text>(
                  find.descendant(
                    of: find.byKey(
                      const ValueKey('lesson-table-drill-actions'),
                    ),
                    matching: find.byType(Text),
                  ),
                ))
                  if (t.data != null) t.data!,
              ];
              final felt = <String>[
                for (final t in tester.widgetList<Text>(
                  find.descendant(
                    of: find.byType(FeltTableView),
                    matching: find.byType(Text),
                  ),
                ))
                  if (t.data != null) t.data!,
              ];
              final problems = sceneStoryProblems(
                speech: speech,
                hints: hints,
                options: options,
                facts: _factsFromSpec(spec),
                feltTexts: felt,
                heroCodes: spec.heroCodes,
              );
              for (final p in problems) {
                violations.add('${a.id}: $p');
              }
              report.add({
                'id': a.id,
                'lesson': lesson.title,
                'speech': speech,
                'hints': hints,
                'options': options,
                'story': spec.story?.source,
                'felt': felt,
                'problems': problems,
              });
            }
            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 10));
            controller.dispose();
            tester.view.reset();
          });
        }
      }
    }
  }

  test('drill copy and answers match the felt story', () {
    final path = Platform.environment['SCENE_STORY_REPORT'];
    if (path != null) {
      File(path)
          .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(report));
    }
    expect(drills, greaterThanOrEqualTo(180));
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
