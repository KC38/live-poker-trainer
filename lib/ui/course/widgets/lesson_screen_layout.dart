/// Shared lesson frame: chrome, coach band, stage, tools, answer dock.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Lessons that use [LessonScreenLayout] instead of the app-bar runner.
bool isLessonScreenFrameLesson(String lessonId) {
  return lessonId == 'lesson-01-01-01-your-two-cards' ||
      lessonId == 'lesson-01-01-01' ||
      lessonId == 'lesson-01-01-02-suits-and-ranks' ||
      lessonId == 'lesson-01-01-02' ||
      lessonId == 'lesson-01-01-03-blinds-and-button' ||
      lessonId == 'lesson-01-01-03' ||
      lessonId == 'lesson-01-02-01-hand-ranks' ||
      lessonId == 'lesson-01-02-01' ||
      lessonId == 'lesson-01-02-02-best-five-kickers' ||
      lessonId == 'lesson-01-02-02' ||
      lessonId == 'lesson-01-03-01-fold-check-call' ||
      lessonId == 'lesson-01-03-01' ||
      lessonId == 'lesson-01-03-02-bet-raise-allin' ||
      lessonId == 'lesson-01-03-02' ||
      lessonId == 'lesson-01-04-01-streets-and-order' ||
      lessonId == 'lesson-01-04-01' ||
      lessonId == 'lesson-01-05-01-winning-pots' ||
      lessonId == 'lesson-01-05-01' ||
      lessonId == 'lesson-01-06-01-guided-complete-hand' ||
      lessonId == 'lesson-01-06-01' ||
      lessonId == 'lesson-01-06-02-section-one-jump' ||
      lessonId == 'lesson-01-06-02' ||
      lessonId == 'lesson-02-01-01-position-labels' ||
      lessonId == 'lesson-02-01-01' ||
      lessonId == 'lesson-02-01-02-acting-order' ||
      lessonId == 'lesson-02-01-02' ||
      lessonId == 'lesson-02-02-01-hand-families' ||
      lessonId == 'lesson-02-02-01' ||
      lessonId == 'lesson-02-03-01-open-fold' ||
      lessonId == 'lesson-02-03-01' ||
      lessonId == 'lesson-02-04-01-facing-raise' ||
      lessonId == 'lesson-02-04-01' ||
      lessonId == 'lesson-02-05-01-effective-stack' ||
      lessonId == 'lesson-02-05-01' ||
      lessonId == 'lesson-02-06-01-live-habits' ||
      lessonId == 'lesson-02-06-01' ||
      lessonId == 'lesson-02-07-01-baseline-full-hand' ||
      lessonId == 'lesson-02-07-01' ||
      lessonId == 'lesson-02-07-02-section-two-jump' ||
      lessonId == 'lesson-02-07-02' ||
      lessonId == 'lesson-03-01-01-reading-live-table' ||
      lessonId == 'lesson-03-01-01' ||
      lessonId == 'lesson-03-02-01-flop-hand-classes' ||
      lessonId == 'lesson-03-02-01' ||
      lessonId == 'lesson-03-03-01-outs-and-price' ||
      lessonId == 'lesson-03-03-01' ||
      lessonId == 'lesson-03-04-01-flop-decisions' ||
      lessonId == 'lesson-03-04-01' ||
      lessonId == 'lesson-03-05-01-turn-decisions' ||
      lessonId == 'lesson-03-05-01' ||
      lessonId == 'lesson-03-06-01-river-decisions' ||
      lessonId == 'lesson-03-06-01' ||
      lessonId == 'lesson-03-07-01-multiway-fundamentals' ||
      lessonId == 'lesson-03-07-01' ||
      lessonId == 'lesson-03-08-01-leak-repair' ||
      lessonId == 'lesson-03-08-01' ||
      lessonId == 'lesson-03-08-02-section-three-jump-test' ||
      lessonId == 'lesson-03-08-02' ||
      lessonId == 'lesson-04-01-01-ranges-not-hands' ||
      lessonId == 'lesson-04-01-01' ||
      lessonId == 'lesson-04-02-01-threebet-squeeze' ||
      lessonId == 'lesson-04-02-01' ||
      lessonId == 'lesson-04-03-01-continuation-plans' ||
      lessonId == 'lesson-04-03-01' ||
      lessonId == 'lesson-04-04-01-sizing-communicates' ||
      lessonId == 'lesson-04-04-01' ||
      lessonId == 'lesson-04-05-01-spr-commitment' ||
      lessonId == 'lesson-04-05-01' ||
      lessonId == 'lesson-04-06-01-observe-sticky-caller' ||
      lessonId == 'lesson-04-06-01' ||
      lessonId == 'lesson-04-06-02-meet-calling-station' ||
      lessonId == 'lesson-04-06-02' ||
      lessonId == 'lesson-04-06-03-adjust-calling-station' ||
      lessonId == 'lesson-04-06-03' ||
      lessonId == 'lesson-04-07-01-observe-narrow-player' ||
      lessonId == 'lesson-04-07-01' ||
      lessonId == 'lesson-04-07-02-meet-nit' ||
      lessonId == 'lesson-04-07-02' ||
      lessonId == 'lesson-04-07-03-adjust-nit' ||
      lessonId == 'lesson-04-07-03' ||
      lessonId == 'lesson-04-08-01-observe-wild-aggressor' ||
      lessonId == 'lesson-04-08-01' ||
      lessonId == 'lesson-04-08-02-meet-maniac' ||
      lessonId == 'lesson-04-08-02' ||
      lessonId == 'lesson-04-08-03-adjust-maniac' ||
      lessonId == 'lesson-04-08-03' ||
      lessonId == 'lesson-04-09-01-type-identification' ||
      lessonId == 'lesson-04-09-01' ||
      lessonId == 'lesson-04-10-01-exploit-checkpoints' ||
      lessonId == 'lesson-04-10-01' ||
      lessonId == 'lesson-04-10-02-section-four-jump-test' ||
      lessonId == 'lesson-04-10-02' ||
      lessonId == 'lesson-05-01-01-multiway-ranges' ||
      lessonId == 'lesson-05-01-01' ||
      lessonId == 'lesson-05-02-01-deep-stack-play' ||
      lessonId == 'lesson-05-02-01' ||
      lessonId == 'lesson-05-03-01-implied-odds' ||
      lessonId == 'lesson-05-03-01' ||
      lessonId == 'lesson-05-04-01-thin-value-bluffcatch' ||
      lessonId == 'lesson-05-04-01' ||
      lessonId == 'lesson-05-05-01-lines-and-probes' ||
      lessonId == 'lesson-05-05-01' ||
      lessonId == 'lesson-05-06-01-line-reading' ||
      lessonId == 'lesson-05-06-01' ||
      lessonId == 'lesson-05-07-01-timing-sizing-evidence' ||
      lessonId == 'lesson-05-07-01' ||
      lessonId == 'lesson-05-08-01-table-dynamics' ||
      lessonId == 'lesson-05-08-01' ||
      lessonId == 'lesson-05-09-01-session-discipline' ||
      lessonId == 'lesson-05-09-01' ||
      lessonId == 'lesson-05-09-02-section-five-checkpoint' ||
      lessonId == 'lesson-05-09-02' ||
      lessonId == 'lesson-06-01-01-range-nut-advantage' ||
      lessonId == 'lesson-06-01-01' ||
      lessonId == 'lesson-06-02-01-equity-realization' ||
      lessonId == 'lesson-06-02-01' ||
      lessonId == 'lesson-06-03-01-capped-uncapped' ||
      lessonId == 'lesson-06-03-01' ||
      lessonId == 'lesson-06-04-01-polar-merged' ||
      lessonId == 'lesson-06-04-01' ||
      lessonId == 'lesson-06-05-01-overbets-geometric' ||
      lessonId == 'lesson-06-05-01' ||
      lessonId == 'lesson-06-06-01-blockers' ||
      lessonId == 'lesson-06-06-01' ||
      lessonId == 'lesson-06-07-01-minimum-defense' ||
      lessonId == 'lesson-06-07-01' ||
      lessonId == 'lesson-06-08-01-mixed-strategy' ||
      lessonId == 'lesson-06-08-01' ||
      lessonId == 'lesson-06-09-01-threebet-fourbet' ||
      lessonId == 'lesson-06-09-01' ||
      lessonId == 'lesson-06-10-01-difficult-folds' ||
      lessonId == 'lesson-06-10-01' ||
      lessonId == 'lesson-06-11-01-observe-selective' ||
      lessonId == 'lesson-06-11-01' ||
      lessonId == 'lesson-06-11-02-meet-tag' ||
      lessonId == 'lesson-06-11-02' ||
      lessonId == 'lesson-06-11-03-adjust-tag' ||
      lessonId == 'lesson-06-11-03' ||
      lessonId == 'lesson-06-12-01-observe-wide-pressure' ||
      lessonId == 'lesson-06-12-01' ||
      lessonId == 'lesson-06-12-02-meet-lag' ||
      lessonId == 'lesson-06-12-02' ||
      lessonId == 'lesson-06-12-03-adjust-lag' ||
      lessonId == 'lesson-06-12-03' ||
      lessonId == 'lesson-06-13-01-mix-five-types' ||
      lessonId == 'lesson-06-13-01' ||
      lessonId == 'lesson-06-13-02-section-six-checkpoint' ||
      lessonId == 'lesson-06-13-02' ||
      lessonId == 'lesson-07-01-01-preflop-to-flop' ||
      lessonId == 'lesson-07-01-01' ||
      lessonId == 'lesson-07-02-01-flop-to-turn-map' ||
      lessonId == 'lesson-07-02-01' ||
      lessonId == 'lesson-07-03-01-river-composition' ||
      lessonId == 'lesson-07-03-01' ||
      lessonId == 'lesson-07-04-01-pot-type-plans' ||
      lessonId == 'lesson-07-04-01' ||
      lessonId == 'lesson-07-05-01-hu-vs-multiway' ||
      lessonId == 'lesson-07-05-01';
}

