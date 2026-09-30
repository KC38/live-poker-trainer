/// Client-side course heart math (mirrors functions/src/course_hearts.ts).
library;

/// Max hearts on a course profile.
const int kDefaultLessonLives = 5;

/// One heart every six hours (matches server [HEART_REFILL_INTERVAL_MS]).
const Duration kHeartRefillInterval = Duration(hours: 6);

/// Result of applying passive time-based heart accrual locally.
class PassiveHeartRefillResult {
  /// Creates a passive refill result.
  const PassiveHeartRefillResult({
    required this.livesRemaining,
    required this.livesMax,
    required this.livesNextRefillAtMs,
    required this.heartsRestored,
    required this.changed,
  });

  /// Hearts after accrual.
  final int livesRemaining;

  /// Heart ceiling.
  final int livesMax;

  /// Next refill epoch ms, or null when full.
  final int? livesNextRefillAtMs;

  /// How many hearts were added.
  final int heartsRestored;

  /// Whether any field changed from the input.
  final bool changed;
}

/// Accrues +1 heart per elapsed refill interval while below the ceiling.
///
/// Clears the timer when full; starts one when below max with no timer.
PassiveHeartRefillResult applyPassiveHeartRefill({
  required int livesRemaining,
  required int livesMax,
  required int? livesNextRefillAtMs,
  required int nowMs,
  Duration interval = kHeartRefillInterval,
}) {
  final ceiling = livesMax > 0 ? livesMax : kDefaultLessonLives;
  var remaining = livesRemaining.clamp(0, ceiling);
  var nextAt = livesNextRefillAtMs;
  var restored = 0;
  final intervalMs = interval.inMilliseconds;

  if (remaining >= ceiling) {
    final changed =
        remaining != livesRemaining ||
        ceiling != livesMax ||
        nextAt != null;
    return PassiveHeartRefillResult(
      livesRemaining: ceiling,
      livesMax: ceiling,
      livesNextRefillAtMs: null,
      heartsRestored: 0,
      changed: changed,
    );
  }

  nextAt ??= nowMs + intervalMs;

  while (remaining < ceiling && nextAt != null && nowMs >= nextAt) {
    remaining += 1;
    restored += 1;
    if (remaining >= ceiling) {
      nextAt = null;
    } else {
      nextAt = nextAt + intervalMs;
    }
  }

  final changed =
      remaining != livesRemaining ||
      ceiling != livesMax ||
      nextAt != livesNextRefillAtMs;
  return PassiveHeartRefillResult(
    livesRemaining: remaining,
    livesMax: ceiling,
    livesNextRefillAtMs: nextAt,
    heartsRestored: restored,
    changed: changed,
  );
}
