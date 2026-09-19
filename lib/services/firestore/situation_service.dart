/// Cloud Functions callables for server-authored training situations.
///
/// No offline fallback — callers must handle network / auth failures.
// ignore_for_file: prefer_initializing_formals
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/models/table_setup.dart';

/// Exact server signal indicating that pool generation is in progress.
const poolGeneratingUnavailableMessage =
    'Situation pool is generating. Retry in a moment.';

/// Returns whether an unavailable response explicitly represents generation.
bool shouldRetryPoolGeneration({
  required String code,
  required String? message,
}) {
  return code == 'unavailable' &&
      message?.trim() == poolGeneratingUnavailableMessage;
}

/// Returns the exponential retry delay for a zero-based [retryIndex].
Duration poolGenerationRetryDelay(
  int retryIndex, {
  Duration initialDelay = const Duration(seconds: 1),
  Duration maximumDelay = const Duration(seconds: 5),
}) {
  if (retryIndex < 0) {
    throw ArgumentError.value(retryIndex, 'retryIndex', 'must be non-negative');
  }

  var delay = initialDelay;
  for (var index = 0; index < retryIndex && delay < maximumDelay; index++) {
    final doubled = delay * 2;
    delay = doubled > maximumDelay ? maximumDelay : doubled;
  }
  return delay > maximumDelay ? maximumDelay : delay;
}

/// Returns whether another delay fits inside the bounded polling window.
bool canRetryPoolGeneration({
  required Duration elapsed,
  required Duration nextDelay,
  required Duration maximumWait,
}) {
  return elapsed + nextDelay <= maximumWait;
}

/// Fetches situations and records progress via HTTPS callables.
class SituationService {
  /// Creates a service.
  SituationService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    this.functionsRegion = 'us-central1',
    this.initialPreparingRetryDelay = const Duration(seconds: 1),
    this.maximumPreparingRetryDelay = const Duration(seconds: 5),
    this.maximumPreparingWait = const Duration(minutes: 9),
  }) : _functions = functions,
       _auth = auth;

  final FirebaseFunctions? _functions;
  final FirebaseAuth? _auth;
  final String functionsRegion;
  final Duration initialPreparingRetryDelay;
  final Duration maximumPreparingRetryDelay;
  final Duration maximumPreparingWait;

  FirebaseFunctions get _fns =>
      _functions ?? FirebaseFunctions.instanceFor(region: functionsRegion);

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  void _requireAuth() {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw SituationServiceException(
        'Sign in required to train.',
        code: 'unauthenticated',
      );
    }
  }

  /// Fetches a branching situation for [setup].
  ///
  /// Sends `{ tableSetup: ... }` per the live Functions contract.
  Future<FetchedSituation> fetchSituation(TableSetup setup) async {
    _requireAuth();
    final callable = _fns.httpsCallable('fetchSituation');
    final pollingClock = Stopwatch()..start();
    for (var retryIndex = 0; ; retryIndex++) {
      try {
        final result = await callable.call(<String, dynamic>{
          'tableSetup': setup.toCallableMap(),
        });
        final data = _asStringKeyedMap(result.data);
        if (data == null) {
          throw SituationServiceException(
            'fetchSituation returned an empty payload.',
            code: 'invalid-response',
          );
        }
        final fetched = FetchedSituation.fromCallable(data);
        if (fetched.situation.nodes.isEmpty ||
            fetched.situation.rootNodeId.isEmpty) {
          throw SituationServiceException(
            'fetchSituation returned an incomplete situation.',
            code: 'invalid-response',
          );
        }
        return fetched;
      } on SituationServiceException {
        rethrow;
      } on FirebaseFunctionsException catch (e) {
        final nextDelay = poolGenerationRetryDelay(
          retryIndex,
          initialDelay: initialPreparingRetryDelay,
          maximumDelay: maximumPreparingRetryDelay,
        );
        if (shouldRetryPoolGeneration(code: e.code, message: e.message) &&
            canRetryPoolGeneration(
              elapsed: pollingClock.elapsed,
              nextDelay: nextDelay,
              maximumWait: maximumPreparingWait,
            )) {
          await Future<void>.delayed(nextDelay);
          continue;
        }
        throw SituationServiceException(_functionsMessage(e), code: e.code);
      } catch (e) {
        throw SituationServiceException(
          'Could not reach the training server. Check your connection and retry.',
          code: 'unavailable',
          cause: e,
        );
      }
    }
  }

  /// Records a completed path against the allocated situation receipt.
  ///
  /// Fields match `RecordProgressInput` in `situation_types.ts`.
  Future<void> recordSituationProgress({
    required String situationId,
    required String setupKey,
    required List<String> pathNodeIds,
    required List<String> chosenActionKeys,
    required String terminalNodeId,
    required double heroNetChips,
    String? notes,
  }) async {
    _requireAuth();
    try {
      final callable = _fns.httpsCallable('recordSituationProgress');
      final payload = <String, dynamic>{
        'situationId': situationId,
        'setupKey': setupKey,
        'pathNodeIds': pathNodeIds,
        'chosenActionKeys': chosenActionKeys,
        'terminalNodeId': terminalNodeId,
        'heroNetChips': heroNetChips,
      };
      if (notes != null && notes.isNotEmpty) {
        payload['notes'] = notes;
      }
      await callable.call(payload);
    } on SituationServiceException {
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      throw SituationServiceException(_functionsMessage(e), code: e.code);
    } catch (e) {
      throw SituationServiceException(
        'Could not save progress. Check your connection and retry.',
        code: 'unavailable',
        cause: e,
      );
    }
  }

  static String _functionsMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Sign in required to train.';
      case 'permission-denied':
        return 'You do not have permission to train right now.';
      case 'resource-exhausted':
        return 'Training is temporarily rate-limited. Try again shortly.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Training server unavailable. Check your connection and retry.';
      case 'failed-precondition':
        return (e.message ?? '').trim().isNotEmpty
            ? e.message!.trim()
            : 'Training is not ready yet. Retry in a moment.';
      default:
        final details = (e.message ?? '').trim();
        if (details.isNotEmpty) return details;
        return 'Training request failed (${e.code}).';
    }
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry('$k', v));
    }
    return null;
  }
}

/// Clear, user-facing failure from [SituationService].
class SituationServiceException implements Exception {
  /// Creates an exception.
  SituationServiceException(this.message, {this.code = 'unknown', this.cause});

  final String message;
  final String code;
  final Object? cause;

  @override
  String toString() => message;
}
