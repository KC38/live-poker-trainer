/// Mini-table + action-dock visuals for Fold/Check/Call and Bet/Raise/All-in.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Felt context for a poker-action teaching spot.
class LessonActionSpot {
  /// Creates a spot.
  const LessonActionSpot({
    required this.heroCodes,
    this.boardCodes = const <String>[],
    this.potLabel = 'Pot',
    this.villainLine,
    this.streetLabel,
    this.stackLabel,
    this.facingBet = false,
    this.identifyUnavailable = false,
    this.openPot = false,
  });

  final List<String> heroCodes;
  final List<String> boardCodes;
  final String potLabel;
  final String? villainLine;
  final String? streetLabel;

  /// Short-stack all-in teaching (e.g. "Stack 12").
  final String? stackLabel;
  final bool facingBet;

  /// Checkpoint mode: tap the illegal action (Check facing a bet).
  final bool identifyUnavailable;

  /// Unchecked pot — betting (not raising) is the open action.
  final bool openPot;
}

/// Resolves a teaching spot for Section 1 action lessons.
LessonActionSpot? resolveLessonActionSpot(CourseActivity activity) {
  switch (activity.id) {
    case 'act-01-03-01-guided-fold':
      return const LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3',
        villainLine: 'UTG opens to 6',
        streetLabel: 'Preflop · Button',
        facingBet: true,
      );
    case 'act-01-03-01-scaffolded-check':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d'],
        potLabel: 'Pot 10',
        villainLine: 'Checked to you',
        streetLabel: 'Flop',
        facingBet: false,
      );
    case 'act-01-03-01-unguided-call':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['9c', '8s', '2h'],
        potLabel: 'Pot 10',
        villainLine: 'Villain bets 5',
        streetLabel: 'Flop',
        facingBet: true,
      );
    case 'act-01-03-01-checkpoint-legal':
      return const LessonActionSpot(
        heroCodes: ['Ac', 'Kd'],
        boardCodes: ['Qh', '9c', '3s'],
        potLabel: 'Pot 12',
        villainLine: 'Villain bets 6',
        streetLabel: 'Flop',
        facingBet: true,
        identifyUnavailable: true,
      );
    case 'act-01-03-02-guided-bet':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Qd'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 10',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · Top pair',
        facingBet: false,
        openPot: true,
      );
    case 'act-01-03-02-scaffolded-raise':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 10',
        villainLine: 'Villain bets 5',
        streetLabel: 'Flop',
        facingBet: true,
      );
    case 'act-01-03-02-unguided-allin':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Jc'],
        boardCodes: ['Td', '8s', '2c'],
        potLabel: 'Pot 30',
        villainLine: 'Villain bets 20',
        streetLabel: 'Flop',
        stackLabel: 'Stack 12',
        facingBet: true,
      );
    case 'act-01-03-02-checkpoint-names':
      return const LessonActionSpot(
        heroCodes: ['Ad', '9c'],
        boardCodes: ['Kh', '7s', '2d'],
        potLabel: 'Pot 8',
        villainLine: 'Checked to you',
        streetLabel: 'Flop',
        facingBet: false,
        openPot: true,
      );
    case 'act-01-06-01-unguided-lab':
      return const LessonActionSpot(
        heroCodes: ['Ah', '7d'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'BTN opens to 6',
        streetLabel: 'Preflop · Big blind',
        facingBet: true,
      );
  }
  return null;
}

/// Mini-table spot for one authored multi-step hand decision.
LessonActionSpot? resolveToyHandStepSpot({
  required String activityId,
  required String stepId,
}) {
  if (!activityId.startsWith('act-01-06-01-')) return null;
  switch (stepId) {
    case 'step-01-06-pre':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
      );
    case 'step-01-06-flop':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 9',
        villainLine: 'Blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
      );
    case 'step-01-06-bb-defend':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 13',
        villainLine: 'BB calls your open',
        streetLabel: 'Preflop · Heading to flop',
        facingBet: false,
      );
    case 'step-01-06-flop-cbet':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 13',
        villainLine: 'BB checks',
        streetLabel: 'Flop · A72 rainbow',
        facingBet: false,
        openPot: true,
      );
    case 'step-01-06-cp-open':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 3',
        villainLine: 'CO folds',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
      );
    case 'step-01-06-cp-end':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 9',
        villainLine: 'Both blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
      );
  }
  return null;
}

/// Whether this activity should render the mini-table action dock.
bool isLessonActionTableActivity(CourseActivity activity) {
  final id = activity.id;
  if (id.startsWith('act-01-06-01-') &&
      (activity.renderer == ActivityRenderer.authoredMultiStepHand ||
          activity.renderer == ActivityRenderer.fullTableHandLab)) {
    return true;
  }
  return (id.startsWith('act-01-03-01-') || id.startsWith('act-01-03-02-')) &&
      activity.renderer == ActivityRenderer.pokerActionSizing;
}

