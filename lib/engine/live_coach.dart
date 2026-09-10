/// Expected-value grading for live full-hand training.
///
/// Grading works in chips. The coach builds the villains' ranges from their
/// archetype and the action they have actually shown, measures hero equity
/// against those ranges, prices every legal line, and recommends the one worth
/// the most. A decision is only marked wrong when it costs more than the
/// model's own uncertainty — a close spot is graded as close rather than as a
/// mistake, because confident red on a coin flip is what makes a coach look
/// stupid.
///
/// This replaced a table of hand-class thresholds that ignored price, board,
/// opponent count, and position, and reported an "EV" that was a fixed
/// fraction of the bet faced rather than any expected value.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/decision_ev.dart';
import 'package:live_poker_trainer/engine/equity.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/hand_range.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Result of a live coaching grade for one Hero action.
class LiveCoachGrade {
  /// Creates a live coach grade.
  const LiveCoachGrade({
    required this.verdict,
    required this.message,
    required this.villainArchetype,
    required this.villainName,
    required this.street,
    required this.heroActionLabel,
    required this.mismatch,
    this.optimalAction,
    this.optimalSizingBb = 0,
    this.evDeltaBb = 0,
    this.heroAction = ExploitAction.check,
    this.heroSizingBb = 0,
    this.villainPosition = '',
    this.heroPosition = '',
    this.villainIsAggressor = false,
    this.callAmount = 0,
    this.equityPercent = 0,
    this.requiredEquityPercent = 0,
    this.heroClass = HandClass.air,
    this.isClose = false,
    this.equityIsExact = false,
    this.villainAirShare = 0,
    this.reasonCodes = const [],
  });

  final CoachVerdict verdict;

  /// Spot-specific coaching copy naming the street, villain, and better line.
  final String message;

  /// Archetype the grade was reasoned against.
  final PlayerArchetype villainArchetype;
  final String villainName;
  final Street street;
  final String heroActionLabel;

  /// How the hero's action differed from the recommended line.
  final CoachMismatch mismatch;

  final ExploitAction? optimalAction;
  final double optimalSizingBb;

  /// Chips the decision cost, in big blinds, against the best available line.
  ///
  /// Zero or very slightly negative for a good decision; a real negative
  /// number for a mistake. This is an expected value, computed from hero's
  /// equity and the price, not a penalty constant.
  final double evDeltaBb;

  /// Hero action mapped onto the exploit vocabulary.
  final ExploitAction heroAction;

  /// Hero bet / raise size in big blinds (0 for passive actions).
  final double heroSizingBb;

  /// Villain seat position label (BB / SB / BTN / …).
  final String villainPosition;

  /// Hero seat position label.
  final String heroPosition;

  /// True only when the villain voluntarily bet or raised this street.
  final bool villainIsAggressor;

  /// Chips hero must add to call (snapshot at grade time).
  final double callAmount;

  /// Hero's equity against the villain range, as a percentage.
  final int equityPercent;

  /// Equity a call needs to break even, as a percentage. Zero when free.
  final int requiredEquityPercent;

  /// What hero actually holds relative to the board.
  final HandClass heroClass;

  /// Whether the decision was inside the model's margin — right answer, but
  /// the alternative was barely worse.
  final bool isClose;

  /// Whether [equityPercent] came from full enumeration rather than sampling.
  final bool equityIsExact;

  /// Share of the villain's range that is air or a weak draw, `0..1`.
  final double villainAirShare;

  /// Curriculum reason codes explaining *why* (never change [optimalAction]).
  ///
  /// Derived from archetype + mismatch + price/equity so offline copy and the
  /// Claude prompt share one spine. Empty only for ungraded spots.
  final List<CoachReasonCode> reasonCodes;

  /// Leading curriculum tag, or null when ungraded.
  CoachReasonCode? get primaryReason =>
      reasonCodes.isEmpty ? null : reasonCodes.first;

  /// Stable leak classification of this decision (null when ungraded).
  MistakePattern? get pattern {
    final best = optimalAction;
    if (!verdict.isGraded || best == null) return null;
    return MistakePattern.derive(
      street: street,
      archetype: villainArchetype,
      taken: heroAction,
      best: best,
      mismatch: mismatch,
      heroSizingBb: heroSizingBb,
      bestSizingBb: optimalSizingBb,
    );
  }

