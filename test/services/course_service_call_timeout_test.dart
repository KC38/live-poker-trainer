/// Course callables must time out before the lesson screen's start budget.
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

void main() {
  test('default per-call timeout is shorter than the SDK 60s default', () {
    expect(CourseService().callTimeout, lessThan(const Duration(seconds: 45)));
  });

  test('every callable is built with the configured timeout', () async {
    final functions = _RecordingFunctions();
    final service = CourseService(
      functions: functions,
      auth: MockFirebaseAuth(signedIn: true),
      callTimeout: const Duration(seconds: 7),
    );

    await service.getCourseState();

    expect(functions.calls, ['getCourseState']);
    expect(functions.timeouts, [const Duration(seconds: 7)]);
  });
}

class _RecordingFunctions extends Fake implements FirebaseFunctions {
  final List<String> calls = [];
  final List<Duration?> timeouts = [];

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    calls.add(name);
    timeouts.add(options?.timeout);
    return _OkCallable();
  }
}

class _OkCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return _Result<T>(<String, dynamic>{} as T);
  }
}

class _Result<T> extends Fake implements HttpsCallableResult<T> {
  _Result(this.data);

  @override
  final T data;
}
