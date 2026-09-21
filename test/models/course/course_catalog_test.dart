import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseCatalog catalog;
  late String rawCatalog;

  setUpAll(() async {
    rawCatalog = await rootBundle.loadString('assets/course/v2/catalog.json');
    catalog = CourseCatalog.fromJson(
      jsonDecode(rawCatalog) as Map<String, dynamic>,
    );
  });

  test('client catalog parses with live-cash scope and seven sections', () {
    expect(catalog.scope, 'live_cash_nlh');
    expect(catalog.coachId, 'rex');
    expect(catalog.catalogVersion, '2.0.0');
    expect(catalog.contentChecksum, isNotEmpty);
    expect(catalog.sections, hasLength(7));
    expect(catalog.playerTypes, hasLength(5));
  });

  test('lesson and activity ids are unique and ordered', () {
    final lessonIds = catalog.lessonIdsInOrder;
    final activityIds = catalog.activityIdsInOrder;
    expect(lessonIds.toSet(), hasLength(lessonIds.length));
    expect(activityIds.toSet(), hasLength(activityIds.length));
    expect(lessonIds.first, 'lesson-01-01-01-suits-ranks-and-seats');
    expect(lessonIds.last, 'lesson-07-01-01-plan-stub');
    expect(activityIds, contains('act-01-01-01-hand-lab-seed'));
  });

  test('client catalog json contains no private grading keys', () {
    for (final token in [
      '"grading"',
      '"correctSequence"',
      '"sequenceGrading"',
      '"handLabSpec"',
      '"betterChoiceId"',
      '"reversalRead"',
      '"missGrading"',
      '"acceptedMin"',
      '"acceptedMax"',
    ]) {
      expect(rawCatalog.contains(token), isFalse, reason: token);
    }
  });

  test('player types are introduced before later refs', () {
    final introduced = <CoursePlayerTypeId>{};
    for (final section in catalog.sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          introduced.addAll(lesson.introducesPlayerTypes);
          for (final type in lesson.playerTypeRefs) {
            expect(
              introduced.contains(type),
              isTrue,
              reason: '${lesson.id} refs $type before intro',
            );
          }
        }
      }
    }
    expect(introduced, hasLength(5));
  });
}
