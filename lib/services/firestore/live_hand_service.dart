/// Online Cloud Functions client for server-authoritative live training.
// ignore_for_file: prefer_initializing_formals
library;

import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';

/// App contract version required by the v3 live backend.
const liveClientVersion = '2.0.0';

/// Cloud callable wrapper with bounded retry for pool/branch preparation.
class LiveHandService {
  /// Creates a live service.
  LiveHandService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    this.functionsRegion = 'us-central1',
    this.maximumWait = const Duration(minutes: 9),
  }) : _functions = functions,
       _auth = auth;

  final FirebaseFunctions? _functions;
  final FirebaseAuth? _auth;
  final String functionsRegion;
  final Duration maximumWait;

  FirebaseFunctions get _fns =>
      _functions ?? FirebaseFunctions.instanceFor(region: functionsRegion);

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

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

  /// Restores a session after a dropped request or app interruption.
  Future<LiveHandStartResult> resumeHand(String sessionId) async {
    _requireAuth();
    final data = await _callWithRetry('resumeLiveHand', <String, dynamic>{
      'sessionId': sessionId,
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