/// The one sentence in the speech bubble. Nothing else on the step repeats it.
String lessonFrameSpeech(CourseActivity activity, {int handStepIndex = 0}) {
  if (activity.id == 'act-01-01-01-explain-hole-cards') {
    return 'These two are your cards alone. Nobody else sees them. '
        'Tap your cards to peek.';
  }
  if (activity.id == 'act-01-01-03-explain-button') {
    return 'Button marks the dealer. Blinds sit left of it. '
        'Tap the button, then the small blind, then the big blind.';
  }
  if (activity.id == 'act-01-01-03-checkpoint-layout') {
    return 'The button has the D chip. Tap the small blind, '
        'one seat to its left.';
  }
  if (activity.id == 'act-01-02-01-explain-ladder') {
    return 'Pair beats high card. Flush beats straight. Tap each rung.';
  }
  if (activity.id == 'act-01-02-01-checkpoint-winner') {
    return 'Showdown. Tap your cards if the flush wins, their cards if '
        'the straight wins, or the board to chop.';
  }
  if (activity.id == 'act-01-02-02-explain-five') {
    return 'Only five cards count. Tap each card that plays.';
  }
  if (activity.id == 'act-01-02-02-scaffolded-kicker') {
    return 'Same pair of kings. Tap your cards if the queen kicker wins, '
        'their cards if the jack wins, or the board to chop.';
  }
  if (activity.id == 'act-01-02-02-unguided-board') {
    return 'The board is broadway. Tap the board if both play it, your '
        'cards if a higher hole card wins, or their cards if the button wins.';
  }
  if (activity.id == 'act-01-03-01-explain-passive') {
    return 'Three quiet buttons. Tap Fold, then Check, then Call.';
  }
  if (activity.id == 'act-01-03-02-explain-aggro') {
    return 'Three chip-pushing buttons. Tap Bet, then Raise, then All-in.';
  }
  if (activity.id == 'act-01-04-01-explain-streets') {
    return 'Four streets: preflop, flop, turn, river. Tap each street.';
  }
  if (activity.id == 'act-01-05-01-explain-win') {
    return 'Folds win pots early. Showdown compares hands. Tap each path.';
  }
  if (activity.id == 'act-01-06-01-explain-run') {
    return 'One short hand. Tap Blinds, then You act, then Ending.';
  }
  if (activity.id == 'act-02-01-01-explain-pos') {
    return 'Later seats see more. Tap the button.';
  }
  if (activity.id == 'act-02-01-02-explain-order') {
    return 'Preflop starts left of the big blind. Tap EP, then HJ, then BTN.';
  }
  if (activity.id == 'act-02-02-01-explain-families') {
    return 'Pairs, broadways, suited aces, connectors. Tap each family.';
  }
  if (activity.id == 'act-02-03-01-explain-open') {
    return 'Early is tight. The button opens wider. '
        'Tap Early, then Button, then Live 3x.';
  }
  if (activity.id == 'act-02-04-01-explain-vs') {
    return 'Weak hands fold. Playable hands call. '
        'Tap Fold, then Call, then 3-bet.';
  }
  if (activity.id == 'act-02-05-01-explain-bb') {
    return 'The shorter stack sets the ceiling. '
        'Tap Chips to BB, then Shorter, then Depth.';
  }
  if (activity.id == 'act-02-06-01-explain-habits') {
    return 'Watch the action, say it, cover your cards, and wait. '
        'Tap Watch, then Say, then Cover, then Wait.';
  }
  if (activity.id == 'act-02-07-01-explain-full') {
    return 'Nine seats. The rules stay the same. '
        'Tap Nine, then Same, then Position.';
  }
  if (activity.id == 'act-03-01-01-explain') {
    return 'Before cards, read the table. '
        'Tap Pot, then Stacks, then Button, then Who acts.';
  }
  if (activity.id == 'act-03-02-01-explain') {
    return 'Flop first: made, draw, showdown value, or air. '
        'Tap Made, then Draw, then SDV, then Air.';
  }
  if (activity.id == 'act-03-03-01-explain') {
    return 'Clean outs help. Dirty outs trap you. '
        'Tap Clean, then Dirty, then Price.';
  }
  if (activity.id == 'act-03-04-01-explain') {
    return 'One plan on the flop. '
        'Tap Value, then C-bet, then Check, then Call, then Fold, then Raise.';
  }
  if (activity.id == 'act-03-05-01-explain') {
    return 'A turn bricks or changes the story. '
        'Tap Brick, then Change, then Barrel, then Delay.';
  }
  if (activity.id == 'act-03-06-01-explain') {
    return 'River is value, bluff, bluff-catch, or fold. '
        'Tap Value, then Bluff, then Catch, then Fold.';
  }
  if (activity.id == 'act-03-07-01-explain') {
    return 'More players need stronger hands. '
        'Tap Stronger, then Fewer, then Nuts.';
  }
  if (activity.id == 'act-03-08-01-explain') {
    return 'Common leaks: top pair, bad prices, passive calls, crowd bluffs. '
        'Tap Top pair, then Prices, then Passive, then Crowds.';
  }
  if (activity.id == 'act-04-01-01-explain') {
    return 'You never know one hand. You know a range. '
        'Tap One hand, then Range, then Update.';
  }
  if (activity.id == 'act-04-02-01-explain') {
    return '3-bets define ranges. Squeezes punish flats. '
        'Tap 3-bet, then Ranges, then Squeeze.';
  }
  if (activity.id == 'act-04-03-01-explain') {
    return 'Every flop choice needs a turn and a river. '
        'Tap Flop, then Turn, then River.';
  }
  if (activity.id == 'act-04-04-01-explain') {
    return 'Size is language. Value looks like value. '
        'Tap Value, then Pressure, then Size.';
  }
  if (activity.id == 'act-04-05-01-explain') {
    return 'SPR is stack divided by the pot. '
        'Tap SPR, then Low, then High.';
  }
  if (activity.id == 'act-04-06-01-explain') {
    return 'Before labels, count who enters, who calls, and who folds. '
        'Tap Enters, then Calls, then Folds.';
  }
  if (activity.id == 'act-04-06-02-explain') {
    return 'Calling Station is a working model: high participation, low folding. '
        'Tap Station, then High, then Low.';
  }
  if (activity.id == 'act-04-06-03-explain') {
    return 'Versus stations: thicker value, fewer pure bluffs. '
        'Tap Value, then Bluffs, then Cite.';
  }
  if (activity.id == 'act-04-07-01-explain') {
    return 'Some seats almost never enter. When they do, they mean it. '
        'Tap Rare, then Enter, then Mean it.';
  }
  if (activity.id == 'act-04-07-02-explain') {
    return 'Nit means narrow entry and respect for their heavy action. '
        'Tap Nit, then Narrow, then Respect.';
  }
  if (activity.id == 'act-04-07-03-explain') {
    return 'Steal more from nits. Respect it when they explode. '
        'Tap Steal, then Credit, then Explode.';
  }
  if (activity.id == 'act-04-08-01-explain') {
    return 'Some seats raise and barrel seemingly forever. Count it calmly. '
        'Tap Raise, then Barrel, then Count.';
  }
  if (activity.id == 'act-04-08-02-explain') {
    return 'Maniac means extreme entry and aggression — a model, not an insult. '
        'Tap Maniac, then Entry, then Aggro.';
  }
  if (activity.id == 'act-04-08-03-explain') {
    return 'Versus maniacs: call wider for value, let them hang themselves, no ego. '
        'Tap Wider, then Hang, then Ego.';
  }
  if (activity.id == 'act-04-09-01-explain') {
    return 'Observation is not certainty. Confidence grows with samples and showdowns. '
        'Tap Observe, then Samples, then Showdowns.';
  }
  if (activity.id == 'act-04-10-01-explain') {
    return 'Same cards. Different seats. Exploits change only with evidence. '
        'Tap Cards, then Seats, then Evidence.';
  }
  if (activity.id == 'act-05-01-01-explain') {
    return 'Multiway: nutted hands up, air down. Domination hurts more. '
        'Tap Nutted, then Air, then Domination.';
  }
  if (activity.id == 'act-05-02-01-explain') {
    return 'Deep: more room to realize. Also more room to lose a stack. '
        'Tap Deep, then Realize, then Stack.';
  }
  if (activity.id == 'act-05-03-01-explain') {
    return 'Implied odds: future money. Reverse implied: future losses when second-best. '
        'Tap Implied, then Reverse, then Second.';
  }
  if (activity.id == 'act-05-04-01-explain') {
    return 'Thin value needs calls. Bluff-catches need wide barrels. '
        'Tap Thin, then Catch, then Barrels.';
  }
  if (activity.id == 'act-05-05-01-explain') {
    return 'Lines mean ranges. Check-raise, probe, delay, and donk each update the story. '
        'Tap X/R, then Probe, then Delay, then Donk.';
  }
  if (activity.id == 'act-05-06-01-explain') {
    return 'Each action rewrites the range. Keep updating. '
        'Tap Action, then Rewrite, then Update.';
  }
  if (activity.id == 'act-05-07-01-explain') {
    return 'Timing and sizing are clues, not mind-reading. Small updates only. '
        'Tap Timing, then Sizing, then Clues.';
  }
  if (activity.id == 'act-05-08-01-explain') {
    return 'Tables change. Stuck, tilted, or shifting gears — update. '
        'Tap Stuck, then Tilted, then Gears.';
  }
  if (activity.id == 'act-05-09-01-explain') {
    return 'Winning 1/2 includes knowing when to quit. Guardrails first. '
        'Tap Quit, then Guard, then First.';
  }
  if (activity.id == 'act-06-01-01-explain') {
    return 'Range advantage: more strong hands overall. Nut advantage: more of the nuts. '
        'Tap Range, then Nut, then Advantage.';
  }
  if (activity.id == 'act-06-02-01-explain') {
    return 'Equity on a chart is not cash. Position decides realization. '
        'Tap Equity, then Cash, then Pos.';
  }
  if (activity.id == 'act-06-03-01-explain') {
    return 'Capped means the nuts are unlikely. Uncapped means the nuts are still live. '
        'Tap Capped, then Uncapped, then Nuts.';
  }
  if (activity.id == 'act-06-04-01-explain') {
    return 'Polar: nuts or air. Merged: many medium-strong hands. Size accordingly. '
        'Tap Polar, then Merged, then Size.';
  }
  if (activity.id == 'act-06-05-01-explain') {
    return 'Overbets need a polar story. Geometry links flop, turn, and river sizes. '
        'Tap Overbet, then Polar, then Geo.';
  }
  if (activity.id == 'act-06-06-01-explain') {
    return 'Blockers remove hands. Use them; do not invent EV decimals. '
        'Tap Block, then Use, then No EV.';
  }
  if (activity.id == 'act-06-07-01-explain') {
    return 'Defend enough that over-bluffing fails. No fake percentages. '
        'Tap Defend, then Bluff, then Enough.';
  }
  if (activity.id == 'act-06-08-01-explain') {
    return 'Mixing is frequency with a purpose, not coin-flip theater. '
        'Tap Mix, then Purpose, then Strong.';
  }
  if (activity.id == 'act-06-09-01-explain') {
    return '3-bet and 4-bet pots shrink ranges and SPR. Depth decides commitment. '
        'Tap 3-Bet, then 4-Bet, then Depth.';
  }
  if (activity.id == 'act-06-10-01-explain') {
    return 'Hard folds save buy-ins. Coolers happen; ego call-downs are mistakes. '
        'Tap Hard, then Cooler, then Ego.';
  }
  if (activity.id == 'act-06-11-01-explain') {
    return 'Before labels: who enters tight, then barrels with a plan? Count samples. '
        'Tap Tight, then Barrel, then Sample.';
  }
  if (activity.id == 'act-06-11-02-explain') {
    return 'TAG: tight in, aggressive after — a working model. '
        'Tap Tight, then Aggro, then Model.';
  }
  if (activity.id == 'act-06-11-03-explain') {
    return 'Versus TAG: respect raises; do not invent light bluff-raises. '
        'Tap Credit, then Tighter, then No light.';
  }
  if (activity.id == 'act-06-12-01-explain') {
    return 'Before labels: wide entry plus pressure that still has a plan. Count samples. '
        'Tap Wide, then Pressure, then Sample.';
  }
  if (activity.id == 'act-06-12-02-explain') {
    return 'LAG: wide in, pressure on — still a working model. '
        'Tap Wide, then Pressure, then Model.';
  }
  if (activity.id == 'act-06-12-03-explain') {
    return 'Versus LAG: trap more, call wider, fancy less. '
        'Tap Call, then Trap, then Fancy less.';
  }
  if (activity.id == 'act-06-13-01-explain') {
    return 'Five models. Same cards. Change only with evidence. '
        'Tap Cards, then Seats, then Evidence.';
  }
  if (activity.id == 'act-07-01-01-explain') {
    return 'Enter with a reason. Flop confirms or cancels. '
        'Tap Reason, then Confirm, then Cancel.';
  }
  if (activity.id == 'act-07-02-01-explain') {
    return 'Flop bet needs a turn map. Continue or kill. '
        'Tap Barrel, then Give-up, then Map.';
  }
  if (activity.id == 'act-07-03-01-explain') {
    return 'River: value if they call worse; bluff if they fold better. '
        'Tap Value, then Bluff, then Hold.';
  }
  if (activity.id == 'act-07-04-01-explain') {
    return 'Pot type sets ranges and SPR. Plan accordingly. '
        'Tap Limped, then SRP, then 3-4bet.';
  }
  if (activity.id == 'act-07-05-01-explain') {
    return 'More players: fewer bluffs, thicker value. '
        'Tap Fewer, then Thicker, then Widen.';
  }
  if ((activity.id.startsWith('act-01-06-01-') ||
          activity.id == 'act-01-06-02-jump-hand' ||
          activity.id == 'act-04-03-01-guided') &&
      activity.handSteps.isNotEmpty) {
    final last = activity.handSteps.length - 1;
    final index = handStepIndex < 0
        ? 0
        : (handStepIndex > last ? last : handStepIndex);
    return activity.handSteps[index].prompt;
  }
  final resolved = resolveLessonCoachPrompt(
    activity: activity,
    fallback: activity.accessibilityText,
  );
  return resolved.coach;
}

