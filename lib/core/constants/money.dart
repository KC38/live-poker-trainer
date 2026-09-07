/// Money math helpers keeping chip amounts exact and range math crash-safe.
///
/// All chip amounts in the engine are `double` dollars. Repeated pot splits and
/// percentage-of-pot sizing introduce binary floating point dust (e.g.
/// `450.99999999999994`), which then leaks into UI range math. Rounding every
/// amount to whole cents at the boundaries keeps stacks, pots, and bets exact.
library;

/// Chip amount rounding and safe numeric range helpers.
class Money {
  Money._();

  /// Smallest representable chip fraction (one cent).
  static const double epsilon = 0.005;

  /// Rounds [amount] to whole cents, normalizing `-0.0` to `0.0`.
  static double round(double amount) {
    if (!amount.isFinite) return 0;
    final cents = (amount * 100).roundToDouble();
    final value = cents / 100;
    return value == 0 ? 0 : value;
  }

  /// Rounds [amount] to whole cents and clamps away negative dust.
  static double roundNonNegative(double amount) {
    final value = round(amount);
    return value < 0 ? 0 : value;
  }

  /// Clamps [value] into `[lower, upper]` without throwing when the range is
  /// inverted or non-finite.
  ///
  /// `num.clamp` throws `ArgumentError(lower)` when `lower > upper`, which is
  /// how a short-stacked hero facing an un-raisable bet used to crash the
  /// action dock with `Invalid argument(s): 451.0`.
  static double clamp(double value, double lower, double upper) {
    if (!value.isFinite) return _safe(lower);
    final lo = _safe(lower);
    final hi = _safe(upper);
    if (hi <= lo) return lo;
    if (value < lo) return lo;
    if (value > hi) return hi;
    return value;
  }

  /// Whether [a] and [b] are the same amount to the cent.
  static bool same(double a, double b) => (a - b).abs() < epsilon;

  /// Whether [a] is at least [b] to the cent.
  static bool atLeast(double a, double b) => a >= b - epsilon;

  static double _safe(double value) => value.isFinite ? value : 0;
}
