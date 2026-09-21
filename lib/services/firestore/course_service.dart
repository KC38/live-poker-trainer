/// Cloud Functions client for course attempts and soft grading.
// ignore_for_file: prefer_initializing_formals
library;

import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/services/firestore/live_hand_service.dart';

/// Course callable wrapper with bounded retry and stable idempotency keys.
class CourseService {
  /// Creates a course service.
  CourseService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    this.functionsRegion = 'us-central1',
    this.maximumWait = const Duration(minutes: 2),
  }) : _functions = functions,
       _auth = auth;

  final FirebaseFunctions? _functions;
  final FirebaseAuth? _auth;
  final String functionsRegion;
  final Duration maximumWait;

  FirebaseFunctions get _fns =>
      _functions ?? FirebaseFunctions.instanceFor(region: functionsRegion);

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  /// App contract version shared with live training.
  static const clientVersion = liveClientVersion;

  /// Initializes the course profile document when missing.
  ///
  /// Optional onboarding fields are written only when the profile is new or
  /// the field is still empty server-side.
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {
    _requireAuth();
    await _callWithRetry('initializeCourseProfile', <String, dynamic>{
      'clientVersion': clientVersion,
      'catalogVersion': catalogVersion,
      'timezone': timezone,
      if (experienceBand != null) 'experienceBand': experienceBand,
      if (dailyGoalMinutes != null) 'dailyGoalMinutes': dailyGoalMinutes,
      if (recommendedLessonId != null) 'recommendedLessonId': recommendedLessonId,
    });
  }

  /// Starts or resumes a lesson attempt.
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    _requireAuth();
    final data = await _callWithRetry('startCourseLesson', <String, dynamic>{
      'clientVersion': clientVersion,
      'lessonId': lessonId,
      'catalogVersion': catalogVersion,
      'startRequestId': startRequestId,
      'timezone': timezone,
    });
    return StartCourseLessonResult.fromJson(data);
  }

  /// Submits one activity response. Reuse [idempotencyKey] on network retry.
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    _requireAuth();
    final payload = <String, dynamic>{
      'clientVersion': clientVersion,
      'attemptId': attemptId,
      'activityId': activityId,
      'idempotencyKey': idempotencyKey,
      if (catalogVersion != null) 'catalogVersion': catalogVersion,
      if (choiceId != null) 'choiceId': choiceId,
      if (orderedIds != null) 'orderedIds': orderedIds,
      if (numericValue != null) 'numericValue': numericValue,
    };
    final data = await _callWithRetry('submitCourseStep', payload);
    return SubmitCourseStepResult.fromJson(data);
  }

  /// Completes a finished attempt (idempotent).
  Future<CompleteCourseLessonResult> completeLesson({
    required String attemptId,
    required String idempotencyKey,
    String? catalogVersion,
  }) async {
    _requireAuth();
    final data = await _callWithRetry('completeCourseLesson', <String, dynamic>{
      'clientVersion': clientVersion,
      'attemptId': attemptId,
      'idempotencyKey': idempotencyKey,
      if (catalogVersion != null) 'catalogVersion': catalogVersion,
    });
    return CompleteCourseLessonResult.fromJson(data);
  }

  /// Loads profile + resume pointer.
  Future<Map<String, dynamic>> getCourseState({String? catalogVersion}) async {
    _requireAuth();
    return _callWithRetry('getCourseState', <String, dynamic>{
      'clientVersion': clientVersion,
      if (catalogVersion != null) 'catalogVersion': catalogVersion,
    });
  }

  /// Issues a short-lived anonymous progress transfer receipt.
  Future<Map<String, dynamic>> issueAnonymousProgressTransfer({
    String? catalogVersion,
  }) async {
    _requireAuth();
    return _callWithRetry('issueAnonymousProgressTransfer', <String, dynamic>{
      'clientVersion': clientVersion,
      if (catalogVersion != null) 'catalogVersion': catalogVersion,
    });
  }

  /// Redeems a transfer into the current permanent account.
  Future<Map<String, dynamic>> redeemAnonymousProgressTransfer({
    required String receiptId,
    required String nonce,
  }) async {
    _requireAuth();
    return _callWithRetry('redeemAnonymousProgressTransfer', <String, dynamic>{
      'clientVersion': clientVersion,
      'receiptId': receiptId,
      'nonce': nonce,
    });
  }

  /// Stable client-generated key for starts and submissions.
  static String newRequestKey(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_'
      '${UniqueKeySeed.next()}';

  Future<Map<String, dynamic>> _callWithRetry(
    String callableName,
    Map<String, dynamic> payload,
  ) async {
    final watch = Stopwatch()..start();
    var delay = const Duration(seconds: 1);
    for (;;) {
      try {
        final response = await _fns.httpsCallable(callableName).call(payload);
        return _map(response.data);
      } on FirebaseFunctionsException catch (error) {
        final retryable =
            error.code == 'unavailable' || error.code == 'deadline-exceeded';
        if (!retryable || watch.elapsed + delay > maximumWait) {
          throw CourseServiceException(
            _message(error),
            code: error.code,
            cause: error,
          );
        }
        await Future<void>.delayed(delay);
        final doubled = delay * 2;
        delay =
            doubled > const Duration(seconds: 5)
                ? const Duration(seconds: 5)
                : doubled;
      } catch (error) {
        if (error is CourseServiceException) rethrow;
        throw CourseServiceException(
          'Could not reach the course server. Check your connection.',
          code: 'unavailable',
          cause: error,
        );
      }
    }
  }

  void _requireAuth() {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw const CourseServiceException(
        'Sign in required for course lessons.',
        code: 'unauthenticated',
      );
    }
  }

  static String _message(FirebaseFunctionsException error) {
    final details = error.message?.trim();
    if (details != null && details.isNotEmpty) return details;
    return 'Course request failed (${error.code}).';
  }

  static Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }
    throw const CourseServiceException(
      'Unexpected course response shape.',
      code: 'internal',
    );
  }
}

/// Simple monotonic seed for request keys (tests can reset).
class UniqueKeySeed {
  static int _n = 0;

  /// Next counter value.
  static int next() => ++_n;

  /// Test helper.
  @visibleForTesting
  static void reset() => _n = 0;
}

/// Course callable failure.
class CourseServiceException implements Exception {
  /// Creates an exception.
  const CourseServiceException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'CourseServiceException($code): $message';
}
