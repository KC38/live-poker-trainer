/// Resume interrupted attempt card.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Prompts the learner to resume an open attempt.
class CourseResumeCard extends StatelessWidget {
  /// Creates the resume card.
  const CourseResumeCard({
    super.key,
    required this.resume,
    required this.lessonTitle,
    required this.onResume,
  });

  final CourseResumePointer resume;
  final String lessonTitle;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Resume $lessonTitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onResume,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_circle_outline, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resume',
                        style: GoogleFonts.manrope(
                          color: AppColors.goldBright,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lessonTitle,
                        style: GoogleFonts.manrope(
                          color: AppColors.cream,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Activity ${resume.activityIndex + 1}',
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
