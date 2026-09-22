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
    case 'act-01-06-02-jump-legal':
      return const LessonActionSpot(
        heroCodes: ['Qh', 'Jd'],
        boardCodes: ['Td', '8s', '2c'],
        potLabel: 'Pot 12',
        villainLine: 'Villain bets 8',
        streetLabel: 'Flop',
        facingBet: true,
        identifyUnavailable: true,
      );
  }
  return null;
}

/// Mini-table spot for one authored multi-step hand decision.
LessonActionSpot? resolveToyHandStepSpot({
  required String activityId,
  required String stepId,
}) {
  if (!activityId.startsWith('act-01-06-0')) return null;
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
    case 'j-hand-open':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Th'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
      );
    case 'j-hand-end':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Th'],
        potLabel: 'Pot 9',
        villainLine: 'Blinds fold',
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
  if (id == 'act-01-06-02-jump-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-01-06-02-jump-legal' &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  return (id.startsWith('act-01-03-01-') || id.startsWith('act-01-03-02-')) &&
      activity.renderer == ActivityRenderer.pokerActionSizing;
}

/// Explain-step demo: Fold / Check / Call meanings on a mini felt.
class PassiveActionsDemo extends StatefulWidget {
  /// Creates the demo.
  const PassiveActionsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllActionsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllActionsTapped;

  static const actions = <(String, String, Color)>[
    ('FOLD', 'Give up', AppColors.danger),
    ('CHECK', 'Pass free', AppColors.surfaceMuted),
    ('CALL', 'Match bet', AppColors.surfaceMuted),
  ];

  @override
  State<PassiveActionsDemo> createState() => _PassiveActionsDemoState();
}

class _PassiveActionsDemoState extends State<PassiveActionsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllActionsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PassiveActionsDemo.actions.length) {
      widget.onAllActionsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
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
            children: [
              for (var i = 0; i < PassiveActionsDemo.actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: PassiveActionsDemo.actions[i].$1,
                    caption: PassiveActionsDemo.actions[i].$2,
                    color: PassiveActionsDemo.actions[i].$3,
                    selected: _tapped.contains(PassiveActionsDemo.actions[i].$1),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(PassiveActionsDemo.actions[i].$1)
                            : null,
                  ),
                ),
              ],
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
              widget.interactive
                  ? 'Tap Fold, Check, and Call'
                  : 'Pot chips sit in the middle',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Explain-step demo: Bet / Raise / All-in meanings on a mini felt.
class AggressiveActionsDemo extends StatefulWidget {
  /// Creates the demo.
  const AggressiveActionsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllActionsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllActionsTapped;

  static const actions = <(String, String, Color)>[
    ('BET', 'Open pot', AppColors.gold),
    ('RAISE', 'Reopen bet', AppColors.gold),
    ('ALL-IN', 'Stack-capped', AppColors.danger),
  ];

  @override
  State<AggressiveActionsDemo> createState() => _AggressiveActionsDemoState();
}

class _AggressiveActionsDemoState extends State<AggressiveActionsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllActionsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= AggressiveActionsDemo.actions.length) {
      widget.onAllActionsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
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
            children: [
              for (var i = 0; i < AggressiveActionsDemo.actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: AggressiveActionsDemo.actions[i].$1,
                    caption: AggressiveActionsDemo.actions[i].$2,
                    color: AggressiveActionsDemo.actions[i].$3,
                    selected:
                        _tapped.contains(AggressiveActionsDemo.actions[i].$1),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () =>
                                _onTap(AggressiveActionsDemo.actions[i].$1)
                            : null,
                  ),
                ),
              ],
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
              widget.interactive
                  ? 'Tap Bet, Raise, and All-in'
                  : 'All-in never exceeds your stack',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Explain-step demo: early vs button opens and a live ~3x size.
class OpenRangeDemo extends StatefulWidget {
  /// Creates the demo.
  const OpenRangeDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'EARLY', caption: 'Strong only', color: AppColors.danger),
    (label: 'BUTTON', caption: 'Wider', color: AppColors.gold),
    (label: 'LIVE 3x', caption: 'Open to 6 @ 1/2', color: AppColors.cream),
  ];

  @override
  State<OpenRangeDemo> createState() => _OpenRangeDemoState();
}

