// LPT-628: Densified asks still say Tap the best answer (catalog) densified asks reach the frame bubble through
// selectIdentifyDensifiedCoachLine, never catalog quiz copy plus the
// generic "Tap the best answer." footer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-01-01-01-guided-find-holes':
      'Tap your hole cards on the table — pick the two in front of you.',
  'act-01-01-01-scaffolded-private':
      'Tap the cards only you can see — pick your private holes.',
  'act-01-01-01-unguided-mix':
      'Tap the community cards — pick the shared board in the middle.',
  // LPT-869: SoftPulse-off densify — no "the two at your seat" spoil.
  'act-01-01-01-checkpoint-table':
      'Private cards on this table — tap the ones only you can see.',
  // LPT-814: SoftPulse-quiet densify — no suit-order spoil.
  'act-01-01-02-guided-suits': 'Tap one community card of each suit.',
  // LPT-815 / LPT-816: seat-deal densify — no Suited tile spoil.
  'act-01-01-02-unguided-suited':
      'Tap the seat whose hole cards share a suit.',
  'act-01-01-02-03-guided-suited':
      'Tap the seat whose hole cards share a suit.',
  // LPT-804: SoftPulse-off densify — no correct-tile spoil.
  'act-01-01-02-checkpoint-pair':
      'Same rank in one seat — tap the matching holes.',
  // LPT-836: SoftPulse-quiet densify — no D-chip choice spoil.
  'act-01-01-03-guided-button': 'Tap the dealer button on the table.',
  // LPT-830: SoftPulse-quiet densify — no BB choice spoil.
  'act-01-01-03-scaffolded-blinds':
      'Blinds are 1/2. Tap who posts the big blind.',
  // LPT-832: SoftPulse-quiet densify — no before-deal choice spoil.
  'act-01-01-03-unguided-when': 'Tap when the blinds go in.',
  // LPT-835: SoftPulse-quiet densify — no Top pair / best kicker spoil.
  'act-01-02-02-guided-seven':
      'Tap the five cards that make your best hand.',
  // LPT-871: SoftPulse-quiet densify — no Full house / trips spoil.
  'act-01-02-02-checkpoint-build':
      'Tap the five cards that make your strongest hand.',
  // LPT-837: SoftPulse-quiet densify — no Bets matched spoil.
  'act-01-04-01-unguided-end':
      'Flop betting is live. Tap when this street ends.',
  // LPT-808: SoftPulse-off densify — no correct-seat spoil.
  'act-01-04-01-checkpoint-postflop':
      'Postflop multiway — tap who acts first.',
  'act-01-05-01-guided-fold-win':
      'You bet. Everyone folds. Tap how you take the pot — pick Take pot.',
  // LPT-839: SoftPulse-quiet densify — no Showdown spoil.
  'act-01-05-01-scaffolded-showdown':
      'River bets are called. Tap what happens next.',
  // LPT-782: SoftPulse-off densify — no correct-tile spoil.
  'act-01-05-01-checkpoint-side':
      'You are all-in for less; two big stacks keep betting — tap the matching pot fact.',
  'act-02-01-01-guided-btn': 'Tap who acts last postflop — pick BTN.',
  // LPT-833: SoftPulse-quiet densify — no SB or BB spoil.
  'act-02-01-01-scaffolded-blinds':
      'Tap a seat that posts a forced bet every hand.',
  // LPT-834: SoftPulse-quiet densify — no Cutoff / CO spoil.
  'act-02-01-01-unguided-co': 'Tap the seat right before the button.',
  // LPT-783: SoftPulse-off densify — no correct-tile spoil.
  'act-02-01-01-checkpoint-edge':
      'Same hand early versus button — tap the matching edge.',
  // LPT-838: SoftPulse-quiet densify — no Wait spoil.
  'act-02-01-02-unguided-wait':
      'Action is on UTG. You are on the button. Tap what you should do.',
  // LPT-803: SoftPulse-off densify — no correct-tile spoil.
  'act-02-01-02-checkpoint-full':
      'Six-max flop, everyone in — tap who acts last.',
  'act-02-02-01-guided-pair':
      'Tap the family for your holes — pick Pocket pair.',
  // LPT-841: SoftPulse-quiet densify — no Broadway spoil.
  'act-02-02-01-scaffolded-broadway':
      'Both cards ten or higher — tap the matching family.',
  // LPT-842: SoftPulse-quiet densify — no Suited connector spoil.
  'act-02-02-01-unguided-sc':
      'Same-suit cards next to each other in rank — tap the matching family.',
  // LPT-784: SoftPulse-off densify — no correct-tile spoil.
  'act-02-02-01-checkpoint-trash':
      'Low unconnected offsuit holes — tap the matching family.',
  'act-02-05-01-guided-convert':
      'How many big blinds is your stack? Tap 100bb.',
  // LPT-849: SoftPulse-quiet densify — no 60bb tile spoil.
  'act-02-05-01-scaffolded-eff':
      'Your stack against the highlighted seat — tap the effective stack.',
  'act-02-05-01-unguided-depth':
      'Which depth plays closest to a short-stack shove game — tap the matching depth.',
  // LPT-785: SoftPulse-off densify — no correct-tile spoil.
  'act-02-05-01-checkpoint-200':
      'Your buy-in sits in front of you — tap the matching stack in big blinds.',
  'act-02-06-01-guided-follow': 'Two seats act before you. What first — pick Watch what they do, then decide.',
  // LPT-843: SoftPulse-quiet densify — no Say "raise" spoil.
  'act-02-06-01-scaffolded-verbal':
      'You want to raise. Clearest live choice — tap how you announce it and put out chips.',
  // LPT-844: SoftPulse-quiet densify — no Keep a chip spoil.
  'act-02-06-01-unguided-protect':
      'Your cards sit near the muck — tap how you protect them on the table.',
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
      'UTG opens, you call, BB calls. Pot now — tap 19.',
  // LPT-845: SoftPulse-quiet densify — no UTG / Seat left of the big blind spoil.
  'act-03-01-01-scaffolded':
      'Nine-handed. Dealer button is on seat 7 — tap who acts first preflop.',
  // LPT-846: SoftPulse-quiet densify — no Raise stands / verbal is binding spoil.
  'act-03-01-01-unguided':
      'You say "raise" then try to take it back to a call — tap the matching result.',
  // LPT-787: SoftPulse-off densify — no correct-tile spoil.
  'act-03-01-01-checkpoint':
      'Read the stacks and the pot — tap what matters most next.',
  'act-03-02-01-guided':
      'Class your hand on this flop — pick Made hand — top pair.',
  // LPT-847: SoftPulse-quiet densify — no Strong draw / nut flush draw spoil.
  'act-03-02-01-scaffolded':
      'Class your hand on this flop — tap the matching label.',
  // LPT-848: SoftPulse-quiet densify — no Air / little equity spoil.
  'act-03-02-01-unguided':
      'Multiway flop. Class your hand — tap the matching label.',
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
  // LPT-827: SoftPulse-quiet densify — no Strong aggression / Strong heat spoil.
  'act-04-07-01-scaffolded':
      'That seat finally raises and then barrels — tap the matching note.',
  // LPT-826: SoftPulse-quiet densify — no No — sample too small / Wait spoil.
  'act-04-07-01-unguided':
      'They folded two hands — tap whether a type label is ready.',
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
  // LPT-858: SoftPulse-quiet densify — no Continues pressure too wide spoil.
  'act-04-08-01-scaffolded':
      'They bet flop, turn, and river with weak showdowns twice. Note — tap the matching observation.',
  // LPT-860: SoftPulse-quiet densify — no Frequencies and shows spoil.
  'act-04-08-01-unguided':
      'Best note style versus wild aggression — tap the matching note.',
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
  // LPT-823: SoftPulse-quiet densify — no Rise / Stay zero spoil.
  'act-04-09-01-scaffolded':
      'After 30 hands of sticky calls — tap how confidence should move.',
  // LPT-777: SoftPulse-off densify — no correct-tile spoil.
  'act-04-09-01-checkpoint':
      'Course should show what beside a type label — tap the matching note.',
  'act-04-10-02-jump-range':
      'UTG open is best described as — tap the matching range.',
  'act-04-10-02-jump-spr':
      "What's the SPR? Tap the matching number.",
  'act-05-01-01-guided':
      'Four-way flop. Best continue with — pick Nut flush draw.',
  'act-05-01-01-checkpoint':
      'Multiway construction priority — tap the matching priority.',
  'act-05-02-01-guided': 'Deep stacks. Best reason to call this raise with your small pair — tap Implied odds if they pay sets.',
  // LPT-859: SoftPulse-quiet densify — no Map turn/river plans spoil.
  'act-05-02-01-unguided':
      'SPR ~12 on the flop. Your first job — tap the matching plan.',
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
  // LPT-861: SoftPulse-quiet densify — no Often polarized spoil.
  'act-05-05-01-unguided':
      'BB donks large on A-high dry flop into PFR. Meaning — tap the matching read.',
  // LPT-742: SoftPulse-off densify — no correct-tile spoil.
  'act-05-05-01-checkpoint':
      'You checked back the flop; they check the turn. Delayed c-bet is best when — tap the matching timing.',
  'act-05-06-01-guided':
      'Villain bets flop, checks turn. Range now — pick Capped — fewer nuts.',
  // LPT-862: SoftPulse-quiet densify — no Rebuild after every action spoil.
  'act-05-06-01-unguided':
      'After each street action — tap the matching line-reading habit.',
  // LPT-745: SoftPulse-off densify — no correct-tile spoil.
  'act-05-06-01-checkpoint':
      'Check-raise flop, bet turn, shove river usually means — tap the matching range.',
  'act-05-07-01-guided': 'Instant river shove after you bet. Correct framing — pick Soft evidence.',
  // LPT-863: SoftPulse-quiet densify — no Weaker / blocking spoil.
  'act-05-07-01-scaffolded':
      'Tiny flop bet into a huge pot often says — tap the matching read.',
  // LPT-855: SoftPulse-quiet densify — no Reject magic tells spoil.
  'act-05-07-01-unguided':
      'Coach says "look left means bluff." Response — tap the matching plan.',
  // LPT-744: SoftPulse-off densify — no correct-tile spoil.
  'act-05-07-01-checkpoint':
      'Best use of live timing — tap the matching habit.',
  'act-05-08-01-guided': 'Villain lost two buy-ins, now open-raises every hand. Note — pick Stuck / tilted.',
  // LPT-825: SoftPulse-quiet densify — no Gear change / Old label spoil.
  'act-05-08-01-scaffolded':
      'Solid selective player suddenly flats junk and donks rivers — tap the matching read.',
  // LPT-746: SoftPulse-off densify — no correct-tile spoil.
  'act-05-08-01-checkpoint':
      'Dynamic reads should be — tap the matching habit.',
  'act-05-09-01-guided':
      'You hit a planned stop-loss. Next step — pick Stop / move down.',
  // LPT-857: SoftPulse-quiet densify — no Decline spoil.
  'act-05-09-01-scaffolded':
      'Bankroll 40 buy-ins for 1/2. A 2/5 game has room. Action — tap the matching plan.',
  // LPT-854: SoftPulse-quiet densify — no Cash out spoil.
  'act-05-09-01-unguided':
      'Tired, winning small, table getting wild — tap the matching plan.',
  // LPT-747: SoftPulse-off densify — no correct-tile spoil.
  'act-05-09-01-checkpoint':
      'Session discipline is part of — tap the matching practice.',
  // LPT-717: SoftPulse-off densify — no correct-tile spoil.
  'act-05-09-02-cp-multi':
      'Four-way pot priority — tap the matching priority.',
  'act-05-09-02-cp-tell': 'Instant shove proves — tap the matching read.',
  'act-05-09-02-cp-stop': 'Hit stop-loss. Do — tap the matching plan.',
  'act-06-01-01-guided': 'PFR on A-high dry flop. Who often has range advantage — pick Preflop raiser.',
  // LPT-864: SoftPulse-quiet densify — no Wide caller spoil.
  'act-06-01-01-scaffolded':
      'Paired board. Caller defends wide. Who may have nut advantage — tap the matching seat.',
  // LPT-764: SoftPulse-off densify — no correct-tile spoil.
  'act-06-01-01-checkpoint':
      'Advantage is a reason to — tap the matching plan.',
  'act-06-02-01-guided':
      'Same draw OOP vs IP. Where does it realize better — pick In position.',
  // LPT-865: SoftPulse-quiet densify — no Discount / fold spoil.
  'act-06-02-01-scaffolded':
      'Weak showdown value OOP facing dual barrels. Default — tap the matching plan.',
  // LPT-856: SoftPulse-quiet densify — no Fold equity spoil.
  'act-06-02-01-unguided':
      'Semi-bluff check-raise with the nut draw. Purpose — tap the matching reason.',
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
      // Card-token densify stems rewrite onto the remapped deal (LPT-851).
      // withLessonTapInstruction may rewrite authored pick→tap (LPT-662).
      final aligned = alignLessonActionCopy(activity, line);
      expect(speech, contains(aligned.split(' — ').first));
    });
  }

  test(
    'Blinds SoftPulse-quiet / SoftPulse-off densify stems do not spoil '
    'choices (LPT-830/831/832/833/834/836)',
    () {
      const spoils = <String, List<String>>{
        'act-01-01-03-guided-button': [
          'the seat with the d chip',
          'pick the seat',
          'posted 2 chips',
        ],
        'act-01-01-03-scaffolded-blinds': [
          'two left',
          'posting 2',
          'seat two left',
        ],
        'act-01-01-03-unguided-when': [
          'before any hole',
          'after the flop',
          'showdown',
        ],
        'act-01-01-03-checkpoint-layout': [
          'one seat to its left',
          'seat 0',
          'seat 4',
        ],
        'act-02-01-01-scaffolded-blinds': [
          'sb or bb',
          'pick sb',
          'pick bb',
        ],
        'act-02-01-01-unguided-co': [
          'cutoff',
          'pick co',
          '(co)',
        ],
      };
      for (final MapEntry(key: id, value: phrases) in spoils.entries) {
        final resolved = selectIdentifyDensifiedCoachLine(id);
        expect(resolved, isNotNull, reason: id);
        final activity = catalog.activityById(id);
        expect(activity, isNotNull, reason: id);
        final speech = lessonFrameSpeech(activity!);
        final lower = speech.toLowerCase();
        expect(
          speech,
          alignLessonActionCopy(activity, resolved!),
          reason: '$id frame speech matches densify',
        );
        for (final spoil in phrases) {
          expect(
            lower,
            isNot(contains(spoil)),
            reason: '$id must not contain "$spoil"',
          );
        }
      }
    },
  );
}
