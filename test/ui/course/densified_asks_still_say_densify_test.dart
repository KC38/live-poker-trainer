// LPT-628: Densified asks still say Tap the best answer (catalog) densified asks reach the frame bubble through
// selectIdentifyDensifiedCoachLine, never catalog quiz copy plus the
// generic "Tap the best answer." footer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-01-01-01-guided-find-holes':
      'Tap your hole cards on the table — pick the two in front of you.',
  'act-01-01-01-scaffolded-private':
      'Tap the cards only you can see — pick your private holes.',
  'act-01-01-01-unguided-mix':
      'Tap the community cards — pick the shared board in the middle.',
  'act-01-01-01-checkpoint-table':
      'Tap the cards that are only yours — pick the two at your seat.',
  'act-01-01-02-guided-suits': 'Tap one community card of each suit — pick Hearts, diamonds, clubs, spades.',
  'act-01-01-02-unguided-suited': 'Tap the suited hole cards — pick Suited.',
  // LPT-804: SoftPulse-off densify — no correct-tile spoil.
  'act-01-01-02-checkpoint-pair':
      'Same rank in one seat — tap the matching holes.',
  'act-01-01-03-guided-button':
      'Tap the dealer button on the table — pick The seat with the D chip.',
  'act-01-01-03-scaffolded-blinds': 'Blinds are 1/2. Tap who posts the big blind — pick The seat two left of the button, posting 2.',
  'act-01-01-03-unguided-when':
      'Tap when the blinds go in — pick Before any hole cards are dealt.',
  'act-01-02-02-guided-seven': 'Tap the five cards that make your best hand — pick Top pair with best kicker.',
  'act-01-02-02-checkpoint-build': 'Tap the five cards for your strongest hand — pick Full house — trips over the higher pair.',
  'act-01-04-01-unguided-end':
      'Flop betting is live. Tap when this street ends — pick Bets matched.',
  // LPT-808: SoftPulse-off densify — no correct-seat spoil.
  'act-01-04-01-checkpoint-postflop':
      'Postflop multiway — tap who acts first.',
  'act-01-05-01-guided-fold-win':
      'You bet. Everyone folds. Tap how you take the pot — pick Take pot.',
  'act-01-05-01-scaffolded-showdown':
      'River bets are called. Tap what happens next — pick Showdown.',
  // LPT-782: SoftPulse-off densify — no correct-tile spoil.
  'act-01-05-01-checkpoint-side':
      'You are all-in for less; two big stacks keep betting — tap the matching pot fact.',
  'act-02-01-01-guided-btn': 'Tap who acts last postflop — pick BTN.',
  'act-02-01-01-scaffolded-blinds':
      'Tap a seat that posts a forced bet every hand — pick SB or BB.',
  'act-02-01-01-unguided-co':
      'Tap the seat right before the button — pick Cutoff (CO).',
  // LPT-783: SoftPulse-off densify — no correct-tile spoil.
  'act-02-01-01-checkpoint-edge':
      'Same hand early versus button — tap the matching edge.',
  'act-02-01-02-unguided-wait': 'Action is on UTG. You are on the button. What do you do — pick Wait — do not act yet.',
  // LPT-803: SoftPulse-off densify — no correct-tile spoil.
  'act-02-01-02-checkpoint-full':
      'Six-max flop, everyone in — tap who acts last.',
  'act-02-02-01-guided-pair':
      'Tap the family for your holes — pick Pocket pair.',
  'act-02-02-01-scaffolded-broadway':
      'Tap the family for your holes — pick Broadway.',
  'act-02-02-01-unguided-sc':
      'Tap the family for your holes — pick Suited connector.',
  // LPT-784: SoftPulse-off densify — no correct-tile spoil.
  'act-02-02-01-checkpoint-trash':
      'Low unconnected offsuit holes — tap the matching family.',
  'act-02-05-01-guided-convert':
      'Blinds 1/2. You have 200 chips. How many big blinds — pick 100bb.',
  'act-02-05-01-scaffolded-eff':
      'You have 150bb. Villain has 60bb. Effective stack — pick 60bb.',
  'act-02-05-01-unguided-depth':
      'Which depth plays closest to a short-stack shove game — pick 50bb.',
  // LPT-785: SoftPulse-off densify — no correct-tile spoil.
  'act-02-05-01-checkpoint-200':
      'Blinds 2/5. You buy in for 1000 chips — tap the matching stack in big blinds.',
  'act-02-06-01-guided-follow': 'Two seats act before you. What first — pick Watch what they do, then decide.',
  'act-02-06-01-scaffolded-verbal': 'You want to raise. Clearest live choice — pick Say "raise" and put out the chips.',
  'act-02-06-01-unguided-protect': 'Your cards sit near the muck. Best habit — pick Keep a chip or hand on your cards.',
  // LPT-786: SoftPulse-off densify — no correct-tile spoil.
  'act-02-06-01-checkpoint-oot':
      'Action is two seats left. You toss in a raise early — tap the matching problem.',
  // LPT-788: SoftPulse-off densify — no correct-tile spoil.
  'act-02-07-01-checkpoint-habit':
      'Full ring. Action two seats left. Your cards are uncovered — tap the matching fix.',
  // LPT-675: SoftPulse-off jump — stem must not name Cutoff.
  'act-02-07-02-jump-pos':
      'Seat right before the button — pick it on the map.',
  'act-03-01-01-guided':
      'Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now — pick 21.',
  'act-03-01-01-scaffolded': 'Nine-handed. Dealer button is on seat 7. Who acts first preflop — pick Seat left of the big blind (UTG).',
  'act-03-01-01-unguided': 'You say "raise" then try to take it back to a call. Result — pick The raise stands — verbal is binding.',
  // LPT-787: SoftPulse-off densify — no correct-tile spoil.
  'act-03-01-01-checkpoint':
      'Hero 140bb, villain 55bb, pot 18 — tap what matters most next.',
  'act-03-02-01-guided':
      'Board Ks 9d 2c. You hold Kh Qh. Class — pick Made hand — top pair.',
  'act-03-02-01-scaffolded': 'Board Jh 8h 3c. You hold Ah 9h. Class — pick Strong draw — nut flush draw.',
  'act-03-02-01-unguided': 'Board Qc 7d 2s. You hold 5h 4h multiway. Class — pick Air — little equity, no pair.',
  // LPT-805: SoftPulse-off densify — no correct-tile / template-card spoil.
  'act-03-02-01-checkpoint':
      'Best label for this flop class — tap the matching label.',
  'act-03-05-01-guided': 'Flop As 7d 2c. Turn 3h. For a missed c-bettor, is this a brick — pick Brick — rarely helps the caller.',
  // LPT-807: SoftPulse-off densify — no correct-tile / template-card spoil.
  'act-03-05-01-checkpoint':
      'Bluffed the flop; turn completes front-door draws — tap the matching plan.',
  // LPT-780: SoftPulse-off densify — no correct-tile spoil.
  'act-04-06-03-checkpoint':
      'Why bluff less versus a Calling Station — tap the matching reason.',
  'act-04-07-01-guided': 'Seat folded 20 of 22 hands. Observation — pick Narrow entry — plays few hands.',
  'act-04-07-01-scaffolded': 'That seat finally raises and then barrels. Observation — pick Strong aggression when they enter.',
  'act-04-07-01-unguided':
      'They folded two hands. Label them already — pick No — sample too small.',
  // LPT-763: SoftPulse-off densify — no correct-tile spoil.
  'act-04-07-01-checkpoint':
      'Evidence bundle for this seat — tap the matching note.',
  // LPT-765: SoftPulse-off densify — no correct-tile spoil.
  'act-04-07-02-checkpoint':
      'Nit is best treated as — tap the matching model stance.',
  // LPT-778: SoftPulse-off densify — no correct-tile spoil.
  'act-04-07-03-checkpoint':
      'Why respect a Nit check-raise — tap the matching reason.',
  'act-04-08-01-guided': 'Seat raises or 3-bets twelve of fifteen pots. Observation — pick Extreme entry and aggression.',
  'act-04-08-01-scaffolded': 'They bet flop, turn, and river with weak showdowns twice. Note — pick Continues pressure too wide.',
  'act-04-08-01-unguided': 'Best note style versus wild aggression — pick Frequencies and shows — no ego story.',
  // LPT-770: SoftPulse-off densify — no correct-tile spoil.
  'act-04-08-01-checkpoint':
      'Evidence bundle for this seat — tap the matching note.',
  // LPT-771: SoftPulse-off densify — no correct-tile spoil.
  'act-04-08-02-checkpoint':
      'Which types are legal to mix now — tap the matching set.',
  // LPT-781: SoftPulse-off densify — no correct-tile spoil.
  'act-04-08-03-checkpoint':
      'Why call wider versus a Maniac — tap the matching reason.',
  'act-04-09-01-guided': 'You saw one huge bluff. What do you know — pick One note — low certainty.',
  'act-04-09-01-scaffolded': 'After 30 hands of sticky calls, confidence should — pick Rise — still revisable.',
  // LPT-777: SoftPulse-off densify — no correct-tile spoil.
  'act-04-09-01-checkpoint':
      'Course should show what beside a type label — tap the matching note.',
  'act-04-10-02-jump-range':
      'UTG open is best described as — tap the matching range.',
  'act-04-10-02-jump-spr':
      'Stack 60bb, pot 15bb. SPR — tap the matching number.',
  'act-05-01-01-guided':
      'Four-way flop. Best continue with — pick Nut flush draw.',
  'act-05-01-01-checkpoint':
      'Multiway construction priority — tap the matching priority.',
  'act-05-02-01-guided': '200bb effective. Best reason to call a raise with 55 BTN — pick Implied odds if they pay sets.',
  'act-05-02-01-unguided': 'SPR ~12 on the flop. Your first job — pick Map turn/river plans before committing.',
  // LPT-735: SoftPulse-off densify — no correct-tile spoil.
  'act-05-02-01-checkpoint':
      '150–300bb cash play rewards — tap the matching reward.',
  // LPT-734: SoftPulse-off densify — no correct-tile spoil.
  'act-05-03-01-checkpoint':
      'Implied odds rise most when — tap the matching condition.',
  // LPT-736: SoftPulse-off densify — no correct-tile spoil.
  'act-05-04-01-checkpoint':
      'Same hand, different types — tap the matching change.',
  'act-05-05-01-guided':
      'Nit check-raises flop. Default read — pick Value-heavy — respect.',
  'act-05-05-01-unguided': 'BB donks large on A-high dry flop into PFR. Meaning — pick Often polarized — strong or bluff.',
  // LPT-742: SoftPulse-off densify — no correct-tile spoil.
  'act-05-05-01-checkpoint':
      'Delayed c-bet is best when — tap the matching timing.',
  'act-05-06-01-guided':
      'Villain bets flop, checks turn. Range now — pick Capped — fewer nuts.',
  'act-05-06-01-unguided':
      'Best line-reading habit — pick Rebuild after every action.',
  // LPT-745: SoftPulse-off densify — no correct-tile spoil.
  'act-05-06-01-checkpoint':
      'Check-raise flop, bet turn, shove river usually means — tap the matching range.',
  'act-05-07-01-guided': 'Instant river shove after you bet. Correct framing — pick Soft evidence.',
  'act-05-07-01-scaffolded':
      'Tiny flop bet into a huge pot often says — pick Weaker / blocking.',
  'act-05-07-01-unguided':
      'Coach says "look left means bluff." Response — pick Reject magic tells.',
  // LPT-744: SoftPulse-off densify — no correct-tile spoil.
  'act-05-07-01-checkpoint':
      'Best use of live timing — tap the matching habit.',
  'act-05-08-01-guided': 'Villain lost two buy-ins, now open-raises every hand. Note — pick Stuck / tilted.',
  'act-05-08-01-scaffolded': 'Solid selective player suddenly flats junk and donks rivers. Best read — pick Gear change.',
  // LPT-746: SoftPulse-off densify — no correct-tile spoil.
  'act-05-08-01-checkpoint':
      'Dynamic reads should be — tap the matching habit.',
  'act-05-09-01-guided':
      'You hit a planned stop-loss. Next step — pick Stop / move down.',
  'act-05-09-01-scaffolded':
      'Bankroll 40 buy-ins for 1/2. Spot opens at 2/5. Action — pick Decline.',
  'act-05-09-01-unguided':
      'Tired, winning small, table getting wild. Best — pick Cash out.',
  // LPT-747: SoftPulse-off densify — no correct-tile spoil.
  'act-05-09-01-checkpoint':
      'Session discipline is part of — tap the matching practice.',
  // LPT-717: SoftPulse-off densify — no correct-tile spoil.
  'act-05-09-02-cp-multi':
      'Four-way pot priority — tap the matching priority.',
  'act-05-09-02-cp-tell': 'Instant shove proves — tap the matching read.',
  'act-05-09-02-cp-stop': 'Hit stop-loss. Do — tap the matching plan.',
  'act-06-01-01-guided': 'PFR on A-high dry flop. Who often has range advantage — pick Preflop raiser.',
  'act-06-01-01-scaffolded': 'Paired board. Caller defends wide. Who may have nut advantage — pick Wide caller.',
  // LPT-764: SoftPulse-off densify — no correct-tile spoil.
  'act-06-01-01-checkpoint':
      'Advantage is a reason to — tap the matching plan.',
  'act-06-02-01-guided':
      'Same draw OOP vs IP. Where does it realize better — pick In position.',
  'act-06-02-01-scaffolded': 'Weak showdown value OOP facing dual barrels. Default — pick Discount / fold.',
  'act-06-02-01-unguided': 'Semi-bluff check-raise with nut draw IP-denied. Purpose — pick Fold equity.',
  // LPT-766: SoftPulse-off densify — no correct-tile spoil.
  'act-06-02-01-checkpoint':
      'Equity realization rises with — tap the matching levers.',
  'act-07-12-01-uncertain':
      'Three mixed samples only. Confidence — tap the matching level.',
  'act-07-12-01-retire':
      'Old Calling Station now folds rivers and 3-bets light. Do — tap the matching next step.',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id frame speech is the densified ask (LPT-628)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, contains(line.split(' — ').first));
    });
  }
}