  /// Structured prompt for the Claude coach.
  ///
  /// The equity, the price, and what the villain's range is made of are all
  /// stated, so the model explains a number the player can check rather than
  /// inventing a justification for a verdict it was handed.
  String toPrompt(
    GameState game, {
    RepeatInfo? repeat,
    ImprovementInfo? improvement,
  }) {
    final history = StringBuffer();
    if (repeat != null && repeat.isRepeat) {
      history.write(' Leak history: this is occurrence #${repeat.displayCount} '
          'of the pattern "${repeat.pattern.primaryTag.label}" '
          '(${repeat.pattern.key}), ${repeat.sessionCount} in this session. '
          'Explicitly say it is a repeated mistake, quote the count, and name '
          'the pattern.');
    }
    if (improvement != null) {
      history.write(' Leak history: the player previously '
          '${_pastTense(improvement.lastWrongAction)} in this spot '
          '${improvement.priorMistakes} times '
          '("${improvement.tag.label}") and just got it right, '
          'streak ${improvement.streak}. Explicitly acknowledge the fix and '
          'what they used to do.');
    }
    final board = game.community.map((c) => c.code).join(' ');
    final hole = game.hero.holeCards.map((c) => c.code).join(' ');
    final bestLabel = optimalAction?.label ?? 'no clear best line';
    final endorse = switch (optimalAction) {
      ExploitAction.fold =>
        'Endorse folding only. Never tell the player to call, defend, or continue.',
      ExploitAction.call =>
        'Endorse calling only. Never tell the player to fold.',
      ExploitAction.check =>
        'Endorse checking only. Never tell the player to fold or inflate the pot.',
      ExploitAction.raise =>
        'Endorse raising/betting only. Never tell the player to fold.',
      null => 'No graded line — stay neutral; do not invent a verdict.',
    };
    final aggressorLine = villainIsAggressor
        ? 'Villain role: voluntary aggressor (they bet or raised this street).'
        : 'Villain role: NOT the aggressor '
            '(posted blinds and/or called only — do NOT say they fired, bet, '
            'raised, or led).';
    final maths = callAmount > Money.epsilon
        ? 'Hero equity versus that range: $equityPercent%. Equity needed to '
            'call at this price: $requiredEquityPercent%. '
        : 'Hero equity versus that range: $equityPercent%. Nothing to call. ';
    final closeNote = isClose
        ? 'This spot is close: the alternative line was only slightly worse, '
            'so do not scold. '
        : '';
    final curriculum = reasonCodes.isEmpty
        ? ''
        : 'Curriculum reason codes: '
            '${reasonCodes.map((c) => c.id).join(', ')}. '
            'Required phrases (include each idea; prefer the wording verbatim): '
            '${reasonCodes.map((c) => '"${c.phrase}"').join('; ')}. ';
    return 'Narration contract: slot-fill only. Include street, archetype, '
        'equity%/price, endorsed action, and the curriculum phrases below. '
        'Do not invent strategy, multi-street lines, or reasons outside those '
        'phrases. '
        'Street being graded: ${street.label}. '
        'Hero position: ${heroPosition.isEmpty ? 'unknown' : heroPosition}. '
        'Hero hole cards: ${hole.isEmpty ? 'unknown' : hole}. '
        'Board: ${board.isEmpty ? 'none' : board}. '
        'Hero holds: ${heroClass.label}. '
        'Pot: ${ChipFormat.dollars(game.totalPot)} '
        '(${(game.totalPot / max(game.bigBlind, 1)).toStringAsFixed(0)} BB). '
        'Call amount facing hero: ${ChipFormat.dollars(callAmount)}. '
        'Primary villain: $villainName at '
        '${villainPosition.isEmpty ? 'unknown' : villainPosition}, '
        'archetype ${villainArchetype.label} '
        '(VPIP ${villainArchetype.vpip.toStringAsFixed(0)}, '
        'PFR ${villainArchetype.pfr.toStringAsFixed(0)}). '
        '$aggressorLine '
        'Their range here is ${(villainAirShare * 100).round()}% air or weak '
        'draws. '
        '$maths'
        'Hero action: $heroActionLabel. '
        'Recommended: $bestLabel'
        '${optimalSizingBb > 0 ? ' ~${optimalSizingBb.toStringAsFixed(0)} BB' : ''}. '
        'EV difference: ${evDeltaBb.toStringAsFixed(2)} BB. '
        'Verdict: ${verdict.name}. Error type: ${mismatch.name}. '
        '$closeNote'
        '$curriculum'
        '$endorse '
        'Quote the equity and the price in your explanation — the player can '
        'check those numbers, so they must appear and must not be changed. '
        'In one or two sentences, tell the player specifically why '
        '$heroActionLabel '
        '${verdict == CoachVerdict.correct ? 'works' : 'is worse than the recommended line'} '
        'against a ${villainArchetype.label} on the ${street.label}. '
        'Ground the reason in the curriculum phrases above — prefer those '
        'phrases verbatim; do not invent a different principle. '
        'Reference the archetype tendency by name. Do not give generic advice.'
        '$history';
  }

