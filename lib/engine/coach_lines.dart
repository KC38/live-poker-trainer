/// Spot-specific coach phrasing used offline and as the Claude fallback.
///
/// Every line names the concrete decision: the street, the villain and their
/// archetype, what the hero did, the better line, and why that archetype makes
/// it better. Openers rotate on a hash of the spot so two different decisions
/// never read as the same canned sentence.
///
/// Graded copy also embeds [CoachReasonCode] phrases — the same curriculum
/// spine required in [LiveCoachGrade.toPrompt] — so offline and Claude share
/// one vocabulary for *why* without a second strategy authority.
///
/// Voice is [CoachPersona] (Mack Hayes): short clauses, blunt live-cash
/// cadence, table slang. Persona never overrides [ExploitAction] or invents
/// reasons outside [CoachReasonCode] phrases.
library;

import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Original coach character — product voice only, never a strategy authority.
///
/// Shared by Claude's system prompt and offline [CoachLines] openers so the
/// shelf sounds like one coach whether the API is up or not. Does not name
/// any real author or claim endorsement.
abstract final class CoachPersona {
  /// In-product coach name.
  static const String name = 'Mack Hayes';

  /// One-line identity for prompts and tests.
  static const String blurb =
      'blunt live-cash coach — short clauses, table slang, no lectures';

  /// Style rules layered *around* the narration contract (voice only).
  static const String styleGuide = '''
Speak as Mack Hayes, an original character (not a real author; never claim
endorsement of any book or named pro).

Lexical style only:
- Short clauses. Hard stops. Live-table cadence, not a classroom lecture.
- Table slang is fine (leak, print, light, hang, barrel, price) when it
  dresses locked facts — never to invent a new line.
- Do not override the endorsed action. Do not invent multi-street plans.
- Do not introduce reasons outside the curriculum phrases you were given.
''';
}

/// The checkable facts behind a grade.
///
/// Coach copy used to assert a tendency and stop there ("folding this much
/// makes Sammy print"), which is unfalsifiable and reads as bluster when the
/// verdict is wrong. Every graded line now leads with numbers the player can
/// verify at the table: what the call costs, what it needs, and what the hand
/// actually has.
class CoachEvidence {
  /// Creates the evidence for one graded decision.
  const CoachEvidence({
    required this.equityPercent,
    required this.requiredEquityPercent,
    required this.heroHand,
    required this.heroClass,
    required this.villainName,
    required this.villainAirShare,
    required this.callAmount,
    required this.potSize,
    required this.hasBoard,
  });

  /// Hero's equity against the villain range, as a percentage.
  final int equityPercent;

  /// Equity needed to break even on a call. Zero when nothing is faced.
  final int requiredEquityPercent;

  /// Hero's hole cards, rendered for display.
  final String heroHand;

  /// What hero holds relative to the board.
  final HandClass heroClass;

  final String villainName;

  /// Share of the villain range that is air or a weak draw, `0..1`.
  final double villainAirShare;

  final double callAmount;
  final double potSize;
  final bool hasBoard;

  /// One sentence of arithmetic, or empty preflop where a board read would be
  /// invented rather than measured.
  String get sentence {
    final facing = callAmount > 0;
    final hand = heroHand.isEmpty ? 'your hand' : heroHand;
    final holding =
        hasBoard ? '$hand has ${heroClass.label} and ' : '$hand has ';

    if (facing) {
      return 'Calling ${ChipFormat.dollars(callAmount)} into '
          '${ChipFormat.dollars(potSize)} needs $requiredEquityPercent%; '
          '$holding$equityPercent% against '
          "$villainName's range here.";
    }
    return '$holding$equityPercent% against '
        "$villainName's range here"
        '${villainAirShare >= 0.4 ? ', and ${(villainAirShare * 100).round()}% '
            'of it is air or a weak draw' : ''}.';
  }
}

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

/// Curriculum spine: stable reason codes that explain a grade.
///
/// Derived from the same inputs as the EV grade (archetype, mismatch,
/// price/equity). Codes never change the recommended action — they only
/// supply shared *why* wording for offline [CoachLines] and Claude prompts.
///
/// Phrases are Miller-inspired live low-stakes exploitative ideas; they do
/// not name any author or claim endorsement. Ids are persistence-friendly —
/// do not rename an existing [id].
enum CoachReasonCode {
  /// Equity loses to pot odds — continue costs chips.
  foldWhenPriceWrong(
    'fold_when_price_wrong',
    'Fold when the price is wrong for your equity.',
  ),

