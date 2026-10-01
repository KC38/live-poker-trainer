/// Section picker: Duolingo-style cards that organize the course path.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

/// Friendly label for a catalog experience band.
String experienceBandLabel(String band) {
  return switch (band) {
    'never_played' => 'NEVER PLAYED',
    'rules_known' => 'RULES KNOWN',
    'first_casino' => 'FIRST CASINO',
    'regular_live' => 'REGULAR LIVE',
    'winning_12' => 'WINNING 1/2',
    'advanced_live' => 'ADVANCED LIVE',
    'full_hand_integration' => 'FULL-HAND INTEGRATION',
    _ => band.replaceAll('_', ' ').toUpperCase(),
  };
}

/// Progress for one section derived from path nodes.
class CourseSectionProgress {
  /// Creates section progress.
  const CourseSectionProgress({
    required this.section,
    required this.completed,
    required this.total,
    required this.isCurrent,
    required this.isUnlocked,
  });

  final CourseSection section;
  final int completed;
  final int total;
  final bool isCurrent;
  final bool isUnlocked;

  double get fraction => total == 0 ? 0 : (completed / total).clamp(0, 1);

  int get percent => (fraction * 100).round();
}

/// Section id whose lessons should appear on the Home path.
///
/// Prefers an explicit [focusedSectionId] (from JUMP HERE) when that section
/// still has nodes; otherwise the section containing the next lesson, then
/// the first node on the map.
String? resolveHomePathSectionId(
  CourseHomeSnapshot snapshot, {
  String? focusedSectionId,
}) {
  if (focusedSectionId != null) {
    final stillPresent = snapshot.nodes.any(
      (node) => node.sectionId == focusedSectionId,
    );
    if (stillPresent) return focusedSectionId;
  }
  final nextSectionId = snapshot.nextNode?.sectionId;
  if (nextSectionId != null) return nextSectionId;
  if (snapshot.nodes.isEmpty) return null;
  return snapshot.nodes.first.sectionId;
}

/// Nodes for a single section on the Home path (empty when [sectionId] is null).
List<CourseMapNode> homePathNodesForSection(
  List<CourseMapNode> nodes,
  String? sectionId,
) {
  if (sectionId == null) return const [];
  return [
    for (final node in nodes)
      if (node.sectionId == sectionId) node,
  ];
}

/// Builds [CourseSectionProgress] rows from a Home snapshot.
List<CourseSectionProgress> buildSectionProgress(
  CourseHomeSnapshot snapshot,
) {
  final completedIds = <String>{};
  for (final node in snapshot.nodes) {
    if (node.state == CourseNodeState.completed ||
        node.state == CourseNodeState.mastered) {
      completedIds.add(node.lessonId);
    }
  }
  final currentSectionId = snapshot.nextNode?.sectionId;
  final rows = <CourseSectionProgress>[];
  for (final section in snapshot.sections) {
    var total = 0;
    var done = 0;
    var anyAvailable = false;
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        total += 1;
        if (completedIds.contains(lesson.id)) done += 1;
      }
    }
    for (final node in snapshot.nodes) {
      if (node.sectionId != section.id) continue;
      if (node.state != CourseNodeState.locked) {
        anyAvailable = true;
        break;
      }
    }
    rows.add(
      CourseSectionProgress(
        section: section,
        completed: done,
        total: total,
        isCurrent: section.id == currentSectionId,
        isUnlocked: anyAvailable || done > 0,
      ),
    );
  }
  return rows;
}

/// Full-screen sheet listing every course section with jump targets.
class CourseSectionPickerSheet extends StatelessWidget {
  /// Creates the sheet.
  const CourseSectionPickerSheet({
    super.key,
    required this.rows,
    required this.onJump,
    this.scrollController,
  });

  final List<CourseSectionProgress> rows;
  final void Function(CourseSectionProgress row) onJump;
  final ScrollController? scrollController;

  /// Presents the sheet and returns the chosen section id, if any.
  static Future<String?> show(
    BuildContext context, {
    required CourseHomeSnapshot snapshot,
  }) {
    final rows = buildSectionProgress(snapshot);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (context, controller) {
            return CourseSectionPickerSheet(
              rows: rows,
              scrollController: controller,
              onJump: (row) => Navigator.of(context).pop(row.section.id),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.slateDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sections',
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.slate),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final row = rows[index];
                return _SectionCard(
                  row: row,
                  onJump: () => onJump(row),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.row, required this.onJump});

  final CourseSectionProgress row;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context) {
    final section = row.section;
    final accent = unitBannerColorForSection(section.order);
    final unlocked = row.isUnlocked;

    return Semantics(
      button: true,
      label:
          'Section ${section.order}, ${section.title}, ${row.percent} percent complete',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: unlocked ? onJump : null,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: row.isCurrent
                    ? accent.withValues(alpha: 0.7)
                    : AppColors.slateDark,
                width: row.isCurrent ? 1.5 : 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _SpeechBubble(text: section.summary),
                      ),
                      const SizedBox(width: 8),
                      RexMascot(
                        size: 64,
                        mood: row.isCurrent ? RexMood.celebrate : RexMood.calm,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Section ${section.order}',
                              style: GoogleFonts.manrope(
                                color: AppColors.cream,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            experienceBandLabel(section.experienceBand),
                            style: GoogleFonts.manrope(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.title,
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (row.isCurrent) ...[
                        _ProgressTrack(
                          percent: row.percent,
                          accent: accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CURRENT SECTION',
                          style: GoogleFonts.manrope(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ] else
                        TextButton(
                          onPressed: unlocked ? onJump : null,
                          style: TextButton.styleFrom(
                            foregroundColor: unlocked
                                ? accent
                                : AppColors.slate,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            unlocked ? 'JUMP HERE' : 'LOCKED',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateDark),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: AppColors.cream,
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.percent, required this.accent});

  final int percent;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 22,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: AppColors.slateDark),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (percent / 100).clamp(0.0, 1.0),
                      child: Container(color: accent),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.emoji_events_rounded, color: accent, size: 22),
      ],
    );
  }
}
