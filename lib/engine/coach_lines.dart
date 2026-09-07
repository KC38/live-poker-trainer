/// Spot-specific coach phrasing used offline and as the Gemini fallback.
///
/// Every line names the concrete decision: the street, the villain and their
/// archetype, what the hero did, the better line, and why that archetype makes
/// it better. Openers rotate on a hash of the spot so two different decisions
/// never read as the same canned sentence.
library;

import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// How the hero's action differed from the better line.
enum CoachMismatch {
  /// Hero played the recommended line.
  none,

  /// Hero continued where folding was better.
  tooLoose,

  /// Hero folded where continuing was better.
  tooTight,

  /// Hero called or checked where raising was better.
  tooPassive,

  /// Hero raised where calling or checking was better.
  tooAggressive,

  /// Right action, wrong bet size.
  sizing,
}

/// Builds varied, decision-specific coaching copy.
class CoachLines {
  CoachLines._();

  /// Rotates openers so back-to-back spots of the same shape still differ.
  static int _rotation = 0;

  /// Resets rotation. Used by tests for determinism.
  static void resetRotation() => _rotation = 0;

  /// Classifies the hero's action against the recommended one.
  static CoachMismatch classify({
    required ExploitAction best,
    required ExploitAction taken,
    required bool sizingOff,
  }) {
    if (best == taken) {
      return sizingOff ? CoachMismatch.sizing : CoachMismatch.none;
    }
    if (best == ExploitAction.fold) return CoachMismatch.tooLoose;
    if (taken == ExploitAction.fold) return CoachMismatch.tooTight;
    if (best == ExploitAction.raise) return CoachMismatch.tooPassive;
    return CoachMismatch.tooAggressive;
  }

  /// A one-line table read shown when a new hand is dealt.
  static String dealIntro(GameState game) {
    final hero = game.hero;
    final hand = hero.holeCards.map((c) => c.display).join(' ');
    final villains = game.players.where((p) => !p.isHero).toList();
    if (villains.isEmpty) return 'New hand — $hand. Your move.';

    final counts = <PlayerArchetype, int>{};
    for (final v in villains) {
      counts[v.archetype] = (counts[v.archetype] ?? 0) + 1;
    }
    final headline = counts.entries.reduce(
      (a, b) => b.value > a.value ? b : a,
    );
    final plan = switch (headline.key) {
      PlayerArchetype.callingStation =>
        'stations at the table — plan for showdown value, not bluffs',
      PlayerArchetype.nit =>
        'nits at the table — steal their checks, believe their bets',
      PlayerArchetype.maniac =>
        'maniacs at the table — let them build it, call a shade wider',
      PlayerArchetype.lag => 'LAGs at the table — defend more, trap harder',
      PlayerArchetype.tag => 'TAGs at the table — hunt thin edges, avoid wars',
      PlayerArchetype.hero => 'a mixed table — read each seat',
    };
    return '$hand, ${game.players.length}-handed. '
        '${headline.value} $plan.';
  }

  /// Short pre-action tip for the decision hero faces right now.
  ///
  /// One line only — never stacks with a live grade. Names street, pot, and
  /// the villain to act against so the shelf stays decision-specific.
  static String decisionTip({
    required Street street,
    required String villainName,
    required PlayerArchetype archetype,
    required double callAmount,
    required double pot,
    required bool villainIsAggressor,
    String villainPosition = '',
  }) {
    final where = _streetPhrase(street);
    final potLine = ChipFormat.dollars(pot);
    final seat = villainPosition.isEmpty ? '' : ' ($villainPosition)';
    final arch = archetype.shortLabel;

    if (callAmount <= 0) {
      final options = <String>[
        'Checked to you $where — pot $potLine. Bet or take the free card.',
        'Your turn $where vs $villainName$seat ($arch). Pot $potLine.',
      ];
      return _pick(options, seed: street.index + archetype.index * 5);
    }

    final price = ChipFormat.dollars(callAmount);
    final options = villainIsAggressor
        ? <String>[
            '$villainName$seat ($arch) bets $where — $price to call, '
                'pot $potLine.',
            'Facing $price $where from $villainName$seat ($arch). '
                'Pot $potLine.',
          ]
        : <String>[
            '$price to call $where vs $villainName$seat ($arch). '
                'Pot $potLine.',
            'Your turn $where — $price vs $villainName$seat ($arch), '
                'pot $potLine.',
          ];
    return _pick(options, seed: street.index * 11 + archetype.index * 3);
  }

