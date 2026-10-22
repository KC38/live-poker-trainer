/// Remembers how far each felt deal got, outside any widget's lifetime.
///
/// The deal used to live only in `FeltTableView`'s State. Any remount of the
/// table — a sibling appearing above it on Nice!/Oops!, a branch swap, a key
/// change, a parent rebuilt with a new widget type — created a fresh
/// [FeltDealController] and every card flew in again. Earlier fixes kept one
/// remount path stable at a time (LPT-642, #1548, #1582, #1912); the next new
/// layout re-opened it. The ledger makes a remount resume instead of replay:
/// a felt that mounts for an epoch the ledger already saw continues from the
/// recorded progress (usually: everything already on the table).
library;

import 'package:flutter/foundation.dart';

/// Cards already on the felt for one deal epoch.
@immutable
class FeltDealProgress {
  /// Creates a progress snapshot.
  const FeltDealProgress({required this.holes, required this.board});

  /// Hole cards visible per seat index (0–2).
  final Map<int, int> holes;

  /// Board cards visible.
  final int board;

  /// True when nothing has landed yet.
  bool get isEmpty => board == 0 && holes.values.every((n) => n == 0);
}

/// Per-step store of [FeltDealProgress] by deal epoch.
///
/// Owned by whoever defines "one deal" — the lesson activity controller
/// clears it on every new step bind and on a wrong-answer retry (which is
/// meant to deal a fresh hand).
class FeltDealLedger {
  /// Tests: turn resume off to find raw remount paths (the structural layer).
  @visibleForTesting
  static bool debugDisableResume = false;

  final Map<String, FeltDealProgress> _byEpoch = {};

  /// Progress recorded for [epoch], if any.
  FeltDealProgress? progressFor(String epoch) =>
      debugDisableResume ? null : _byEpoch[epoch];

  /// Records [progress] for [epoch]. Never moves a deal backwards.
  void record(String epoch, FeltDealProgress progress) {
    if (epoch.isEmpty || progress.isEmpty) return;
    final old = _byEpoch[epoch];
    if (old == null) {
      _byEpoch[epoch] = progress;
      return;
    }
    final holes = Map<int, int>.of(old.holes);
    progress.holes.forEach((seat, n) {
      if (n > (holes[seat] ?? 0)) holes[seat] = n;
    });
    _byEpoch[epoch] = FeltDealProgress(
      holes: holes,
      board: progress.board > old.board ? progress.board : old.board,
    );
  }

  final Map<String, int> _marks = {};

  /// How far a scripted felt sequence (drill story frames) got under [key].
  int? markFor(String key) => debugDisableResume ? null : _marks[key];

  /// Records [value] for [key]. Never moves backwards.
  void mark(String key, int value) {
    final old = _marks[key];
    if (old == null || value > old) _marks[key] = value;
  }

  /// Forgets every deal (new step, or a retry that deals a fresh hand).
  void clear() {
    _byEpoch.clear();
    _marks.clear();
  }

  /// Number of epochs recorded (tests).
  @visibleForTesting
  int get length => _byEpoch.length;
}
