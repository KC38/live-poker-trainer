/// Recoverable unsupported / failed activity renderer.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

/// Shown when a renderer is missing or fails to build.
class UnsupportedActivity extends StatelessWidget {
  /// Creates the fallback.
  const UnsupportedActivity({
    super.key,
    required this.activity,
    required this.controller,
    this.reason = 'This activity type is not supported yet.',
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: reason,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity unavailable',
              style: GoogleFonts.manrope(
                color: AppColors.warning,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Renderer: ${activity.renderer.name}\nId: ${activity.id}',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.slate,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