  /// Equity beats pot odds — the call (or continue) is +EV at this price.
  continueWhenPriced(
    'continue_when_priced',
    'Continue when your equity beats the price.',
  ),

  /// Nits bet strong ranges; calling light is the classic leak.
  dontPayOffNits(
    'dont_pay_off_nits',
    "Don't pay off nits — their bets mean a real hand.",
  ),

  /// Nits over-fold when they have not shown strength.
  attackNitFolds(
    'attack_nit_folds',
    'Attack nits when they show weakness — they over-fold.',
  ),

  /// Raising a nit isolates against the top of their range.
  dontRaiseNitStrength(
    'dont_raise_nit_strength',
    "Don't raise into a nit's strength — only better hands continue.",
  ),

  /// Stations call too wide; thin value prints.
  valueThinVsStations(
    'value_thin_vs_stations',
    'Value thin against stations — they pay off too wide.',
  ),

  /// Stations do not fold; bluffs are gifts.
  neverBluffStations(
    'never_bluff_stations',
    'Never bluff stations — they call with almost anything.',
  ),

  /// Same action, larger size — stations call both.
  sizeUpVsStations(
    'size_up_vs_stations',
    'Size up for value vs stations — they call big almost as often as small.',
  ),

  /// Maniacs / LAGs bluff too often; folding the defend range is a leak.
  defendVsLooseAggro(
    'defend_vs_loose_aggro',
    'Defend wider vs loose-aggressive players — they bluff too much.',
  ),

  /// Even wide opponents sometimes have it; price still matters.
  dontChaseLooseAggro(
    'dont_chase_vs_loose_aggro',
    "Don't chase loose-aggressive bets when equity still loses to the price.",
  ),

  /// Let wide aggression pay you; raising can inflate a pot you already own.
  letAggroHang(
    'let_aggro_hang',
    'Let aggressive opponents hang themselves — call more, raise less.',
  ),

  /// TAG / solid aggression is credible.
  respectSolidBets(
    'respect_solid_bets',
    'Respect solid players when they fire — their range is credible.',
  ),

  /// Thin value and disciplined pot control vs solid opponents.
  takeThinEdges(
    'take_thin_edges',
    'Take thin value edges — bet when ahead, avoid bloating air.',
  ),

  /// Right action, wrong size.
  sizeMatters(
    'size_matters',
    'Size matters — the same action at a better price extracts more.',
  ),

  /// Fallback when no sharper exploit tag applies.
  playTheSpot(
    'play_the_spot',
    'Play the spot on its merits: equity, price, and who is in the pot.',
  );

  const CoachReasonCode(this.id, this.phrase);

  /// Stable identifier for prompts, logs, and future persistence.
  final String id;

  /// Canonical one-liner for offline copy and required Claude phrasing.
  final String phrase;

  /// Resolves a persisted id; unknown ids map to [playTheSpot].
  static CoachReasonCode fromId(String id) {
    for (final code in values) {
      if (code.id == id) return code;
    }
    return CoachReasonCode.playTheSpot;
  }

  /// Derives curriculum codes from the same facts as the EV grade.
  ///
  /// Order: price discipline first (when arithmetic decides continue/fold),
  /// then the archetype exploit. Never empty — [playTheSpot] is the fallback.
  static List<CoachReasonCode> derive({
    required PlayerArchetype archetype,
    required CoachMismatch mismatch,
    required ExploitAction? best,
    required int equityPercent,
    required int requiredEquityPercent,
    required double callAmount,
    required bool villainIsAggressor,
  }) {
    final codes = <CoachReasonCode>[];
    final facing = callAmount > 0;
    final equityBeatsPrice =
        !facing || equityPercent >= requiredEquityPercent;
    final equityMissesPrice =
        facing && equityPercent < requiredEquityPercent;

    _addPriceCodes(
      codes: codes,
      mismatch: mismatch,
      best: best,
      facing: facing,
      equityBeatsPrice: equityBeatsPrice,
      equityMissesPrice: equityMissesPrice,
    );

    final exploit = _exploitCode(
      archetype: archetype,
      mismatch: mismatch,
      best: best,
      villainIsAggressor: villainIsAggressor,
    );
    if (exploit != null && !codes.contains(exploit)) {
      codes.add(exploit);
    }

    if (codes.isEmpty) {
      codes.add(CoachReasonCode.playTheSpot);
    }
    return List.unmodifiable(codes);
  }