  /// Coaching for a spot where no clean exploit line exists.
  static String ambiguous({
    required PlayerArchetype archetype,
    required Street street,
    required String villainName,
    required double callAmount,
    bool villainIsAggressor = true,
  }) {
    final free = callAmount <= 0;
    final where = _streetPhrase(street);
    final options = free
        ? <String>[
            '$where and it is checked to you — $villainName is a '
                '${archetype.shortLabel.toLowerCase()}, so ${_freeCheckPlan(archetype)}',
            'Free look $where. Against a '
                '${archetype.shortLabel.toLowerCase()} like $villainName, '
                '${_freeCheckPlan(archetype)}',
          ]
        : <String>[
            'Close spot $where for ${ChipFormat.dollars(callAmount)}. '
                '${_facingBetPlan(archetype, villainName, villainIsAggressor)}',
            'No clear exploit $where — '
                '${_facingBetPlan(archetype, villainName, villainIsAggressor)}',
          ];
    return _pick(options, seed: street.index + archetype.index * 7);
  }

  /// The graded coaching line for a hero decision.
  static String forGrade({
    required bool correct,
    required CoachMismatch mismatch,
    required PlayerArchetype archetype,
    required String villainName,
    required Street street,
    required ExploitAction best,
    required ExploitAction taken,
    required double bestSizing,
    required double heroSizing,
    required double potSize,
    required double callAmount,
    bool villainIsAggressor = true,
    String villainPosition = '',
  }) {
    final where = _streetPhrase(street);
    final why = _why(
      mismatch: mismatch,
      archetype: archetype,
      villainName: villainName,
      street: street,
      villainIsAggressor: villainIsAggressor,
      villainPosition: villainPosition,
    );
    final seed = street.index * 31 +
        archetype.index * 7 +
        best.index * 3 +
        taken.index;

    if (correct) {
      final openers = <String>[
        '${_verb(taken)} is right $where',
        'Correct — ${_verb(taken).toLowerCase()} $where',
        'Good ${_noun(taken)} $where',
        'Nice ${_noun(taken)} — exactly the line $where',
      ];
      return '${_pick(openers, seed: seed)}. $why';
    }

    final better = _betterPhrase(best, bestSizing, potSize, callAmount);
    final openers = switch (mismatch) {
      CoachMismatch.sizing => <String>[
          'Right idea, wrong size $where — you made it '
              '${_bb(heroSizing)}, target ${_bb(bestSizing)}',
          'Sizing is off $where: ${_bb(heroSizing)} instead of '
              '${_bb(bestSizing)}',
        ],
      CoachMismatch.tooLoose => <String>[
          'Too loose $where — you ${_verb(taken).toLowerCase()}d where $better',
          'That is a leak $where: ${_verb(taken).toLowerCase()}ing costs you, $better',
        ],
      CoachMismatch.tooTight => <String>[
          'Too tight $where — you folded where $better',
          'Folding $where gives up too much value; $better',
        ],
      CoachMismatch.tooPassive => <String>[
          'Too passive $where — you ${_verb(taken).toLowerCase()}d, $better',
          'You left money out there $where: $better',
        ],
      CoachMismatch.tooAggressive => <String>[
          'Too aggressive $where — you ${_verb(taken).toLowerCase()}d, $better',
          'Over-betting the spot $where: $better',
        ],
      CoachMismatch.none => <String>['Close $where, $better'],
    };
    return '${_pick(openers, seed: seed)}. $why';
  }

  // --- phrasing helpers ---

  static String _pick(List<String> options, {required int seed}) {
    if (options.isEmpty) return '';
    _rotation++;
    return options[(seed + _rotation) % options.length];
  }