  static String _pastTense(ExploitAction a) => switch (a) {
        ExploitAction.fold => 'folded',
        ExploitAction.check => 'checked',
        ExploitAction.call => 'called',
        ExploitAction.raise => 'raised',
      };
}

/// Best line in a spot, from the same EV stack as [LiveCoach.grade].
///
/// Used to stamp practice-scenario optimal without trusting an LLM.
@immutable
class LiveCoachRecommendation {
  /// Creates a recommendation.
  const LiveCoachRecommendation({
    required this.optimalAction,
    required this.optimalSizingBb,
    required this.explanation,
    required this.villainArchetype,
    required this.villainName,
    required this.street,
    required this.villainIsAggressor,
    required this.callAmount,
    required this.equityPercent,
    required this.requiredEquityPercent,
    required this.reasonCodes,
  });

  final ExploitAction optimalAction;
  final double optimalSizingBb;

  /// Offline curriculum copy for the endorsed line (CORRECT framing).
  final String explanation;

  final PlayerArchetype villainArchetype;
  final String villainName;
  final Street street;
  final bool villainIsAggressor;
  final double callAmount;
  final int equityPercent;
  final int requiredEquityPercent;
  final List<CoachReasonCode> reasonCodes;
}

/// Grades Hero actions on expected value during full-hand play.
class LiveCoach {
  LiveCoach._();

  /// Smallest mistake worth flagging, in big blinds.
  ///
  /// Below this the difference is noise to a live player even if the model is
  /// certain about it, and calling it a mistake trains superstition.
  static const double minGradedLossBb = 0.75;

  /// Smallest mistake worth flagging, as a share of the pot.
  static const double minGradedLossPotFraction = 0.04;

  /// How much wider the band is when only the bet size is in question.
  static const double sizingBandMultiple = 2.5;

  /// Sizing loss, as a share of the pot, above which the size stops being a
  /// note and becomes a mistake in its own right.
  ///
  /// Choosing the right action and choosing the perfect size are different
  /// skills, and a player who bets for value has not made an error just
  /// because the model prefers a bigger one. Below this the coach says "good
  /// bet, go bigger"; above it — betting a tenth of the pot with the nuts —
  /// the size really is the mistake.
  static const double sizingMistakePotFraction = 0.25;

  /// Relative size gap worth mentioning at all when the action was right.
  static const double sizingHintThreshold = 0.25;

  /// Prices the current spot and returns the best line, or null if ungradable.
  ///
  /// Same ranges → equity → [DecisionModel] path as [grade]. Practice
  /// scenarios use this to stamp `optimal_*` so Gemini never owns the answer.
  static LiveCoachRecommendation? recommend(GameState state) {
    final eval = _evaluateSpot(state);
    if (eval == null) return null;

    final best = eval.analysis.best;
    final bestSizingBb = best.sizingBb(eval.bb);
    final equityPercent = (eval.analysis.rawEquity.equity * 100).round();
    final requiredEquityPercent =
        (eval.analysis.requiredEquity * 100).round();
    final airShare =
        (eval.analysis.villainComposition[HandClass.air] ?? 0) +
            (eval.analysis.villainComposition[HandClass.weakDraw] ?? 0);
    final reasonCodes = CoachReasonCode.derive(
      archetype: eval.arch,
      mismatch: CoachMismatch.none,
      best: best.action,
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      callAmount: eval.callAmt,
      villainIsAggressor: eval.villainIsAggressor,
    );
    final evidence = CoachEvidence(
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      heroHand: eval.hero.holeCards.map((c) => c.display).join(''),
      heroClass: eval.analysis.heroClass,
      villainName: eval.villainName,
      villainAirShare: airShare,
      callAmount: eval.callAmt,
      potSize: eval.pot,
      hasBoard: state.community.isNotEmpty,
    );

    return LiveCoachRecommendation(
      optimalAction: best.action,
      optimalSizingBb: bestSizingBb,
      explanation: CoachLines.forGrade(
        correct: true,
        isClose: false,
        mismatch: CoachMismatch.none,
        archetype: eval.arch,
        villainName: eval.villainName,
        street: state.street,
        best: best.action,
        taken: best.action,
        bestSizing: bestSizingBb,
        heroSizing: bestSizingBb,
        potSize: eval.pot,
        callAmount: eval.callAmt,
        villainIsAggressor: eval.villainIsAggressor,
        villainPosition: eval.villainPos,
        evidence: evidence,
        reasonCodes: reasonCodes,
      ),
      villainArchetype: eval.arch,
      villainName: eval.villainName,
      street: state.street,
      villainIsAggressor: eval.villainIsAggressor,
      callAmount: eval.callAmt,
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      reasonCodes: reasonCodes,
    );
  }