  static void _addPriceCodes({
    required List<CoachReasonCode> codes,
    required CoachMismatch mismatch,
    required ExploitAction? best,
    required bool facing,
    required bool equityBeatsPrice,
    required bool equityMissesPrice,
  }) {
    if (!facing) return;

    switch (mismatch) {
      case CoachMismatch.tooLoose:
        if (equityMissesPrice) {
          codes.add(CoachReasonCode.foldWhenPriceWrong);
        }
      case CoachMismatch.tooTight:
        if (equityBeatsPrice) {
          codes.add(CoachReasonCode.continueWhenPriced);
        }
      case CoachMismatch.none:
        if (best == ExploitAction.fold && equityMissesPrice) {
          codes.add(CoachReasonCode.foldWhenPriceWrong);
        } else if ((best == ExploitAction.call ||
                best == ExploitAction.raise) &&
            equityBeatsPrice) {
          codes.add(CoachReasonCode.continueWhenPriced);
        }
      case CoachMismatch.tooPassive:
      case CoachMismatch.tooAggressive:
      case CoachMismatch.sizing:
        break;
    }
  }

  /// Archetype exploit tag for this mismatch (or correct line).
  static CoachReasonCode? _exploitCode({
    required PlayerArchetype archetype,
    required CoachMismatch mismatch,
    required ExploitAction? best,
    required bool villainIsAggressor,
  }) {
    return switch (archetype) {
      PlayerArchetype.nit => _nitCode(mismatch, best, villainIsAggressor),
      PlayerArchetype.callingStation => _stationCode(mismatch, best),
      PlayerArchetype.maniac || PlayerArchetype.lag =>
        _aggroCode(mismatch, best),
      PlayerArchetype.tag => _tagCode(mismatch, best),
      PlayerArchetype.hero => CoachReasonCode.playTheSpot,
    };
  }

  static CoachReasonCode _nitCode(
    CoachMismatch mismatch,
    ExploitAction? best,
    bool villainIsAggressor,
  ) {
    return switch (mismatch) {
      CoachMismatch.tooLoose => CoachReasonCode.dontPayOffNits,
      CoachMismatch.tooTight || CoachMismatch.tooPassive =>
        CoachReasonCode.attackNitFolds,
      CoachMismatch.tooAggressive => CoachReasonCode.dontRaiseNitStrength,
      CoachMismatch.sizing => CoachReasonCode.sizeMatters,
      CoachMismatch.none => best == ExploitAction.fold && villainIsAggressor
          ? CoachReasonCode.dontPayOffNits
          : best == ExploitAction.raise
              ? CoachReasonCode.attackNitFolds
              : CoachReasonCode.dontPayOffNits,
    };
  }

  static CoachReasonCode _stationCode(
    CoachMismatch mismatch,
    ExploitAction? best,
  ) {
    return switch (mismatch) {
      CoachMismatch.tooAggressive => CoachReasonCode.neverBluffStations,
      CoachMismatch.tooPassive => CoachReasonCode.valueThinVsStations,
      CoachMismatch.tooTight => CoachReasonCode.valueThinVsStations,
      CoachMismatch.tooLoose => CoachReasonCode.playTheSpot,
      CoachMismatch.sizing => CoachReasonCode.sizeUpVsStations,
      CoachMismatch.none => best == ExploitAction.raise
          ? CoachReasonCode.valueThinVsStations
          : best == ExploitAction.check || best == ExploitAction.fold
              ? CoachReasonCode.neverBluffStations
              : CoachReasonCode.valueThinVsStations,
    };
  }

  static CoachReasonCode _aggroCode(
    CoachMismatch mismatch,
    ExploitAction? best,
  ) {
    return switch (mismatch) {
      CoachMismatch.tooTight => CoachReasonCode.defendVsLooseAggro,
      CoachMismatch.tooLoose => CoachReasonCode.dontChaseLooseAggro,
      CoachMismatch.tooAggressive => CoachReasonCode.letAggroHang,
      CoachMismatch.tooPassive => CoachReasonCode.defendVsLooseAggro,
      CoachMismatch.sizing => CoachReasonCode.sizeMatters,
      CoachMismatch.none => best == ExploitAction.fold
          ? CoachReasonCode.dontChaseLooseAggro
          : CoachReasonCode.defendVsLooseAggro,
    };
  }

