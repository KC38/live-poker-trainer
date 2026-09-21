import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';

void main() {
  const enabled = <String, dynamic>{
    'courseEnabled': true,
    'courseStartsEnabled': true,
    'guestCourseEnabled': true,
    'placementTestsEnabled': true,
    'catalogVersion': '2.0.0',
    'minimumClientVersion': '2.0.0',
  };

  group('CourseFlags', () {
    test('parses an enabled document', () {
      final flags = CourseFlags.fromMap(enabled);
      expect(flags.canStartCourse, isTrue);
      expect(flags.canStartAsGuest, isTrue);
      expect(flags.placementTestsEnabled, isTrue);
    });

    test(
      'guest cohort and paused starts are independent of the kill switch',
      () {
        final guestsOff = CourseFlags.fromMap({
          ...enabled,
          'guestCourseEnabled': false,
        });
        expect(guestsOff.courseEnabled, isTrue);
        expect(guestsOff.canStartCourse, isTrue);
        expect(guestsOff.canStartAsGuest, isFalse);

        final startsPaused = CourseFlags.fromMap({
          ...enabled,
          'courseStartsEnabled': false,
        });
        expect(startsPaused.courseEnabled, isTrue);
        expect(startsPaused.guestCourseEnabled, isTrue);
        expect(startsPaused.canStartCourse, isFalse);
        expect(startsPaused.canStartAsGuest, isFalse);
      },
    );
    test('disabled document cannot start the course', () {
      final flags = CourseFlags.fromMap({
        ...enabled,
        'courseEnabled': false,
        'courseStartsEnabled': false,
        'guestCourseEnabled': false,
      });
      expect(flags.courseEnabled, isFalse);
      expect(flags.canStartCourse, isFalse);
      expect(flags.canStartAsGuest, isFalse);
    });

    test('malformed documents fail closed', () {
      expect(CourseFlags.fromMap(null).courseEnabled, isFalse);
      expect(CourseFlags.fromMap(<String, dynamic>{}).canStartCourse, isFalse);
      expect(
        CourseFlags.fromMap(<String, dynamic>{
          'courseEnabled': true,
          'courseStartsEnabled': true,
        }).courseEnabled,
        isFalse,
      );
      expect(
        CourseFlags.fromMap({...enabled, 'catalogVersion': ''}).courseEnabled,
        isFalse,
      );
    });

    test('fetch failure fails closed', () {
      final flags = CourseFlags.resolve(
        fetched: false,
        data: enabled,
        clientVersion: '2.0.0',
      );
      expect(flags.courseEnabled, isFalse);
      expect(flags.canStartAsGuest, isFalse);
    });

    test('minimum client version disables an otherwise enabled course', () {
      final flags = CourseFlags.resolve(
        fetched: true,
        data: {...enabled, 'minimumClientVersion': '9.0.0'},
        clientVersion: '2.0.0',
      );
      expect(flags.courseEnabled, isFalse);
      expect(flags.canStartCourse, isFalse);
      expect(flags.minimumClientVersion, '9.0.0');
    });

    test('a current client keeps an enabled course', () {
      final flags = CourseFlags.resolve(
        fetched: true,
        data: enabled,
        clientVersion: '2.0.0',
      );
      expect(flags.canStartCourse, isTrue);
      expect(flags.canStartAsGuest, isTrue);
    });
  });
}
