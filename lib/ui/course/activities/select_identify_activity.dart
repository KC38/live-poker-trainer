/// Select / identify activity (positions, cards, classifications).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Multiple-choice identify activity with optional guided highlight.
class SelectIdentifyActivity extends StatelessWidget {
  /// Creates the activity.
  const SelectIdentifyActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    final presentation = resolveSelectIdentifyPresentation(activity);
    if (presentation == SelectIdentifyPresentation.tableRegionTap) {
      return _TableRegionTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    if (presentation == SelectIdentifyPresentation.handCategoryTap) {
      return _HandCategoryTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    if (presentation == SelectIdentifyPresentation.showdownTap) {
      return _ShowdownTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    if (presentation == SelectIdentifyPresentation.bestFiveCardTap) {
      return _BestFiveCardTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }

    final scene = resolveLessonTableScene(activity);
    final resolved = resolveLessonCoachPrompt(
      activity: activity,
      fallback: _coachFallback(presentation, scene != null),
    );
    final coachText = resolved.coach;
    final showPrompt = resolved.showPrompt;
    final showCoach = shouldShowLessonCoach(
      activity: activity,
      showGuidance: showGuidance,
      coach: coachText,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.draft.choiceId;
        final locked = controller.submitting || controller.lastResult != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoach) RexCoachLine(text: coachText),
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(scene: scene),
            ],
            if (showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (presentation == SelectIdentifyPresentation.suitTapPicker)
              SuitTapPicker(
                key: ValueKey<String>(
                  '${activity.id}-${controller.bindGeneration}',
                ),
                activity: activity,
                controller: controller,
                locked: locked,
              )
            else if (presentation == SelectIdentifyPresentation.holeCards)
              _HoleCardFeltTray(
                activity: activity,
                selectedId: selected,
                locked: locked,
                showGuidance: showGuidance,
                onSelect: (id) => controller.selectChoice(id, autoSubmit: true),
              )
            else
              for (var i = 0; i < activity.choices.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildChoice(
                  presentation: presentation,
                  choice: activity.choices[i],
                  index: i,
                  selected: selected == activity.choices[i].id,
                  locked: locked,
                ),
              ],
          ],
        );
      },
    );
  }

  String _coachFallback(SelectIdentifyPresentation presentation, bool hasScene) {
    return switch (presentation) {
      SelectIdentifyPresentation.suitTapPicker =>
        'Tap every suit that belongs in a standard deck.',
      SelectIdentifyPresentation.holeCards =>
        'Look at the cards — pick the matching pair.',
      SelectIdentifyPresentation.suitSets =>
        'Read the suits, then pick the complete set.',
      SelectIdentifyPresentation.tableRegionTap =>
        'Tap the answer on the table.',
      SelectIdentifyPresentation.handCategoryTap =>
        'Read the board and your holes — tap the category you made.',
      SelectIdentifyPresentation.showdownTap =>
        'Look at both hands — tap who wins.',
      SelectIdentifyPresentation.bestFiveCardTap =>
        'Tap the five cards that play in your best hand.',
      SelectIdentifyPresentation.text =>
        hasScene
            ? 'Look at the table, then pick the answer that matches.'
            : 'Pick the best answer.',
    };
  }

  Widget _buildChoice({
    required SelectIdentifyPresentation presentation,
    required CourseChoice choice,
    required int index,
    required bool selected,
    required bool locked,
  }) {
    final highlight =
        showGuidance &&
        activity.stage == ActivityStage.guided &&
        index == 0 &&
        controller.draft.choiceId == null;
    final onPressed = locked
        ? null
        : () => controller.selectChoice(choice.id, autoSubmit: true);

    switch (presentation) {
      case SelectIdentifyPresentation.holeCards:
        return HoleCardChoiceButton(
          codes: parseCardCodes(choice.label),
          accessibilityText: choice.accessibilityText,
          selected: selected,
          highlighted: highlight,
          enabled: !locked,
          onPressed: onPressed,
        );
      case SelectIdentifyPresentation.suitSets:
        return SuitSetChoiceButton(
          tokens: parseSuitTokens(choice.label),
          label: choice.label,
          accessibilityText: choice.accessibilityText,
          selected: selected,
          highlighted: highlight,
          enabled: !locked,
          onPressed: onPressed,
        );
      case SelectIdentifyPresentation.suitTapPicker:
      case SelectIdentifyPresentation.tableRegionTap:
      case SelectIdentifyPresentation.handCategoryTap:
      case SelectIdentifyPresentation.showdownTap:
      case SelectIdentifyPresentation.bestFiveCardTap:
      case SelectIdentifyPresentation.text:
        return LessonChoiceButton(
          label: choice.label,
          accessibilityText: choice.accessibilityText,
          selected: selected,
          highlighted: highlight,
          enabled: !locked,
          onPressed: onPressed,
        );
    }
  }
}

class _TableRegionTapActivity extends StatefulWidget {
  const _TableRegionTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  State<_TableRegionTapActivity> createState() =>
      _TableRegionTapActivityState();
}

class _TableRegionTapActivityState extends State<_TableRegionTapActivity> {
  LessonTableRegion? _selectedRegion;
  int? _selectedSeatIndex;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void didUpdateWidget(covariant _TableRegionTapActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
      _selectedRegion = null;
      _selectedSeatIndex = null;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (widget.controller.draft.choiceId == null &&
        (_selectedRegion != null || _selectedSeatIndex != null)) {
      setState(() {
        _selectedRegion = null;
        _selectedSeatIndex = null;
      });
    }
  }

