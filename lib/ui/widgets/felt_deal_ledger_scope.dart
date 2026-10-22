/// Hands a [FeltDealLedger] to every [FeltTableView] below it.
library;

import 'package:flutter/widgets.dart';
import 'package:live_poker_trainer/core/deal/felt_deal_ledger.dart';

/// Felts under this scope resume their deal after a remount instead of
/// dealing the hand again.
class FeltDealLedgerScope extends InheritedWidget {
  /// Creates a scope for [ledger].
  const FeltDealLedgerScope({
    super.key,
    required this.ledger,
    required super.child,
  });

  /// Deal progress shared by every felt in this subtree.
  final FeltDealLedger ledger;

  /// The nearest ledger, without registering a rebuild dependency (safe from
  /// `initState`).
  static FeltDealLedger? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FeltDealLedgerScope>()?.ledger;

  @override
  bool updateShouldNotify(FeltDealLedgerScope oldWidget) =>
      !identical(ledger, oldWidget.ledger);
}

/// Which felt cards already landed in the current deal.
///
/// Cards that mount while [settled] is true (first frame of a resumed felt),
/// or whose key already landed in this deal, appear in place: no fade/scale
/// and no deal SFX. That covers a remount of the whole felt (ledger resume)
/// and a remount of just a card or a seat row inside it (a key or structure
/// change on lock — the #1582 class of replay).
class DealtCardRevealSettledScope extends InheritedWidget {
  /// Creates the scope.
  const DealtCardRevealSettledScope({
    super.key,
    required this.settled,
    required this.landed,
    required super.child,
  });

  /// True only during the first frame of a resumed felt.
  final bool settled;

  /// Keys of cards that already finished landing this deal (owned by the
  /// felt; cleared when a new hand is dealt).
  final Set<Key> landed;

  static DealtCardRevealSettledScope? _of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DealtCardRevealSettledScope>();

  /// Whether a card with [key] mounting at [context] was already dealt.
  static bool settledAt(BuildContext context, Key? key) {
    final scope = _of(context);
    if (scope == null) return false;
    return scope.settled || (key != null && scope.landed.contains(key));
  }

  /// Records that the card with [key] landed.
  static void markLanded(BuildContext context, Key? key) {
    if (key == null) return;
    _of(context)?.landed.add(key);
  }

  @override
  bool updateShouldNotify(DealtCardRevealSettledScope oldWidget) =>
      settled != oldWidget.settled || !identical(landed, oldWidget.landed);
}
