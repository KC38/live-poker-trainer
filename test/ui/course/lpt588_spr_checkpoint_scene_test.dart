/// LPT-588: the SPR checkpoint `LessonTableScene` deals the same turn board
/// as `teachSpec.deal.fixedCards` and `LessonActionSpot` (Qs 7c 2d 9h).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

const _id = 'act-04-05-01-checkpoint';

Map<String, dynamic> _activityJson() {
  Map<String, dynamic>? found;
  void walk(Object? o) {
    if (found != null) return;
    if (o is Map<String, dynamic>) {
      if (o['id'] == _id && o.containsKey('renderer')) {
        found = o;
        return;
      }
      o.values.forEach(walk);
    } else if (o is List) {
      o.forEach(walk);
    }
  }

  walk(jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync()));
  return Map<String, dynamic>.from(found!);
}

void main() {
  late CourseActivity activity;
  setUpAll(() {
    final raw = File('assets/course/v2/catalog.json').readAsStringSync();
    final catalog = CourseCatalog.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    activity = catalog.activityById(_id)!;
  });

  test('Scene board matches teachSpec fixedCards and ActionSpot', () {
    final fixed =
        (activity.teachSpec!['deal'] as Map)['fixedCards']
            as Map<String, dynamic>;
    final board = [for (final c in fixed['board'] as List) c as String];
    final hero = [for (final c in fixed['hero'] as List) c as String];
    expect(board, ['Qs', '7c', '2d', '9h']);

    // poker_action_sizing paints the ActionSpot; resolve the Scene override
    // as a Scene-first renderer would so the fallback cannot drift (LPT-588).
    final sceneFirst = CourseActivity.fromJson({
      ..._activityJson(),
      'renderer': 'select_identify',
    });
    final scene = resolveLessonTableScene(sceneFirst);
    expect(scene, isNotNull);
    expect(scene!.boardCodes, board);
    expect(scene.heroCodes, hero);

    final spot = resolveLessonActionSpot(activity);
    expect(spot, isNotNull);
    expect(spot!.boardCodes, board);
    expect(spot.heroCodes, hero);
    expect(spot.streetLabel, 'Turn · facing jam');
  });

  test('checkpoint stays Hint-free', () {
    expect(activity.assessmentRole, isNotNull);
    expect(activity.teachSpec!.containsKey('pressHints'), isFalse);
    expect(activity.coachMedia.where((m) => m.kind == 'hint'), isEmpty);
    expect(lessonFrameHintsDisabled(activity), isTrue);
  });
}
