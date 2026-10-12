// LPT-415: SPR decides commitment unguided posts remaining stacks that make
// the felt match the SPR 20 coach line (240 into pot 12).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

void main() {
  test('SPR unguided stacks left 240 into pot 12 = SPR 20', () {
    final catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final spot = resolveLessonActionSpot(
      catalog.activityById('act-04-05-01-unguided')!,
    )!;
    expect(spot.stackLabel, 'Stacks left 240');
    expect(spot.potLabel, startsWith('Pot 12'));
    final stack = int.parse(RegExp(r'\d+').firstMatch(spot.stackLabel!)![0]!);
    final pot = int.parse(RegExp(r'\d+').firstMatch(spot.potLabel)![0]!);
    expect(stack / pot, 20);
  });
}
