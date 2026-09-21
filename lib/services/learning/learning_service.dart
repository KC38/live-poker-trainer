/// HTTPS callable wrappers for the learning platform.
///
/// Callables (`startLesson`, `completeLesson`, `getLearningState`) are planned
/// on the Functions side; this client facade matches that contract so the UI
/// can wire early behind feature flags.
// ignore_for_file: prefer_initializing_formals
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin facade over learning Cloud Functions callables.
class LearningService {
  /// Creates a service. Optional overrides support tests.
  LearningService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    this.functionsRegion = 'us-central1',
  })  : _functions = functions,
        _auth = auth;

  final FirebaseFunctions? _functions;
  final FirebaseAuth? _auth;

  /// Functions region (must match deployed callables).
  final String functionsRegion;

  FirebaseFunctions get _fns =>
      _functions ?? FirebaseFunctions.instanceFor(region: functionsRegion);

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  void _requireAuth() {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw LearningServiceException(
        'Sign in required for learning.',
        code: 'unauthenticated',
      );
    }
  }

  /// Starts a lesson attempt for [lessonId].
  Future<Map<String, dynamic>> startLesson({required String lessonId}) async {
    _requireAuth();
    return _call('startLesson', <String, dynamic>{'lessonId': lessonId});
  }

  /// Completes a lesson attempt with [payload] (scores, answers, timing).
  Future<Map<String, dynamic>> completeLesson({
    required String lessonId,
    Map<String, dynamic> payload = const {},
  }) async {
    _requireAuth();
    return _call('completeLesson', <String, dynamic>{
      'lessonId': lessonId,
      ...payload,
    });
  }

  /// Returns the learner's progress / next-activity snapshot.
  Future<Map<String, dynamic>> getLearningState() async {
    _requireAuth();
    return _call('getLearningState', <String, dynamic>{});
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _fns.httpsCallable(name).call(data);
      final raw = result.data;
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      return <String, dynamic>{'data': raw};
    } on FirebaseFunctionsException catch (e) {
      throw LearningServiceException(
        e.message ?? 'Learning request failed.',
        code: e.code,
      );
    }
  }
}

/// Typed failure from [LearningService].
class LearningServiceException implements Exception {
  /// Creates an exception.
  LearningServiceException(this.message, {this.code});

  /// Human-readable message.
  final String message;

  /// Functions / auth error code when available.
  final String? code;

  @override
  String toString() =>
      code == null ? message : 'LearningServiceException($code): $message';
}