/// Hint copy when the catalog step has no hint media.
String? lessonFrameHintFallback(CourseActivity activity) {
  if (activity.id == 'act-01-01-01-explain-hole-cards') {
    return 'Your two cards are at your seat, along the bottom of the table.';
  }
  return null;
}

/// Face the placeholder shows. Real Rex art replaces this widget later.
enum LessonMascotExpression {
  /// Prompt, before an answer.
  thinking,

  /// Accepted answer.
  happy,

  /// Miss.
  wrong,
}

/// Oscar-sized stand-in. 104 by 118 matches the coach-band area on a phone.
class LessonMascotPlaceholder extends StatelessWidget {
  /// Creates the placeholder for [expression].
  const LessonMascotPlaceholder({super.key, required this.expression});

  /// Width of the bust, in logical pixels.
  static const double width = 104;

  /// Height of the bust, in logical pixels.
  static const double height = 118;

  /// Which face to draw.
  final LessonMascotExpression expression;

  String get _label {
    return switch (expression) {
      LessonMascotExpression.thinking => 'Coach, thinking',
      LessonMascotExpression.happy => 'Coach, happy',
      LessonMascotExpression.wrong => 'Coach, wrong',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: _label,
      child: CustomPaint(
        size: const Size(width, height),
        painter: _MascotPlaceholderPainter(expression),
      ),
    );
  }
}

