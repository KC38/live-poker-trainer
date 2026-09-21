import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';

void main() {
  group('CourseFlags', () {
    test('fails closed for null and incomplete maps', () {
      expect(CourseFlags.fromMap(null).courseEnabled, isFalse);
      expect(CourseFlags.fromMap(<String, dynamic>{}).courseEnabled, isFalse);
      expect(
        CourseFlags.fromMap(<String, dynamic>{'courseEnabled': true})
            .courseEnabled,
        isFalse,
      );
    });

    test('parses enabled flag documents', () {
      final flags = CourseFlags.fromMap(<String, dynamic>{
        'courseEnabled': true,
        'courseStartsEnabled': true,
        'guestCourseEnabled': true,
        'placementTestsEnabled': false,
        'catalogVersion': '2.0.0',
        'minimumClientVersion': '2.0.0',
      });
      expect(flags.canStartCourse, isTrue);
      expect(flags.canStartAsGuest, isTrue);
      expect(flags.placementTestsEnabled, isFalse);
    });
  });
}
