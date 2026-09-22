/// Arrange action-order / sequence activity.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

final _rankOnly = RegExp(r'^[2-9TJQKA]$', caseSensitive: false);

/// Stable display order for the selectable palette (not the answer key).
///
/// Seeded by [activityId] so rebuilds keep the same order mid-answer; a new
/// activity id yields a new shuffle. When length > 1, the result is never the
/// authored order so teach-by-doing stays real.
List<CourseChoice> shuffledSequencePalette({
  required String activityId,
  required List<CourseChoice> items,
}) {
  if (items.length <= 1) {
    return List<CourseChoice>.unmodifiable(items);
  }
  final out = List<CourseChoice>.of(items);
  final rng = Random(_stableSeed(activityId));
  for (var i = out.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = out[i];
    out[i] = out[j];
    out[j] = tmp;
  }
  final authoredIds = items.map((item) => item.id).toList(growable: false);
  final shuffledIds = out.map((item) => item.id).toList(growable: false);
  if (_sameIdOrder(authoredIds, shuffledIds)) {
    final tmp = out[0];
    out[0] = out[1];
    out[1] = tmp;
  }
  return List<CourseChoice>.unmodifiable(out);
}

int _stableSeed(String activityId) {
  // FNV-1a 32-bit — stable across runs (unlike [String.hashCode]).
  var hash = 0x811c9dc5;
  for (final unit in activityId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

bool _sameIdOrder(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Whether this activity asks for strongest → weakest (vs low → high).
bool ordersStrongestFirst(CourseActivity activity) {
  if (activity.id == 'act-01-06-02-jump-ranks') return true;
  final prompt = (activity.prompt ?? '').toLowerCase();
  final a11y = activity.accessibilityText.toLowerCase();
  return prompt.contains('strongest to weakest') ||
      prompt.contains('strongest first') ||
      a11y.contains('strongest to weakest') ||
      a11y.contains('strongest first');
}

/// Empty tray hint for compare/order builders.
String emptyOrderTrayHint({
  required CourseActivity activity,
  required bool rankMode,
}) {
  if (ordersStrongestFirst(activity)) return 'Tap strongest first';
  if (rankMode || isHandExampleSequenceActivity(activity)) {
    return 'Tap lowest first';
  }
  if (isStreetSequenceActivity(activity)) {
    return 'Tap streets below first → last';
  }
  if (isSeatOrderSequenceActivity(activity)) {
    return 'Tap seats below first → last';
  }
  return 'Tap lowest first';
}

/// Mid-build status under the order tray (Checking… once complete/submitting).
String orderSequenceStatusLine({
  required CourseActivity activity,
  required bool submitting,
  required bool complete,
  required bool rankMode,
}) {
  if (submitting || complete) return 'Checking…';
  if (rankMode) return 'Tap low → high';
  if (ordersStrongestFirst(activity)) return 'Tap strong → weak';
  if (isHandExampleSequenceActivity(activity)) return 'Tap low → high';
  return 'Tap next';
}

/// Appends [id] to the order draft and auto-submits when the sequence is full.
void appendOrderedId({
  required LessonActivityController controller,
  required CourseActivity activity,
  required List<String> ordered,
  required String id,
}) {
  // Ignore re-taps while Checking… / graded, and ignore already-placed ids.
  if (controller.submitting || controller.lastResult != null) return;
  if (ordered.contains(id)) return;
  final next = [...ordered, id];
  final complete =
      activity.sequenceItems.isNotEmpty &&
      next.length == activity.sequenceItems.length;
  controller.setOrderedIds(next, autoSubmit: complete);
}

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
            shuffledSequencePalette(
                  activityId: activity.id,
                  items: activity.sequenceItems,
                )
                .where((item) => !ordered.contains(item.id))
                .toList(growable: false);
        final strongestFirst = ordersStrongestFirst(activity);
        final fallback =
            _rankMode
                ? 'Tap ranks from lowest to highest.'
                : strongestFirst
                ? 'Tap strongest hand first, then weaker.'
                : _handMode
                ? 'Tap hands from lowest to highest.'
                : isStreetSequenceActivity(activity)
                ? 'Tap streets from first to last.'
                : isSeatOrderSequenceActivity(activity)
                ? 'Tap seats in the order they act.'
                : 'Tap seats in the order they act.';
        final resolved = resolveLessonCoachPrompt(
          activity: activity,
          fallback: fallback,
        );
        final coach = resolved.coach;
        final showPrompt = resolved.showPrompt;
        final showCoach = shouldShowLessonCoach(
          activity: activity,
          showGuidance: showGuidance,
          coach: coach,
        );
        final statusLine = orderSequenceStatusLine(
          activity: activity,
          submitting: controller.submitting,
          complete: remaining.isEmpty && ordered.isNotEmpty,
          rankMode: _rankMode,
        );
        final trayHint = emptyOrderTrayHint(
          activity: activity,
          rankMode: _rankMode,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoach) RexCoachLine(text: coach),
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
            const SizedBox(height: 10),
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
                          trayHint,
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
                statusLine,
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
                              : () => appendOrderedId(
                                controller: controller,
                                activity: activity,
                                ordered: ordered,
                                id: item.id,
                              ),
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
                              trayHint,
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
                      statusLine,
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
                            (id) => appendOrderedId(
                              controller: controller,
                              activity: activity,
                              ordered: ordered,
                              id: id,
                            ),
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
                                      : () => appendOrderedId(
                                        controller: controller,
                                        activity: activity,
                                        ordered: ordered,
                                        id: item.id,
                                      ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ] else ...[
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
                          trayHint,
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
                              if (_rankMode)
                                _RankTile(
                                  label: _labelFor(ordered[i]),
                                  badge: '${i + 1}',
                                  selected: true,
                                )
                              else
                                Chip(
                                  label: Text(
                                    '${i + 1}. ${_labelFor(ordered[i])}',
                                  ),
                                  backgroundColor: AppColors.gold.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                statusLine,
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
                    if (_rankMode)
                      _RankTile(
                        label: item.label,
                        onPressed:
                            locked
                                ? null
                                : () => appendOrderedId(
                                  controller: controller,
                                  activity: activity,
                                  ordered: ordered,
                                  id: item.id,
                                ),
                      )
                    else
                      ActionChip(
                        onPressed:
                            locked
                                ? null
                                : () => appendOrderedId(
                                  controller: controller,
                                  activity: activity,
                                  ordered: ordered,
                                  id: item.id,
                                ),
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