  /// Grades [action] in the current [state] before it is applied.
  static LiveCoachGrade grade({
    required GameState state,
    required PokerAction action,
  }) {
    final hero = state.hero;
    final callAmt = state.callAmountFor(hero);
    final villainInfo = _primaryVillain(state);
    final arch = villainInfo.player?.archetype ?? PlayerArchetype.tag;
    final villainName = villainInfo.player?.name ?? 'the field';
    final villainPos = villainInfo.position;
    final heroSeat = state.players.indexWhere((p) => p.isHero);
    final heroPos = heroSeat >= 0 ? state.positionLabel(heroSeat) : '';
    final mapped = _mapAction(action);

    LiveCoachGrade ungraded() => LiveCoachGrade(
          verdict: CoachVerdict.none,
          message: CoachLines.ambiguous(
            archetype: arch,
            street: state.street,
            villainName: villainName,
            callAmount: callAmt,
            villainIsAggressor: villainInfo.isAggressor,
          ),
          villainArchetype: arch,
          villainName: villainName,
          street: state.street,
          heroActionLabel: action.label,
          mismatch: CoachMismatch.none,
          heroAction: mapped,
          villainPosition: villainPos,
          heroPosition: heroPos,
          villainIsAggressor: villainInfo.isAggressor,
          callAmount: callAmt,
        );

    final eval = _evaluateSpot(state);
    if (eval == null) return ungraded();

    final analysis = eval.analysis;
    final best = analysis.best;
    final taken = DecisionModel.priceHeroAction(
      spot: eval.spot,
      analysis: analysis,
      action: mapped,
      totalBet: action.amount,
    );

    final evLoss = max(0.0, best.ev - taken.ev);
    var band = max(
      max(minGradedLossBb * eval.bb, minGradedLossPotFraction * eval.pot),
      analysis.uncertainty,
    );
    // Picking the right action is a far more reliable output of a one-street
    // model than picking the exact size, so a bet that is merely a little off
    // is not treated with the same confidence as a bet that should have been
    // a check. Without this, every value bet that is not the model's favourite
    // size grades as a mistake, which is both wrong and infuriating.
    final sizingOnly = best.action == ExploitAction.raise &&
        taken.action == ExploitAction.raise;
    if (sizingOnly) {
      band = max(
        band * sizingBandMultiple,
        eval.pot * sizingMistakePotFraction,
      );
    }
    final correct = evLoss <= band;
    // "Close" means hero did not pick the top line but the gap is inside the
    // band. The verdict still rewards them; only the copy softens.
    final isClose = correct && best.action != taken.action;

    final bestSizingBb = best.sizingBb(eval.bb);
    final heroSizingBb = taken.sizingBb(eval.bb);
    // A size worth mentioning even though the decision was right.
    final sizingHintBb = correct &&
            sizingOnly &&
            bestSizingBb > 0 &&
            (heroSizingBb - bestSizingBb).abs() >
                bestSizingBb * sizingHintThreshold
        ? bestSizingBb
        : 0.0;

    final mismatch = correct
        ? CoachMismatch.none
        : CoachLines.classify(
            best: best.action,
            taken: taken.action,
            sizingOff: sizingOnly,
          );

    final airShare = (analysis.villainComposition[HandClass.air] ?? 0) +
        (analysis.villainComposition[HandClass.weakDraw] ?? 0);

    final equityPercent = (analysis.rawEquity.equity * 100).round();
    final requiredEquityPercent = (analysis.requiredEquity * 100).round();
    final evidence = CoachEvidence(
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      heroHand: eval.hero.holeCards.map((c) => c.display).join(''),
      heroClass: analysis.heroClass,
      villainName: eval.villainName,
      villainAirShare: airShare,
      callAmount: eval.callAmt,
      potSize: eval.pot,
      hasBoard: state.community.isNotEmpty,
    );

    final reasonCodes = CoachReasonCode.derive(
      archetype: eval.arch,
      mismatch: mismatch,
      best: best.action,
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      callAmount: eval.callAmt,
      villainIsAggressor: eval.villainIsAggressor,
    );

    return LiveCoachGrade(
      verdict: correct ? CoachVerdict.correct : CoachVerdict.incorrect,
      message: CoachLines.forGrade(
        correct: correct,
        isClose: isClose,
        mismatch: mismatch,
        archetype: eval.arch,
        villainName: eval.villainName,
        street: state.street,
        best: best.action,
        taken: taken.action,
        bestSizing: bestSizingBb,
        heroSizing: heroSizingBb,
        potSize: eval.pot,
        callAmount: eval.callAmt,
        villainIsAggressor: eval.villainIsAggressor,
        villainPosition: eval.villainPos,
        evidence: evidence,
        sizingHintBb: sizingHintBb,
        reasonCodes: reasonCodes,
      ),
      villainArchetype: eval.arch,
      villainName: eval.villainName,
      street: state.street,
      heroActionLabel: action.label,
      mismatch: mismatch,
      optimalAction: best.action,
      optimalSizingBb: bestSizingBb,
      evDeltaBb: Money.round(-evLoss / eval.bb * 100) / 100,
      heroAction: mapped,
      heroSizingBb: heroSizingBb,
      villainPosition: eval.villainPos,
      heroPosition: eval.heroPos,
      villainIsAggressor: eval.villainIsAggressor,
      callAmount: eval.callAmt,
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      heroClass: analysis.heroClass,
      isClose: isClose,
      equityIsExact: analysis.rawEquity.exact,
      villainAirShare: airShare,
      reasonCodes: reasonCodes,
    );
  }