  static CoachReasonCode _tagCode(
    CoachMismatch mismatch,
    ExploitAction? best,
  ) {
    return switch (mismatch) {
      CoachMismatch.tooLoose => CoachReasonCode.respectSolidBets,
      CoachMismatch.tooTight => CoachReasonCode.takeThinEdges,
      CoachMismatch.tooPassive => CoachReasonCode.takeThinEdges,
      CoachMismatch.tooAggressive => CoachReasonCode.respectSolidBets,
      CoachMismatch.sizing => CoachReasonCode.sizeMatters,
      CoachMismatch.none => best == ExploitAction.fold
          ? CoachReasonCode.respectSolidBets
          : CoachReasonCode.takeThinEdges,
    };
  }
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
            'Checked to you $where. $villainName is a '
                '${archetype.shortLabel.toLowerCase()} — '
                '${_freeCheckPlan(archetype)}',
            'Free look $where. Vs a '
                '${archetype.shortLabel.toLowerCase()} like $villainName: '
                '${_freeCheckPlan(archetype)}',
          ]
        : <String>[
            'Close $where for ${ChipFormat.dollars(callAmount)}. '
                '${_facingBetPlan(archetype, villainName, villainIsAggressor)}',
            'No clear print $where. '
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
    bool isClose = false,
    CoachEvidence? evidence,
    double sizingHintBb = 0,
    List<CoachReasonCode> reasonCodes = const [],
  }) {
    final where = _streetPhrase(street);
    final facts = evidence?.sentence ?? '';
    // Curriculum spine first when present so offline copy matches toPrompt.
    final why = reasonCodes.isNotEmpty
        ? reasonCodes.map((c) => c.phrase).join(' ')
        : _why(
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
      // A line that was not the top choice but sat inside the model's margin
      // is fine, and saying so is more useful — and more honest — than
      // congratulating the player on a line the model did not pick.
      // Mack Hayes cadence: short clauses, hard stops, table slang.
      final openers = sizingHintBb > 0
          // The decision was right and is scored right; the size is a note,
          // not a mark against them.
          ? <String>[
              'Solid ${_noun(taken)} $where — next time ${_bb(sizingHintBb)}',
              '${_verb(taken)} is right $where. Size it to ${_bb(sizingHintBb)}',
            ]
          : isClose
          ? <String>[
              'Fine line $where — close call. ${_noun(best)} barely ahead',
              'Close $where. ${_noun(taken)} costs almost nothing vs '
                  '${_noun(best)}',
            ]
          : <String>[
              'Right. ${_verb(taken)} $where',
              "That's the spot. ${_verb(taken).toLowerCase()} $where",
              'Clean ${_noun(taken)} $where',
              'Good ${_noun(taken)}. Exactly $where',
            ];
      return _join(_pick(openers, seed: seed), facts, why);
    }

    final better = _betterPhrase(best, bestSizing, potSize, callAmount);
    final openers = switch (mismatch) {
      CoachMismatch.sizing => <String>[
          'Right idea, wrong size $where. You ${_bb(heroSizing)}; '
              'target ${_bb(bestSizing)}',
          'Size is off $where — target ${_bb(bestSizing)}, not your '
              '${_bb(heroSizing)}',
        ],
      CoachMismatch.tooLoose => <String>[
          'Too loose $where. You ${_verb(taken).toLowerCase()}d; $better',
          'Leak $where: ${_verb(taken).toLowerCase()}ing. $better',
        ],
      CoachMismatch.tooTight => <String>[
          'Too tight $where. Folded when $better',
          'Gave it up $where. $better',
        ],
      CoachMismatch.tooPassive => <String>[
          'Too soft $where. You ${_verb(taken).toLowerCase()}d; $better',
          'Left chips out $where. $better',
        ],
      CoachMismatch.tooAggressive => <String>[
          'Too hot $where. You ${_verb(taken).toLowerCase()}d; $better',
          'Overplaying it $where. $better',
        ],
      CoachMismatch.none => <String>['Close $where. $better'],
    };
    return _join(_pick(openers, seed: seed), facts, why);
  }

  // --- phrasing helpers ---

  /// Joins the opener, the arithmetic, and the archetype reason into one
  /// paragraph, skipping any part that is empty.
  static String _join(String opener, String facts, String why) {
    final parts = <String>[
      if (opener.isNotEmpty) '$opener.',
      if (facts.isNotEmpty) facts,
      if (why.isNotEmpty) why,
    ];
    return parts.join(' ');
  }

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

  /// Bet sizes in big blinds. Small sizes keep a decimal, because the gap
  /// between "3 BB" and "3.5 BB" is the whole point of a sizing note.
  static String _bb(double sizingBb) => sizingBb < 10
      ? '${sizingBb.toStringAsFixed(1)} BB'
      : '${sizingBb.toStringAsFixed(0)} BB';

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
