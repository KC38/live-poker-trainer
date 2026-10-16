/// Steal more densify coach waits for hero holes (LPT-1012).
///
/// Catalog prompts name `You have K9o` before the deal lands. Mid-deal frame
/// speech must keep the Nit-in-BB lead without naming holes; after
/// [feltDealReady] the remapped combo may appear.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _id = 'act-04-07-03-guided';

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  test('$_id deal-settling speech keeps Nit lead without naming holes', () {
    final activity = catalog.activityById(_id);
    expect(activity, isNotNull, reason: _id);
    final settling = lessonFrameDealSettlingSpeech(activity!);
    expect(settling.toLowerCase(), contains('nit'));
    expect(settling.toLowerCase(), contains('watch the deal'));
    expect(settling.toLowerCase(), isNot(contains('you have')));
    expect(settling, isNot(contains(RegExp(r'\b[AKQJT2-9]{1,2}[so]\b'))));
    expect(settling.toLowerCase(), contains('tap'));
  });

  test('$_id idle speech names holes only after feltDealReady', () {
    final activity = catalog.activityById(_id);
    expect(activity, isNotNull, reason: _id);
    final controller = LessonActivityController(
      activity: activity!,
      isReview: false,
    );
    expect(controller.feltDealReady, isFalse);
    expect(controller.feltDealTracked, isFalse);

    controller.notifyFeltDealReady(false);
    expect(controller.feltDealTracked, isTrue);
    expect(controller.feltDealReady, isFalse);

    final settling = lessonFrameDealSettlingSpeech(activity);
    expect(settling.toLowerCase(), contains('watch the deal'));

    controller.notifyFeltDealReady(true);
    expect(controller.feltDealReady, isTrue);
    final ready = lessonFrameSpeech(activity);
    expect(ready.toLowerCase(), contains('you have'));
    expect(ready, contains(RegExp(r'\b[AKQJT2-9]{1,2}[so]\b')));
  });
}
