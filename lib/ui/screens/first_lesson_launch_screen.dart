/// Standalone launch route for the production first lesson.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';

/// Minimal entry surface so onboarding can run the first lesson without Home.
class FirstLessonLaunchScreen extends StatelessWidget {
  /// Creates the launch screen.
  const FirstLessonLaunchScreen({
    super.key,
    this.lessonId = kFirstCourseLessonId,
  });

  /// Defaults to the production first lesson.
  final String lessonId;

  /// Pushes the standalone first-lesson runner above [context].
  static Future<void> open(
    BuildContext context, {
    String lessonId = kFirstCourseLessonId,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FirstLessonLaunchScreen(lessonId: lessonId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rex',
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your two cards',
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A short interactive lesson. No Home map required.',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => LessonRunnerScreen(
                        lessonId: lessonId,
                        embeddedInShell: false,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bgDark,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Start lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
