/// LPT-625: every unguided (and scaffolded-qq) `poker_action_sizing` dock
/// that authors a `soft_pulse` cue has a `_guidedPulseTargetId` arm, and the
/// arm golds that authored target (a real choice), not the first-choice
/// Hint fallback.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';

void main() {
  late List<CourseActivity> docks;
  setUpAll(() {
    final catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    docks = [
      for (final section in catalog.sections)
        for (final unit in section.units)
          for (final lesson in unit.lessons)
            for (final a in lesson.activities)
              if (a.renderer == ActivityRenderer.pokerActionSizing &&
                  (a.id.contains('unguided') || a.id.contains('scaffolded-qq')))
                a,
    ];
  });

  String? softPulseTarget(CourseActivity a) {
    final cues = a.teachSpec?['cues'];
    if (cues is! List) return null;
    for (final c in cues) {
      if (c is Map && c['kind'] == 'soft_pulse') return c['target'] as String?;
    }
    return null;
  }

  test('unguided docks map SoftPulse to the authored cue target', () {
    expect(docks.length, greaterThanOrEqualTo(24));
    final unmapped = <String>[];
    for (final a in docks) {
      final cue = softPulseTarget(a);
      final mapped = guidedPulseTargetIdForTest(a);
      if (cue == null) continue;
      if (mapped == null) {
        unmapped.add(a.id);
        continue;
      }
      expect(mapped, cue, reason: '${a.id} map arm != authored cue');
      expect(
        a.choices.map((c) => c.id),
        contains(mapped),
        reason: '${a.id} SoftPulse target must be a dock choice',
      );
    }
    expect(unmapped, isEmpty, reason: 'missing _guidedPulseTargetId arms');
  });
}
