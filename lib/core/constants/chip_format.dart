/// Chip / currency display helpers for stacks, pots, bets, and EV.
library;

/// How monetary amounts are shown across the table UI.
enum ChipDisplayMode {
  /// Dollar amounts only (`$70`).
  dollars,

  /// Big-blind amounts only (`35.0 BB`).
  bb,

  /// Both dollars and BB (`$70 · 35.0 BB`).
  both;

  String get label => switch (this) {
        ChipDisplayMode.dollars => 'Dollars only',
        ChipDisplayMode.bb => 'BB only',
        ChipDisplayMode.both => 'Both (\$ and BB)',
      };
}

/// Formats chip amounts according to [mode] and [bigBlind].
class ChipFormat {
  ChipFormat._();

  /// Formats a dollar figure without the BB suffix.
  static String dollars(double amount) {
    if (amount == amount.roundToDouble()) {
      return '\$${amount.toStringAsFixed(0)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Formats an amount in big blinds.
  static String bb(double amount, double bigBlind, {int? decimals}) {
    if (bigBlind <= 0) return '0 BB';
    final value = amount / bigBlind;
    final places = decimals ?? (value.abs() >= 10 ? 0 : 1);
    return '${value.toStringAsFixed(places)} BB';
  }

  /// Formats [amount] for stacks, pot, bets, and dock labels.
  static String chips(
    double amount,
    double bigBlind,
    ChipDisplayMode mode, {
    int? bbDecimals,
  }) {
    return switch (mode) {
      ChipDisplayMode.dollars => dollars(amount),
      ChipDisplayMode.bb => bb(amount, bigBlind, decimals: bbDecimals),
      ChipDisplayMode.both =>
        '${dollars(amount)} · ${bb(amount, bigBlind, decimals: bbDecimals)}',
    };
  }

  /// Formats an optimal action line, e.g. `RAISE · $70 · 35.0 BB`.
  static String optimalLine({
    required String actionLabel,
    required double sizingBb,
    required double bigBlind,
    required ChipDisplayMode mode,
  }) {
    if (sizingBb <= 0) return actionLabel;
    final dollarsAmt = sizingBb * bigBlind;
    return switch (mode) {
      ChipDisplayMode.dollars =>
        '$actionLabel · ${dollars(dollarsAmt)}',
      ChipDisplayMode.bb =>
        '$actionLabel · ${sizingBb.toStringAsFixed(1)} BB',
      ChipDisplayMode.both =>
        '$actionLabel · ${dollars(dollarsAmt)} · '
            '${sizingBb.toStringAsFixed(1)} BB',
    };
  }

  /// Formats EV delta with dollars and/or BB.
  static String evDelta(
    double evDeltaBb,
    double bigBlind,
    ChipDisplayMode mode,
  ) {
    final sign = evDeltaBb >= 0 ? '+' : '-';
    final absBb = evDeltaBb.abs();
    final bbPart = '$sign${absBb.toStringAsFixed(2)} BB';
    final signedDollars = '$sign${dollars(absBb * bigBlind)}';
    return switch (mode) {
      ChipDisplayMode.dollars => 'EV Δ $signedDollars',
      ChipDisplayMode.bb => 'EV Δ $bbPart',
      ChipDisplayMode.both => 'EV Δ $signedDollars · $bbPart',
    };
  }
}
