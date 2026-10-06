/// One-pass ordered felt deal (holes then board). Never re-deals a slot.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';

/// Coordinates hole + board reveals so each card lands once, in order.
///
/// A new [epoch] deals only the street that is arriving: preflop deals holes,
/// flop deals three board cards (holes already out), turn deals the fourth
/// card, river deals the fifth. Rebuilds with the same [epoch] only extend
/// the board; they never replay holes or already-up cards.
class FeltDealController extends ChangeNotifier {
  /// Creates a deal controller. [onDealt] fires once per newly landed card.
  FeltDealController({this.onDealt});

  /// Called when a card becomes visible (for SFX).
  final VoidCallback? onDealt;

  String _epoch = '';
  int _seatCount = 0;
  int _dealerIndex = 0;
  var _holesWanted = false;
  var _boardTarget = 0;
  var _boardVisible = 0;
  final Map<int, int> _holeVisible = {};
  Timer? _timer;
  var _running = false;

  /// Stable deal identity for the current hand / lesson spot.
  String get epoch => _epoch;

  /// How many board cards are currently shown.
  int get boardVisible => _boardVisible;

  /// How many hole cards are shown at [seatIndex] (0–2).
  int holeVisibleAt(int seatIndex) => _holeVisible[seatIndex] ?? 0;

  /// Syncs targets for [epoch]. New epochs deal the arriving street only;
  /// same epochs only deal newly required board cards.
  void bind({
    required String epoch,
    required int seatCount,
    required int dealerIndex,
    required int boardTarget,
    required bool dealHoles,
  }) {
    final target = boardTarget.clamp(0, 5);
    if (epoch != _epoch) {
      _stopTimer();
      _epoch = epoch;
      _seatCount = seatCount;
      _dealerIndex = dealerIndex;
      _holesWanted = dealHoles;
      _boardTarget = target;
      _holeVisible.clear();
      _seedAlreadyDealt(target);
      if (CardDealPace.instant) {
        _snapComplete();
      } else {
        _kick();
      }
      return;
    }

    var changed = false;
    if (seatCount != _seatCount) {
      _seatCount = seatCount;
      changed = true;
    }
    if (dealerIndex != _dealerIndex) {
      _dealerIndex = dealerIndex;
      changed = true;
    }
    if (dealHoles && !_holesWanted) {
      _holesWanted = true;
      changed = true;
    }
    if (target > _boardTarget) {
      _boardTarget = target;
      changed = true;
    }
    if (changed) {
      if (CardDealPace.instant) {
        _snapComplete();
      } else {
        _kick();
      }
    }
  }

  /// Leaves earlier streets in place when a deal begins mid-hand.
  ///
  /// Flop (3): holes are already dealt. Turn (4): holes and flop. River (5):
  /// holes, flop, and turn. Preflop (0) and partial boards deal from empty.
  void _seedAlreadyDealt(int target) {
    _boardVisible = switch (target) {
      >= 5 => 4,
      >= 4 => 3,
      _ => 0,
    };
    if (_holesWanted && target >= 3) {
      for (var seat = 0; seat < _seatCount; seat++) {
        _holeVisible[seat] = 2;
      }
    }
  }

  void _snapComplete() {
    _stopTimer();
    _running = false;
    if (_holesWanted) {
      for (var seat = 0; seat < _seatCount; seat++) {
        _holeVisible[seat] = 2;
      }
    }
    _boardVisible = _boardTarget;
    notifyListeners();
  }

  void _kick() {
    if (_running) return;
    if (_isComplete) return;
    _running = true;
    // First card lands immediately; later cards wait [dealCard] apart.
    scheduleMicrotask(_advance);
  }

  bool get _isComplete {
    if (_holesWanted) {
      for (var seat = 0; seat < _seatCount; seat++) {
        if (holeVisibleAt(seat) < 2) return false;
      }
    }
    return _boardVisible >= _boardTarget;
  }

  /// Next hole seat to receive a card, or null when holes are done.
  ({int seat, int cardIndex})? _nextHole() {
    if (!_holesWanted || _seatCount <= 0) return null;
    final dealer = _dealerIndex.clamp(0, _seatCount - 1);
    for (var card = 0; card < 2; card++) {
      for (var offset = 1; offset <= _seatCount; offset++) {
        final seat = (dealer + offset) % _seatCount;
        if (holeVisibleAt(seat) <= card) {
          return (seat: seat, cardIndex: card);
        }
      }
    }
    return null;
  }

  void _advance() {
    if (_epoch.isEmpty) {
      _running = false;
      return;
    }
    final hole = _nextHole();
    if (hole != null) {
      _holeVisible[hole.seat] = hole.cardIndex + 1;
      notifyListeners();
      onDealt?.call();
      _scheduleNext();
      return;
    }
    if (_boardVisible < _boardTarget) {
      _boardVisible += 1;
      notifyListeners();
      onDealt?.call();
      _scheduleNext();
      return;
    }
    _running = false;
  }

  void _scheduleNext() {
    if (_isComplete || CardDealPace.instant) {
      if (CardDealPace.instant && !_isComplete) {
        _snapComplete();
        return;
      }
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
