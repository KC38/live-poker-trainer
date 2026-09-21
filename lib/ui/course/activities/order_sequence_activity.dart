/// Arrange action-order / sequence activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
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

  bool get _handMode => isHandExampleSequenceActivity(activity);

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
                : _handMode
                ? 'Tap each hand into the order asked.'
                : isStreetSequenceActivity(activity)
                ? 'Tap streets from first to last.'
                : isSeatOrderSequenceActivity(activity)
                ? 'Tap seats in the order they act.'
                : 'Tap seats in the order they act.');
        final showPrompt =
            activity.prompt != null &&
            activity.prompt!.trim().toLowerCase() != coach.trim().toLowerCase();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showGuidance || activity.primaryCoachLine != null)
              RexCoachLine(text: coach),
            if (showPrompt) ...[
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
            if (_handMode) ...[
              Text(
                ordered.isEmpty ? 'Your order (empty)' : 'Your order',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label:
                    'Current order: ${ordered.isEmpty ? 'empty' : ordered.join(', ')}',
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.feltDark.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.feltBorder.withValues(alpha: 0.8),
                    ),
                  ),
                  child: ordered.isEmpty
                      ? Text(
                          'Tap hands below in the order asked',
                          style: GoogleFonts.manrope(
                            color: AppColors.slate,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < ordered.length; i++)
                              HandExampleTile(
                                example:
                                    resolveHandExample(
                                      id: ordered[i],
                                      label: _labelFor(ordered[i]),
                                    ) ??
                                    LessonHandExample(
                                      id: ordered[i],
                                      title: _labelFor(ordered[i]),
                                      codes: const [],
                                    ),
                                badge: '${i + 1}',
                                selected: true,
                                enabled: false,
                                compact: true,
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                remaining.isEmpty ? 'All hands placed' : 'Tap next',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in remaining)
                    HandExampleTile(
                      example:
                          resolveHandExample(id: item.id, label: item.label) ??
                          LessonHandExample(
                            id: item.id,
                            title: item.label,
                            codes: const [],
                          ),
                      selected: false,
                      enabled: !locked,
                      compact: true,
                      onPressed:
                          locked
                              ? null
                              : () => controller.setOrderedIds([
                                ...ordered,
                                item.id,
                              ]),
                    ),
                ],
              ),
            ] else if (isStreetSequenceActivity(activity) ||
                isSeatOrderSequenceActivity(activity)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ordered.isEmpty
                          ? (isStreetSequenceActivity(activity)
                              ? 'Your street order'
                              : 'Your seat order')
                          : 'Your order',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Semantics(
                      label:
                          'Current order: ${ordered.isEmpty ? 'empty' : ordered.join(', ')}',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (ordered.isEmpty)
                            Text(
                              isStreetSequenceActivity(activity)
                                  ? 'Tap streets below first → last'
                                  : 'Tap seats below first → last',
                              style: GoogleFonts.manrope(
                                color: AppColors.slate,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            for (var i = 0; i < ordered.length; i++)
                              if (isStreetSequenceActivity(activity))
                                StreetOrderTile(
                                  label: _labelFor(ordered[i]),
                                  badge: '${i + 1}',
                                  selected: true,
                                  enabled: false,
                                )
                              else
                                SeatOrderTile(
                                  label: _labelFor(ordered[i]),
                                  badge: '${i + 1}',
                                  selected: true,
                                  enabled: false,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      remaining.isEmpty ? 'Ready — Check below.' : 'Tap next',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isStreetSequenceActivity(activity))
                      _StreetTileGrid(
                        items: remaining,
                        locked: locked,
                        onPick:
                            (id) => controller.setOrderedIds([...ordered, id]),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final item in remaining)
                            SeatOrderTile(
                              label: item.label,
                              enabled: !locked,
                              onPressed:
                                  locked
                                      ? null
                                      : () => controller.setOrderedIds([
                                        ...ordered,
                                        item.id,
                                      ]),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ] else ...[
              Semantics(
                label:
                    'Current order: ${ordered.isEmpty ? 'empty' : ordered.join(', ')}',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < ordered.length; i++)
                      if (_rankMode)
                        _RankTile(
                          label: _labelFor(ordered[i]),
                          badge: '${i + 1}',
                          selected: true,
                        )
                      else
                        Chip(
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
                    if (_rankMode)
                      _RankTile(
                        label: item.label,
                        onPressed:
                            locked
                                ? null
                                : () => controller.setOrderedIds([
                                  ...ordered,
                                  item.id,
                                ]),
                      )
                    else
                      ActionChip(
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
            ],
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

class _StreetTileGrid extends StatelessWidget {
  const _StreetTileGrid({
    required this.items,
    required this.locked,
    required this.onPick,
  });

  final List<CourseChoice> items;
  final bool locked;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    Widget row(List<CourseChoice> slice) {
      return Row(
        children: [
          for (var i = 0; i < slice.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: StreetOrderTile(
                label: slice[i].label,
                enabled: !locked,
                expand: true,
                onPressed: locked ? null : () => onPick(slice[i].id),
              ),
            ),
          ],
          for (var i = slice.length; i < 2; i++) ...[
            if (i > 0 || slice.isNotEmpty) const SizedBox(width: 8),
            const Expanded(child: SizedBox()),
          ],
        ],
      );
    }

    final top = items.take(2).toList(growable: false);
    final bottom = items.skip(2).toList(growable: false);
    return Column(
      children: [
        if (top.isNotEmpty) row(top),
        if (bottom.isNotEmpty) ...[const SizedBox(height: 8), row(bottom)],
      ],
    );
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
