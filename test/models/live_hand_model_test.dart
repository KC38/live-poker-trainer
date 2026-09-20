/// Client projection tests for authoritative live side-pot payouts.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';

Map<String, dynamic> _terminalView({
  required List<Map<String, dynamic>> pots,
  required List<int> winnerSeats,
}) {
  return {
    'sessionId': 'session',
    'handId': 'hand',
    'setupKey': 'setup',
    'decisionId': 'terminal',
    'stateVersion': 2,
    'smallBlind': 1,
    'bigBlind': 2,
    'street': 'river',
    'board': ['2c', '3d', '4h', '8s', 'Kd'],
    'pot': 500,
    'buttonSeat': 0,
    'heroSeat': 0,
    'actorSeat': null,
    'status': 'complete',
    'terminalReason': 'showdown',
    'seats': [
      for (var seat = 0; seat < 3; seat++)
        {
          'seat': seat,
          'name': seat == 0 ? 'Hero' : 'Villain $seat',
          'archetype': seat == 0 ? 'HERO' : 'TAG',
          'stack': 0,
          'streetBet': 0,
          'folded': false,
          'allIn': true,
          'holeCards':
              [
                ['Ah', 'Ad'],
                ['Kh', 'Kd'],
                ['Qh', 'Qd'],
              ][seat],
        },
    ],
    'legalActions': <Map<String, dynamic>>[],
    'winnerSeats': winnerSeats,
    'pots': pots,
  };
}