  /// Shared ranges → equity → [DecisionModel] evaluation for [state].
  static _SpotEval? _evaluateSpot(GameState state) {
    final hero = state.hero;
    final heroSeat = state.players.indexWhere((p) => p.isHero);
    if (hero.holeCards.length < 2 || heroSeat < 0) return null;

    final callAmt = state.callAmountFor(hero);
    final villainInfo = _primaryVillain(state);
    final arch = villainInfo.player?.archetype ?? PlayerArchetype.tag;
    final pot = state.totalPot;
    final bb = state.bigBlind < 1 ? 1.0 : state.bigBlind;

    final heroCards = FastEvaluator.encodeAll(hero.holeCards);
    final board = FastEvaluator.encodeAll(state.community);
    final dead = {...heroCards, ...board};

    final views = <VillainView>[];
    for (var i = 0; i < state.players.length; i++) {
      final p = state.players[i];
      if (p.isHero || p.folded) continue;
      final range = _rangeFor(state, p, i, dead);
      if (range.isEmpty) continue;
      views.add(
        VillainView(
          archetype: p.archetype,
          name: p.name,
          position: state.positionLabel(i),
          range: range,
          currentBet: p.currentBet,
          stack: p.stack,
          isAggressor: state.lastAggressor == i,
        ),
      );
    }
    if (views.isEmpty) return null;

    final spot = SpotView(
      heroCards: heroCards,
      board: board,
      street: state.street,
      pot: pot,
      callAmount: callAmt,
      heroCurrentBet: hero.currentBet,
      heroStack: hero.stack,
      bigBlind: bb,
      villains: views,
      heroInPosition: _heroInPosition(state, heroSeat),
      seed: EquitySimulator.spotSeed(
        heroCards: heroCards,
        board: board,
        street: state.street.index,
        potCents: (pot * 100).round(),
      ),
    );

    return _SpotEval(
      spot: spot,
      analysis: DecisionModel.analyse(spot),
      hero: hero,
      arch: arch,
      villainName: villainInfo.player?.name ?? 'the field',
      villainPos: villainInfo.position,
      heroPos: state.positionLabel(heroSeat),
      callAmt: callAmt,
      pot: pot,
      bb: bb,
      villainIsAggressor: villainInfo.isAggressor,
    );
  }

