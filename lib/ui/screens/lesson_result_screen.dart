/// Lesson completion summary.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Shown after [completeCourseLesson] succeeds.
class LessonResultScreen extends StatelessWidget {
  /// Creates the result screen.
  const LessonResultScreen({
    super.key,
    required this.lessonTitle,
    required this.result,
    this.standalone = true,
  });

  final String lessonTitle;
  final CompleteCourseLessonResult result;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lesson complete',
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lessonTitle,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              _StatTile(
                label: 'XP earned',
                value: '+${result.xpAwarded}',
              ),
              _StatTile(
                label: 'Mastery',
                value: '${(result.mastery * 100).round()}%',
              ),
              _StatTile(
                label: 'Study streak',
                value: '${result.streak}',
              ),
              _StatTile(
                label: 'Accepted accuracy',
                value: '${(result.acceptedAccuracy * 100).round()}%',
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (standalone) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bgDark,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
