/// Online Cloud Functions client for server-authoritative live training.
// ignore_for_file: prefer_initializing_formals
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';

/// App contract version required by the v3 live backend.
const liveClientVersion = '2.0.0';

/// Incremental seat-action feed while the server resolves villains.
@immutable
class LiveActionFeedUpdate {
  /// Creates one feed snapshot.
  const LiveActionFeedUpdate({
    required this.sessionId,
    required this.decisionId,
    required this.events,
    required this.board,
    required this.street,
    required this.status,
    this.waitingOnSeat,
  });

  final String sessionId;
  final String decisionId;
  final List<LiveActionEventModel> events;
  final List<String> board;
  final String street;

  /// `acting` | `coaching` | `done`
  final String status;

  /// Seat currently waiting on an LLM decision, if any.
  final int? waitingOnSeat;

  bool get isCoaching => status == 'coaching';

  factory LiveActionFeedUpdate.fromJson(Map<String, dynamic> json) {
    final rawSeat = json['waitingOnSeat'];
    return LiveActionFeedUpdate(
      sessionId: json['sessionId'] as String? ?? '',
      decisionId: json['decisionId'] as String? ?? '',
      events:
          _maps(
            json['events'],
          ).map(LiveActionEventModel.fromJson).toList(growable: false),
      board:
          (json['board'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(growable: false),
      street: json['street'] as String? ?? 'preflop',
      status: json['status'] as String? ?? 'acting',
      waitingOnSeat: rawSeat is num ? rawSeat.toInt() : null,
    );
  }

  static List<Map<String, dynamic>> _maps(dynamic value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>)
          item
        else if (item is Map)
          item.map((key, nested) => MapEntry('$key', nested)),
    ];
  }
}

/// Cloud callable wrapper with bounded retry for pool/branch preparation.
class LiveHandService {
  /// Creates a live service.
  LiveHandService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.functionsRegion = 'us-central1',
    this.maximumWait = const Duration(minutes: 9),
  }) : _functions = functions,
       _auth = auth,
       _firestore = firestore;

  final FirebaseFunctions? _functions;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final String functionsRegion;
  final Duration maximumWait;

  FirebaseFunctions get _fns =>
      _functions ?? FirebaseFunctions.instanceFor(region: functionsRegion);

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  /// Starts one unseen warmed hand for the current user.
  Future<LiveHandStartResult> startHand(GameSettingsModel settings) async {
    _requireAuth();
    final startRequestId = _requestKey('start');
    final data = await _callWithRetry('startLiveHand', <String, dynamic>{
      'clientVersion': liveClientVersion,
      'startRequestId': startRequestId,
      'tableSetup': <String, dynamic>{
        'mode': 'random',
        'seatCount': settings.seatCount,
        'smallBlind': settings.smallBlind,
        'bigBlind': settings.bigBlind,
        'maxStackDepthBb': settings.maxStackDepthBb,
      },
    });
    return LiveHandStartResult.fromJson(data);
  }

  /// Starts an isolated course warm-up, calibration, or hand lab.
  Future<LiveHandStartResult> startCourseHand({
    required String courseKind,
    String? courseHandId,
    String? handLabSpecId,
    String? attemptId,
    String? activityId,
    String? lessonId,
    String? returnNodeId,
  }) async {
    _requireAuth();
    final startRequestId = _requestKey('course');
    final data = await _callWithRetry('startLiveHand', <String, dynamic>{
      'clientVersion': liveClientVersion,
      'startRequestId': startRequestId,
      'tableSetup': <String, dynamic>{
        'mode': 'course',
        'courseKind': courseKind,
        if (courseHandId != null) 'courseHandId': courseHandId,
        if (handLabSpecId != null) 'handLabSpecId': handLabSpecId,
        if (attemptId != null) 'attemptId': attemptId,
        if (activityId != null) 'activityId': activityId,
        if (lessonId != null) 'lessonId': lessonId,
        if (returnNodeId != null) 'returnNodeId': returnNodeId,
      },
    });
    return LiveHandStartResult.fromJson(data);
  }

  /// Reads Live access tier (also returned on getCourseState).
  Future<Map<String, dynamic>> getLiveAccess() async {
    _requireAuth();
    return _callWithRetry('getLiveAccess', const <String, dynamic>{});
  }

  static String _requestKey(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  /// Submits one exact server-provided action id.
  Future<LiveActionResult> submitAction({
    required LiveHandViewModel view,
    required LiveLegalActionModel action,
    required String idempotencyKey,
  }) async {
    _requireAuth();
    final data = await _callWithRetry('submitLiveAction', <String, dynamic>{
      'sessionId': view.sessionId,
      'handId': view.handId,
      'stateVersion': view.stateVersion,
      'decisionId': view.decisionId,
      'idempotencyKey': idempotencyKey,
      'actionId': action.actionId,
    });
    return LiveActionResult.fromJson(data);
  }

  /// Watches seat actions published while [decisionId] is resolving.
  Stream<LiveActionFeedUpdate> watchActionFeed({
    required String sessionId,
    required String decisionId,
  }) {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('liveActionFeed')
        .doc('current')
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return null;
          return LiveActionFeedUpdate.fromJson(data);
        })
        .where((update) => update != null)
        .cast<LiveActionFeedUpdate>()
        .where(
          (update) =>
              update.sessionId == sessionId && update.decisionId == decisionId,
        );
  }

  /// Restores a session after a dropped request or app interruption.
  Future<LiveHandStartResult> resumeHand(String sessionId) async {
    _requireAuth();
    final data = await _callWithRetry('resumeLiveHand', <String, dynamic>{
      'sessionId': sessionId,
      'clientVersion': liveClientVersion,
    });
    return LiveHandStartResult.fromJson(data);
  }

  /// Rewinds the last Hero decision so coach review can try another branch.
  Future<LiveHandStartResult> undoAction({
    required LiveHandViewModel view,
  }) async {
    _requireAuth();
    final data = await _callWithRetry('undoLiveAction', <String, dynamic>{
      'sessionId': view.sessionId,
      'stateVersion': view.stateVersion,
      'clientVersion': liveClientVersion,
    });
    return LiveHandStartResult.fromJson(data);
  }

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
          throw LiveHandServiceException(
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
        if (error is LiveHandServiceException) rethrow;
        throw LiveHandServiceException(
          'Could not reach the live training server. Check your connection.',
          code: 'unavailable',
          cause: error,
        );
      }
    }
  }

  void _requireAuth() {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw const LiveHandServiceException(
        'Sign in required to train.',
        code: 'unauthenticated',
      );
    }
  }

  static String _message(FirebaseFunctionsException error) {
    final detail = (error.message ?? '').trim();
    return switch (error.code) {
      'failed-precondition' when detail.isNotEmpty => detail,
      'unauthenticated' => 'Sign in required to train.',
      'aborted' => 'The table changed. Resume the hand and try again.',
      'resource-exhausted' => 'Training capacity is temporarily unavailable.',
      _ when detail.isNotEmpty => detail,
      _ => 'Live training request failed (${error.code}).',
    };
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry('$key', item));
    }
    throw const LiveHandServiceException(
      'Training server returned an invalid response.',
      code: 'invalid-response',
    );
  }
}

/// User-facing online live-hand failure.
class LiveHandServiceException implements Exception {
  const LiveHandServiceException(
    this.message, {
    this.code = 'unknown',
    this.cause,
  });

  final String message;
  final String code;
  final Object? cause;

  @override
  String toString() => message;
}