  static String _streetPhrase(Street street) => switch (street) {
        Street.preflop => 'preflop',
        Street.flop => 'on the flop',
        Street.turn => 'on the turn',
        Street.river => 'on the river',
        Street.showdown => 'at showdown',
      };

  static String _verb(ExploitAction action) => switch (action) {
        ExploitAction.fold => 'Fold',
        ExploitAction.check => 'Check',
        ExploitAction.call => 'Call',
        ExploitAction.raise => 'Raise',
      };

  static String _noun(ExploitAction action) => switch (action) {
        ExploitAction.fold => 'fold',
        ExploitAction.check => 'check',
        ExploitAction.call => 'call',
        ExploitAction.raise => 'raise',
      };

  static String _bb(double sizingBb) => '${sizingBb.toStringAsFixed(0)} BB';

  static String _betterPhrase(
    ExploitAction best,
    double bestSizing,
    double potSize,
    double callAmount,
  ) {
    return switch (best) {
      ExploitAction.fold => 'folding for ${ChipFormat.dollars(callAmount)} '
          'was the cheaper line',
      ExploitAction.check => 'checking keeps the pot small and your range wide',
      ExploitAction.call => 'calling ${ChipFormat.dollars(callAmount)} into '
          '${ChipFormat.dollars(potSize)} was better',
      ExploitAction.raise => bestSizing > 0
          ? 'raising to about ${_bb(bestSizing)} was better'
          : 'raising was better',
    };
  }

  static String _freeCheckPlan(PlayerArchetype archetype) => switch (archetype) {
        PlayerArchetype.nit => 'a probe bet picks this up far too often.',
        PlayerArchetype.callingStation =>
          'only bet when you actually hold value — they will call.',
        PlayerArchetype.maniac =>
          'checking lets them bluff into you; keep the trap set.',
        PlayerArchetype.lag => 'check and let them barrel into your strength.',
        PlayerArchetype.tag => 'bet your value, check your air.',
        PlayerArchetype.hero => 'take the free card.',
      };

  static String _facingBetPlan(
    PlayerArchetype archetype,
    String name,
    bool isAggressor,
  ) =>
      switch (archetype) {
        PlayerArchetype.nit => isAggressor
            ? '$name is a nit, so their bet is close to the nuts — need real equity.'
            : '$name is a nit — do not pay them off light just to see a flop.',
        PlayerArchetype.callingStation => isAggressor
            ? '$name calls too much but rarely bluffs, so their bet means a hand.'
            : '$name is a station — value when you connect, avoid bloating light.',
        PlayerArchetype.maniac =>
          '$name is a maniac, so discount their range and lean toward calling.',
        PlayerArchetype.lag =>
          '$name is a LAG, so widen your continues but keep raises honest.',
        PlayerArchetype.tag => isAggressor
            ? '$name is a TAG, so respect the bet and look for a cheaper street.'
            : '$name is a TAG — hunt thin edges without forcing the pot.',
        PlayerArchetype.hero => 'take the price that matches your equity.',
      };

