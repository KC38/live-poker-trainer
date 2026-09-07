/// Mistake patterns: stable keys and coarse tags for repeated-leak tracking.
///
/// Every INCORRECT verdict is reduced to two identifiers:
///
/// * a fine-grained **mistake key** — `street:archetype:taken->best`
///   (e.g. `river:nit:raise->call`, or `turn:station:raise->raise:small` for a
///   sizing miss), which says "the same decision in the same shape of spot";
/// * one or more **coarse tags** (`MistakeTag`) — the poker leak the decision
///   belongs to (e.g. bluffing into calling stations), which lets the coach
///   say "same mistake" even when the street or exact action differs.
///
/// A **context key** (`street:archetype:best`) describes the spot without the
/// hero's action, so a later CORRECT decision in the same spot can be matched
/// back to the leak and acknowledged as an improvement.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Coarse leak categories. Ids are persisted; never rename an existing id.
enum MistakeTag {
  // Archetype-specific leaks (the ones worth coaching by name).
  overbluffingStations(
    'overbluffing_vs_stations',
    'Bluffing into calling stations',
  ),
  notValueBettingStations(
    'not_value_betting_vs_stations',
    'Missing value vs calling stations',
  ),
  foldingTooMuchVsAggro(
    'folding_too_much_vs_maniacs',
    'Folding too much vs maniacs and LAGs',
  ),
  chasingVsAggro('chasing_vs_maniacs', 'Chasing thin vs maniacs and LAGs'),
  payingOffNits('paying_off_nits', 'Paying off nits'),
  raisingIntoNits('raising_into_nits', "Raising into a nit's strength"),
  notAttackingNits('not_attacking_nits', "Not attacking nits' weakness"),
  underSizingVsStations(
    'sizing_too_small_vs_stations',
    'Betting too small vs stations',
  ),

  // Generic action-shape leaks (always attached as a fallback tag).
  raiseWhenCallBest('raise_when_call_best', 'Raising when calling was best'),
  betWhenCheckBest('bet_when_check_best', 'Betting when checking was best'),
  callWhenRaiseBest('call_when_raise_best', 'Calling when raising was best'),
  checkWhenBetBest('check_when_bet_best', 'Checking when betting was best'),
  callWhenFoldBest('call_when_fold_best', 'Calling when folding was best'),
  raiseWhenFoldBest('raise_when_fold_best', 'Raising when folding was best'),
  foldWhenCallBest('fold_when_call_best', 'Folding when calling was best'),
  foldWhenRaiseBest('fold_when_raise_best', 'Folding when raising was best'),
  sizingTooSmall('sizing_too_small', 'Sizing too small'),
  sizingTooLarge('sizing_too_large', 'Sizing too large'),
  other('other', 'Off the recommended line');

  const MistakeTag(this.id, this.label);

  /// Stable persisted identifier.
  final String id;

  /// Human-readable leak name for stats and coaching copy.
  final String label;

  /// Whether this tag names an archetype-specific exploit leak.
  bool get isArchetypeSpecific => index <= underSizingVsStations.index;

  /// Resolves a persisted id; unknown ids map to [other].
  static MistakeTag fromId(String id) {
    for (final tag in values) {
      if (tag.id == id) return tag;
    }
    return MistakeTag.other;
  }
}

/// Short lowercase token for an archetype inside mistake keys.
String archetypeKeyToken(PlayerArchetype archetype) => switch (archetype) {
      PlayerArchetype.hero => 'hero',
      PlayerArchetype.maniac => 'maniac',
      PlayerArchetype.nit => 'nit',
      PlayerArchetype.callingStation => 'station',
      PlayerArchetype.tag => 'tag',
      PlayerArchetype.lag => 'lag',
    };

/// Derived classification of one graded decision.
@immutable
class MistakePattern {
  /// Creates a pattern.
  const MistakePattern({
    required this.key,
    required this.contextKey,
    required this.coarseContextKey,
    required this.tags,
    required this.street,
    required this.archetype,
    required this.taken,
    required this.best,
    required this.mismatch,
  });

  /// Fine-grained key, e.g. `river:nit:raise->call`.
  final String key;

  /// Spot without the hero action, e.g. `river:nit:call`.
  final String contextKey;

  /// Spot without street, e.g. `nit:call` (same archetype, same right answer).
  final String coarseContextKey;

