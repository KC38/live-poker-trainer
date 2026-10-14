// LPT-669: SoftPulse explain successors stay table-tap + visual SoftPulse walks.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

void main() {
  late CourseCatalog catalog;

  setUpAll(() {
    catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('SoftPulse explain successors stay table-tap SoftPulse walks', () {
    final softPulseExplains = <CourseActivity>[];
    for (final section in catalog.sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            if (activity.renderer != ActivityRenderer.coachDialogue) {
              continue;
            }
            final cues = authoredSoftPulseTargets(activity);
            if (cues == null || cues.isEmpty) continue;
            softPulseExplains.add(activity);
          }
        }
      }
    }

    expect(softPulseExplains, isNotEmpty);
    // Parents + S1–S4 successors; content-driven wiring covers all of them.
    expect(softPulseExplains.length, greaterThanOrEqualTo(150));

    final missingTap = <String>[];
    final missingVisual = <String>[];
    for (final activity in softPulseExplains) {
      if (!isTableRegionTapActivity(activity)) {
        missingTap.add(activity.id);
      }
      final visual = resolveCoachDialogueVisual(activity);
      if (!visual.requiresFeltTap) {
        missingVisual.add('${activity.id}->${visual.kind.name}');
      }
    }

    expect(missingTap, isEmpty, reason: 'table-tap allowlist gaps');
    expect(missingVisual, isEmpty, reason: 'resolveCoachDialogueVisual gaps');
  });

  test('authored-cue kind covers a known S4 SoftPulse successor', () {
    final activity = catalog.activityById('act-04-01-01-02-explain-move');
    expect(activity, isNotNull);
    expect(isTableRegionTapActivity(activity!), isTrue);
    expect(
      resolveCoachDialogueVisual(activity).kind,
      CoachDialogueVisualKind.authoredCues,
    );
    expect(authoredSoftPulseTargets(activity), ['RAISE', 'NARROWER', 'CALL']);
  });

  test('parent SoftPulse explains keep dedicated visuals', () {
    final suits = catalog.activityById('act-01-01-02-explain-suits');
    expect(suits, isNotNull);
    expect(
      resolveCoachDialogueVisual(suits!).kind,
      CoachDialogueVisualKind.suitsRanks,
    );
    expect(isTableRegionTapActivity(suits), isTrue);
  });
}