class _MascotPlaceholderPainter extends CustomPainter {
  _MascotPlaceholderPainter(this.expression);

  final LessonMascotExpression expression;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFF3D4A63);
    final skin = Paint()..color = const Color(0xFFC4A484);
    final ink =
        Paint()
          ..color = const Color(0xFF1A120C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
    final shirt = Paint()..color = const Color(0xFFE7A3B8);

    final shoulder = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, size.height * 0.62, size.width - 16, size.height * 0.4),
      const Radius.circular(18),
    );
    canvas.drawRRect(shoulder, shirt);

    final head = Offset(size.width / 2, size.height * 0.36);
    canvas.drawCircle(head, 28, skin);
    canvas.drawCircle(head, 28, ink..strokeWidth = 1.4);

    final hair =
        Path()
          ..moveTo(head.dx - 26, head.dy - 4)
          ..quadraticBezierTo(head.dx, head.dy - 40, head.dx + 26, head.dy - 2)
          ..quadraticBezierTo(head.dx + 18, head.dy - 18, head.dx, head.dy - 16)
          ..quadraticBezierTo(
            head.dx - 16,
            head.dy - 18,
            head.dx - 26,
            head.dy - 4,
          );
    canvas.drawPath(hair, body);

    final eyeY = head.dy - 2;
    if (expression == LessonMascotExpression.wrong) {
      canvas.drawLine(
        Offset(head.dx - 14, eyeY),
        Offset(head.dx - 4, eyeY + 3),
        ink,
      );
      canvas.drawCircle(
        Offset(head.dx + 10, eyeY),
        2.4,
        Paint()..color = ink.color,
      );
    } else {
      canvas.drawCircle(
        Offset(head.dx - 9, eyeY),
        2.4,
        Paint()..color = ink.color,
      );
      canvas.drawCircle(
        Offset(head.dx + 9, eyeY),
        2.4,
        Paint()..color = ink.color,
      );
    }

    final mouth = Path();
    if (expression == LessonMascotExpression.happy) {
      mouth
        ..moveTo(head.dx - 8, head.dy + 10)
        ..quadraticBezierTo(head.dx, head.dy + 18, head.dx + 8, head.dy + 10);
    } else if (expression == LessonMascotExpression.wrong) {
      mouth
        ..moveTo(head.dx - 7, head.dy + 16)
        ..quadraticBezierTo(head.dx, head.dy + 9, head.dx + 7, head.dy + 16);
    } else {
      mouth
        ..moveTo(head.dx - 6, head.dy + 12)
        ..lineTo(head.dx + 6, head.dy + 12);
      final hand =
          Path()
            ..moveTo(head.dx + 4, head.dy + 20)
            ..quadraticBezierTo(
              head.dx + 16,
              head.dy + 22,
              head.dx + 10,
              head.dy + 8,
            );
      canvas.drawPath(hand, ink);
    }
    canvas.drawPath(mouth, ink);
  }

  @override
  bool shouldRepaint(covariant _MascotPlaceholderPainter oldDelegate) {
    return oldDelegate.expression != expression;
  }
}