  /// Coarse tags, most specific first. Never empty.
  final List<MistakeTag> tags;

  final Street street;
  final PlayerArchetype archetype;
  final ExploitAction taken;
  final ExploitAction best;
  final CoachMismatch mismatch;

  /// The most specific coarse tag.
  MistakeTag get primaryTag => tags.first;

  /// Builds the pattern for a graded decision.
  ///
  /// For CORRECT decisions ([mismatch] == [CoachMismatch.none]) the key still
  /// describes the spot (`taken == best`) and tags is `[MistakeTag.other]`;
  /// callers use [contextKey] / [coarseContextKey] to match prior leaks.
  static MistakePattern derive({
    required Street street,
    required PlayerArchetype archetype,
    required ExploitAction taken,
    required ExploitAction best,
    required CoachMismatch mismatch,
    double heroSizingBb = 0,
    double bestSizingBb = 0,
  }) {
    final s = street.name;
    final a = archetypeKeyToken(archetype);
    final t = taken.name;
    final b = best.name;
    final sizingSuffix = mismatch == CoachMismatch.sizing
        ? (heroSizingBb < bestSizingBb ? ':small' : ':large')
        : '';
    return MistakePattern(
      key: '$s:$a:$t->$b$sizingSuffix',
      contextKey: '$s:$a:$b',
      coarseContextKey: '$a:$b',
      tags: deriveTags(
        archetype: archetype,
        taken: taken,
        best: best,
        mismatch: mismatch,
        heroSizingBb: heroSizingBb,
        bestSizingBb: bestSizingBb,
      ),
      street: street,
      archetype: archetype,
      taken: taken,
      best: best,
      mismatch: mismatch,
    );
  }

  /// Coarse tags for a mismatch, most specific first.
  static List<MistakeTag> deriveTags({
    required PlayerArchetype archetype,
    required ExploitAction taken,
    required ExploitAction best,
    required CoachMismatch mismatch,
    double heroSizingBb = 0,
    double bestSizingBb = 0,
  }) {
    if (mismatch == CoachMismatch.none) return const [MistakeTag.other];

    final tags = <MistakeTag>[];
    final aggro = archetype == PlayerArchetype.maniac ||
        archetype == PlayerArchetype.lag;
    final station = archetype == PlayerArchetype.callingStation;
    final nit = archetype == PlayerArchetype.nit;

    // Archetype-specific leak first, when the mismatch is one of the classic
    // exploit errors against that player type.
    switch (mismatch) {
      case CoachMismatch.tooAggressive:
        if (station) tags.add(MistakeTag.overbluffingStations);
        if (nit) tags.add(MistakeTag.raisingIntoNits);
      case CoachMismatch.tooPassive:
        if (station) tags.add(MistakeTag.notValueBettingStations);
        if (nit) tags.add(MistakeTag.notAttackingNits);
      case CoachMismatch.tooTight:
        if (aggro) tags.add(MistakeTag.foldingTooMuchVsAggro);
      case CoachMismatch.tooLoose:
        if (nit) tags.add(MistakeTag.payingOffNits);
        if (aggro) tags.add(MistakeTag.chasingVsAggro);
      case CoachMismatch.sizing:
        if (station && heroSizingBb < bestSizingBb) {
          tags.add(MistakeTag.underSizingVsStations);
        }
      case CoachMismatch.none:
        break;
    }

    // Generic action-shape tag so every mistake has a coarse bucket.
    final generic = switch (mismatch) {
      CoachMismatch.tooAggressive => best == ExploitAction.check
          ? MistakeTag.betWhenCheckBest
          : MistakeTag.raiseWhenCallBest,
      CoachMismatch.tooPassive => taken == ExploitAction.check
          ? MistakeTag.checkWhenBetBest
          : MistakeTag.callWhenRaiseBest,
      CoachMismatch.tooLoose => taken == ExploitAction.raise
          ? MistakeTag.raiseWhenFoldBest
          : MistakeTag.callWhenFoldBest,
      CoachMismatch.tooTight => best == ExploitAction.raise
          ? MistakeTag.foldWhenRaiseBest
          : MistakeTag.foldWhenCallBest,
      CoachMismatch.sizing => heroSizingBb < bestSizingBb
          ? MistakeTag.sizingTooSmall
          : MistakeTag.sizingTooLarge,
      CoachMismatch.none => MistakeTag.other,
    };
    tags.add(generic);
    return List.unmodifiable(tags);
  }
}

