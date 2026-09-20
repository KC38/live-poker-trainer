/// Villain decisions sampled from [VillainModel] frequencies.
///
/// The coach narrows ranges with the same bet / call / raise tables. Driving
/// felt play from those frequencies keeps "calling station on the table" and
/// "calling station in the grade" aligned.
///
/// **RNG contract:** each call to [decide] draws at most one
/// [Random.nextDouble] for the primary action sample. Legal fallbacks (cannot
/// raise → call; cannot bet → check) are deterministic and do not re-roll.
/// Preflop lag/maniac open-raises also use that single roll. Pass a seeded
/// [Random] for reproducible tests.
library;

import 'dart:math';

import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/villain_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Legal lines the villain AI may choose.
enum VillainLine {
  /// Fold to a bet.
  fold,

  /// Check when facing no bet.
  check,

  /// Call the current bet (amount is chips to add).
  call,

  /// Bet or raise to [VillainChoice.raiseTo].
  raise,
}

/// A sampled villain decision before the engine applies chip accounting.
class VillainChoice {
  /// Creates a choice.
  const VillainChoice({
    required this.line,
    this.callAmount = 0,
    this.raiseTo = 0,
  });

  final VillainLine line;

  /// Chips to add for [VillainLine.call].
  final double callAmount;

  /// Absolute street total for [VillainLine.raise].
  final double raiseTo;
}

/// Samples a legal [VillainChoice] for a villain seat from [VillainModel].
class VillainAi {
  VillainAi._();

  /// Default open/probe size as a fraction of pot (matches model reference).
  static const double defaultBetToPot = VillainModel.referenceBetToPot;

  /// Decides for [playerIdx] in [state] using [random].
  ///
  /// Postflop uses [HandClassifier] + [VillainModel]. Preflop keeps
  /// chart-style hole-card heuristics because hand classes are board-relative.
  /// Never returns fold when checking is free (`callAmount == 0`).
  static VillainChoice decide(
    GameState state,
    int playerIdx,
    Random random,
  ) {
    final villain = state.players[playerIdx];
    final callAmount = state.callAmountFor(villain);

    if (callAmount <= Money.epsilon) {
      return _whenCheckedTo(state, villain, random);
    }

    if (state.street == Street.preflop) {
      return _preflopFacingBet(state, villain, callAmount, random);
    }

    return _postflopFacingBet(state, villain, callAmount, random);
  }

  /// Classifies [villain]'s hole cards on [state]'s board for diagnostics/tests.
  static HandClass handClassFor(GameState state, PlayerModel villain) {
    if (villain.holeCards.length < 2 || state.community.length < 3) {
      return HandClass.air;
    }
    final holes = FastEvaluator.encodeAll(villain.holeCards);
    final board = FastEvaluator.encodeAll(state.community);
    return HandClassifier.classify(holes[0], holes[1], board);
  }

  /// Probe / value size as a pot fraction for [archetype] when betting first.
  static double betSizeFraction(PlayerArchetype archetype) =>
      switch (archetype) {
        PlayerArchetype.maniac => 0.75,
        PlayerArchetype.lag => 0.66,
        PlayerArchetype.callingStation => 0.40,
        PlayerArchetype.nit => 0.50,
        PlayerArchetype.tag || PlayerArchetype.hero => defaultBetToPot,
      };

  // ---------------------------------------------------------------------------
  // Checked to (or option to bet)
  // ---------------------------------------------------------------------------

  static VillainChoice _whenCheckedTo(
    GameState state,
    PlayerModel villain,
    Random random,
  ) {
    // Free-check rule: never fold. Preflop BB option stays a check — the
    // board-relative model does not describe open-raise ranges.
    if (state.street == Street.preflop) {
      return const VillainChoice(line: VillainLine.check);
    }

    final handClass = handClassFor(state, villain);
    final fraction = betSizeFraction(villain.archetype);
    final betP = VillainModel.betFrequency(
      villain.archetype,
      handClass,
      betToPot: fraction,
    );

    final roll = random.nextDouble();
    if (roll >= betP) {
      return const VillainChoice(line: VillainLine.check);
    }

    final pot = max(state.totalPot, state.bigBlind);
    final desired = max(state.bigBlind, pot * fraction);
    final target = _legalRaiseTarget(state, villain, desired);
    if (target <= state.highestBet + Money.epsilon) {
      return const VillainChoice(line: VillainLine.check);
    }
    return VillainChoice(line: VillainLine.raise, raiseTo: target);
  }

  // ---------------------------------------------------------------------------
  // Facing a bet — postflop
  // ---------------------------------------------------------------------------

