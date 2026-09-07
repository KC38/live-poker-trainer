/// Chip / currency display helpers for stacks, pots, bets, and EV.
library;

import 'package:live_poker_trainer/core/constants/money.dart';

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

  /// Mode used on the live felt, where dual amounts on every seat, the pot,
  /// and each bet make the table unreadable.
  ///
  /// `both` collapses to currency only; an explicit `bb` choice is respected
  /// because a single unit is still uncluttered. Hand review, stats, and table
  /// setup keep the user's full choice.
  ChipDisplayMode get tableMode =>
      this == ChipDisplayMode.both ? ChipDisplayMode.dollars : this;
}

/// Formats chip amounts according to [mode] and [bigBlind].
class ChipFormat {
  ChipFormat._();

  /// Formats a dollar figure without the BB suffix.
  static String dollars(double amount) {
    final value = Money.round(amount);
    if (value == value.roundToDouble()) {
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
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

  /// Whether [actionLabel] is a sized aggression line (bet / raise / all-in).
  static bool isSizedAction(String actionLabel) {
    final upper = actionLabel.trim().toUpperCase();
    return upper == 'RAISE' || upper == 'BET' || upper == 'ALL-IN';
  }

  /// Formats an action + size line, e.g. `RAISE · $70`.
  ///
  /// Sizing is appended only for bet/raise/all-in when [sizingBb] is positive.
  /// Passive actions (fold / check / call) stay label-only.
  static String optimalLine({
    required String actionLabel,
    required double sizingBb,
    required double bigBlind,
    required ChipDisplayMode mode,
  }) {
    if (sizingBb <= 0 || !isSizedAction(actionLabel)) {
      return actionLabel;
    }
    final amount = chips(sizingBb * bigBlind, bigBlind, mode);
    return '$actionLabel · $amount';
  }

  /// Signed EV amount only (no "EV Δ" prefix) for coach stats cells.
  static String evDeltaAmount(
    double evDeltaBb,
    double bigBlind,
    ChipDisplayMode mode,
  ) {
    final sign = evDeltaBb >= 0 ? '+' : '-';
    final absBb = evDeltaBb.abs();
    final bbPart = '$sign${absBb.toStringAsFixed(2)} BB';
    final signedDollars = '$sign${dollars(absBb * bigBlind)}';
    return switch (mode) {
      ChipDisplayMode.dollars => signedDollars,
      ChipDisplayMode.bb => bbPart,
      ChipDisplayMode.both => '$signedDollars · $bbPart',
    };
  }

  /// Formats EV delta with dollars and/or BB.
  static String evDelta(
    double evDeltaBb,
    double bigBlind,
    ChipDisplayMode mode,
  ) {
    return 'EV Δ ${evDeltaAmount(evDeltaBb, bigBlind, mode)}';
  }
}
