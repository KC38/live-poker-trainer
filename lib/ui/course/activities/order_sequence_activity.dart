/// Arrange action-order / sequence activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

final _rankOnly = RegExp(r'^[2-9TJQKA]$', caseSensitive: false);

/// Drag-free tap-to-order sequence builder with undo.
class OrderSequenceActivity extends StatelessWidget {
  /// Creates the activity.
  const OrderSequenceActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  bool get _rankMode =>
      activity.sequenceItems.isNotEmpty &&
      activity.sequenceItems.every((item) => _rankOnly.hasMatch(item.label));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final ordered = controller.draft.orderedIds;
        final locked = controller.submitting || controller.lastResult != null;
        final remaining =
            activity.sequenceItems
                .where((item) => !ordered.contains(item.id))
                .toList(growable: false);
        final coach =
            activity.primaryCoachLine?.text ??
            (_rankMode
                ? 'Tap ranks from lowest to highest.'
                : 'Tap seats in the order they act.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showGuidance || activity.primaryCoachLine != null)
              RexCoachLine(text: coach),
            if (activity.prompt != null) ...[
              const SizedBox(height: 12),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Semantics(
              label:
                  'Current order: ${ordered.isEmpty ? 'empty' : ordered.join(', ')}',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < ordered.length; i++)
                    _rankMode
                        ? _RankTile(
                          label: _labelFor(ordered[i]),
                          badge: '${i + 1}',
                          selected: true,
                        )
                        : Chip(
                          label: Text('${i + 1}. ${_labelFor(ordered[i])}'),
                          backgroundColor: AppColors.gold.withValues(
                            alpha: 0.2,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in remaining)
                  _rankMode
                      ? _RankTile(
                        label: item.label,
                        onPressed:
                            locked
                                ? null
                                : () => controller.setOrderedIds([
                                  ...ordered,
                                  item.id,
                                ]),
                      )
                      : ActionChip(
                        onPressed:
                            locked
                                ? null
                                : () => controller.setOrderedIds([
                                  ...ordered,
                                  item.id,
                                ]),
                        label: Text(item.label),
                      ),
              ],
            ),
            if (ordered.isNotEmpty && !locked) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    final next = [...ordered]..removeLast();
                    controller.setOrderedIds(next);
                  },
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Undo last'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _labelFor(String id) {
    for (final item in activity.sequenceItems) {
      if (item.id == id) return item.label;
    }
    return id;
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.label,
    this.badge,
    this.selected = false,
    this.onPressed,
  });

  final String label;
  final String? badge;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 56,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.gold : AppColors.slateDark,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badge != null)
            Text(
              badge!,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.bgDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      label: 'Rank $label',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