/// How often a just-recorded mistake has been seen before.
@immutable
class RepeatInfo {
  /// Creates repeat info.
  const RepeatInfo({
    required this.pattern,
    required this.totalCount,
    required this.sessionCount,
    required this.tagTotalCount,
    this.lastSeen,
  });

  final MistakePattern pattern;

  /// Times this exact [MistakePattern.key] has occurred, including now.
  final int totalCount;

  /// Times this key has occurred in the current session, including now.
  final int sessionCount;

  /// Times the primary coarse tag has occurred, including now.
  final int tagTotalCount;

  /// Previous occurrence of this key, if any.
  final DateTime? lastSeen;

  /// True when the same key (or coarse leak) has been seen before.
  bool get isRepeat => totalCount > 1 || tagTotalCount > 1;

  /// Whether the *exact* key repeated (vs only the coarse leak).
  bool get isExactRepeat => totalCount > 1;

  /// The number the coach should quote: exact repeats when available, else
  /// the coarse-leak count.
  int get displayCount => isExactRepeat ? totalCount : tagTotalCount;
}

/// A correct decision in a spot the user previously got wrong repeatedly.
@immutable
class ImprovementInfo {
  /// Creates improvement info.
  const ImprovementInfo({
    required this.matchedKey,
    required this.tag,
    required this.priorMistakes,
    required this.streak,
    required this.exactContext,
    required this.lastWrongAction,
  });

  /// The mistake key this improvement is credited against.
  final String matchedKey;

  /// Coarse tag of the matched leak.
  final MistakeTag tag;

  /// How many times the leak had been recorded before this fix.
  final int priorMistakes;

  /// Consecutive correct decisions on this pattern since its last mistake
  /// (including this one).
  final int streak;

  /// True when the street also matched (vs archetype + best action only).
  final bool exactContext;

  /// The action the hero used to take in this spot.
  final ExploitAction lastWrongAction;
}

/// Aggregate view of one recurring leak for the Stats screen.
@immutable
class MistakeSummary {
  /// Creates a summary.
  const MistakeSummary({
    required this.key,
    required this.tag,
    required this.street,
    required this.archetype,
    required this.taken,
    required this.best,
    required this.count,
    required this.lastSeen,
    required this.improvements,
    required this.currentStreak,
    required this.lastEventWasImprovement,
    required this.evLostBb,
  });

  final String key;
  final MistakeTag tag;
  final String street;
  final String archetype;
  final String taken;
  final String best;
  final int count;
  final DateTime lastSeen;
  final int improvements;
  final int currentStreak;
  final bool lastEventWasImprovement;

  /// Total EV given up on this pattern (positive number of BB).
  final double evLostBb;

  /// Trend: improving when the most recent event on the pattern is a fix,
  /// recurring when the mistake has repeated and still stands, isolated
  /// otherwise.
  MistakeTrend get trend {
    if (lastEventWasImprovement && currentStreak > 0) {
      return MistakeTrend.improving;
    }
    if (count >= 2) return MistakeTrend.recurring;
    return MistakeTrend.isolated;
  }

  /// Sentence-case description, e.g. "River vs Nit: raised, call was best".
  String get title {
    final streetLabel = street[0].toUpperCase() + street.substring(1);
    return '$streetLabel vs $archetype: ${_past(taken)}, '
        '${best.toLowerCase()} was best';
  }

  static String _past(String action) => switch (action.toLowerCase()) {
        'fold' => 'folded',
        'check' => 'checked',
        'call' => 'called',
        'raise' => 'raised',
        _ => action,
      };
}

/// Direction of a recurring leak.
enum MistakeTrend { improving, recurring, isolated }

/// Whole leak-finder dataset for the Stats screen.
@immutable
class MistakeStats {
  /// Creates leak-finder stats.
  const MistakeStats({
    this.totalMistakes = 0,
    this.totalImprovements = 0,
    this.topMistakes = const [],
    this.byArchetype = const {},
    this.byStreet = const {},
    this.byTag = const {},
  });

  final int totalMistakes;
  final int totalImprovements;

  /// Patterns sorted by count desc, then recency.
  final List<MistakeSummary> topMistakes;
  final Map<String, int> byArchetype;
  final Map<String, int> byStreet;
  final Map<MistakeTag, int> byTag;

  bool get isEmpty => totalMistakes == 0;
}