void main() {
  test('keeps distinct main and side-pot winners separate', () {
    final view = LiveHandViewModel.fromJson(
      _terminalView(
        winnerSeats: [0, 1],
        pots: [
          {
            'amount': 300,
            'eligibleSeats': [0, 1, 2],
            'winnerSeats': [0],
          },
          {
            'amount': 200,
            'eligibleSeats': [1, 2],
            'winnerSeats': [1],
          },
        ],
      ),
    );
    final game = view.toGameState(handCount: 1);

    expect(game.awardShareFor(0), 300);
    expect(game.awardShareFor(1), 200);
    expect(game.isSplitPot, isFalse);
  });

  test('marks an actual tied pot as split', () {
    final view = LiveHandViewModel.fromJson(
      _terminalView(
        winnerSeats: [0, 1],
        pots: [
          {
            'amount': 500,
            'eligibleSeats': [0, 1, 2],
            'winnerSeats': [0, 1],
          },
        ],
      ),
    );
    final game = view.toGameState(handCount: 1);

    expect(game.awardShareFor(0), 250);
    expect(game.awardShareFor(1), 250);
    expect(game.isSplitPot, isTrue);
  });

  test('coach copy marks chips and spells tendency keys', () {
    const assessment = LiveCoachingAssessment(
      actionId: 'CALL',
      rating: 'recommended',
      confidence: 'high',
      summary: 'Call the remaining 42.36 all-in.',
      playerTypeReason:
          'Viktor has 51.7 bluffRiver and 93.7 aggression, plus 57.8 VPIP. '
          'Cole has high aggression of 57.8.',
      sizingNote:
          'Hero needs 5.5% equity to call the final 42.36 into a pot of 731.64. '
          'Calling into a massive 748 pot. Facing a 210 all-in.',
      tendencyKeys: const ['bluffRiver', 'aggression', 'vpip'],
    );

    final message = assessment.message;
    expect(message, contains(r'$42.36'));
    expect(message, contains(r'$731.64'));
    expect(message, contains(r'massive $748 pot'));
    expect(message, contains(r'a $210 all-in'));
    expect(message, isNot(contains('massive 748 pot')));
    expect(message, isNot(contains('a 210 all-in')));
    expect(message, contains('51.7% river bluff'));
    expect(message, contains('93.7% aggression'));
    expect(message, contains('aggression of 57.8%'));
    expect(message, contains('57.8% VPIP'));
    expect(message, isNot(contains(RegExp(r'aggression of 57\.8(?!%)'))));
    expect(message, contains('5.5% equity'));
    expect(message, isNot(contains('bluffRiver')));
    expect(message, isNot(contains(r'$5.5')));
  });

  test('coach copy keeps odds ratios and complete percents intact', () {
    expect(
      polishCoachCopy(
        'Chaos has an aggression of 76.3% and offers 8-to-1 pot odds.',
      ),
      allOf(
        contains('aggression of 76.3%'),
        isNot(contains('76%.3%')),
        contains('8-to-1 pot odds'),
        isNot(contains(r'8-to-$1')),
      ),
    );
    expect(
      polishCoachCopy('aggression of 76.3 on the river'),
      contains('aggression of 76.3%'),
    );
  });

  test('coach copy keeps pot fractions intact', () {
    expect(
      polishCoachCopy('making 2/3 pot directly exploitative against stations.'),
      allOf(contains('2/3 pot'), isNot(contains(r'2/$3'))),
    );
    expect(
      polishCoachCopy('A 3/4 pot bet charges draws.'),
      allOf(contains('3/4 pot'), isNot(contains(r'3/$4'))),
    );
    expect(
      polishCoachCopy('Betting 40 pot extracts value.'),
      contains(r'$40 pot'),
    );
  });

  test('coach copy keeps rates and pot multipliers intact', () {
    expect(
      polishCoachCopy('Rex calls down wide with showdown call 50.7.'),
      allOf(
        contains('showdown call 50.7%'),
        isNot(contains(r'call $50')),
        isNot(contains(r'$50.7')),
      ),
    );
    expect(
      polishCoachCopy(
        r'Shoving $134 into a $364 pot represents a 0.37x pot bet.',
      ),
      allOf(contains('0.37x pot'), isNot(contains(r'$0.37x'))),
    );
    expect(
      polishCoachCopy('call 50 more against the shove.'),
      contains(r'call $50'),
    );
    expect(
      polishCoachCopy('Hero must risk 178 to win a final pot of 795.'),
      allOf(contains(r'risk $178'), contains(r'pot of $795')),
    );
    expect(
      polishCoachCopy('Hero needs 18.6% equity risking 101 into a pot of 442.'),
      allOf(contains(r'risking $101'), contains(r'pot of $442')),
    );
    expect(
      polishCoachCopy(
        "Folding preserves Hero's 262 stack against Stan's value-heavy shove.",
      ),
      contains(r'$262 stack'),
    );
    expect(
      polishCoachCopy(
        r'Risking 0 preserves your full $219 stack against a cold 4-bet.',
      ),
      allOf(contains('Risking 0'), isNot(contains(r'Risking $0'))),
    );
    expect(
      polishCoachCopy(
        r'Calling your last $29 at an SPR of 0.04 lets you realize.',
      ),
      allOf(contains('SPR of 0.04'), isNot(contains(r'SPR of $0.04'))),
    );
    expect(
      polishCoachCopy(r'Risking $260 to win 462 offers 36% pot odds.'),
      contains(r'win $462'),
    );
    expect(
      polishCoachCopy(
        'Facing a 59 call into a \$511 pot, we need 10.4% equity.',
      ),
      allOf(contains(r'$59 call'), contains(r'$511 pot')),
    );
    expect(
      polishCoachCopy(
        'Calling requires 125 into a \$508 pot, offering direct pot odds.',
      ),
      contains(r'requires $125'),
    );
    expect(
      polishCoachCopy('Blitz has 16.2 three-bet frequency and shoves wide.'),
      allOf(contains('16.2% 3-bet'), isNot(contains('16.2 three-bet'))),
    );
    // "3-betting (20.7) tendencies" missing % (batch 0207).
    expect(
      polishCoachCopy(
        "unprofitable despite Blitz's wide 3-betting (20.7) tendencies.",
      ),
      allOf(
        contains('3-bet (20.7%) tendencies'),
        isNot(contains('(20.7) tendencies')),
        isNot(contains('3-betting (20.7)')),
      ),
    );
    expect(
      polishCoachCopy('wide aggression (20.7) tendencies on the river.'),
      contains('(20.7%) tendencies'),
    );
    expect(
      polishCoachCopy('Hero needs 24.8% pot odds to call \$118 into 358.'),
      contains(r'into $358'),
    );
    expect(
      polishCoachCopy(
        'Sammy and Rex exhibit high aggression (65.8 and 69.7) and '
        'active 3-bet frequencies (10.8 and 12.6).',
      ),
      allOf(contains('(65.8% and 69.7%)'), contains('(10.8% and 12.6%)')),
    );
    // Comma-paired rates missing % (batch 0210).
    expect(
      polishCoachCopy(
        'Against sticky callers with high VPIP (50.8, 45.1), calling '
        'plays well postflop in position.',
      ),
      allOf(
        contains('VPIP (50.8%, 45.1%)'),
        isNot(contains('(50.8, 45.1)')),
      ),
    );
    expect(
      polishCoachCopy('Calling \$75 leaves just 73 behind into a \$378 pot.'),
      contains(r'just $73 behind'),
    );
    expect(
      polishCoachCopy(r'Calling $120 leaves just $75 behind out of position.'),
      allOf(contains(r'just $75 behind'), isNot(contains(r'$$75'))),
    );
    expect(
      polishCoachCopy(r'Hero has only 163 remaining into an $867 pot.'),
      contains(r'only $163 remaining'),
    );
    expect(
      polishCoachCopy(
        'stations behind with high showdown call marks '
        '(Dale 77.4, Fred 71.7) make calling unprofitable.',
      ),
      contains('(Dale 77.4%, Fred 71.7%)'),
    );
    // Named rate list continuations after a percented rate (batch 0222).
    expect(
      polishCoachCopy(
        'Multiple aggressive players (Chaos aggression 93.9%, Rex 65.4, '
        'Jade 69.7) and the preflop 3-bettor Ivy act behind us.',
      ),
      allOf(
        contains('(Chaos aggression 93.9%, Rex 65.4%, Jade 69.7%)'),
        isNot(contains('Rex 65.4,')),
        isNot(contains('Jade 69.7)')),
      ),
    );
    expect(
      polishCoachCopy(r'Calling $210 leaves Hero with only 10 chips behind.'),
      contains(r'only $10 chips behind'),
    );
    expect(
      polishCoachCopy(
        'Calling stations (showdown call 65%-74) stay in the hand.',
      ),
      contains('65%-74%'),
    );
    expect(
      polishCoachCopy(
        'calling stations have high showdown call (65.5-79.1%) and call flop.',
      ),
      allOf(
        contains('(65.5%-79.1%)'),
        isNot(contains('(65.5-79.1%)')),
      ),
    );
    expect(
      polishCoachCopy('stations call with showdown call 65-74 often.'),
      contains('65%-74%'),
    );
    expect(
      polishCoachCopy(r'Surrendering against a 45 bet into a $180 pot.'),
      allOf(contains(r'a $45 bet'), isNot(contains('a 45 bet'))),
    );
    expect(
      polishCoachCopy('A 3 bet is not a chip size.'),
      allOf(contains('A 3 bet'), isNot(contains(r'A $3 bet'))),
    );
    expect(
      polishCoachCopy("Folding preserves Hero's 125 bb stack."),
      contains(r'$125 bb stack'),
    );
    expect(
      polishCoachCopy('Chaos has an aggression of 76.3% and offers 8-to-1 pot odds.'),
      contains('8-to-1 pot odds'),
    );
    expect(
      polishCoachCopy(
        "Checking preserves Hero's 72 chip stack to realize showdown.",
      ),
      contains(r'$72 chip stack'),
    );
    expect(
      polishCoachCopy(
        r'Calling $144 to contest a 698 total pot requires 20.6% equity.',
      ),
      contains(r'$698 total pot'),
    );
    expect(
      polishCoachCopy(
        'With an effective stack of 157 and SPR of 0.5, Hero cannot extract.',
      ),
      contains(r'stack of $157'),
    );
    expect(
      polishCoachCopy(
        "Maya's 42.3 river bluffing frequency includes many air balls.",
      ),
      contains('42.3% river bluff'),
    );
    expect(
      polishCoachCopy(
        'Blitz is a Maniac with 81.5% aggression and 51.5 river bluff '
        'frequency.',
      ),
      allOf(
        contains('81.5% aggression'),
        contains('51.5% river bluff'),
        isNot(contains('51.5 river bluff')),
      ),
    );
    expect(
      polishCoachCopy(
        'Surrendering for 155 more into a pot that already exceeds 800.',
      ),
      allOf(contains(r'for $155 more'), contains(r'exceeds $800')),
    );
    expect(
      polishCoachCopy(
        r'folding for 137 into a $732 pot gives up massive value.',
      ),
      allOf(
        contains(r'for $137 into'),
        isNot(contains(RegExp(r'for 137 into'))),
      ),
    );
    expect(
      polishCoachCopy(
        'Surrendering for 42 chips in a 570-chip pot is indefensible.',
      ),
      allOf(contains(r'for $42 chips'), contains(r'$570-chip pot')),
    );
    expect(
      polishCoachCopy(
        'Folding retains 164 chips but ignores the 20% pot odds.',
      ),
      contains(r'retains $164 chips'),
    );
    expect(
      polishCoachCopy(
        r'Surrendering against a 151 bet into a $548 pot forfeits share.',
      ),
      contains(r'a $151 bet'),
    );
    expect(
      polishCoachCopy(
        r'Facing a 120-chip effective shove into $537 requires only 18.3%.',
      ),
      contains(r'$120-chip effective shove'),
    );
    expect(
      polishCoachCopy('Fred (showdown call: 67.9) stays in with worse.'),
      contains('showdown call: 67.9%'),
    );
    expect(
      polishCoachCopy(r'Risking only 40 chips to contest an $886 pot is fine.'),
      contains(r'Risking only $40'),
    );
    expect(
      polishCoachCopy('Folding preserves 302 chips and prevents committing.'),
      contains(r'preserves $302 chips'),
    );
    expect(
      polishCoachCopy(
        "Calling fails to charge Dale's remaining \$68 and Fred's 38 chips.",
      ),
      contains(r"Fred's $38 chips"),
    );
    expect(
      polishCoachCopy(
        'flatting captures value against Rex (53.8) and Jade (52.6).',
      ),
      contains('Rex (53.8%) and Jade (52.6%)'),
    );
    expect(
      polishCoachCopy(
        'Against opponents showing 81.4 and 67.3% aggression, folding is tight.',
      ),
      contains('81.4% and 67.3%'),
    );
    expect(
      polishCoachCopy(
        'With an SPR of 0.1 and 13.9% modeled equity, checking retains flexibility.',
      ),
      allOf(
        contains('SPR of 0.1 and 13.9%'),
        isNot(contains('SPR of 0.1%')),
      ),
    );
    expect(
      polishCoachCopy('Opponents show extreme aggression at 87.7 and 92.9.'),
      contains('aggression at 87.7% and 92.9%'),
    );
    expect(
      polishCoachCopy(
        'Rex exhibits high aggression at 59.5, so flatting keeps his bluffs in.',
      ),
      allOf(
        contains('aggression at 59.5%'),
        isNot(contains('aggression at 59.5,')),
      ),
    );
    expect(
      polishCoachCopy(
        "flatting against Rico's aggressive (77.4) and 3-bet (25.3%) "
        'heavy profile.',
      ),
      allOf(
        contains('aggression (77.4%)'),
        contains('3-bet (25.3%)'),
        isNot(contains('aggressive (77.4)')),
      ),
    );
    // Nested "(3-bet (N%)" inside a name paren (batch 0197 #119 live).
    expect(
      polishCoachCopy(
        'TAG profiles like Alex (3-bet (9.4%) and Cole (3-bet (9.9%) '
        'entering multiway 4-bet pots signal tight value ranges.',
      ),
      allOf(
        contains('Alex (3-bet 9.4%)'),
        contains('Cole (3-bet 9.9%)'),
        isNot(contains('3-bet (9.4%)')),
        isNot(contains('3-bet (9.9%)')),
      ),
    );
    // Mid-list nested rate inside an open paren (batch 0198).
    expect(
      polishCoachCopy(
        'The turn bettor is an aggressive Maniac (aggression 78.3%, '
        'VPIP (51.3%) who bluffs and overvalues hands.',
      ),
      allOf(
        contains('Maniac (aggression 78.3%, VPIP 51.3%) who'),
        isNot(contains('VPIP (51.3%)')),
      ),
    );
    expect(
      polishCoachCopy(
        'The turn bettor is an aggressive Maniac (aggression (78.3%), '
        'VPIP (51.3%) who bluffs and overvalues hands.',
      ),
      allOf(
        contains('aggression 78.3%'),
        isNot(contains('aggression (78.3%)')),
      ),
    );
    // Mid-list nest closed by "and Name" (batch 0203).
    expect(
      polishCoachCopy(
        "Paul (VPIP 40.7%, showdown call (62.6%) and Alex's "
        'strong range make it difficult to realize equity.',
      ),
      allOf(
        contains("Paul (VPIP 40.7%, showdown call 62.6%) and Alex's"),
        isNot(contains('showdown call (62.6%)')),
      ),
    );
    // Mid-list nest closed by lowercase continuer (batch 0205).
    expect(
      polishCoachCopy(
        "Ned's ultra-tight profile (VPIP 10.8%, 3-bet (3.8%) "
        'alongside multiway all-ins guarantees strong made hands.',
      ),
      allOf(
        contains('profile (VPIP 10.8%, 3-bet 3.8%) alongside'),
        isNot(contains('3-bet (3.8%)')),
      ),
    );
    // Mid-list nest closed by semicolon continuer (batch 0224).
    expect(
      polishCoachCopy(
        'Maniac fires frequently with inferior hands (aggression 74.8%, '
        'river bluff (62.6%); raising isolates better.',
      ),
      allOf(
        contains('(aggression 74.8%, river bluff 62.6%); raising'),
        isNot(contains('river bluff (62.6%)')),
      ),
    );
    // Standalone rate + "and Name" must stay (batch 0204 FP).
    expect(
      polishCoachCopy(
        'Viktor exhibits high aggression (77%) and Carl '
        'demonstrates high sizing tell (80%).',
      ),
      allOf(
        contains('aggression (77%) and Carl'),
        contains('sizing tell (80%)'),
      ),
    );
    // List items ", and …" must keep paren rates.
    expect(
      polishCoachCopy(
        'Sammy opens wide (VPIP 44.6%, PFR (26%), and multiple '
        'passive calling stations (VPIP › 48, showdown call > 65) '
        'provide strong multiway implied odds.',
      ),
      contains('PFR (26%)'),
    );
    expect(
      polishCoachCopy(
        'Maya has a loose 3-bet stat (15.1), multiway all-in action narrows '
        'ranges.',
      ),
      allOf(
        contains('3-bet stat (15.1%)'),
        isNot(contains('3-bet stat (15.1),')),
      ),
    );
    expect(
      polishCoachCopy(
        r'Needing 190 to compete for a total pot of $642 is fine.',
      ),
      contains(r'Needing $190'),
    );
    expect(
      polishCoachCopy(
        'Folding against opponents with aggression above 77 is timid.',
      ),
      contains('aggression above 77%'),
    );
    // "showdown call up to 77.4" (batch 0226).
    expect(
      polishCoachCopy(
        'Sticky stations (showdown call up to 77.4) and aggressive '
        'squeezers will dominate your medium suited connector multiway.',
      ),
      allOf(
        contains('showdown call up to 77.4%'),
        isNot(contains('up to 77.4)')),
      ),
    );
    // Unclosed profile rate list before a verb (batch 0226).
    expect(
      polishCoachCopy(
        'Rico (MANIAC, aggression 90.7%, VPIP 52.1%) and Sammy (LAG, '
        'aggression 70.3% generate massive action with wide ranges.',
      ),
      allOf(
        contains('Sammy (LAG, aggression 70.3%) generate'),
        isNot(contains('aggression 70.3% generate')),
      ),
    );
    expect(
      polishCoachCopy(
        "Rico's extreme aggression (86.4) and wide VPIP (70.2) push many "
        'inferior hands into his range.',
      ),
      allOf(
        contains('aggression (86.4%)'),
        contains('VPIP (70.2%)'),
        isNot(contains(RegExp(r'aggression \(86\.4\)(?!%)'))),
        isNot(contains(RegExp(r'VPIP \(70\.2\)(?!%)'))),
      ),
    );
    // H3: tendency label + "frequency" noun before the paren rate.
    expect(
      polishCoachCopy(
        'Blitz exhibits extreme aggression (91.6%) and high '
        'river bluff frequency (63.1), meaning his three-barrel shove.',
      ),
      allOf(
        contains('river bluff frequency (63.1%)'),
        isNot(contains(RegExp(r'frequency \(63\.1\)(?!%)'))),
      ),
    );
    expect(
      polishCoachCopy('high aggression (69.0) keeps pressure on.'),
      contains('aggression (69.0%)'),
    );
    // Live 0118 H8: "aggression rating of 85.6" missing %.
    expect(
      polishCoachCopy(
        'Blitz has an extreme aggression rating of 85.6 and high '
        'VPIP (63.1%), meaning their range contains ample bluffs.',
      ),
      allOf(
        contains('aggression rating of 85.6%'),
        contains('VPIP (63.1%)'),
        isNot(contains(RegExp(r'aggression rating of 85\.6(?!%)'))),
      ),
    );
    expect(
      polishCoachCopy('stations show aggression rating 85.6 on the river.'),
      contains('aggression rating 85.6%'),
    );
    expect(
      polishCoachCopy('stations show frequency (63.1) on the river.'),
      contains('frequency (63.1%)'),
    );
    expect(
      polishCoachCopy('Maya has bluff frequency (63.1) in this spot.'),
      contains('bluff frequency (63.1%)'),
    );
    expect(
      polishCoachCopy('river bluff frequency 63.1) from OCR noise.'),
      contains('river bluff frequency (63.1%)'),
    );
    expect(
      polishCoachCopy(
        'Maniac profiles with 85% aggression and 60.1% bluffRiver bluff '
        'far too often to surrender.',
      ),
      allOf(
        contains('60.1% river bluff and bluff'),
        isNot(contains('river bluff bluff')),
      ),
    );
    expect(
      polishCoachCopy(
        'Giving up equity when facing a river bet requiring only 111 chips '
        r'to win a $502 pot is a mistake.',
      ),
      allOf(
        contains(r'requiring only $111 chips'),
        isNot(contains(RegExp(r'requiring only 111 chips'))),
      ),
    );
    // Chip size before "3-bet" must not gain a percent (batch 0154).
    expect(
      polishCoachCopy(
        r'Matches the $30 3-bet offering 21.9% pot odds with a '
        '23.4% estimated multiway equity.',
      ),
      allOf(
        contains(r'$30 3-bet'),
        isNot(contains(r'$30%')),
        contains('21.9%'),
        contains('23.4%'),
      ),
    );
    expect(
      polishCoachCopy(r'Facing a $30 three-bet from Blitz.'),
      allOf(contains(r'$30 3-bet'), isNot(contains(r'$30%'))),
    );
    expect(
      polishCoachCopy('Blitz has 16.2 3-bet and shoves wide.'),
      contains('16.2% 3-bet'),
    );
    // Comparison operators must gain % (batch 0163).
    expect(
      polishCoachCopy(
        'Sammy opens wide (VPIP 44.6%, PFR (26%), and multiple '
        'passive calling stations (VPIP › 48, showdown call > 65) '
        'provide strong multiway implied odds.',
      ),
      allOf(
        contains('VPIP › 48%'),
        contains('showdown call > 65%'),
        contains('VPIP 44.6%'),
        contains('PFR (26%)'),
        isNot(contains(RegExp(r'VPIP › 48[,)]'))),
        isNot(contains(RegExp(r'showdown call > 65\)'))),
      ),
    );
  });
}
