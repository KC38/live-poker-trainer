/// Sequential post-deal action badges (folds before later seats act).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/models/game_state.dart';

/// One seat's last action, in the order that seat would act.
typedef FeltPostDealAction = ({int seat, String label});

/// Actions that happen after the hole cards are out, in preflop act order.
///
/// Blinds post before the deal, so `BLIND` is omitted. Folded seats with no
/// label still count as a fold so early-fold lesson seats play in order.
List<FeltPostDealAction> postDealActionsInOrder(GameState game) {
  final n = game.players.length;
  if (n == 0) return const [];
  final first = (game.bbIndex + 1) % n;
  final actions = <FeltPostDealAction>[];
  for (var i = 0; i < n; i++) {
    final seat = (first + i) % n;
    final player = game.players[seat];
    final raw = player.lastActionLabel?.trim() ?? '';
    if (raw.isEmpty) {
      if (player.folded) {
        actions.add((seat: seat, label: 'FOLD'));
      }
      continue;
    }
    final label = raw.toUpperCase().replaceAll('_', '-');
    if (label == 'BLIND') continue;
    actions.add((seat: seat, label: label));
  }
  return actions;
}

/// Holds last-action badges until hole cards land, then pops them in order.
///
/// Lesson spots snapshot UTG/HJ already folded. Live play applies actions
/// after the deal; those later labels skip the opening sequence and show
/// immediately so replay pacing is not doubled.
class FeltActionRevealController extends ChangeNotifier {
  /// Creates a reveal controller. [onRevealed] fires once per opening-batch
  /// action (for SFX).
  FeltActionRevealController({this.onRevealed});

  /// Called when an opening-batch action badge becomes visible.
  final void Function(int seatIndex, String label)? onRevealed;

  String _epoch = '';
  var _sequence = false;
  var _batchLocked = false;
  var _running = false;
  List<int> _order = [];
  List<int> _batch = [];
  final Map<int, String> _labels = {};
  final Set<int> _revealed = {};
  Timer? _timer;

  /// True when opening-deal action badges should wait on the hole cards.
  bool get isSequencing => _sequence;

  /// True when every action that was present at hole-card complete is up.
  bool get openingBatchComplete {
    if (!_sequence) return true;
    if (!_batchLocked) return false;
    for (final seat in _batch) {
      if (!_revealed.contains(seat)) return false;
    }
    return true;
  }

  /// Whether [seatIndex] may show its snapshot last-action / folded state.
  bool isRevealed(int seatIndex) {
    if (!_sequence) return true;
    if (!_order.contains(seatIndex)) return true;
    return _revealed.contains(seatIndex);
  }

  /// Syncs the current hand. A new [epoch] with holes still going out starts
  /// a sequence; holes already complete (flop/turn/instant) show actions now.
  void bind({
    required String epoch,
    required bool holesComplete,
    required List<FeltPostDealAction> actions,
  }) {
    if (CardDealPace.instant) {
      _stopTimer();
      _epoch = epoch;
      _sequence = false;
      _batchLocked = true;
      _order = [for (final action in actions) action.seat];
      _batch = List<int>.from(_order);
      _labels
        ..clear()
        ..addEntries(
          actions.map((action) => MapEntry(action.seat, action.label)),
        );
      _revealed
        ..clear()
        ..addAll(_order);
      notifyListeners();
      return;
    }

    if (epoch != _epoch) {
      _stopTimer();
      _epoch = epoch;
      _revealed.clear();
      _batch = [];
      _batchLocked = false;
      _sequence = !holesComplete;
      _running = false;
    }

    _order = [for (final action in actions) action.seat];
    _labels
      ..clear()
      ..addEntries(
        actions.map((action) => MapEntry(action.seat, action.label)),
      );

    if (!_sequence) {
      _revealed
        ..clear()
        ..addAll(_order);
      _batchLocked = true;
      _batch = List<int>.from(_order);
      notifyListeners();
      return;
    }

    if (!holesComplete) {
      notifyListeners();
      return;
    }

    if (!_batchLocked) {
      _batchLocked = true;
      _batch = List<int>.from(_order);
      notifyListeners();
      _kick();
      return;
    }

    var changed = false;
    for (final seat in _order) {
      if (!_batch.contains(seat) && _revealed.add(seat)) {
        changed = true;
      }
    }
    if (changed) notifyListeners();
    _kick();
  }

  void _kick() {
    if (_running) return;
    if (!_pending) return;
    _running = true;
    _timer?.cancel();
    _timer = Timer(CardDealPace.dealCard, _advance);
  }

  bool get _pending {
    for (final seat in _batch) {
      if (!_revealed.contains(seat)) return true;
    }
    return false;
  }

  void _advance() {
    int? next;
    for (final seat in _batch) {
      if (!_revealed.contains(seat)) {
        next = seat;
        break;
      }
    }
    if (next == null) {
      _running = false;
      return;
    }
    _revealed.add(next);
    onRevealed?.call(next, _labels[next] ?? 'FOLD');
    notifyListeners();
    if (!_pending) {
      _running = false;
      return;
    }
    _timer?.cancel();
    _timer = Timer(CardDealPace.dealCard, _advance);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