  /// The archetype-specific reason the recommended line beats the taken one.
  static String _why({
    required CoachMismatch mismatch,
    required PlayerArchetype archetype,
    required String villainName,
    required Street street,
    required bool villainIsAggressor,
    String villainPosition = '',
  }) {
    final late = street == Street.turn || street == Street.river;
    final seat = villainPosition.isEmpty ? '' : ' ($villainPosition)';
    return switch (archetype) {
      PlayerArchetype.nit => switch (mismatch) {
          CoachMismatch.tooLoose => villainIsAggressor
              ? '$villainName$seat is a nit — when they fire, they have it. '
                  'Paying them off is the single most expensive leak.'
              : '$villainName$seat is a nit — posting or calling is not '
                  'aggression. Paying them off light is still a leak.',
          CoachMismatch.tooTight =>
            'Nits also over-fold. $villainName$seat gives up too often to keep '
                'folding your equity.',
          CoachMismatch.tooPassive => late
              ? 'Nits check-fold turns and rivers constantly — $villainName$seat '
                  'hands you the pot if you bet.'
              : 'Nits fold too much preflop; take the initiative from '
                  '$villainName$seat.',
          CoachMismatch.tooAggressive =>
            'Raising a nit only gets called by better. $villainName$seat is not '
                'folding a hand strong enough to bet.',
          CoachMismatch.sizing =>
            'Nits are price-sensitive: size for the fold, not for the pot.',
          CoachMismatch.none => villainIsAggressor
              ? '$villainName$seat is a nit — believe their bets, attack their checks.'
              : '$villainName$seat is a nit — believe real bets, attack their checks.',
        },
      PlayerArchetype.callingStation => switch (mismatch) {
          CoachMismatch.tooLoose =>
            'Stations bet only when they connect. $villainName leading out is '
                'the one time to believe them.',
          CoachMismatch.tooTight =>
            '$villainName calls with everything, so your showdown value is '
                'worth more than usual — do not fold it.',
          CoachMismatch.tooPassive =>
            'Stations pay off. Every street you do not bet, $villainName '
                'keeps money you were owed.',
          CoachMismatch.tooAggressive =>
            'You cannot bluff a station. $villainName calls, so raising just '
                'inflates a pot you are not favoured in.',
          CoachMismatch.sizing =>
            'Size up against stations — $villainName calls a big bet almost '
                'as often as a small one.',
          CoachMismatch.none =>
            '$villainName is a station: value big, bluff never.',
        },
      PlayerArchetype.maniac => switch (mismatch) {
          CoachMismatch.tooLoose =>
            'Even maniacs get there. $villainName is wide, not bluffing with '
                'literally everything.',
          CoachMismatch.tooTight =>
            '$villainName bluffs far too often — folding here hands them the '
                'pot they were buying.',
          CoachMismatch.tooPassive =>
            'Let $villainName pay for the aggression. A raise charges their '
                'whole bluffing range.',
          CoachMismatch.tooAggressive =>
            'No need to raise a maniac — $villainName bets for you. Keep the '
                'pot where your equity is best.',
          CoachMismatch.sizing =>
            'Against a maniac, sizing should target their calling range, not '
                'their folds.',
          CoachMismatch.none =>
            '$villainName is a maniac — let them hang themselves.',
        },
      PlayerArchetype.lag => switch (mismatch) {
          CoachMismatch.tooLoose =>
            '$villainName is wide but not reckless; this line needs more than '
                'a hope card.',
          CoachMismatch.tooTight =>
            'Folding this much versus a LAG makes $villainName print. Defend '
                'wider.',
          CoachMismatch.tooPassive =>
            'LAGs fold to re-aggression more than they let on — put '
                '$villainName to the test.',
          CoachMismatch.tooAggressive =>
            '$villainName has a wide range that continues; calling keeps '
                'their bluffs in and your risk down.',
          CoachMismatch.sizing =>
            'Versus a LAG, pick a size that is awkward for their float range.',
          CoachMismatch.none =>
            '$villainName is a LAG — defend more, trap more.',
        },
      PlayerArchetype.tag => switch (mismatch) {
          CoachMismatch.tooLoose =>
            '$villainName is solid, so their aggression is credible. Save the '
                'chips for a better spot.',
          CoachMismatch.tooTight =>
            'Even TAGs cannot have it every time. $villainName is bluffing '
                'often enough to continue.',
          CoachMismatch.tooPassive =>
            'Thin value works against a TAG — $villainName folds worse and '
                'calls with second best.',
          CoachMismatch.tooAggressive =>
            'Raising a TAG mostly isolates you against better. Keep it '
                'small versus $villainName.',
          CoachMismatch.sizing =>
            'TAGs read sizing well — keep your bets consistent across the '
                'range.',
          CoachMismatch.none =>
            '$villainName is a TAG — take thin edges, avoid the big wars.',
        },
      PlayerArchetype.hero => 'Play the spot on its merits, one street at a '
          'time.',
    };
  }
}