  String get _coachText {
    final authored = widget.activity.primaryCoachLine?.text;
    if (authored != null) return authored;
    return switch (widget.activity.id) {
      'act-01-01-01-guided-find-holes' =>
        'Your private cards are on the felt. Find them.',
      'act-01-01-01-scaffolded-private' =>
        'Nobody else can peek at your holes.',
      'act-01-01-01-unguided-mix' =>
        'Everyone shares the cards in the middle.',
      'act-01-01-01-checkpoint-table' =>
        'Ownership stays split — board is shared.',
      'act-01-01-03-guided-button' =>
        'Find the dealer button on the felt.',
      'act-01-01-03-scaffolded-blinds' =>
        'Blinds sit left of the button. Tap the big blind.',
      'act-01-01-03-unguided-when' =>
        'When do those forced bets go in?',
      'act-01-01-03-checkpoint-layout' =>
        'Button is marked. Tap the small blind seat.',
      'act-02-01-01-guided-btn' =>
        'Tap who acts last postflop.',
      'act-02-01-01-scaffolded-blinds' =>
        'Tap a seat that posts a forced bet every hand.',
      'act-02-01-01-unguided-co' =>
        'Tap the seat right before the button.',
      'act-02-01-01-checkpoint-edge' =>
        'Same cards — later seats play stronger.',
      'act-02-01-02-unguided-wait' =>
          'Action is on UTG — you are on the button. Tap what you do.',
      'act-02-01-02-checkpoint-full' =>
          'Six-max flop, everyone in — tap who acts last.',
      'act-01-04-01-unguided-end' =>
        'Betting is live. Tap when this street is done.',
      'act-01-04-01-checkpoint-postflop' =>
        'Postflop — tap who acts first.',
      'act-01-05-01-guided-fold-win' =>
          'Everyone folded. Tap how you take the pot.',
      'act-01-05-01-scaffolded-showdown' =>
          'River is called. Tap what happens next.',
      'act-01-05-01-unguided-pot' =>
          'Blinds plus the open — tap the chip total.',
      'act-01-05-01-checkpoint-side' =>
          'You are short all-in. Tap what is true.',
      'act-01-02-02-unguided-board' =>
          'Both checked down — tap who takes the pot.',
      'act-02-07-01-checkpoint-habit' =>
          'Cards uncovered and action left — tap the safe habit.',
      'act-02-06-01-guided-follow' =>
          'Two seats act before you — tap what you do first.',
      'act-02-06-01-scaffolded-verbal' =>
          'You want to raise — tap the clearest live announce.',
      'act-02-06-01-unguided-protect' =>
          'Cards near the muck — tap how you protect them.',
      'act-02-06-01-checkpoint-oot' =>
          'You raised early — tap what went wrong.',
      'act-02-07-02-jump-pos' =>
          'Tap the seat right before the button.',
      'act-02-07-02-jump-family' =>
          'Look at your holes — tap the family they belong to.',
      'act-01-02-01-scaffolded-spot' =>
          'Board and holes show five clubs — tap what you made.',
      'act-02-07-02-jump-stack' =>
          'Effective stack is the shorter one — tap it.',
      'act-02-02-01-guided-pair' =>
          'Matching ranks in the hole — tap the family.',
      'act-02-02-01-scaffolded-broadway' =>
          'Both cards ten-or-better — tap the family.',
      'act-02-02-01-unguided-sc' =>
          'Look at your holes — tap the family.',
      'act-02-02-01-checkpoint-trash' =>
          'Early seat with junk — tap the family.',
      'act-02-05-01-scaffolded-eff' =>
          'You 150bb, villain 60bb — tap the effective stack.',
      'act-02-05-01-unguided-depth' =>
          'Tap the depth that plays closest to a shove game.',
      'act-03-01-01-guided' =>
          'Blinds plus three 6s — tap the pot total.',
      'act-03-01-01-scaffolded' =>
          'Preflop — tap who acts first (left of the BB).',
      'act-03-01-01-unguided' =>
          'You said raise. Tap what counts at a live table.',
      'act-03-01-01-checkpoint' =>
          'Shorter stack caps the matchup — tap what matters with the pot.',
      'act-03-02-01-guided' =>
          'Board pairs your king — tap the flop class.',
      'act-03-02-01-scaffolded' =>
          'Two hearts on board with the nut heart — tap the class.',
      'act-03-02-01-unguided' =>
          'No pair, almost no draw multiway — tap the class.',
      'act-03-02-01-checkpoint' =>
          'Eight or queen completes — tap the class.',
      'act-03-03-01-guided' =>
          'King-high board. Tap the remaining aces — your clean outs.',
      'act-03-03-01-scaffolded' =>
          'Pot 20, bet 10 — tap how many chips to call.',
      'act-03-03-01-unguided' =>
          'Getting 3:1 with real outs — tap what you do.',
      'act-03-03-01-checkpoint' =>
          'Nut flush draw, deep and sticky — tap Implied.',
      'act-03-05-01-guided' =>
          'Dry ace flop, blank three — tap Brick.',
      'act-03-05-01-checkpoint' =>
          'Air bluff meets a draw-completing queen — tap the plan.',
      'act-03-06-01-checkpoint' =>
          'Medium one pair faces a big bet — tap the river job.',
      'act-03-07-01-unguided' =>
          'Deep multiway — tap the better speculative hand.',
      'act-03-07-01-checkpoint' =>
          'Seat enters most pots — tap what you note.',
      'act-03-08-01-checkpoint' =>
          'Two seats, different frequencies — tap the note.',
      'act-03-08-02-jump-table' =>
          'Pot 16, shorter 40bb — tap what you track first.',
      'act-03-08-02-jump-class' =>
          'Qd9d3c with JdTd — tap the flop class.',
      'act-03-08-02-jump-leak' =>
          'Gutshot vs a 2x pot bet — tap the fix.',
      'act-04-01-01-guided' =>
          'UTG opens at 1/2 — tap the range shape.',
      'act-04-01-01-scaffolded' =>
          'BTN open, BB 3-bet, BTN calls — tap who is stronger.',
      'act-04-01-01-unguided' =>
          'They bet twice — you pinned Exactly AK. Tap the problem.',
      'act-04-01-01-checkpoint' =>
          'Same board, different villain lines — tap what changes.',
      'act-04-03-01-checkpoint' =>
          'You have a flop plan — tap the turn branches.',
      'act-04-04-01-unguided' =>
          'Two value sizes both get calls — tap the grading idea.',
      'act-04-06-01-guided' =>
          'Seat calls 7 of 9 preflops — tap the observation.',
      'act-04-06-01-scaffolded' =>
          'Second pair called three streets twice — tap the note.',
      'act-04-06-01-unguided' =>
          'One dramatic call — tap how confident the label is.',
      'act-04-06-01-checkpoint' =>
          'Before you label — tap the evidence bundle.',
      'act-04-06-02-guided' =>
          'Sticky second pair calls — tap the working label.',
      'act-04-06-02-scaffolded' =>
          'A player-type label is a working model — tap it.',
      'act-04-06-02-unguided' =>
          'Limps, calls, never folds turns — tap the label.',
      'act-04-06-02-checkpoint' =>
          'Only two hands so far — tap your confidence.',
      'act-04-06-03-checkpoint' =>
          'Why cut bluffs vs a station — tap the cite.',
      'act-04-07-01-guided' =>
          'Folded 20 of 22 — tap the observation.',
      'act-04-07-01-scaffolded' =>
          'Raises then barrels — tap the observation.',
      'act-04-07-01-unguided' =>
          'Only two folds — tap whether to label.',
      'act-04-07-01-checkpoint' =>
          'Before you label — tap the evidence bundle.',
      'act-04-07-02-guided' =>
          'Rare entry, large 3-bets — tap the working label.',
      'act-04-07-02-unguided' =>
          'Folds forever, then explodes — tap the label.',
      'act-04-07-02-checkpoint' =>
          'Treat Nit as a working model — tap it.',
      'act-04-07-03-checkpoint' =>
          'Nit check-raises — tap why you respect it.',
      'act-04-08-01-guided' =>
          'Raises 12 of 15 — tap the observation.',
      'act-04-08-01-scaffolded' =>
          'Barrels three streets light — tap the note.',
      'act-04-08-01-unguided' =>
          'Wild aggression — tap the note style.',
      'act-04-08-01-checkpoint' =>
          'Before you label — tap the evidence bundle.',
      'act-04-08-02-guided' =>
          'Opens 60%, barrels light — tap the working label.',
      'act-04-08-02-unguided' =>
          'Light 3-bets, never gives up — tap the label.',
      'act-04-08-02-checkpoint' =>
          'Legal mix now — tap the introduced types.',
      'act-04-08-03-checkpoint' =>
          'Maniac barrels — tap why you call wider.',
      'act-04-09-01-guided' =>
          'One huge bluff — tap what you know.',
      'act-04-09-01-scaffolded' =>
          '30 sticky hands — tap how confidence moves.',
      'act-04-09-01-unguided' =>
          'Station starts folding — tap the next step.',
      'act-04-09-01-checkpoint' =>
          'Beside a type label — tap what belongs.',
      'act-04-10-02-jump-range' =>
          'UTG open — tap how wide the range is.',
      'act-04-10-02-jump-station' =>
          'Sticky three streets — tap the exploit.',
      'act-04-10-02-jump-nit' =>
          'Tiny range, huge raise — tap the line.',
      'act-04-10-02-jump-maniac' =>
          'Barrels forever, top pair — tap the line.',
      'act-05-01-01-guided' =>
          'Four-way flop — tap the best continue.',
      'act-05-01-01-checkpoint' =>
          'Multiway priority — tap the construction rule.',
      'act-05-02-01-guided' =>
          '200bb with 55 — tap why you call.',
      'act-05-02-01-unguided' =>
          'SPR ~12 — tap your first job.',
      'act-05-02-01-checkpoint' =>
          'Deep cash play — tap what it rewards.',
      'act-05-03-01-checkpoint' =>
          'Implied odds — tap when they rise most.',
      'act-05-04-01-checkpoint' =>
          'Same hand, new type — tap what must change.',
      'act-05-05-01-guided' =>
          'Nit check-raises — tap the default read.',
      'act-05-05-01-unguided' =>
          'Large BB donk on dry ace — tap the meaning.',
      'act-05-05-01-checkpoint' =>
          'Delayed c-bet — tap when it is best.',
      'act-05-06-01-guided' =>
          'Bet flop, check turn — tap Capped.',
      'act-05-06-01-unguided' =>
          'Best habit — tap Rebuild.',
      'act-05-06-01-checkpoint' =>
          'XR / bet / shove — tap Uncapped.',
      'act-05-07-01-guided' =>
          'Instant shove — tap Soft evidence.',
      'act-05-07-01-scaffolded' =>
          'Tiny flop bet — tap Weaker / blocking.',
      'act-05-07-01-unguided' =>
          'Look-left tell — tap Reject.',
      'act-05-07-01-checkpoint' =>
          'Best use of timing — tap Tiny update.',
      'act-05-08-01-guided' =>
          'Lost two buy-ins — tap Stuck / tilted.',
      'act-05-08-01-scaffolded' =>
          'Flats junk / donks — tap Gear change.',
      'act-05-08-01-checkpoint' =>
          'Dynamic reads — tap Fresh samples.',
      'act-05-09-01-guided' =>
          'Hit stop-loss — tap Stop / move down.',
      'act-05-09-01-scaffolded' =>
          '2/5 opens — tap Decline.',
      'act-05-09-01-unguided' =>
          'Tired and up small — tap Cash out.',
      'act-05-09-01-checkpoint' =>
          'Session discipline — tap Your edge.',
      'act-05-09-02-cp-multi' =>
          'Four-way pot — tap Nut potential.',
      'act-05-09-02-cp-tell' =>
          'Instant shove — tap Soft evidence.',
      'act-05-09-02-cp-stop' =>
          'Hit stop-loss — tap Honor stop.',
      'act-06-01-01-guided' =>
          'A-high dry flop — tap Preflop raiser.',
      'act-06-01-01-scaffolded' =>
          'Paired board — tap Wide caller.',
      'act-06-01-01-checkpoint' =>
          'Advantage — tap Apply pressure.',
      'act-06-02-01-guided' =>
          'Same draw — tap In position.',
      'act-06-02-01-scaffolded' =>
          'Weak SDV OOP — tap Discount / fold.',
      'act-06-02-01-unguided' =>
          'Nut draw XR — tap Fold equity.',
      'act-06-02-01-checkpoint' =>
          'Realization rises with — tap Position + initiative.',
      'act-06-03-01-guided' =>
          'Checks turn after flop bet — tap Capped.',
      'act-06-03-01-unguided' =>
          'XR flop / bet turn / bomb — tap Uncapped.',
      'act-06-03-01-checkpoint' =>
          'Caps are for — tap Attack caps.',
      'act-06-04-01-guided' =>
          'River overbet — tap Polarized.',
      'act-06-04-01-unguided' =>
          'Mismatch to avoid — tap Tiny bluffs.',
      'act-06-04-01-checkpoint' =>
          'Merged betting aims to — tap Thin value.',
      'act-06-05-01-guided' =>
          'Best overbet river — tap Nuts / bluffs.',
      'act-06-05-01-unguided' =>
          'Random 3x pot medium — tap Avoid.',
      'act-06-05-01-checkpoint' =>
          'Geometric sizing helps — tap Multi-street plan.',
      'act-06-06-01-guided' =>
          'Flush-board river bluff — tap Ace blocker.',
      'act-06-06-01-scaffolded' =>
          'Bluff-catch flush bomb — tap Unblock bluffs.',
      'act-06-06-01-unguided' =>
          'Blockers replace — tap Tweak evidence.',
      'act-06-06-01-checkpoint' =>
          'Solver EV quotes — tap No fake EV.',
      'act-06-07-01-guided' =>
          'Facing a river bet — tap Strong catchers.',
      'act-06-07-01-unguided' =>
          'MDF numbers — tap Intuition.',
      'act-06-07-01-checkpoint' =>
          'Minimum defense goal — tap Punish over-bluffs.',
      'act-06-08-01-scaffolded' =>
          'Vs Calling Station — tap Less bluff.',
      'act-06-08-01-unguided' =>
          'Randomness for its own sake — tap Need a reason.',
      'act-06-08-01-checkpoint' =>
          'Best mix description — tap Purpose freq.',
      'act-06-09-01-guided' =>
          '100bb 4-bet pot · top pair — tap High commit.',
      'act-06-09-01-unguided' =>
          'Light 4-bet for ego — tap Avoid ego.',
      'act-06-09-01-checkpoint' =>
          'Depth change in 3-bet pots — tap SPR / commit.',
      'act-06-10-01-scaffolded' =>
          'KK loses to AA all-in — tap Cooler.',
      'act-06-10-01-unguided' =>
          'Calling because you are "due" — tap Ego call.',
      'act-06-10-01-checkpoint' =>
          'Review after a big loss — tap Cooler / mistake?.',
      'act-06-11-01-guided' =>
          'Folds most, then 3-bets / c-bets — tap Selective + plan.',
      'act-06-11-01-scaffolded' =>
          'Gives up on turns when called — tap Disciplined.',
      'act-06-11-01-unguided' =>
          'Two hands of tightness — tap Keep sampling.',
      'act-06-11-01-checkpoint' =>
          'Best pre-label note bundle — tap Tight · plan · give.',
      'act-06-11-02-guided' =>
          'Folds most, 3-bets strong — tap TAG.',
      'act-06-11-02-scaffolded' =>
          'TAG versus Maniac — tap Selective vs extreme.',
      'act-06-11-02-unguided' =>
          'Opens tight, selective c-bets — tap TAG.',
      'act-06-11-02-checkpoint' =>
          'TAG is a working model — tap Working model.',
      'act-06-11-03-checkpoint' =>
          'Versus TAG — tap Selective + disciplined.',
      'act-06-12-01-guided' =>
          'Wide opens + barrels, some folds — tap Wide + pressure.',
      'act-06-12-01-scaffolded' =>
          'Difference vs maniac — tap Some folds.',
      'act-06-12-01-unguided' =>
          'One wide open — tap Keep sampling.',
      'act-06-12-01-checkpoint' =>
          'Best pre-label notes — tap Wide · barrels · folds.',
      'act-06-12-02-guided' =>
          'Opens wide, barrels often — tap LAG.',
      'act-06-12-02-scaffolded' =>
          'LAG vs Station — tap Pressure vs passive.',
      'act-06-12-02-unguided' =>
          'Wide opens, keeps barreling — tap LAG.',
      'act-06-12-02-checkpoint' =>
          'Beside LAG label — tap Sample limits.',
      'act-06-12-03-unguided' =>
          'Inventing triple-barrel bluffs into a LAG — tap Usually avoid.',
      'act-06-12-03-checkpoint' =>
          'LAG exploit cites — tap Wide + pressure.',
      'act-06-13-01-checkpoint' =>
          'Selective entry + disciplined barrels — tap TAG — respect.',
      'act-06-13-02-cp-adv' =>
          'PFR on dry A-high — tap Range advantage.',
      'act-06-13-02-cp-cap' =>
          'Check-back turn — tap More capped.',
      'act-06-13-02-cp-polar' =>
          'River overbet shape — tap Polarized.',
      'act-06-13-02-cp-tag' =>
          'Tight entry, planned barrels — tap TAG.',
      'act-06-13-02-cp-lag' =>
          'Wide entry, sustained pressure — tap LAG.',
      'act-07-01-01-guided' =>
          'AQo 3-bet · 872tt — tap Plan is sick.',
      'act-07-01-01-scaffolded' =>
          'BTN steal KTo · KT2r — tap Value continues.',
      'act-07-01-01-unguided' =>
          'Best habit — tap Name the thesis.',
      'act-07-01-01-checkpoint' =>
          'Dead plan — tap Abandon quickly.',
      'act-07-02-01-guided' =>
          'AK c-bet · Q72r — tap Aces & blanks.',
      'act-07-02-01-scaffolded' =>
          'Gutshot · brick raise — tap Give up.',
      'act-07-02-01-unguided' =>
          'No turn idea — tap Map first.',
      'act-07-02-01-checkpoint' =>
          'Turn map — tap Continue/kill list.',
      'act-07-03-01-scaffolded' =>
          'Nut flush blocker — tap Blocks strong calls.',
      'act-07-03-01-unguided' =>
          'No story — tap Check.',
      'act-07-03-01-checkpoint' =>
          'River rule — tap Value needs calls.',
      'act-07-04-01-guided' =>
          'Multiway limped — tap Nut potential.',
      'act-07-04-01-scaffolded' =>
          'HU SRP IP — tap C-bet maps.',
      'act-07-04-01-unguided' =>
          '4-bet 100bb — tap Higher commitment.',
      'act-07-04-01-checkpoint' =>
          'Pot type — tap Ranges and SPR.',
      'act-07-05-01-guided' =>
          'Four-way river — tap Usually no.',
      'act-07-05-01-scaffolded' =>
          'HU vs nit — tap Higher HU.',
      'act-07-05-01-unguided' =>
          'Multiway top set — tap Thicker value.',
      'act-07-05-01-checkpoint' =>
          'Player count — tap First-class input.',
      'act-07-06-01-guided' =>
          '35bb TPTK — tap Closer to stacking.',
      'act-07-06-01-scaffolded' =>
          '250bb 55 — tap More attractive.',
      'act-07-06-01-unguided' =>
          'Hero 200 / Villain 40 — tap 40bb.',
      'act-07-06-01-checkpoint' =>
          'Stack depth — tap Every hand.',
      'act-07-07-01-checkpoint' =>
          'No type evidence — tap Baseline.',
      'act-07-08-01-checkpoint' =>
          'Integrated decision — tap All four.',
      'act-07-09-01-guided' =>
          'Best leak note — tap Specific note.',
      'act-07-09-01-scaffolded' =>
          'BTN vs unknown BB — tap Written range.',
      'act-07-09-01-unguided' =>
          'Review the book — tap On a schedule.',
      'act-07-09-01-checkpoint' =>
          'Default book purpose — tap Baseline.',
      'act-07-11-01-guided' =>
          'Warm-up checklist — tap Full list.',
      'act-07-11-01-scaffolded' =>
          'Carry into Live — tap Defaults + exploits.',
      'act-07-11-01-unguided' =>
          'Scope reminder — tap Live cash NLH.',
      'act-07-11-01-checkpoint' =>
          'Warm-up goal — tap One hand.',
      'act-07-12-01-cs' =>
          'Sticky calls — tap Station value.',
      'act-07-12-01-nit' =>
          'Tiny range heat — tap Nit respect.',
      'act-07-12-01-maniac' =>
          'Endless barrels — tap Maniac catch.',
      'act-07-12-01-tag' =>
          'Selective barrels — tap TAG respect.',
      'act-07-12-01-lag' =>
          'Wide pressure — tap LAG trap.',
      'act-07-12-01-uncertain' =>
          'Three mixed samples — tap Low certainty.',
      'act-07-12-01-retire' =>
          'Label flipped — tap Retire model.',
      _ => 'Tap the answer on the table.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(widget.activity);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final locked =
            widget.controller.submitting ||
            widget.controller.lastResult != null;
        final selected = widget.controller.draft.choiceId;
        final coach = _coachText;
        final prompt = widget.activity.prompt?.trim();
        // Felt + Rex already teach — skip near-duplicate prompt dumps on
        // street / pot / position felt quizzes (and hide Rex under Nice!).
        final feltFirstSelect =
            widget.activity.id.startsWith('act-01-04-01-') ||
            widget.activity.id.startsWith('act-01-05-01-') ||
            widget.activity.id.startsWith('act-02-01-01-') ||
            widget.activity.id == 'act-02-01-02-unguided-wait' ||
            widget.activity.id == 'act-02-01-02-checkpoint-full' ||
            widget.activity.id == 'act-01-02-02-unguided-board' ||
            widget.activity.id.startsWith('act-02-06-01-') ||
            widget.activity.id == 'act-02-07-01-checkpoint-habit' ||
            widget.activity.id == 'act-02-07-02-jump-pos' ||
            widget.activity.id == 'act-02-07-02-jump-stack' ||
            widget.activity.id == 'act-02-05-01-scaffolded-eff' ||
            widget.activity.id == 'act-02-05-01-unguided-depth' ||
            widget.activity.id == 'act-02-02-01-guided-pair' ||
            widget.activity.id == 'act-02-02-01-scaffolded-broadway' ||
            widget.activity.id == 'act-02-02-01-unguided-sc' ||
            widget.activity.id == 'act-02-02-01-checkpoint-trash' ||
            widget.activity.id == 'act-02-07-02-jump-family' ||
            widget.activity.id == 'act-01-02-01-scaffolded-spot' ||
            widget.activity.id == 'act-03-01-01-guided' ||
            widget.activity.id == 'act-03-01-01-scaffolded' ||
            widget.activity.id == 'act-03-01-01-unguided' ||
            widget.activity.id == 'act-03-01-01-checkpoint' ||
            widget.activity.id == 'act-03-02-01-guided' ||
            widget.activity.id == 'act-03-02-01-scaffolded' ||
            widget.activity.id == 'act-03-02-01-unguided' ||
            widget.activity.id == 'act-03-02-01-checkpoint' ||
            widget.activity.id == 'act-03-03-01-guided' ||
            widget.activity.id == 'act-03-03-01-scaffolded' ||
            widget.activity.id == 'act-03-03-01-unguided' ||
            widget.activity.id == 'act-03-03-01-checkpoint' ||
            widget.activity.id == 'act-03-05-01-guided' ||
            widget.activity.id == 'act-03-05-01-checkpoint' ||
            widget.activity.id == 'act-03-06-01-checkpoint' ||
            widget.activity.id == 'act-03-07-01-unguided' ||
            widget.activity.id == 'act-03-07-01-checkpoint' ||
            widget.activity.id == 'act-03-08-01-checkpoint' ||
            widget.activity.id == 'act-03-08-02-jump-table' ||
            widget.activity.id == 'act-03-08-02-jump-class' ||
            widget.activity.id == 'act-03-08-02-jump-leak' ||
            widget.activity.id == 'act-04-01-01-guided' ||
            widget.activity.id == 'act-04-01-01-scaffolded' ||
            widget.activity.id == 'act-04-01-01-unguided' ||
            widget.activity.id == 'act-04-01-01-checkpoint' ||
            widget.activity.id == 'act-04-03-01-checkpoint' ||
            widget.activity.id == 'act-04-04-01-unguided' ||
            widget.activity.id == 'act-04-06-01-guided' ||
            widget.activity.id == 'act-04-06-01-scaffolded' ||
            widget.activity.id == 'act-04-06-01-unguided' ||
            widget.activity.id == 'act-04-06-01-checkpoint' ||
            widget.activity.id == 'act-04-06-02-guided' ||
            widget.activity.id == 'act-04-06-02-scaffolded' ||
            widget.activity.id == 'act-04-06-02-unguided' ||
            widget.activity.id == 'act-04-06-02-checkpoint' ||
            widget.activity.id == 'act-04-06-03-checkpoint' ||
            widget.activity.id.startsWith('act-04-07-01-') ||
            widget.activity.id == 'act-04-07-02-guided' ||
            widget.activity.id == 'act-04-07-02-unguided' ||
            widget.activity.id == 'act-04-07-02-checkpoint' ||
            widget.activity.id == 'act-04-07-03-checkpoint' ||
            widget.activity.id.startsWith('act-04-08-01-') ||
            widget.activity.id == 'act-04-08-02-guided' ||
            widget.activity.id == 'act-04-08-02-unguided' ||
            widget.activity.id == 'act-04-08-02-checkpoint' ||
            widget.activity.id == 'act-04-08-03-checkpoint' ||
            widget.activity.id.startsWith('act-04-09-01-') ||
            widget.activity.id == 'act-04-10-02-jump-range' ||
            widget.activity.id == 'act-04-10-02-jump-station' ||
            widget.activity.id == 'act-04-10-02-jump-nit' ||
            widget.activity.id == 'act-04-10-02-jump-maniac' ||
            widget.activity.id == 'act-05-01-01-guided' ||
            widget.activity.id == 'act-05-01-01-checkpoint' ||
            widget.activity.id == 'act-05-02-01-guided' ||
            widget.activity.id == 'act-05-02-01-unguided' ||
            widget.activity.id == 'act-05-02-01-checkpoint' ||
            widget.activity.id == 'act-05-03-01-checkpoint' ||
            widget.activity.id == 'act-05-04-01-checkpoint' ||
            widget.activity.id == 'act-05-05-01-guided' ||
            widget.activity.id == 'act-05-05-01-unguided' ||
            widget.activity.id == 'act-05-05-01-checkpoint' ||
            widget.activity.id == 'act-05-06-01-guided' ||
            widget.activity.id == 'act-05-06-01-unguided' ||
            widget.activity.id == 'act-05-06-01-checkpoint' ||
            widget.activity.id == 'act-05-07-01-guided' ||
            widget.activity.id == 'act-05-07-01-scaffolded' ||
            widget.activity.id == 'act-05-07-01-unguided' ||
            widget.activity.id == 'act-05-07-01-checkpoint' ||
            widget.activity.id == 'act-05-08-01-guided' ||
            widget.activity.id == 'act-05-08-01-scaffolded' ||
            widget.activity.id == 'act-05-08-01-checkpoint' ||
            widget.activity.id == 'act-05-09-01-guided' ||
            widget.activity.id == 'act-05-09-01-scaffolded' ||
            widget.activity.id == 'act-05-09-01-unguided' ||
            widget.activity.id == 'act-05-09-01-checkpoint' ||
            widget.activity.id == 'act-05-09-02-cp-multi' ||
            widget.activity.id == 'act-05-09-02-cp-tell' ||
            widget.activity.id == 'act-05-09-02-cp-stop' ||
            widget.activity.id == 'act-06-01-01-guided' ||
            widget.activity.id == 'act-06-01-01-scaffolded' ||
            widget.activity.id == 'act-06-01-01-checkpoint' ||
            widget.activity.id == 'act-06-02-01-guided' ||
            widget.activity.id == 'act-06-02-01-scaffolded' ||
            widget.activity.id == 'act-06-02-01-unguided' ||
            widget.activity.id == 'act-06-02-01-checkpoint' ||
            widget.activity.id == 'act-06-03-01-guided' ||
            widget.activity.id == 'act-06-03-01-unguided' ||
            widget.activity.id == 'act-06-03-01-checkpoint' ||
            widget.activity.id == 'act-06-04-01-guided' ||
            widget.activity.id == 'act-06-04-01-unguided' ||
            widget.activity.id == 'act-06-04-01-checkpoint' ||
            widget.activity.id == 'act-06-05-01-guided' ||
            widget.activity.id == 'act-06-05-01-unguided' ||
            widget.activity.id == 'act-06-05-01-checkpoint' ||
            widget.activity.id == 'act-06-06-01-guided' ||
            widget.activity.id == 'act-06-06-01-scaffolded' ||
            widget.activity.id == 'act-06-06-01-unguided' ||
            widget.activity.id == 'act-06-06-01-checkpoint' ||
            widget.activity.id == 'act-06-07-01-guided' ||
            widget.activity.id == 'act-06-07-01-unguided' ||
            widget.activity.id == 'act-06-07-01-checkpoint' ||
            widget.activity.id == 'act-06-08-01-scaffolded' ||
            widget.activity.id == 'act-06-08-01-unguided' ||
            widget.activity.id == 'act-06-08-01-checkpoint' ||
            widget.activity.id == 'act-06-09-01-guided' ||
            widget.activity.id == 'act-06-09-01-unguided' ||
            widget.activity.id == 'act-06-09-01-checkpoint' ||
            widget.activity.id == 'act-06-10-01-scaffolded' ||
            widget.activity.id == 'act-06-10-01-unguided' ||
            widget.activity.id == 'act-06-10-01-checkpoint' ||
            widget.activity.id == 'act-06-11-01-guided' ||
            widget.activity.id == 'act-06-11-01-scaffolded' ||
            widget.activity.id == 'act-06-11-01-unguided' ||
            widget.activity.id == 'act-06-11-01-checkpoint' ||
            widget.activity.id == 'act-06-11-02-guided' ||
            widget.activity.id == 'act-06-11-02-scaffolded' ||
            widget.activity.id == 'act-06-11-02-unguided' ||
            widget.activity.id == 'act-06-11-02-checkpoint' ||
            widget.activity.id == 'act-06-11-03-checkpoint' ||
            widget.activity.id == 'act-06-12-01-guided' ||
            widget.activity.id == 'act-06-12-01-scaffolded' ||
            widget.activity.id == 'act-06-12-01-unguided' ||
            widget.activity.id == 'act-06-12-01-checkpoint' ||
            widget.activity.id == 'act-06-12-02-guided' ||
            widget.activity.id == 'act-06-12-02-scaffolded' ||
            widget.activity.id == 'act-06-12-02-unguided' ||
            widget.activity.id == 'act-06-12-02-checkpoint' ||
            widget.activity.id == 'act-06-12-03-unguided' ||
            widget.activity.id == 'act-06-12-03-checkpoint' ||
            widget.activity.id == 'act-06-13-01-checkpoint' ||
            widget.activity.id == 'act-06-13-02-cp-adv' ||
            widget.activity.id == 'act-06-13-02-cp-cap' ||
            widget.activity.id == 'act-06-13-02-cp-polar' ||
            widget.activity.id == 'act-06-13-02-cp-tag' ||
            widget.activity.id == 'act-06-13-02-cp-lag' ||
            widget.activity.id == 'act-07-01-01-guided' ||
            widget.activity.id == 'act-07-01-01-scaffolded' ||
            widget.activity.id == 'act-07-01-01-unguided' ||
            widget.activity.id == 'act-07-01-01-checkpoint' ||
            widget.activity.id == 'act-07-02-01-guided' ||
            widget.activity.id == 'act-07-02-01-scaffolded' ||
            widget.activity.id == 'act-07-02-01-unguided' ||
            widget.activity.id == 'act-07-02-01-checkpoint' ||
            widget.activity.id == 'act-07-03-01-scaffolded' ||
            widget.activity.id == 'act-07-03-01-unguided' ||
            widget.activity.id == 'act-07-03-01-checkpoint' ||
            widget.activity.id == 'act-07-04-01-guided' ||
            widget.activity.id == 'act-07-04-01-scaffolded' ||
            widget.activity.id == 'act-07-04-01-unguided' ||
            widget.activity.id == 'act-07-04-01-checkpoint' ||
            widget.activity.id == 'act-07-05-01-guided' ||
            widget.activity.id == 'act-07-05-01-scaffolded' ||
            widget.activity.id == 'act-07-05-01-unguided' ||
            widget.activity.id == 'act-07-05-01-checkpoint' ||
            widget.activity.id == 'act-07-06-01-guided' ||
            widget.activity.id == 'act-07-06-01-scaffolded' ||
            widget.activity.id == 'act-07-06-01-unguided' ||
            widget.activity.id == 'act-07-06-01-checkpoint' ||
            widget.activity.id == 'act-07-07-01-checkpoint' ||
            widget.activity.id == 'act-07-08-01-checkpoint' ||
            widget.activity.id == 'act-07-09-01-guided' ||
            widget.activity.id == 'act-07-09-01-scaffolded' ||
            widget.activity.id == 'act-07-09-01-unguided' ||
            widget.activity.id == 'act-07-09-01-checkpoint' ||
            widget.activity.id == 'act-07-11-01-guided' ||
            widget.activity.id == 'act-07-11-01-scaffolded' ||
            widget.activity.id == 'act-07-11-01-unguided' ||
            widget.activity.id == 'act-07-11-01-checkpoint' ||
            widget.activity.id == 'act-07-12-01-cs' ||
            widget.activity.id == 'act-07-12-01-nit' ||
            widget.activity.id == 'act-07-12-01-maniac' ||
            widget.activity.id == 'act-07-12-01-tag' ||
            widget.activity.id == 'act-07-12-01-lag' ||
            widget.activity.id == 'act-07-12-01-uncertain' ||
            widget.activity.id == 'act-07-12-01-retire';
        final showPrompt =
            !feltFirstSelect &&
            prompt != null &&
            prompt.isNotEmpty &&            prompt.toLowerCase() != coach.trim().toLowerCase();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!locked) RexCoachLine(text: coach),
            if (showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                widget.activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(
                scene: scene,
                selectedRegion: _selectedRegion,
                selectedSeatIndex: _selectedSeatIndex,
                showSoftPulse:
                    selected == null &&
                    !locked &&
                    ((widget.showGuidance &&
                            (widget.activity.stage == ActivityStage.guided ||
                                widget.activity.stage ==
                                    ActivityStage.scaffolded)) ||
                        widget.activity.id == 'act-01-02-02-unguided-board'),
                enabled: !locked,
                onRegionTap:
                    locked
                        ? null
                        : (target) {
                          final mapped = mapTableRegionToChoiceId(
                            activityId: widget.activity.id,
                            region: target.region,
                            seatIndex: target.seatIndex,
                            choices: widget.activity.choices,
                          );
                          if (mapped == null) return;
                          setState(() {
                            _selectedRegion = target.region;
                            _selectedSeatIndex = target.seatIndex;
                          });
                          widget.controller.selectChoice(mapped, autoSubmit: true);
                        },
              ),
            ],
            if (!locked &&
                (widget.controller.submitting ||
                    widget.controller.lastResult == null)) ...[
              Builder(
                builder: (context) {
                  final status = widget.controller.submitting
                      ? 'Checking…'
                      : feltFirstSelect
                      // Rex already cues the tile — no third "tap…" line.
                      ? (coach.isNotEmpty ? '' : 'Tap on the felt.')
                      : 'Tap the answer on the table.';
                  if (status.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HandCategoryTapActivity extends StatelessWidget {
  const _HandCategoryTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  String get _coachFallback => switch (activity.id) {
        'act-02-07-02-jump-family' =>
          'Look at your holes — tap the family they belong to.',
        'act-02-02-01-guided-pair' =>
          'Matching ranks in the hole — tap the family.',
        'act-02-02-01-scaffolded-broadway' =>
          'Both cards ten-or-better — tap the family.',
        'act-02-02-01-unguided-sc' =>
          'Look at your holes — tap the family.',
        'act-02-02-01-checkpoint-trash' =>
          'Early seat with junk — tap the family.',
        'act-03-02-01-guided' =>
          'Board pairs your king — tap the flop class.',
        'act-03-02-01-scaffolded' =>
          'Two hearts on board with the nut heart — tap the class.',
        'act-03-02-01-unguided' =>
          'No pair, almost no draw multiway — tap the class.',
        'act-03-02-01-checkpoint' =>
          'Eight or queen completes — tap the class.',
        'act-03-03-01-guided' =>
          'King-high board. Tap the remaining aces — your clean outs.',
        'act-03-03-01-unguided' =>
          'Getting 3:1 with real outs — tap what you do.',
        'act-03-03-01-checkpoint' =>
          'Nut flush draw, deep and sticky — tap Implied.',
        'act-03-05-01-guided' =>
          'Dry ace flop, blank three — tap Brick.',
        'act-03-05-01-checkpoint' =>
          'Air bluff meets a draw-completing queen — tap the plan.',
        'act-03-06-01-checkpoint' =>
          'Medium one pair faces a big bet — tap the river job.',
        'act-03-07-01-unguided' =>
          'Deep multiway — tap the better speculative hand.',
        'act-03-07-01-checkpoint' =>
          'Seat enters most pots — tap what you note.',
        'act-03-08-01-checkpoint' =>
          'Two seats, different frequencies — tap the note.',
        'act-03-08-02-jump-table' =>
          'Pot 16, shorter 40bb — tap what you track first.',
        'act-03-08-02-jump-class' =>
          'Qd9d3c with JdTd — tap the flop class.',
        'act-03-08-02-jump-leak' =>
          'Gutshot vs a 2x pot bet — tap the fix.',
        'act-04-01-01-guided' =>
          'UTG opens at 1/2 — tap the range shape.',
        'act-04-01-01-scaffolded' =>
          'BTN open, BB 3-bet, BTN calls — tap who is stronger.',
        'act-04-01-01-unguided' =>
          'They bet twice — you pinned Exactly AK. Tap the problem.',
        'act-04-01-01-checkpoint' =>
          'Same board, different villain lines — tap what changes.',
        'act-04-03-01-checkpoint' =>
          'You have a flop plan — tap the turn branches.',
        'act-04-04-01-unguided' =>
          'Two value sizes both get calls — tap the grading idea.',
        'act-04-06-01-guided' =>
          'Seat calls 7 of 9 preflops — tap the observation.',
        'act-04-06-01-scaffolded' =>
          'Second pair called three streets twice — tap the note.',
        'act-04-06-01-unguided' =>
          'One dramatic call — tap how confident the label is.',
        'act-04-06-01-checkpoint' =>
          'Before you label — tap the evidence bundle.',
        _ => 'Look at the board and your holes — tap what you made.',
      };

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(activity);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locked = controller.submitting || controller.lastResult != null;
        final selected = controller.draft.choiceId;
        // Felt already shows the cards — never dump board/hole codes into Rex.
        final resolved =
            scene != null
                ? (
                  coach: _coachFallback,
                  showPrompt: false,
                )
                : resolveLessonCoachPrompt(
                  activity: activity,
                  fallback: _coachFallback,
                );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: resolved.coach),
            if (resolved.showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(scene: scene),
            ],
            const SizedBox(height: 14),
            Builder(
              builder: (context) {
                final densifyOuts =
                    activity.id == 'act-03-03-01-guided' &&
                    !locked &&
                    selected == null;
                final minFelt =
                    densifyOuts
                        ? MediaQuery.sizeOf(context).height * 0.34
                        : null;
                final status = () {
                  if (controller.lastResult != null) return '';
                  if (controller.submitting) return 'Checking…';
                  if (selected == null) {
                    return activity.id == 'act-02-07-02-jump-family' ||
                            activity.id.startsWith('act-02-02-01-')
                        ? 'Tap the starting-hand family.'
                        : activity.id.startsWith('act-03-02-01-')
                        ? 'Tap the flop class.'
                        : activity.id == 'act-03-03-01-guided'
                        ? 'Tap the remaining aces.'
                        : activity.id == 'act-03-03-01-unguided'
                        ? 'Tap Call, Fold, or Raise.'
                        : activity.id == 'act-03-03-01-checkpoint'
                        ? 'Tap Implied.'
                        : activity.id == 'act-03-05-01-guided'
                        ? 'Tap brick or scare.'
                        : activity.id == 'act-03-05-01-checkpoint'
                        ? 'Tap your turn plan.'
                        : activity.id == 'act-03-06-01-checkpoint'
                        ? 'Tap the river job.'
                        : activity.id == 'act-03-07-01-unguided'
                        ? 'Tap the speculative hand.'
                        : activity.id == 'act-03-07-01-checkpoint'
                        ? 'Tap what you observe.'
                        : activity.id == 'act-03-08-01-checkpoint'
                        ? 'Tap the seat note.'
                        : activity.id == 'act-03-08-02-jump-table'
                        ? 'Tap what you track first.'
                        : activity.id == 'act-03-08-02-jump-class'
                        ? 'Tap the flop class.'
                        : activity.id == 'act-03-08-02-jump-leak'
                        ? 'Tap the price fix.'
                        : activity.id.startsWith('act-04-01-01-')
                        ? 'Tap the range answer.'
                        : activity.id == 'act-04-03-01-checkpoint'
                        ? 'Tap the branching plan.'
                        : activity.id == 'act-04-04-01-unguided'
                        ? 'Tap the soft-grade idea.'
                        : activity.id.startsWith('act-04-06-01-')
                        ? 'Tap the observation note.'
                        : 'Tap the hand category you made.';
                  }
                  return 'Checking…';
                }();
                final tiles = <Widget>[
                  for (var i = 0; i < activity.choices.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final choice = activity.choices[i];
                        final example =
                            resolveHandExample(
                              id: choice.id,
                              label: choice.label,
                            ) ??
                            LessonHandExample(
                              id: choice.id,
                              title: choice.label,
                              codes: const [],
                            );
                        final pulseNext =
                            showGuidance &&
                            activity.stage == ActivityStage.guided &&
                            i == 0 &&
                            selected == null &&
                            !locked &&
                            (activity.id.startsWith('act-02-02-01-') ||
                                activity.id == 'act-03-05-01-guided');
                        final invitePulse =
                            showGuidance &&
                            selected == null &&
                            !locked &&
                            (activity.id.startsWith('act-01-02-01-') ||
                                activity.id == 'act-03-03-01-guided');
                        return _FamilySoftPulse(
                          active: pulseNext || invitePulse,
                          child: HandExampleTile(
                            example: example,
                            selected: selected == choice.id,
                            enabled: !locked,
                            compact: true,
                            expand: densifyOuts,
                            onPressed:
                                locked
                                    ? null
                                    : () => controller.selectChoice(
                                      choice.id,
                                      autoSubmit: true,
                                    ),
                          ),
                        );
                      },
                    ),
                  ],
                ];
                final statusWidget =
                    status.isEmpty
                        ? const SizedBox.shrink()
                        : (densifyOuts
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.feltDark.withValues(
                                  alpha: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.45),
                                ),
                              ),
                              child: Text(
                                status,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: AppColors.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            : Text(
                              status,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: AppColors.slate,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ));
                final column = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...tiles,
                    if (status.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      statusWidget,
                    ],
                  ],
                );
                if (minFelt == null) return column;
                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minFelt),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.feltLight, AppColors.feltDark],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.feltBorder.withValues(alpha: 0.85),
                      ),
                    ),
                    child: column,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Soft gold pulse on the next guided family tile.