/// Mascot plus the only instruction for this step.
class LessonCoachBand extends StatelessWidget {
  /// Creates the coach row.
  const LessonCoachBand({
    super.key,
    required this.speech,
    required this.expression,
  });

  /// Bubble copy. Empty hides the words and keeps the mascot box.
  final String speech;

  /// Face for this beat.
  final LessonMascotExpression expression;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonMascotPlaceholder(expression: expression),
          const SizedBox(width: 2),
          Expanded(child: _SpeechBubble(text: speech)),
        ],
      ),
    );
  }
}

/// Rounded bubble with a tail aimed at the coach's mouth.
///
/// The top edge and the tail stay fixed against the mascot. A longer line
/// grows the bubble downward. A shorter line does not lift the tail or the
/// first line of text.
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  /// How far the tail tip sits from the top, lined up with the placeholder mouth.
  static const double tailCenterY = 52;

  static const double tailWidth = 12;
  static const double tailHeight = 16;
  static const double radius = 18;

  /// Tall enough that the tail at [tailCenterY] never has to move.
  static const double minHeight = tailCenterY + tailHeight / 2 + radius + 16;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const ValueKey<String>('lesson-speech-bubble'),
      painter: const _SpeechBubblePainter(
        fill: AppColors.bgElevated,
        border: AppColors.slateDark,
        tailCenterY: tailCenterY,
        tailWidth: tailWidth,
        tailHeight: tailHeight,
        radius: radius,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(tailWidth + 14, 14, 14, 14),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter({
    required this.fill,
    required this.border,
    required this.tailCenterY,
    required this.tailWidth,
    required this.tailHeight,
    required this.radius,
  });

  final Color fill;
  final Color border;
  final double tailCenterY;
  final double tailWidth;
  final double tailHeight;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _path(Size size) {
    final left = tailWidth;
    final right = size.width;
    final bottom = size.height;
    final half = tailHeight / 2;
    // Fixed against the coach. The bubble's min height keeps this inside
    // the corner radii, so a short or long line cannot slide the tail.
    final tipY = tailCenterY;
    final tailTop = tipY - half;
    final tailBot = tipY + half;
    final r = Radius.circular(radius);

    return Path()
      ..moveTo(left + radius, 0)
      ..lineTo(right - radius, 0)
      ..arcToPoint(Offset(right, radius), radius: r)
      ..lineTo(right, bottom - radius)
      ..arcToPoint(Offset(right - radius, bottom), radius: r)
      ..lineTo(left + radius, bottom)
      ..arcToPoint(Offset(left, bottom - radius), radius: r)
      ..lineTo(left, tailBot)
      ..lineTo(0, tipY)
      ..lineTo(left, tailTop)
      ..lineTo(left, radius)
      ..arcToPoint(Offset(left + radius, 0), radius: r)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) => false;
}