class _OpenRangeDemoState extends State<OpenRangeDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= OpenRangeDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
          Text(
            'Who opens — and how wide',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < OpenRangeDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: OpenRangeDemo.points[i].label,
                    caption: OpenRangeDemo.points[i].caption,
                    color: OpenRangeDemo.points[i].color,
                    selected: _tapped.contains(OpenRangeDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(OpenRangeDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Early, Button, and Live 3x'
                : 'Early tight · button wider · live opens ~3x',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: fold / call / 3-bet responses versus an open.
class VsOpenResponseDemo extends StatefulWidget {
  /// Creates the demo.
  const VsOpenResponseDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllResponsesTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllResponsesTapped;

  static const responses = <({String label, String caption, Color color})>[
    (label: 'FOLD', caption: 'Weak hands', color: AppColors.slate),
    (label: 'CALL', caption: 'Playable', color: AppColors.cream),
    (label: '3-BET', caption: 'Strong / polar', color: AppColors.gold),
  ];

  @override
  State<VsOpenResponseDemo> createState() => _VsOpenResponseDemoState();
}

class _VsOpenResponseDemoState extends State<VsOpenResponseDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllResponsesTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsOpenResponseDemo.responses.length) {
      widget.onAllResponsesTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
          Text(
            'Facing an open',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsOpenResponseDemo.responses.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: VsOpenResponseDemo.responses[i].label,
                    caption: VsOpenResponseDemo.responses[i].caption,
                    color: VsOpenResponseDemo.responses[i].color,
                    selected:
                        _tapped.contains(VsOpenResponseDemo.responses[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () =>
                                _onTap(VsOpenResponseDemo.responses[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Fold, Call, and 3-Bet'
                : 'Weak fold · playable call · strong 3-bet',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: count stacks in BB; shorter stack sets the ceiling.
class BbStackDepthDemo extends StatefulWidget {
  /// Creates the demo.
  const BbStackDepthDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'CHIPS→BB', caption: '200 @ 1/2 = 100bb', color: AppColors.cream),
    (label: 'SHORTER', caption: 'Sets the ceiling', color: AppColors.gold),
    (label: 'DEPTH', caption: '50bb ≠ 200bb', color: AppColors.slate),
  ];

  @override
  State<BbStackDepthDemo> createState() => _BbStackDepthDemoState();
}

class _BbStackDepthDemoState extends State<BbStackDepthDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= BbStackDepthDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
          Text(
            'Stack depth in big blinds',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < BbStackDepthDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: BbStackDepthDemo.points[i].label,
                    caption: BbStackDepthDemo.points[i].caption,
                    color: BbStackDepthDemo.points[i].color,
                    selected: _tapped.contains(BbStackDepthDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(BbStackDepthDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Chips→BB, Shorter, and Depth'
                : 'Count in BB · shorter stack caps the pot',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: live-table habits (watch, say, cover, wait).
class TableHabitsDemo extends StatefulWidget {
  /// Creates the demo.
  const TableHabitsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllHabitsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllHabitsTapped;

  static const habits = <({String label, String caption, Color color})>[
    (label: 'WATCH', caption: 'Follow the action', color: AppColors.cream),
    (label: 'SAY', caption: 'Announce clearly', color: AppColors.gold),
    (label: 'COVER', caption: 'Protect hole cards', color: AppColors.slate),
    (label: 'WAIT', caption: 'Act in turn', color: AppColors.danger),
  ];

  @override
  State<TableHabitsDemo> createState() => _TableHabitsDemoState();
}

class _TableHabitsDemoState extends State<TableHabitsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllHabitsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TableHabitsDemo.habits.length) {
      widget.onAllHabitsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
          Text(
            'Live-table habits',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: TableHabitsDemo.habits[row * 2 + col].label,
                      caption: TableHabitsDemo.habits[row * 2 + col].caption,
                      color: TableHabitsDemo.habits[row * 2 + col].color,
                      selected: _tapped.contains(
                        TableHabitsDemo.habits[row * 2 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                TableHabitsDemo.habits[row * 2 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Watch, Say, Cover, and Wait'
                : 'Watch · say · cover · wait your turn',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


class _DemoActionCard extends StatelessWidget {
  const _DemoActionCard({
    required this.label,
    required this.caption,
    required this.color,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.gold : color.withValues(alpha: 0.9);
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.28)
                : color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
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
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
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
    final authored = choice.label.trim().toUpperCase();
    final authoredWords = authored.split(RegExp(r'\s+'));
    // Prefer multi-word teaching labels (Raise to 6, See flop, Jam 100bb).
    // Keep Check/Fold chrome short even when content adds a caption word.
    final preferAuthoredLabel = authoredWords.length >= 2 &&
        authoredWords.first != 'CHECK' &&
        authoredWords.first != 'FOLD';
    final short =
        unavailableLook
            ? 'CHECK (off)'
            : preferAuthoredLabel
            ? authored
            : action.startsWith('ALL')
            ? (authored.contains('12') ? 'ALL-IN 12' : 'ALL-IN')
            : switch (action.split(' ').first) {
              'FOLD' => 'FOLD',
              'CHECK' => 'CHECK',
              'CALL' => authored.startsWith('CALL') ? authored : 'CALL',
              'RAISE' => authored.startsWith('RAISE') ? authored : 'RAISE',
              'BET' => authored.startsWith('BET') ? authored : 'BET',
              _ => authored,
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
