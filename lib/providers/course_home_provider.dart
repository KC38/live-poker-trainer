/// Home course map state from getCourseState + bundled catalog.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_hearts.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

/// Loads and derives the Home course map for the signed-in user.
final courseHomeProvider =
    AsyncNotifierProvider<CourseHomeController, CourseHomeSnapshot>(
      CourseHomeController.new,
    );

/// Fetches server course state and builds a [CourseHomeSnapshot].
class CourseHomeController extends AsyncNotifier<CourseHomeSnapshot> {
  Timer? _passiveRefillTimer;

  @override
  Future<CourseHomeSnapshot> build() async {
    ref.onDispose(() {
      _passiveRefillTimer?.cancel();
      _passiveRefillTimer = null;
    });
    final snapshot = await _load();
    _schedulePassiveRefill(snapshot);
    return snapshot;
  }

  Future<CourseHomeSnapshot> _load() async {
    final uid = ref.watch(authUidProvider);
    final catalog = await ref.watch(courseCatalogProvider.future);
    if (uid == null || uid.isEmpty) {
      return CourseHomeSnapshot(
        status: CourseHomeLoadStatus.error,
        nodes: const [],
        sections: catalog.sections,
        errorMessage: 'Sign in to load your course path.',
        rexLine: 'Sign in so I can load your path.',
      );
    }
    final service = ref.watch(courseServiceProvider);
    try {
      final raw = await service.getCourseState(
        catalogVersion: catalog.catalogVersion,
      );
      return snapshotFromCourseState(catalog: catalog, raw: raw);
    } on CourseServiceException catch (error) {
      final offline =
          error.code == 'unavailable' || error.code == 'deadline-exceeded';
      return buildCourseHomeSnapshot(
        catalog: catalog,
        flags: CourseFlags.disabled(catalogVersion: catalog.catalogVersion),
        available: false,
        offline: offline,
        errorMessage: error.message,
      );
    }
  }

  /// Reloads course state from the server without blanking the Home map.
  ///
  /// Keeps the previous [CourseHomeSnapshot] visible while the fetch runs so
  /// heart / gem updates do not flash the full-screen loading state.
  Future<void> refresh() async {
    final previous = state;
    if (previous.hasValue) {
      state = const AsyncLoading<CourseHomeSnapshot>().copyWithPrevious(
        previous,
      );
    }
    final next = await AsyncValue.guard(_load);
    state = next;
    final snap = next.valueOrNull;
    if (snap != null) {
      _schedulePassiveRefill(snap);
    }
  }

  /// Patches heart / gem fields from a refill response without a full reload.
  void applyHeartRefill(RefillCourseHeartsResult result) {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.withHeartState(
      hearts: result.livesRemaining,
      livesMax: result.livesMax,
      gems: result.gems,
      livesNextRefillAtMs: result.livesNextRefillAtMs,
      nextAdClaimAtMs: result.nextAdClaimAtMs,
      adClaimsRemainingToday: result.adClaimsRemainingToday,
    );
    state = AsyncData(next);
    _schedulePassiveRefill(next);
  }

  /// Records the heart wallet from a graded step without reloading the path.
  void applyStepHeartWallet({
    required int livesRemaining,
    required int livesMax,
    int? livesNextRefillAtMs,
  }) {
    final current = state.valueOrNull;
    if (current == null || current.status != CourseHomeLoadStatus.ready) {
      return;
    }
    final ceiling = livesMax > 0 ? livesMax : current.livesMax;
    final next = current.withHeartState(
      hearts: livesRemaining.clamp(0, ceiling).toInt(),
      livesMax: ceiling,
      gems: current.gems,
      livesNextRefillAtMs: livesNextRefillAtMs,
      nextAdClaimAtMs: current.nextAdClaimAtMs,
      adClaimsRemainingToday: current.adClaimsRemainingToday,
    );
    state = AsyncData(next);
    _schedulePassiveRefill(next);
  }

  /// Applies due passive hearts locally, then soft-syncs with the server.
  void applyDuePassiveRefill({int? nowMs}) {
    final current = state.valueOrNull;
    if (current == null) return;
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final accrued = applyPassiveHeartRefill(
      livesRemaining: current.hearts,
      livesMax: current.livesMax,
      livesNextRefillAtMs: current.livesNextRefillAtMs,
      nowMs: now,
    );
    if (!accrued.changed || accrued.heartsRestored <= 0) {
      _schedulePassiveRefill(current, nowMs: now);
      return;
    }
    final next = current.withHeartState(
      hearts: accrued.livesRemaining,
      livesMax: accrued.livesMax,
      gems: current.gems,
      livesNextRefillAtMs: accrued.livesNextRefillAtMs,
      nextAdClaimAtMs: current.nextAdClaimAtMs,
      adClaimsRemainingToday: current.adClaimsRemainingToday,
    );
    state = AsyncData(next);
    _schedulePassiveRefill(next, nowMs: now);
    // Persist accrual on the server without blanking the map.
    unawaited(refresh());
  }

  void _schedulePassiveRefill(CourseHomeSnapshot snapshot, {int? nowMs}) {
    _passiveRefillTimer?.cancel();
    _passiveRefillTimer = null;
    final nextAt = snapshot.livesNextRefillAtMs;
    if (nextAt == null || snapshot.hearts >= snapshot.livesMax) return;
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final delayMs = nextAt - now;
    if (delayMs <= 0) {
      // Fire on the next microtask so callers can finish assigning state first.
      scheduleMicrotask(() => applyDuePassiveRefill(nowMs: now));
      return;
    }
    _passiveRefillTimer = Timer(Duration(milliseconds: delayMs), () {
      applyDuePassiveRefill();
    });
  }
}

/// Pure mapping from getCourseState JSON → Home snapshot (tests inject this).
CourseHomeSnapshot snapshotFromCourseState({
  required CourseCatalog catalog,
  required Map<String, dynamic> raw,
}) {
  final available = raw['available'] == true;
  final flagsRaw = raw['flags'];
  final flags = flagsRaw is Map
      ? CourseFlags.fromMap(Map<String, dynamic>.from(flagsRaw))
      : CourseFlags.disabled(catalogVersion: catalog.catalogVersion);

  CourseProfileView? profile;
  final profileRaw = raw['profile'];
  if (profileRaw is Map) {
    profile = CourseProfileView.fromJson(Map<String, dynamic>.from(profileRaw));
  }

  CourseAttemptSnapshot? openAttempt;
  final openRaw = raw['openAttempt'];
  if (openRaw is Map) {
    openAttempt = CourseAttemptSnapshot.fromJson(
      Map<String, dynamic>.from(openRaw),
    );
  }

  final reviewIds = <String>[];
  final reviewsRaw = raw['reviewsDue'];
  if (reviewsRaw is List) {
    for (final item in reviewsRaw) {
      if (item is Map) {
        final lessonId = item['lessonId']?.toString();
        if (lessonId != null && lessonId.isNotEmpty) {
          reviewIds.add(lessonId);
        }
      }
    }
  }

  return buildCourseHomeSnapshot(
    catalog: catalog,
    flags: flags,
    available: available,
    profile: profile,
    openAttempt: openAttempt,
    reviewLessonIds: reviewIds,
  );
}