/// Close, lesson progress, and one heart per life.
class LessonChromeBar extends StatelessWidget {
  /// Creates the chrome row.
  const LessonChromeBar({
    super.key,
    required this.progress,
    required this.livesRemaining,
    required this.livesMax,
    required this.onClose,
  });

  /// 0 to 1 across the lesson.
  final double progress;

  /// Hearts still filled.
  final int livesRemaining;

  /// Heart icons in the row.
  final int livesMax;

  /// Leaves the lesson.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hearts = livesMax <= 0 ? 3 : livesMax;
    return SizedBox(
      height: 36,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.slate),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: AppColors.slateDark,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              label: '$livesRemaining of $hearts lives',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < hearts; i++)
                    Icon(
                      Icons.favorite,
                      key: ValueKey<String>('lesson-heart-$i'),
                      size: 22,
                      color:
                          i < livesRemaining
                              ? AppColors.danger
                              : AppColors.slateDark,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Undo, redo, and hint. Visible only while the step is unanswered.
class LessonToolRow extends StatelessWidget {
  /// Creates the tool row.
  const LessonToolRow({
    super.key,
    required this.onUndo,
    required this.onRedo,
    required this.onHint,
    required this.canUndo,
    required this.canRedo,
    required this.canHint,
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onHint;
  final bool canUndo;
  final bool canRedo;
  final bool canHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          _ToolButton(
            tooltip: 'Undo',
            icon: Icons.undo,
            onPressed: canUndo ? onUndo : null,
          ),
          const SizedBox(width: 10),
          _ToolButton(
            tooltip: 'Redo',
            icon: Icons.redo,
            onPressed: canRedo ? onRedo : null,
          ),
          const Spacer(),
          _ToolButton(
            tooltip: 'Hint',
            icon: Icons.lightbulb_outline,
            label: 'HINT',
            onPressed: canHint ? onHint : null,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? AppColors.slate : AppColors.slateDark;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slateDark),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 22),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      label!,
                      style: GoogleFonts.manrope(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom beat that replaces the tool row after a grade.
class LessonAnswerDock extends StatelessWidget {
  /// Creates the dock for [result].
  const LessonAnswerDock({
    super.key,
    required this.result,
    required this.onContinue,
    this.busy = false,
    this.recovery,
  });

  final SubmitCourseStepResult result;
  final VoidCallback onContinue;
  final bool busy;
  final String? recovery;

  @override
  Widget build(BuildContext context) {
    final accepted = result.accepted;
    final accent = accepted ? AppColors.success : AppColors.danger;
    final title = accepted ? 'Nice!' : "Oops, that's not correct";
    return Material(
      color: AppColors.bgElevated,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                color: accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (recovery != null && recovery!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Try: $recovery',
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (result.feedback.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                result.feedback,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            FilledButton(
              onPressed: busy ? null : onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.bgDark,
                disabledBackgroundColor: accent.withValues(alpha: 0.72),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.8,
                ),
              ),
              child:
                  busy
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.bgDark,
                        ),
                      )
                      : Text(
                        'Continue',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.4,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The lesson frame. [stage] is the only region that changes per step.
///
/// Every lesson uses this widget. A hand step passes `LessonTableStage`.
/// A step with no hand passes its own teaching widget. See
/// `.cursor/skills/lesson-screen-layout/SKILL.md`.
class LessonScreenLayout extends StatelessWidget {
  /// Creates the frame.
  const LessonScreenLayout({
    super.key,
    required this.progress,
    required this.livesRemaining,
    required this.livesMax,
    required this.onClose,
    required this.speech,
    required this.expression,
    required this.stage,
    required this.onUndo,
    required this.onRedo,
    required this.onHint,
    required this.canUndo,
    required this.canRedo,
    required this.canHint,
    this.result,
    this.onContinue,
    this.answerBusy = false,
    this.recovery,
    this.notice,
  });

  final double progress;
  final int livesRemaining;
  final int livesMax;
  final VoidCallback onClose;
  final String speech;
  final LessonMascotExpression expression;
  final Widget stage;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onHint;
  final bool canUndo;
  final bool canRedo;
  final bool canHint;
  final SubmitCourseStepResult? result;
  final VoidCallback? onContinue;
  final bool answerBusy;

  /// Short name of the better tap, shown under a miss.
  final String? recovery;

  /// One-line catch-up under the chrome, such as a resumed lesson.
  final String? notice;

  @override
  Widget build(BuildContext context) {
    final graded = result != null && onContinue != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonChromeBar(
          progress: progress,
          livesRemaining: livesRemaining,
          livesMax: livesMax,
          onClose: onClose,
        ),
        if (notice != null && notice!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              notice!,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        LessonCoachBand(speech: speech, expression: expression),
        Expanded(child: stage),
        if (graded)
          LessonAnswerDock(
            result: result!,
            onContinue: onContinue!,
            busy: answerBusy,
            recovery: recovery,
          )
        else
          LessonToolRow(
            onUndo: onUndo,
            onRedo: onRedo,
            onHint: onHint,
            canUndo: canUndo,
            canRedo: canRedo,
            canHint: canHint,
          ),
      ],
    );
  }
}
