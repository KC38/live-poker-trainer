/// LPT-624: every SoftPulse explain authors an activity-level
/// `explainGrading` Nice! line (private bank), so success feedback never
/// falls back to `accessibilityText` / the idle ask.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

const _explains = <String>[
  'act-01-01-01-explain-hole-cards',
  'act-01-01-02-explain-suits',
  'act-01-01-03-explain-button',
  'act-01-03-01-explain-passive',
  'act-01-03-02-explain-aggro',
  'act-01-05-01-explain-win',
  'act-01-06-01-explain-run',
  'act-02-01-01-explain-pos',
  'act-02-02-01-explain-families',
  'act-02-03-01-explain-open',
  'act-02-04-01-explain-vs',
  'act-02-05-01-explain-bb',
  'act-02-07-01-explain-full',
  'act-03-01-01-explain',
  'act-03-02-01-explain',
  'act-03-03-01-explain',
  'act-03-04-01-explain',
  'act-03-05-01-explain',
  'act-03-06-01-explain',
  'act-03-07-01-explain',
  'act-03-08-01-explain',
  'act-04-01-01-explain',
  'act-04-02-01-explain',
  'act-04-03-01-explain',
  'act-04-04-01-explain',
  'act-04-05-01-explain',
  'act-04-06-01-explain',
  'act-04-06-02-explain',
  'act-04-06-03-explain',
  'act-04-07-01-explain',
  'act-04-07-02-explain',
  'act-04-07-03-explain',
  'act-04-08-03-explain',
  'act-04-09-01-explain',
  'act-04-10-01-explain',
  'act-05-01-01-explain',
  'act-05-02-01-explain',
  'act-05-03-01-explain',
  'act-05-04-01-explain',
  'act-05-05-01-explain',
  'act-05-06-01-explain',
  'act-05-07-01-explain',
  'act-05-08-01-explain',
  'act-05-09-01-explain',
  'act-06-01-01-explain',
  'act-06-02-01-explain',
  'act-06-03-01-explain',
  'act-06-04-01-explain',
  'act-06-05-01-explain',
  'act-06-06-01-explain',
  'act-06-07-01-explain',
  'act-06-08-01-explain',
  'act-06-09-01-explain',
  'act-06-10-01-explain',
  'act-06-11-01-explain',
  'act-06-11-02-explain',
  'act-06-11-03-explain',
  'act-06-12-01-explain',
  'act-06-12-02-explain',
  'act-06-12-03-explain',
  'act-06-13-01-explain',
  'act-07-01-01-explain',
  'act-07-02-01-explain',
  'act-07-03-01-explain',
  'act-07-04-01-explain',
  'act-07-05-01-explain',
  'act-07-06-01-explain',
  'act-07-07-01-explain',
  'act-07-08-01-explain',
  'act-07-09-01-explain',
  'act-07-10-01-explain',
  'act-07-10-02-explain',
  'act-07-10-03-explain',
  'act-07-10-04-explain',
  'act-07-10-05-explain',
  'act-07-11-01-explain',
];

void main() {
  late CourseCatalog catalog;
  late Map<String, dynamic> grading;
  setUpAll(() {
    catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final bank = jsonDecode(
      File('functions/src/generated/course_bank.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    grading = bank['gradingByActivityId'] as Map<String, dynamic>;
  });

  test('SoftPulse explains carry a short Nice! line (LPT-624)', () {
    expect(_explains, hasLength(76));
    for (final id in _explains) {
      final a = catalog.activityById(id);
      expect(a, isNotNull, reason: id);
      expect(a!.renderer, ActivityRenderer.coachDialogue, reason: id);
      final cues = a.teachSpec!['cues'] as List<dynamic>;
      expect(
        cues.any((c) => (c as Map)['kind'] == 'soft_pulse'),
        isTrue,
        reason: id,
      );
      final eg =
          (grading[id] as Map<String, dynamic>)['explainGrading']
              as Map<String, dynamic>?;
      expect(eg, isNotNull, reason: '$id needs explainGrading');
      expect(eg!['grade'], 'recommended', reason: id);
      final feedback = (eg['feedback'] as String).trim();
      expect(feedback, isNotEmpty, reason: id);
      expect(feedback, isNot(a.accessibilityText.trim()), reason: id);
      expect(feedback.toLowerCase(), isNot(startsWith('tap')), reason: id);
      expect(feedback.length, lessThanOrEqualTo(60), reason: id);
    }
  });
}