class _FamilySoftPulse extends StatefulWidget {
  const _FamilySoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_FamilySoftPulse> createState() => _FamilySoftPulseState();
}

class _FamilySoftPulseState extends State<_FamilySoftPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _FamilySoftPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.22 + (_pulse.value * 0.38);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow * 0.55),
                blurRadius: 10 + (_pulse.value * 6),
                spreadRadius: 0.4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ShowdownTapActivity extends StatefulWidget {
  const _ShowdownTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  State<_ShowdownTapActivity> createState() => _ShowdownTapActivityState();
}

class _ShowdownTapActivityState extends State<_ShowdownTapActivity> {
  LessonTableRegion? _selectedRegion;

  String get _coachFallback {
    if (widget.activity.id == 'act-01-02-02-scaffolded-kicker') {
      return 'Same pair — tap who wins on kickers.';
    }
    if (widget.activity.id == 'act-01-02-02-unguided-board') {
      return 'Both checked down — tap who takes the pot.';
    }
    if (widget.activity.id == 'act-01-02-01-checkpoint-winner') {
      return 'Showdown — tap who wins on the felt.';
    }
    return 'Look at both hands — tap who wins.';
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void didUpdateWidget(covariant _ShowdownTapActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
      _selectedRegion = null;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (widget.controller.draft.choiceId == null && _selectedRegion != null) {
      setState(() => _selectedRegion = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(widget.activity);
    final feltInteractive =
        scene != null &&
        (scene.villainCodes.isNotEmpty || scene.heroCodes.isNotEmpty);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final locked =
            widget.controller.submitting ||
            widget.controller.lastResult != null;
        final selected = widget.controller.draft.choiceId;
        // Felt already shows the cards — never dump board/hole codes into Rex.
        final resolved =
            scene != null
                ? (coach: _coachFallback, showPrompt: false)
                : resolveLessonCoachPrompt(
                  activity: widget.activity,
                  fallback: _coachFallback,
                );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!locked) RexCoachLine(text: resolved.coach),
            if (scene == null && resolved.showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                widget.activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (scene != null) ...[
              const SizedBox(height: 12),
              LessonTableContext(
                scene: scene,
                selectedRegion: _selectedRegion,
                showSoftPulse:
                    widget.showGuidance &&
                    selected == null &&
                    !locked &&
                    widget.activity.stage == ActivityStage.guided,
                enabled: !locked,
                onRegionTap:
                    feltInteractive && !locked
                        ? (target) {
                          final mapped = mapTableRegionToChoiceId(
                            activityId: widget.activity.id,
                            region: target.region,
                            seatIndex: target.seatIndex,
                            choices: widget.activity.choices,
                          );
                          if (mapped == null) return;
                          setState(() => _selectedRegion = target.region);
                          widget.controller.selectChoice(
                            mapped,
                            autoSubmit: true,
                          );
                        }
                        : null,
              ),
            ],
            const SizedBox(height: 12),
            for (var i = 0; i < widget.activity.choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final choice = widget.activity.choices[i];
                  // Felt already teaches You vs Them — keep chop docks only.
                  if (feltInteractive &&
                      !choice.id.contains('chop') &&
                      choice.id != 'split') {
                    return const SizedBox.shrink();
                  }
                  final example =
                      resolveHandExample(id: choice.id, label: choice.label) ??
                      LessonHandExample(
                        id: choice.id,
                        title: choice.label,
                        codes: const [],
                      );
                  return HandExampleTile(
                    example: example,
                    selected: selected == choice.id,
                    enabled: !locked,
                    compact: false,
                    expand: true,
                    onPressed:
                        locked
                            ? null
                            : () => widget.controller.selectChoice(
                              choice.id,
                              autoSubmit: true,
                            ),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final status = () {
                  if (widget.controller.lastResult != null) return '';
                  if (widget.controller.submitting) return 'Checking…';
                  if (selected == null) {
                    return feltInteractive
                        ? 'Tap You or Them on the felt.'
                        : 'Tap the result that wins the pot.';
                  }
                  return 'Checking…';
                }();
                if (status.isEmpty) return const SizedBox.shrink();
                return Text(
                  status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _BestFiveCardTapActivity extends StatelessWidget {
  const _BestFiveCardTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  String get _coachFallback =>
      'Only five cards count — tap the ones that play.';

  @override
  Widget build(BuildContext context) {
    final spot = resolveBestFiveSpot(activity);
    if (spot == null) {
      return Text(
        'Missing best-five spot for ${activity.id}',
        style: GoogleFonts.manrope(color: AppColors.cream),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locked = controller.submitting || controller.lastResult != null;
        // Cards are on the picker — never dump hole/board codes into Rex.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: _coachFallback),
            const SizedBox(height: 14),
            BestFiveCardPicker(
              key: ValueKey<String>(
                '${activity.id}-${controller.bindGeneration}',
              ),
              activity: activity,
              controller: controller,
              spot: spot,
              locked: locked,
            ),
          ],
        );
      },
    );
  }
}

/// Felt suit picker that maps tap sets onto authored choice ids.
class SuitTapPicker extends StatefulWidget {
  /// Creates the suit tap picker.
  const SuitTapPicker({
    super.key,
    required this.activity,
    required this.controller,
    required this.locked,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool locked;

  @override
  State<SuitTapPicker> createState() => _SuitTapPickerState();
}

class _SuitTapPickerState extends State<SuitTapPicker> {
  static const _palette = <LessonSuitToken>[
    LessonSuitToken.hearts,
    LessonSuitToken.diamonds,
    LessonSuitToken.clubs,
    LessonSuitToken.spades,
    LessonSuitToken.stars,
  ];

  final Set<LessonSuitToken> _selected = <LessonSuitToken>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFromController);
    _hydrateFromChoice(widget.controller.draft.choiceId);
  }

  @override
  void didUpdateWidget(covariant SuitTapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _hydrateFromChoice(widget.controller.draft.choiceId);
      return;
    }
    // Same controller, new activity (resume / advance): drop provisional taps.
    if (oldWidget.activity.id != widget.activity.id) {
      _hydrateFromChoice(widget.controller.draft.choiceId);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  void _syncFromController() {
    final choiceId = widget.controller.draft.choiceId;
    if (choiceId == null) {
      // Undo after a Check-ready set: drop tiles. Keep provisional 1–2 taps.
      final mapped = mapSuitTapSelectionToChoiceId(
        selected: _selected,
        choices: widget.activity.choices,
      );
      if (mapped != null && _selected.isNotEmpty && !widget.locked) {
        setState(_selected.clear);
      }
      return;
    }
    final fromChoice = _tokensForChoice(choiceId);
    if (fromChoice.isNotEmpty &&
        !_setEquals(fromChoice, _selected) &&
        mapSuitTapSelectionToChoiceId(
              selected: _selected,
              choices: widget.activity.choices,
            ) !=
            choiceId) {
      setState(() {
        _selected
          ..clear()
          ..addAll(fromChoice);
      });
    }
  }

  void _hydrateFromChoice(String? choiceId) {
    _selected
      ..clear()
      ..addAll(_tokensForChoice(choiceId));
  }

  Set<LessonSuitToken> _tokensForChoice(String? choiceId) {
    if (choiceId == null) return <LessonSuitToken>{};
    for (final choice in widget.activity.choices) {
      if (choice.id == choiceId) {
        return parseSuitTokens(choice.label).toSet();
      }
    }
    return <LessonSuitToken>{};
  }

  bool _setEquals(Set<LessonSuitToken> a, Set<LessonSuitToken> b) {
    return a.length == b.length && a.containsAll(b);
  }

  void _toggle(LessonSuitToken token) {
    if (widget.locked) return;
    setState(() {
      if (!_selected.add(token)) {
        _selected.remove(token);
      }
    });
    final mapped = mapSuitTapSelectionToChoiceId(
      selected: _selected,
      choices: widget.activity.choices,
    );
    if (mapped == null) {
      if (widget.controller.draft.choiceId != null) {
        widget.controller.undoDraft();
      }
      return;
    }
    // Auto-submit only once all four real suits are in — never on a
    // partial "missing" set that still needs another tap.
    final hasAllReal = _selected.containsAll(const {
      LessonSuitToken.hearts,
      LessonSuitToken.diamonds,
      LessonSuitToken.clubs,
      LessonSuitToken.spades,
    });
    widget.controller.selectChoice(mapped, autoSubmit: hasAllReal);
  }

  String _statusLine() {
    if (widget.controller.lastResult != null) return '';
    if (widget.controller.submitting) return 'Checking…';
    if (_selected.isEmpty) return 'Tap suits to build your answer.';
    final hasAllReal = _selected.containsAll(const {
      LessonSuitToken.hearts,
      LessonSuitToken.diamonds,
      LessonSuitToken.clubs,
      LessonSuitToken.spades,
    });
    if (hasAllReal) return 'Checking…';
    final realCount = _selected.where((t) => t.isReal).length;
    return '$realCount of 4 real suits — skip decoys.';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final status = _statusLine();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              decoration: BoxDecoration(
                color: AppColors.feltLight.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.feltBorder.withValues(alpha: 0.55),
                ),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final token in _palette)
                    SuitTapTile(
                      token: token,
                      selected: _selected.contains(token),
                      enabled: !widget.locked,
                      onPressed: () => _toggle(token),
                    ),
                ],
              ),
            ),
            if (status.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                status,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Felt tray of hole-card choices — teach-by-tapping card faces, not prose.
class _HoleCardFeltTray extends StatelessWidget {
  const _HoleCardFeltTray({
    required this.activity,
    required this.selectedId,
    required this.locked,
    required this.showGuidance,
    required this.onSelect,
  });

  final CourseActivity activity;
  final String? selectedId;
  final bool locked;
  final bool showGuidance;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TAP A HAND',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < activity.choices.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            HoleCardChoiceButton(
              codes: parseCardCodes(activity.choices[i].label),
              accessibilityText: activity.choices[i].accessibilityText,
              selected: selectedId == activity.choices[i].id,
              highlighted:
                  showGuidance &&
                  activity.stage == ActivityStage.guided &&
                  i == 0 &&
                  selectedId == null,
              enabled: !locked,
              onPressed:
                  locked ? null : () => onSelect(activity.choices[i].id),
            ),
          ],
        ],
      ),
    );
  }
}