  static VillainChoice _postflopFacingBet(
    GameState state,
    PlayerModel villain,
    double callAmount,
    Random random,
  ) {
    final handClass = handClassFor(state, villain);
    final pot = state.totalPot;
    final potWithoutCall = max(1.0, pot - callAmount);
    final priceToPot = callAmount / potWithoutCall;

    var raiseP = VillainModel.raiseFrequency(
      villain.archetype,
      handClass,
      priceToPot: priceToPot,
    );
    var callP = VillainModel.callFrequency(
      villain.archetype,
      handClass,
      priceToPot: priceToPot,
    );

    final canRaise = _canRaise(state, villain, callAmount);
    if (!canRaise) {
      // Absorb raise mass into call — they still want to put money in.
      callP = (callP + raiseP).clamp(0.0, 1.0);
      raiseP = 0.0;
    }

    // Profiles can sum above 1 (e.g. stations with monsters). Normalize so the
    // sample is a proper distribution; fold mass is whatever remains.
    final continueMass = raiseP + callP;
    if (continueMass > 1.0) {
      raiseP /= continueMass;
      callP /= continueMass;
    }

    final roll = random.nextDouble();
    if (roll < raiseP) {
      final target = _raiseTarget(state, villain, pot);
      if (target > state.highestBet + Money.epsilon) {
        return VillainChoice(line: VillainLine.raise, raiseTo: target);
      }
      // Illegal raise after sampling — deterministic call fallback (no re-roll).
      return VillainChoice(line: VillainLine.call, callAmount: callAmount);
    }
    if (roll < raiseP + callP) {
      return VillainChoice(line: VillainLine.call, callAmount: callAmount);
    }
    return const VillainChoice(line: VillainLine.fold);
  }

  // ---------------------------------------------------------------------------
  // Facing a bet — preflop (chart heuristics; not VillainModel)
  // ---------------------------------------------------------------------------

  static VillainChoice _preflopFacingBet(
    GameState state,
    PlayerModel villain,
    double callAmount,
    Random random,
  ) {
    final arch = villain.archetype;
    final high = max(villain.holeCards[0].rank, villain.holeCards[1].rank);
    final low = min(villain.holeCards[0].rank, villain.holeCards[1].rank);
    final isPair = villain.holeCards[0].rank == villain.holeCards[1].rank;
    final isSuited = villain.holeCards[0].suit == villain.holeCards[1].suit;

    switch (arch) {
      case PlayerArchetype.maniac:
      case PlayerArchetype.lag:
        // Single RNG draw: raise attempt vs call.
        if (random.nextDouble() < 0.4 &&
            _canRaise(state, villain, callAmount)) {
          final target = _legalRaiseTarget(
            state,
            villain,
            state.highestBet + max(state.minRaise, state.bigBlind) * 4,
          );
          if (target > state.highestBet + Money.epsilon) {
            return VillainChoice(line: VillainLine.raise, raiseTo: target);
          }
        }
        return VillainChoice(line: VillainLine.call, callAmount: callAmount);
      case PlayerArchetype.nit:
        final premium =
            (isPair && villain.holeCards[0].rank >= 10) ||
            (high == 14 && isSuited);
        return premium
            ? VillainChoice(line: VillainLine.call, callAmount: callAmount)
            : const VillainChoice(line: VillainLine.fold);
      case PlayerArchetype.callingStation:
        final play = callAmount <= state.bigBlind * 3 || isPair || isSuited;
        return play
            ? VillainChoice(line: VillainLine.call, callAmount: callAmount)
            : const VillainChoice(line: VillainLine.fold);
      default:
        final playable = isPair || (high >= 11 && low >= 9);
        return playable
            ? VillainChoice(line: VillainLine.call, callAmount: callAmount)
            : const VillainChoice(line: VillainLine.fold);
    }
  }

  // ---------------------------------------------------------------------------
  // Sizing helpers (mirrors PokerEngine legal-raise rules)
  // ---------------------------------------------------------------------------

  static bool _canRaise(
    GameState state,
    PlayerModel villain,
    double callAmount,
  ) {
    if (villain.stack <= callAmount + Money.epsilon) return false;
    final minTo = _minRaiseTo(state, villain);
    return minTo > state.highestBet + Money.epsilon;
  }

  static double _raiseTarget(
    GameState state,
    PlayerModel villain,
    double pot,
  ) {
    final desired = state.highestBet + max(state.minRaise, pot * 0.8);
    return _legalRaiseTarget(state, villain, desired);
  }

  static double _minRaiseTo(GameState state, PlayerModel player) {
    final allIn = Money.round(player.stack + player.currentBet);
    final increment = max(state.minRaise, state.bigBlind);
    final floor = Money.round(state.highestBet + increment);
    if (floor >= allIn - Money.epsilon) return allIn;
    return floor;
  }

  static double _legalRaiseTarget(
    GameState state,
    PlayerModel villain,
    double desired,
  ) {
    final allIn = Money.round(villain.stack + villain.currentBet);
    final increment = max(state.minRaise, state.bigBlind);
    final floor = Money.round(state.highestBet + increment);
    if (allIn <= state.highestBet + Money.epsilon) {
      return allIn;
    }
    if (floor >= allIn - Money.epsilon) {
      return allIn;
    }
    return Money.clamp(Money.round(desired), floor, allIn);
  }
}