  /// Builds one villain's range from their archetype and everything they have
  /// shown in this hand.
  ///
  /// Earlier streets are narrowed only weakly: reaching the turn proves they
  /// did not fold, but not whether that took a call or a free check. The
  /// current street uses the action actually observed.
  static HandRange _rangeFor(
    GameState state,
    PlayerModel villain,
    int seatIndex,
    Set<int> dead,
  ) {
    final board = FastEvaluator.encodeAll(state.community);
    final range = RangeBuilder.preflop(
      archetype: villain.archetype,
      positionLabel: state.positionLabel(seatIndex),
      asAggressor: state.street == Street.preflop &&
          state.lastAggressor == seatIndex,
    );

    for (final size in const [3, 4]) {
      if (board.length > size) {
        RangeBuilder.narrow(
          range: range,
          archetype: villain.archetype,
          board: board.sublist(0, size),
          action: RangeAction.survived,
        );
      }
    }

    if (board.length >= 3) {
      final observed = _observedAction(state, villain, seatIndex);
      if (observed != null) {
        RangeBuilder.narrow(
          range: range,
          archetype: villain.archetype,
          board: board,
          action: observed.action,
          sizeToPot: observed.sizeToPot,
        );
      }
    }

    range.removeCards(dead);
    return range;
  }

  /// What this villain has been seen doing on the current street.
  static ({RangeAction action, double sizeToPot})? _observedAction(
    GameState state,
    PlayerModel villain,
    int seatIndex,
  ) {
    final pot = state.totalPot;
    final potBefore = max(pot - villain.currentBet, state.bigBlind);

    if (state.lastAggressor == seatIndex &&
        villain.currentBet > Money.epsilon) {
      return (
        action: RangeAction.bet,
        sizeToPot: villain.currentBet / potBefore,
      );
    }
    if (!villain.hasActedThisRound) return null;
    if (villain.currentBet <= Money.epsilon) {
      return (action: RangeAction.checked, sizeToPot: 0);
    }
    return (
      action: RangeAction.called,
      sizeToPot: villain.currentBet / potBefore,
    );
  }

  /// Whether hero acts after every live villain on later streets.
  ///
  /// Seats are ranked by how close they are to the button, which is the order
  /// post-flop action actually runs in.
  static bool _heroInPosition(GameState state, int heroSeat) {
    final n = state.players.length;
    if (n == 0) return false;
    int distance(int seat) => (state.dealerIndex - seat + n) % n;
    final heroDistance = distance(heroSeat);
    for (var i = 0; i < n; i++) {
      final p = state.players[i];
      if (p.isHero || p.folded) continue;
      if (distance(i) < heroDistance) return false;
    }
    return true;
  }

  /// Picks the primary villain and whether they voluntarily aggressed.
  ///
  /// Blind posts never count as aggression ([GameState.lastAggressor] is only
  /// set on bet/raise). When nobody has raised, the biggest committed live
  /// seat is the reference villain but [isAggressor] stays false.
  static ({PlayerModel? player, String position, bool isAggressor})
      _primaryVillain(GameState state) {
    final aggressor = state.lastAggressor;
    if (aggressor != null &&
        aggressor >= 0 &&
        aggressor < state.players.length) {
      final p = state.players[aggressor];
      if (!p.isHero && !p.folded) {
        return (
          player: p,
          position: state.positionLabel(aggressor),
          isAggressor: true,
        );
      }
    }
    PlayerModel? best;
    var bestIdx = -1;
    for (var i = 0; i < state.players.length; i++) {
      final p = state.players[i];
      if (p.isHero || p.folded) continue;
      if (best == null || p.currentBet > best.currentBet) {
        best = p;
        bestIdx = i;
      }
    }
    if (best == null) {
      return (player: null, position: '', isAggressor: false);
    }
    return (
      player: best,
      position: state.positionLabel(bestIdx),
      isAggressor: false,
    );
  }

  static ExploitAction _mapAction(PokerAction action) {
    return switch (action.type) {
      PokerActionType.fold => ExploitAction.fold,
      PokerActionType.check => ExploitAction.check,
      PokerActionType.call => ExploitAction.call,
      PokerActionType.bet ||
      PokerActionType.raise ||
      PokerActionType.allIn =>
        ExploitAction.raise,
    };
  }
}

/// Internal spot snapshot shared by [LiveCoach.grade] and [LiveCoach.recommend].
class _SpotEval {
  const _SpotEval({
    required this.spot,
    required this.analysis,
    required this.hero,
    required this.arch,
    required this.villainName,
    required this.villainPos,
    required this.heroPos,
    required this.callAmt,
    required this.pot,
    required this.bb,
    required this.villainIsAggressor,
  });

  final SpotView spot;
  final DecisionAnalysis analysis;
  final PlayerModel hero;
  final PlayerArchetype arch;
  final String villainName;
  final String villainPos;
  final String heroPos;
  final double callAmt;
  final double pot;
  final double bb;
  final bool villainIsAggressor;
}
