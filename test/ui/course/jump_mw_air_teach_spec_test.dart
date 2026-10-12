// LPT-425: the catalog teachSpec deal for the Section 3 multiway jump must
// match the Dart felt template (true air), not the old 98 flush draw.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

void main() {
  test('jump-mw teachSpec fixedCards match the Dart true-air spot', () {
    final catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final a = catalog.activityById('act-03-08-02-jump-mw')!;
    final fixed = a.teachSpec!['deal']['fixedCards'] as Map;
    final spot = resolveLessonActionSpot(a)!;
    expect(fixed['hero'], spot.heroCodes);
    expect(fixed['board'], spot.boardCodes);
    expect(fixed['hero'], ['7s', '3d']);
    expect(fixed['board'], ['Ah', 'Kh', '9h']);
    final cues = a.teachSpec!['cues'] as List;
    expect((cues.single as Map)['target'], 'j3-fold');
    expect((cues.single as Map)['kind'], 'none');
    expect(a.teachSpec!.containsKey('pressHints'), isFalse);
  });
}