/// Explain-step demo: Fold / Check / Call meanings on a mini felt.
class PassiveActionsDemo extends StatelessWidget {
  /// Creates the demo.
  const PassiveActionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
        child: Column(
          children: [
            Text(
              'Your three passive buttons',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(
                  child: _DemoActionCard(
                    label: 'FOLD',
                    caption: 'Give up',
                    color: AppColors.danger,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: 'CHECK',
                    caption: 'Pass free',
                    color: AppColors.surfaceMuted,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: 'CALL',
                    caption: 'Match bet',
                    color: AppColors.surfaceMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Pot chips sit in the middle',
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explain-step demo: Bet / Raise / All-in meanings on a mini felt.
class AggressiveActionsDemo extends StatelessWidget {
  /// Creates the demo.
  const AggressiveActionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
        child: Column(
          children: [
            Text(
              'Your three aggressive buttons',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(
                  child: _DemoActionCard(
                    label: 'BET',
                    caption: 'Open pot',
                    color: AppColors.gold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: 'RAISE',
                    caption: 'Reopen bet',
                    color: AppColors.gold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: 'ALL-IN',
                    caption: 'Stack-capped',
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'All-in never exceeds your stack',
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoActionCard extends StatelessWidget {
  const _DemoActionCard({
    required this.label,
    required this.caption,
    required this.color,
  });

  final String label;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini felt showing pot, optional villain bet, board, and hero holes.
class LessonActionTable extends StatelessWidget {
  /// Creates the table.
  const LessonActionTable({super.key, required this.spot});

  final LessonActionSpot spot;

  @override
  Widget build(BuildContext context) {
    final hero = <CardModel>[];
    for (final code in spot.heroCodes) {
      try {
        hero.add(CardModel.fromCode(code));
      } catch (_) {}
    }
    final board = <CardModel>[];
    for (final code in spot.boardCodes) {
      try {
        board.add(CardModel.fromCode(code));
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          if (spot.streetLabel != null)
            Text(
              spot.streetLabel!,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (spot.villainLine != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgDark.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                spot.villainLine!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _PotChip(label: spot.potLabel),
              if (spot.stackLabel != null) _PotChip(label: spot.stackLabel!),
            ],
          ),
          if (board.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < board.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  MiniCard(card: board[i], size: MiniCardSize.small),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'You',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < hero.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                MiniCard(card: hero[i], size: MiniCardSize.small),
              ],
            ],
          ),
          if (spot.facingBet) ...[
            const SizedBox(height: 8),
            Text(
              'A bet faces you',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (spot.openPot) ...[
            const SizedBox(height: 8),
            Text(
              'Pot is open to a bet',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No bet to match',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PotChip extends StatelessWidget {
  const _PotChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
              border: Border.all(color: AppColors.bgDark, width: 1.2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live-style action dock buttons for course choices.
class LessonActionDock extends StatelessWidget {
  /// Creates the dock.
  const LessonActionDock({
    super.key,
    required this.choices,
    required this.selectedId,
    required this.enabled,
    required this.onSelect,
    this.identifyUnavailable = false,
  });

  final List<CourseChoice> choices;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String> onSelect;
  final bool identifyUnavailable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < choices.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _DockButton(
              choice: choices[i],
              selected: selectedId == choices[i].id,
              enabled: enabled,
              unavailableLook:
                  identifyUnavailable &&
                  (choices[i].action?.toUpperCase() == 'CHECK' ||
                      choices[i].id.contains('check')),
              onPressed: () => onSelect(choices[i].id),
            ),
          ),
        ],
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.unavailableLook = false,
  });

  final CourseChoice choice;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;
  final bool unavailableLook;

  Color get _fill {
    final action = (choice.action ?? choice.label).toUpperCase();
    if (unavailableLook) {
      return AppColors.slateDark.withValues(alpha: 0.55);
    }
    if (action.startsWith('FOLD')) return AppColors.danger.withValues(alpha: 0.4);
    if (action.startsWith('ALL')) {
      return AppColors.danger.withValues(alpha: 0.45);
    }
    if (action.startsWith('RAISE') || action.startsWith('BET')) {
      return AppColors.gold.withValues(alpha: 0.28);
    }
    return AppColors.surfaceMuted.withValues(alpha: 0.55);
  }

  Color get _border {
    if (selected) return AppColors.gold;
    if (unavailableLook) return AppColors.slate;
    final action = (choice.action ?? choice.label).toUpperCase();
    if (action.startsWith('FOLD') || action.startsWith('ALL')) {
      return AppColors.danger;
    }
    if (action.startsWith('RAISE') || action.startsWith('BET')) {
      return AppColors.gold;
    }
    return AppColors.feltBorder;
  }

  @override
  Widget build(BuildContext context) {
    final action = (choice.action ?? choice.label).toUpperCase();
    // Live-table labels stay short (CHECK / CALL 5 / ALL-IN 12). Longer content
    // labels stay in Semantics so agents can disambiguate from footer.
    final short =
        unavailableLook
            ? 'CHECK (off)'
            : action.startsWith('ALL')
            ? (choice.label.toUpperCase().contains('12')
                ? 'ALL-IN 12'
                : 'ALL-IN')
            : switch (action.split(' ').first) {
              'FOLD' => 'FOLD',
              'CHECK' => 'CHECK',
              'CALL' => choice.label.toUpperCase().startsWith('CALL')
                  ? choice.label.toUpperCase()
                  : 'CALL',
              'RAISE' => choice.label.toUpperCase().startsWith('RAISE')
                  ? choice.label.toUpperCase()
                  : 'RAISE',
              'BET' => choice.label.toUpperCase().startsWith('BET')
                  ? choice.label.toUpperCase()
                  : 'BET',
              _ => choice.label.toUpperCase(),
            };
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: choice.accessibilityText ??
          [if (choice.action != null) choice.action!, choice.label].join(' '),
      child: Material(
        color: _fill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _border,
                width: selected ? 2.2 : 1.4,
              ),
            ),
            child: Text(
              short,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: unavailableLook ? AppColors.slate : AppColors.cream,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                height: 1.15,
                decoration:
                    unavailableLook ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.slate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
