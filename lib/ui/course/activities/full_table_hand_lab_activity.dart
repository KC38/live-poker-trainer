/// Lesson-scoped full-table hand lab decision (public choices only).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Minimal hand-lab shell: felt framing + authored decision choices.
///
/// Full scripted lab playback is Plan 10; here we grade the public decision
/// through the existing course callables without starting Live Training.
class FullTableHandLabActivity extends StatelessWidget {
  /// Creates the activity.
  const FullTableHandLabActivity({
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
    if (activity.choices.isEmpty) {
      return UnsupportedHandLabNotice(activity: activity);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.feltLight, AppColors.feltDark],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.feltBorder),
          ),
          child: Column(
            children: [
              Text(
                'Hand lab',
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                activity.prompt ?? activity.accessibilityText,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (activity.handLabSpecId != null) ...[
                const SizedBox(height: 6),
                Text(
                  activity.handLabSpecId!,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.slate,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
      ],
    );
  }
}

/// Recoverable empty hand-lab state (no crash).
class UnsupportedHandLabNotice extends StatelessWidget {
  /// Creates the notice.
  const UnsupportedHandLabNotice({super.key, required this.activity});

  final CourseActivity activity;

  @override
  Widget build(BuildContext context) {
    return RexCoachLine(
      text:
          'Hand lab "${activity.handLabSpecId ?? activity.id}" is not playable '
          'in this build. Skip is not available — leave and resume later.',
    );
  }
}
