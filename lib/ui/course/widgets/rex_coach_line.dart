/// Shared Rex coach line for lesson activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

/// Resolves a single Rex instruction vs a duplicate prompt under the bubble.
///
/// Teach-by-doing: prefer one spoken line. Authored dialogue/demo wins; otherwise
/// the activity [CourseActivity.prompt] becomes the Rex line so we do not repeat
/// near-identical copy ("Tap ranks…" + "Order these ranks…").
({String coach, bool showPrompt}) resolveLessonCoachPrompt({
  required CourseActivity activity,
  required String fallback,
}) {
  final authored = activity.primaryCoachLine?.text.trim();
  final prompt = activity.prompt?.trim();
  if (authored != null && authored.isNotEmpty) {
    final show =
        prompt != null &&
        prompt.isNotEmpty &&
        prompt.toLowerCase() != authored.toLowerCase();
    return (coach: authored, showPrompt: show);
  }
  if (prompt != null && prompt.isNotEmpty) {
    return (coach: prompt, showPrompt: false);
  }
  return (coach: fallback, showPrompt: false);
}

/// Felt-first densified asks for select_identify steps whose catalog prompt
/// is still quiz-list language.
///
/// Under [LessonFrameScope], [RexCoachLine] shrinks and the runner bubble
/// uses [lessonFrameSpeech]. Without these lines, frame speech falls through
/// to catalog + "Tap the best answer." (LPT-221). Shared with the activity's
/// own coach so unframed and framed paths stay identical.
String? selectIdentifyDensifiedCoachLine(String activityId) {
  return switch (activityId) {
    'act-02-07-02-jump-family' =>
      'Look at your holes — pick the family they belong to.',
    'act-02-07-02-jump-stack' =>
      'You 120bb · villain 55bb — pick the effective stack.',
    // Count outs densified asks (LPT-279) — same path as baseline jump (LPT-221).
    'act-03-03-01-guided' =>
      'Count only the outs that make the best hand — pick every clean out.',
    'act-03-03-01-scaffolded' =>
      'Pot 20, bet 10 — pick the call that equals the bet.',
    'act-03-03-01-unguided' =>
      'Getting 3:1 with real outs — pick Call, Fold, or Raise.',
    'act-03-03-01-checkpoint' =>
      'Nut flush draw, deep and sticky — pick when future payoffs justify the price.',
    // Close the river checkpoint densified ask (LPT-343) — same path as
    // baseline jump (LPT-221) / count outs (LPT-279). Use pick/tap so
    // withLessonTapInstruction does not append "Tap the best answer."
    'act-03-06-01-checkpoint' =>
      'Medium one pair faces a big bet — pick the river job.',
    // Play tighter multiway densified asks (LPT-368) — same path.
    'act-03-07-01-unguided' =>
      'Deep multiway — pick the better speculative hand.',
    'act-03-07-01-checkpoint' =>
      'Seat enters most pots — pick what you note.',
    // Patch the common leaks checkpoint densified ask (LPT-382) — same path.
    'act-03-08-01-checkpoint' =>
      'Two seats, different frequencies — pick how often each seat enters.',
    // Section 3 jump select_identify densified asks (LPT-390) — same path.
    // jump-class stays felt-first (no hard-coded template ranks/suits).
    // SoftPulse off (kind: none); stems must not spoil the correct tile
    // (LPT-674; SoftPulse LPT-653; same class as LPT-673).
    'act-03-08-02-jump-table' =>
      'Pot 16, shorter 40bb — tap what you track first.',
    'act-03-08-02-jump-class' =>
      'Straight and flush both need runout — pick the hand class.',
    'act-03-08-02-jump-leak' =>
      'Gutshot vs a 2x pot bet — tap the matching price plan.',
    // Think in ranges densified asks (LPT-403) — same path as LPT-390.
    'act-04-01-01-guided' =>
      'UTG opens at 1/2 — pick the stronger, narrower range.',
    'act-04-01-01-scaffolded' =>
      'BTN open, BB 3-bet, BTN calls — pick whose range is stronger.',
    'act-04-01-01-unguided' =>
      'They bet twice — pick why Exactly AK is too precise.',
    'act-04-01-01-checkpoint' =>
      'Same board, different villain lines — pick how advice should change.',
    // Plan beyond the flop checkpoint densified ask (LPT-407) — same path.
    'act-04-03-01-checkpoint' =>
      'You have a flop plan — pick brick→barrel vs flush→abort.',
    // Size with a message unguided densified ask (LPT-410) — same path.
    'act-04-04-01-unguided' =>
      'Two value sizes both get calls — pick nearby soft-grade over one exact chip.',
    // SPR decides commitment guided densified ask (LPT-412) — same path.
    'act-04-05-01-guided' =>
      'Effective 80 into pot 20 — pick SPR 4.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Weigh SPR first / append the dock footer (LPT-812; SoftPulse
    // LPT-653; same class as LPT-809 / LPT-808 / LPT-807).
    'act-04-05-01-checkpoint' =>
      'About to put stacks in — tap the matching plan.',
    // Observe sticky callers densified asks (LPT-416) — same path.
    'act-04-06-01-guided' =>
      'Seat calls 7 of 9 preflops — pick High part.',
    'act-04-06-01-scaffolded' =>
      'Second pair called three streets twice — pick Sticky.',
    'act-04-06-01-unguided' =>
      'One dramatic call — pick Low conf.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Bundle in the idle bubble (LPT-810; SoftPulse LPT-653; same class
    // as LPT-809 / LPT-808 / LPT-807).
    'act-04-06-01-checkpoint' =>
      'Before you label — tap what evidence to gather.',
    // Meet the Calling Station densified asks (LPT-420) — same path.
    'act-04-06-02-guided' =>
      'Sticky second pair called three streets — pick Station.',
    // SoftPulse-quiet densify (scaffolded SoftPulse only after Hint) —
    // situation + tap verb only; never name Working model (LPT-817;
    // SoftPulse LPT-653; same class as LPT-814 / LPT-811).
    'act-04-06-02-scaffolded' =>
      'A player-type label is temporary evidence — tap what it is.',
    // SoftPulse-quiet densify (unguided SoftPulse only after Hint) —
    // situation + tap verb only; never name Station (LPT-818; SoftPulse
    // LPT-653; same class as LPT-817 / LPT-814 / LPT-811).
    'act-04-06-02-unguided' =>
      'Limps, calls, never folds turns — tap which type fits.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Low conf in the idle bubble (LPT-811; SoftPulse LPT-653; same
    // class as LPT-810 / LPT-809 / LPT-808).
    'act-04-06-02-checkpoint' =>
      'Only two hands so far — tap how confident you are.',
    // Recognize capped densified asks (LPT-636) — same path as LPT-416.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-03-01-guided' =>
      'Checks turn after flop bet — pick Capped.',
    'act-06-03-01-unguided' =>
      'XR flop / bet turn / bomb — pick Uncapped.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Attack in the idle bubble (LPT-809; SoftPulse LPT-653; same class
    // as LPT-810 / LPT-811 / LPT-808).
    'act-06-03-01-checkpoint' =>
      'Caps are for — tap the matching plan.',
    // Choose polarized densified asks (LPT-637) — same path as LPT-636.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-04-01-guided' =>
      'River overbet — pick the betting shape.',
    'act-06-04-01-unguided' =>
      'Mismatch to avoid — pick the sizing leak.',
    'act-06-04-01-checkpoint' =>
      'Merged betting aims to — pick the goal.',
    // Use overbets densified asks (LPT-638) — same path as LPT-637.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-05-01-guided' =>
      'Best overbet river — pick the polar candidate.',
    'act-06-05-01-unguided' =>
      'Random 3x pot medium — pick the disciplined line.',
    'act-06-05-01-checkpoint' =>
      'Geometric sizing helps — pick what it links.',
    // Use blockers densified asks (LPT-639) — same path as LPT-638.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-06-01-guided' =>
      'Flush-board river bluff — pick the better blocker.',
    'act-06-06-01-scaffolded' =>
      'Bluff-catch flush bomb — pick what you leave live.',
    'act-06-06-01-unguided' =>
      'Blockers replace — pick how far they go.',
    'act-06-06-01-checkpoint' =>
      'Solver EV quotes — pick the course stance.',
    // Defend enough densified asks (LPT-640) — same path as LPT-639.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-07-01-guided' =>
      'Facing a river bet — pick quality continues.',
    'act-06-07-01-unguided' =>
      'MDF numbers — pick how this course uses them.',
    'act-06-07-01-checkpoint' =>
      'Minimum defense goal — pick what you protect.',
    // Mix with a reason densified asks (LPT-644) — same path as LPT-640.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-08-01-scaffolded' =>
      'Vs Calling Station — pick the mix adjustment.',
    'act-06-08-01-unguided' =>
      'Randomness for its own sake — pick when mix is allowed.',
    'act-06-08-01-checkpoint' =>
      'Best mix description — pick the course standard.',
    // Navigate 3-bet densified asks (LPT-645) — same path as LPT-644.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-09-01-guided' =>
      '100bb 4-bet pot · top pair — pick the depth mindset.',
    'act-06-09-01-unguided' =>
      'Light 4-bet for ego — pick the discipline.',
    'act-06-09-01-checkpoint' =>
      'Depth change in 3-bet pots — pick what shifts.',
    // Difficult folds densified asks (LPT-646) — same path as LPT-645.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-10-01-scaffolded' =>
      'KK loses to AA all-in — pick the review label.',
    'act-06-10-01-unguided' =>
      'Calling because you are "due" — pick the real reason.',
    'act-06-10-01-checkpoint' =>
      'Review after a big loss — pick the honest question.',
    // Observe selective densified asks (LPT-647) — same path as LPT-646.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-11-01-guided' =>
      'Folds most, then 3-bets / c-bets — pick the note.',
    'act-06-11-01-scaffolded' =>
      'Gives up on turns when called — pick the observation.',
    'act-06-11-01-unguided' =>
      'Two hands of tightness — pick the confidence.',
    'act-06-11-01-checkpoint' =>
      'Best pre-label note bundle — pick the evidence pack.',
    // Meet the TAG densified asks (LPT-648) — same path as LPT-647.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-11-02-guided' =>
      'Folds most, 3-bets strong — pick the label.',
    'act-06-11-02-scaffolded' => 'TAG versus Maniac — pick the difference.',
    'act-06-11-02-unguided' =>
      'Opens tight, selective c-bets — pick the label.',
    'act-06-11-02-checkpoint' =>
      'TAG is a label from frequencies — pick how to treat it.',
    // Observe wide densified asks (LPT-649) — same path as LPT-648.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-12-01-guided' =>
      'Wide opens + barrels, some folds — pick the note.',
    'act-06-12-01-scaffolded' =>
      'Difference vs maniac — pick the separation.',
    'act-06-12-01-unguided' => 'One wide open — pick the confidence.',
    'act-06-12-01-checkpoint' =>
      'Best pre-label notes — pick the evidence pack.',
    // Meet the LAG densified asks (LPT-650) — same path as LPT-649.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-12-02-guided' =>
      'Opens wide, barrels often — pick the label.',
    'act-06-12-02-scaffolded' => 'LAG vs Station — pick the difference.',
    'act-06-12-02-unguided' =>
      'Wide opens, keeps barreling — pick the label.',
    'act-06-12-02-checkpoint' => 'Beside LAG label — pick what to show.',
    // Adjust versus LAG densified asks (LPT-651) — same path as LPT-650.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-12-03-unguided' =>
      'Inventing triple-barrel bluffs into a LAG — pick the discipline.',
    'act-06-12-03-checkpoint' => 'LAG exploit cites — pick the cite.',
    // Adjust versus TAG densified asks (LPT-652) — same path as LPT-651.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-11-03-checkpoint' => 'Versus TAG — pick the cite.',
    // Same cards, five type models densified asks (LPT-654) — same path as
    // LPT-652. Use pick/tap so withLessonTapInstruction does not append the
    // footer.
    'act-06-13-01-checkpoint' =>
      'Selective entry + disciplined barrels — pick the model + line.',
    // Section 6 checkpoint densified asks (LPT-655) — same path as LPT-654.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-13-02-cp-adv' =>
      'PFR on dry A-high — pick what they often have.',
    'act-06-13-02-cp-cap' =>
      'Check-back turn — pick how river range shifts.',
    'act-06-13-02-cp-polar' =>
      'River overbet shape — pick the range story.',
    'act-06-13-02-cp-tag' =>
      'Tight entry, planned barrels — pick the label.',
    'act-06-13-02-cp-lag' =>
      'Wide entry, sustained pressure — pick the label.',
    // Carry a preflop plan densified asks (LPT-656) — same path as LPT-655.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-07-01-01-guided' =>
      'AQo 3-bet · 872tt — pick the plan update.',
    'act-07-01-01-scaffolded' =>
      'BTN steal KTo · KT2r — pick the plan update.',
    'act-07-01-01-unguided' =>
      'Best habit — pick what to do before flop act.',
    'act-07-01-01-checkpoint' => 'Dead plan — pick the response.',
    // Map turn barrels densified asks (LPT-657) — same path as LPT-656.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-07-02-01-guided' => 'AK c-bet · Q72r — pick the continue cards.',
    'act-07-02-01-scaffolded' => 'Gutshot · brick raise — pick the map call.',
    'act-07-02-01-unguided' => 'No turn idea — pick what to do first.',
    'act-07-02-01-checkpoint' => 'Turn map — pick the definition.',
    // Compose river densified asks (LPT-658) — same path as LPT-657.
    // Guided is poker_action_sizing (not select_identify). Use pick/tap so
    // withLessonTapInstruction does not append the footer.
    'act-07-03-01-scaffolded' =>
      'Nut flush blocker — pick why the bluff works.',
    'act-07-03-01-unguided' => 'No story — pick the river action.',
    'act-07-03-01-checkpoint' => 'River rule — pick the composition check.',
    // Change plans by pot type densified asks (LPT-659) — same path as LPT-658.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-07-04-01-guided' => 'Multiway limped — pick the priority.',
    'act-07-04-01-scaffolded' => 'HU SRP IP — pick the default weapon.',
    'act-07-04-01-unguided' => '4-bet 100bb — pick the mindset.',
    'act-07-04-01-checkpoint' => 'Pot type — pick what changes.',
    // Switch gears HU vs multiway densified asks (LPT-660) — same path as LPT-659.
    'act-07-05-01-guided' => 'Four-way river — pick the air-bluff call.',
    'act-07-05-01-scaffolded' => 'HU vs nit — pick the steal frequency.',
    'act-07-05-01-unguided' => 'Multiway top set — pick the line lean.',
    'act-07-05-01-checkpoint' => 'Player count — pick how it ranks.',
    // Rewrite plans when stacks densified asks (LPT-661) — same path as LPT-660.
    'act-07-06-01-guided' => '35bb TPTK — pick the commit lean.',
    'act-07-06-01-scaffolded' => '250bb 55 — pick the set-mine lean.',
    'act-07-06-01-unguided' =>
      'Hero 200 / Villain 40 — pick effective stack.',
    'act-07-06-01-checkpoint' => 'Stack depth — pick how often to check.',
    // Replay same hand vs each type densified checkpoint (LPT-664).
    'act-07-07-01-checkpoint' => 'No type evidence — pick the default.',
    // Integrate type, board, line, and sizing densified checkpoint (LPT-665).
    'act-07-08-01-checkpoint' => 'Integrated decision — pick the input set.',
    // Write your default strategy book densified asks (LPT-662) — same path.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-07-09-01-guided' => 'Best leak note — pick the useful shape.',
    'act-07-09-01-scaffolded' =>
      'BTN vs unknown BB — pick the default source.',
    'act-07-09-01-unguided' => 'Review the book — pick when to do it.',
    'act-07-09-01-checkpoint' => 'Default book purpose — pick the role.',
    // Prep a coached Live warm-up hand densified asks (LPT-663) — same path.
    'act-07-11-01-guided' => 'Warm-up checklist — pick what belongs.',
    'act-07-11-01-scaffolded' => 'Carry into Live — pick what travels.',
    'act-07-11-01-unguided' => 'Scope reminder — pick the product lane.',
    'act-07-11-01-checkpoint' => 'Warm-up goal — pick the finish line.',
    // Densified asks still say Tap the best answer (catalog) densified asks (LPT-628) — same path.
    // Densified asks still say Tap the best answer (catalog) densified asks (LPT-628) — same path.
    // Stem-only — never hardcode template Ah Kd / Qs Jh 2c (LPT-792).
    'act-01-01-01-guided-find-holes' =>
      'Tap your hole cards on the table — pick the two in front of you.',
    'act-01-01-01-scaffolded-private' =>
      'Tap the cards only you can see — pick your private holes.',
    'act-01-01-01-unguided-mix' =>
      'Tap the community cards — pick the shared board in the middle.',
    'act-01-01-01-checkpoint-table' =>
      'Tap the cards that are only yours — pick the two at your seat.',
    // SoftPulse-quiet densify (guided same-concept until Hint) — situation +
    // tap verb only; never name Hearts/diamonds/clubs/spades in the idle
    // bubble (LPT-814; SoftPulse LPT-653; same class as LPT-808 / LPT-672).
    'act-01-01-02-guided-suits' =>
      'Tap one community card of each suit.',
    // Seat-deal densify (LPT-815 / LPT-816) — situation + tap verb only;
    // never name Suited / Offsuit / Pocket pair (same class as LPT-804).
    'act-01-01-02-unguided-suited' =>
      'Tap the seat whose hole cards share a suit.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Pocket pair in the idle bubble (LPT-804; SoftPulse LPT-653;
    // same class as LPT-803 / LPT-788 / LPT-672).
    'act-01-01-02-checkpoint-pair' =>
      'Same rank in one seat — tap the matching holes.',
    // LPT-83 split successors (LPT-628 reopen) — SoftPulse-off densify stems
    // must not name Hearts/diamonds/clubs/spades (LPT-814; same as guided).
    'act-01-01-02-01-scaffolded-suits' =>
      'Tap one community card of each suit.',
    'act-01-01-02-01-checkpoint-suits' =>
      'Tap one community card of each suit.',
    'act-01-01-02-03-guided-suited' =>
      'Tap the seat whose hole cards share a suit.',
    'act-01-01-03-guided-button' =>
      'Tap the dealer button on the table — pick The seat with the D chip.',
    'act-01-01-03-scaffolded-blinds' =>
      'Blinds are 1/2. Tap who posts the big blind — pick The seat two left of the button, posting 2.',
    'act-01-01-03-unguided-when' =>
      'Tap when the blinds go in — pick Before any hole cards are dealt.',
    'act-01-02-02-guided-seven' =>
      'Tap the five cards that make your best hand — pick Top pair with best kicker.',
    'act-01-02-02-checkpoint-build' =>
      'Tap the five cards for your strongest hand — pick Full house — trips over the higher pair.',
    'act-01-04-01-unguided-end' =>
      'Flop betting is live. Tap when this street ends — pick Bets matched.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name SB in the idle bubble (LPT-808; SoftPulse LPT-653; same class
    // as LPT-807 / LPT-803 / LPT-672).
    'act-01-04-01-checkpoint-postflop' =>
      'Postflop multiway — tap who acts first.',
    'act-01-05-01-guided-fold-win' =>
      'You bet. Everyone folds. Tap how you take the pot — pick Take pot.',
    'act-01-05-01-scaffolded-showdown' =>
      'River bets are called. Tap what happens next — pick Showdown.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Side pot in the idle bubble (LPT-782; SoftPulse LPT-653; same
    // class as LPT-780 / LPT-672).
    'act-01-05-01-checkpoint-side' =>
      'You are all-in for less; two big stacks keep betting — tap the matching pot fact.',
    'act-02-01-01-guided-btn' =>
      'Tap who acts last postflop — pick BTN.',
    'act-02-01-01-scaffolded-blinds' =>
      'Tap a seat that posts a forced bet every hand — pick SB or BB.',
    'act-02-01-01-unguided-co' =>
      'Tap the seat right before the button — pick Cutoff (CO).',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name On the button in the idle bubble (LPT-783; SoftPulse LPT-653;
    // same class as LPT-782 / LPT-780 / LPT-672).
    'act-02-01-01-checkpoint-edge' =>
      'Same hand early versus button — tap the matching edge.',
    'act-02-01-02-unguided-wait' =>
      'Action is on UTG. You are on the button. What do you do — pick Wait — do not act yet.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name BTN in the idle bubble (LPT-803; SoftPulse LPT-653; same class
    // as LPT-788 / LPT-783 / LPT-672).
    'act-02-01-02-checkpoint-full' =>
      'Six-max flop, everyone in — tap who acts last.',
    'act-02-02-01-guided-pair' =>
      'Tap the family for your holes — pick Pocket pair.',
    'act-02-02-01-scaffolded-broadway' =>
      'Tap the family for your holes — pick Broadway.',
    'act-02-02-01-unguided-sc' =>
      'Tap the family for your holes — pick Suited connector.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Offsuit trash in the idle bubble (LPT-784; SoftPulse LPT-653;
    // same class as LPT-783 / LPT-782 / LPT-672).
    'act-02-02-01-checkpoint-trash' =>
      'Low unconnected offsuit holes — tap the matching family.',
    'act-02-05-01-guided-convert' =>
      'Blinds 1/2. You have 200 chips. How many big blinds — pick 100bb.',
    'act-02-05-01-scaffolded-eff' =>
      'You have 150bb. Villain has 60bb. Effective stack — pick 60bb.',
    'act-02-05-01-unguided-depth' =>
      'Which depth plays closest to a short-stack shove game — pick 50bb.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name 200bb in the idle bubble (LPT-785; SoftPulse LPT-653; same class
    // as LPT-784 / LPT-783 / LPT-782 / LPT-672).
    'act-02-05-01-checkpoint-200' =>
      'Blinds 2/5. You buy in for 1000 chips — tap the matching stack in big blinds.',
    'act-02-06-01-guided-follow' =>
      'Two seats act before you. What first — pick Watch what they do, then decide.',
    'act-02-06-01-scaffolded-verbal' =>
      'You want to raise. Clearest live choice — pick Say "raise" and put out the chips.',
    'act-02-06-01-unguided-protect' =>
      'Your cards sit near the muck. Best habit — pick Keep a chip or hand on your cards.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name You acted out of turn in the idle bubble (LPT-786; SoftPulse
    // LPT-653; same class as LPT-785 / LPT-784 / LPT-672).
    'act-02-06-01-checkpoint-oot' =>
      'Action is two seats left. You toss in a raise early — tap the matching problem.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Cover your cards and wait your turn in the idle bubble (LPT-788;
    // SoftPulse LPT-653; same class as LPT-786 / LPT-787 / LPT-672).
    'act-02-07-01-checkpoint-habit' =>
      'Full ring. Action two seats left. Your cards are uncovered — tap the matching fix.',
    // SoftPulse off (kind: none); stem must not spoil Cutoff (LPT-675;
    // SoftPulse LPT-653; same class as LPT-672 / LPT-673 / LPT-674).
    'act-02-07-02-jump-pos' =>
      'Seat right before the button — pick it on the map.',
    'act-03-01-01-guided' =>
      'Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now — pick 21.',
    'act-03-01-01-scaffolded' =>
      'Nine-handed. Dealer button is on seat 7. Who acts first preflop — pick Seat left of the big blind (UTG).',
    'act-03-01-01-unguided' =>
      'You say "raise" then try to take it back to a call. Result — pick The raise stands — verbal is binding.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Effective 55bb / the 18 pot in the idle bubble (LPT-787;
    // SoftPulse LPT-653; same class as LPT-785 / LPT-786 / LPT-672).
    'act-03-01-01-checkpoint' =>
      'Hero 140bb, villain 55bb, pot 18 — tap what matters most next.',
    'act-03-02-01-guided' =>
      'Board Ks 9d 2c. You hold Kh Qh. Class — pick Made hand — top pair.',
    'act-03-02-01-scaffolded' =>
      'Board Jh 8h 3c. You hold Ah 9h. Class — pick Strong draw — nut flush draw.',
    'act-03-02-01-unguided' =>
      'Board Qc 7d 2s. You hold 5h 4h multiway. Class — pick Air — little equity, no pair.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Draw / open-ended straight draw, and never hardcode template
    // board/holes (LPT-805; SoftPulse LPT-653; remap honesty LPT-806 class;
    // same as LPT-803 / LPT-788 / LPT-672).
    'act-03-02-01-checkpoint' =>
      'Best label for this flop class — tap the matching label.',
    'act-03-05-01-guided' =>
      'Flop As 7d 2c. Turn 3h. For a missed c-bettor, is this a brick — pick Brick — rarely helps the caller.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Often give up, and never hardcode template board/holes (LPT-807;
    // SoftPulse LPT-653; remap honesty LPT-806 class; same as LPT-803 /
    // LPT-788 / LPT-805).
    'act-03-05-01-checkpoint' =>
      'Bluffed the flop; turn completes front-door draws — tap the matching plan.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name They fold too rarely in the idle bubble (LPT-780; same class as
    // LPT-777 / LPT-778 / LPT-765 / LPT-653).
    'act-04-06-03-checkpoint' =>
      'Why bluff less versus a Calling Station — tap the matching reason.',
    'act-04-07-01-guided' =>
      'Seat folded 20 of 22 hands. Observation — pick Narrow entry — plays few hands.',
    'act-04-07-01-scaffolded' =>
      'That seat finally raises and then barrels. Observation — pick Strong aggression when they enter.',
    'act-04-07-01-unguided' =>
      'They folded two hands. Label them already — pick No — sample too small.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Few hands / heavy action in the idle bubble (LPT-763; same class
    // as LPT-746 / LPT-653).
    'act-04-07-01-checkpoint' =>
      'Evidence bundle for this seat — tap the matching note.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name A working model with sample limits in the idle bubble (LPT-765;
    // same class as LPT-764 / LPT-763 / LPT-746 / LPT-653).
    'act-04-07-02-checkpoint' =>
      'Nit is best treated as — tap the matching model stance.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Range is strong when they raise in the idle bubble (LPT-778;
    // same class as LPT-777 / LPT-765 / LPT-770 / LPT-771 / LPT-653).
    'act-04-07-03-checkpoint' =>
      'Why respect a Nit check-raise — tap the matching reason.',
    'act-04-08-01-guided' =>
      'Seat raises or 3-bets twelve of fifteen pots. Observation — pick Extreme entry and aggression.',
    'act-04-08-01-scaffolded' =>
      'They bet flop, turn, and river with weak showdowns twice. Note — pick Continues pressure too wide.',
    'act-04-08-01-unguided' =>
      'Best note style versus wild aggression — pick Frequencies and shows — no ego story.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Enters constantly; barrels without mercy in the idle bubble
    // (LPT-770; same class as LPT-765 / LPT-764 / LPT-746 / LPT-653).
    'act-04-08-01-checkpoint' =>
      'Evidence bundle for this seat — tap the matching note.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Calling Station, Nit, and Maniac in the idle bubble (LPT-771;
    // same class as LPT-770 / LPT-765 / LPT-764 / LPT-746 / LPT-653).
    'act-04-08-02-checkpoint' =>
      'Which types are legal to mix now — tap the matching set.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Their betting range is too wide in the idle bubble (LPT-781; same
    // class as LPT-780 / LPT-777 / LPT-778 / LPT-765 / LPT-653).
    'act-04-08-03-checkpoint' =>
      'Why call wider versus a Maniac — tap the matching reason.',
    'act-04-09-01-guided' =>
      'You saw one huge bluff. What do you know — pick One note — low certainty.',
    'act-04-09-01-scaffolded' =>
      'After 30 hands of sticky calls, confidence should — pick Rise — still revisable.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Sample and confidence limits in the idle bubble (LPT-777; same
    // class as LPT-778 / LPT-765 / LPT-770 / LPT-771 / LPT-653).
    'act-04-09-01-checkpoint' =>
      'Course should show what beside a type label — tap the matching note.',
    // Assessment SoftPulse-off densify (LPT-673): situation + tap verb only —
    // never name the correct tile/value in the idle bubble (same as LPT-672).
    'act-04-10-02-jump-range' =>
      'UTG open is best described as — tap the matching range.',
    'act-04-10-02-jump-spr' =>
      'Stack 60bb, pot 15bb. SPR — tap the matching number.',
    'act-05-01-01-guided' =>
      'Four-way flop. Best continue with — pick Nut flush draw.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Nut potential / clean equity in the idle bubble (LPT-723; same
    // class as LPT-717 / LPT-672 / LPT-653).
    'act-05-01-01-checkpoint' =>
      'Multiway construction priority — tap the matching priority.',
    'act-05-02-01-guided' =>
      '200bb effective. Best reason to call a raise with 55 BTN — pick Implied odds if they pay sets.',
    'act-05-02-01-unguided' =>
      'SPR ~12 on the flop. Your first job — pick Map turn/river plans before committing.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Position / implied odds / disciplined folds in the idle bubble
    // (LPT-735; same class as LPT-723 / LPT-717 / LPT-672 / LPT-653).
    'act-05-02-01-checkpoint' =>
      '150–300bb cash play rewards — tap the matching reward.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Deep stacks / opponents who pay / Depth + pay in the idle bubble
    // (LPT-734; same class as LPT-735 / LPT-723 / LPT-717 / LPT-672 / LPT-653).
    'act-05-03-01-checkpoint' =>
      'Implied odds rise most when — tap the matching condition.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name The line / authored read in the idle bubble (LPT-736; same class
    // as LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672 / LPT-653).
    'act-05-04-01-checkpoint' =>
      'Same hand, different types — tap the matching change.',
    'act-05-05-01-guided' =>
      'Nit check-raises flop. Default read — pick Value-heavy — respect.',
    'act-05-05-01-unguided' =>
      'BB donks large on A-high dry flop into PFR. Meaning — pick Often polarized — strong or bluff.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name After flop check / range strength / After weakness in the idle
    // bubble (LPT-742; same class as LPT-736 / LPT-734 / LPT-735 / LPT-723 /
    // LPT-717 / LPT-672 / LPT-653).
    'act-05-05-01-checkpoint' =>
      'Delayed c-bet is best when — tap the matching timing.',
    'act-05-06-01-guided' =>
      'Villain bets flop, checks turn. Range now — pick Capped — fewer nuts.',
    'act-05-06-01-unguided' =>
      'Best line-reading habit — pick Rebuild after every action.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Uncapped / respect unless type in the idle bubble (LPT-745; same
    // class as LPT-744 / LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 /
    // LPT-717 / LPT-672 / LPT-653).
    'act-05-06-01-checkpoint' =>
      'Check-raise flop, bet turn, shove river usually means — tap the matching range.',
    'act-05-07-01-guided' =>
      'Instant river shove after you bet. Correct framing — pick Soft evidence.',
    'act-05-07-01-scaffolded' =>
      'Tiny flop bet into a huge pot often says — pick Weaker / blocking.',
    'act-05-07-01-unguided' =>
      'Coach says "look left means bluff." Response — pick Reject magic tells.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Tiny update / stronger reads in the idle bubble (LPT-744; same
    // class as LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 /
    // LPT-672 / LPT-653).
    'act-05-07-01-checkpoint' =>
      'Best use of live timing — tap the matching habit.',
    'act-05-08-01-guided' =>
      'Villain lost two buy-ins, now open-raises every hand. Note — pick Stuck / tilted.',
    'act-05-08-01-scaffolded' =>
      'Solid selective player suddenly flats junk and donks rivers. Best read — pick Gear change.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Fresh samples in the idle bubble (LPT-746; same class as LPT-745 /
    // LPT-744 / LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 /
    // LPT-672 / LPT-653).
    'act-05-08-01-checkpoint' =>
      'Dynamic reads should be — tap the matching habit.',
    'act-05-09-01-guided' =>
      'You hit a planned stop-loss. Next step — pick Stop / move down.',
    'act-05-09-01-scaffolded' =>
      'Bankroll 40 buy-ins for 1/2. Spot opens at 2/5. Action — pick Decline.',
    'act-05-09-01-unguided' =>
      'Tired, winning small, table getting wild. Best — pick Cash out.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Your edge in the idle bubble (LPT-747; same class as LPT-746 /
    // LPT-745 / LPT-744 / LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 /
    // LPT-717 / LPT-672 / LPT-653).
    'act-05-09-01-checkpoint' =>
      'Session discipline is part of — tap the matching practice.',
    // Section 5 checkpoint densify — SoftPulse off (kind: none); stems must
    // not spoil the correct tile (LPT-717; SoftPulse LPT-653; same class as
    // LPT-672 / LPT-673 / LPT-674).
    'act-05-09-02-cp-multi' =>
      'Four-way pot priority — tap the matching priority.',
    'act-05-09-02-cp-tell' =>
      'Instant shove proves — tap the matching read.',
    'act-05-09-02-cp-stop' =>
      'Hit stop-loss. Do — tap the matching plan.',
    'act-06-01-01-guided' =>
      'PFR on A-high dry flop. Who often has range advantage — pick Preflop raiser.',
    'act-06-01-01-scaffolded' =>
      'Paired board. Caller defends wide. Who may have nut advantage — pick Wide caller.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Apply pressure in the idle bubble (LPT-764; same class as LPT-746 /
    // LPT-653).
    'act-06-01-01-checkpoint' =>
      'Advantage is a reason to — tap the matching plan.',
    'act-06-02-01-guided' =>
      'Same draw OOP vs IP. Where does it realize better — pick In position.',
    'act-06-02-01-scaffolded' =>
      'Weak showdown value OOP facing dual barrels. Default — pick Discount / fold.',
    'act-06-02-01-unguided' =>
      'Semi-bluff check-raise with nut draw IP-denied. Purpose — pick Fold equity.',
    // SoftPulse-off densify (kind: none) — situation + tap verb only; never
    // name Position + initiative in the idle bubble (LPT-766; same class as
    // LPT-764 / LPT-746 / LPT-653).
    'act-06-02-01-checkpoint' =>
      'Equity realization rises with — tap the matching levers.',
    // Assessment SoftPulse-off densify (LPT-672): situation + tap verb only —
    // never name the correct tile/exploit in the idle bubble.
    'act-07-12-01-uncertain' =>
      'Three mixed samples only. Confidence — tap the matching level.',
    'act-07-12-01-retire' =>
      'Old Calling Station now folds rivers and 3-bets light. Do — tap the matching next step.',
    // Densified asks still say Tap the best answer (catalog) remaining densified asks (LPT-628) — same path.
    'act-01-01-03-checkpoint-layout' =>
      'The button has the D chip. Tap the small blind, one seat to its left.',
    'act-01-02-02-scaffolded-kicker' =>
      'Same pair on the board. Tap your cards if your kicker wins, their cards if theirs wins, or Chop if you tie.',
    'act-01-02-02-unguided-board' =>
      'Both checked down. Tap the board if both play it, or a player\'s cards if you think their holes win.',
    'act-01-05-01-unguided-pot' =>
      'BTN opens — tap the pot before blinds act.',
    'act-04-07-02-guided' =>
      'Seat plays ~8% of hands and 3-bets rarely but large. Label — tap Nit.',
    // SoftPulse-quiet densify (unguided SoftPulse only after Hint) —
    // situation + tap verb only; never name Nit (LPT-819; SoftPulse
    // LPT-653; same class as LPT-818 / LPT-817 / LPT-814).
    'act-04-07-02-unguided' =>
      'Seat folds forever, then check-raises a triple barrel — tap which type fits.',
    'act-04-08-02-guided' =>
      'Seat open-raises 60% and triple-barrels light. Label — tap Maniac.',
    // SoftPulse-quiet densify (unguided SoftPulse only after Hint) —
    // situation + tap verb only; never name Maniac (LPT-820; SoftPulse
    // LPT-653; same class as LPT-819 / LPT-818).
    'act-04-08-02-unguided' =>
      'Seat 3-bets light and never gives up rivers — tap which type fits.',
    // SoftPulse-quiet densify (unguided SoftPulse only after Hint) —
    // situation + tap verb only; never name Update / Calling Station model
    // (or Freeze) (LPT-821; SoftPulse LPT-653; same class as LPT-820 /
    // LPT-819 / LPT-818).
    'act-04-09-01-unguided' =>
      'Former \'station\' starts folding three streets — tap which next step fits.',
    // Section 4 jump densify — SoftPulse off (kind: none); stems must not
    // spoil the correct exploit/tile (LPT-673; SoftPulse LPT-653).
    'act-04-10-02-jump-station' =>
      'Sticky caller three streets. Label + exploit direction — tap the matching plan.',
    'act-04-10-02-jump-nit' =>
      'Tiny range, huge check-raise. Label + line — tap the matching plan.',
    'act-04-10-02-jump-maniac' =>
      'Seat barrels forever. You have top pair. Label + line — tap the matching plan.',
    // Final five-type checkpoint densify — SoftPulse off (kind: none); stems
    // must not spoil the correct exploit/tile (LPT-672; SoftPulse LPT-653).
    'act-07-12-01-cs' =>
      'Sticky calls three streets. Label + exploit — tap the matching plan.',
    'act-07-12-01-nit' =>
      'Tiny range, huge check-raise. Label + line — tap the matching plan.',
    'act-07-12-01-maniac' =>
      'Endless barrels, never folds. Label + line — tap the matching plan.',
    'act-07-12-01-tag' =>
      'Selective entry, disciplined barrels. Label + vs raise — tap the matching plan.',
    'act-07-12-01-lag' =>
      'Wide entry, sustained pressure, some folds. Label + line — tap the matching plan.',
    _ => null,
  };
}

/// Whether Rex should render for [activity] given [showGuidance] and resolved
/// coach copy (covers prompt-as-Rex on unguided steps).
bool shouldShowLessonCoach({
  required CourseActivity activity,
  required bool showGuidance,
  required String coach,
}) {
  if (coach.trim().isEmpty) return false;
  return showGuidance ||
      activity.primaryCoachLine != null ||
      (activity.prompt?.trim().isNotEmpty ?? false);
}

/// One short Rex sentence with optional demonstration chrome.
class RexCoachLine extends StatelessWidget {
  /// Creates a Rex line.
  const RexCoachLine({
    super.key,
    required this.text,
    this.label = 'Rex',
    this.emphasize = false,
  });

  /// Builds from catalog media when present.
  factory RexCoachLine.fromActivity(CourseActivity activity, {Key? key}) {
    final media = activity.primaryCoachLine;
    return RexCoachLine(
      key: key,
      text: media?.text ?? activity.accessibilityText,
      emphasize: media?.kind == 'demonstration',
    );
  }

  final String text;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    if (LessonFrameScope.maybeOf(context) != null) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label: '$label says: $text',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RexMascot(size: 36),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.bgElevated.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border.all(
                  color:
                      emphasize
                          ? AppColors.gold.withValues(alpha: 0.55)
                          : AppColors.slateDark,
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 14.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Choice chip/button used across select-style activities.
class LessonChoiceButton extends StatelessWidget {
  /// Creates a choice button.
  const LessonChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.accessibilityText,
    this.highlighted = false,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final String? accessibilityText;
  final bool highlighted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border =
        selected
            ? AppColors.selectionGlow
            : highlighted
            ? AppColors.goldMuted
            : AppColors.slateDark;
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? label,
      child: AnimatedScale(
        scale: selected ? 1.015 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color:
              selected
                  ? AppColors.selectionGlow.withValues(alpha: 0.22)
                  : highlighted
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.surfaceMuted.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: selected ? 2 : 1),
              ),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  color: enabled ? AppColors.cream : AppColors.slate,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
