/// Standalone launch route for the production first lesson.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';

/// Minimal entry surface so onboarding can run the first lesson without Home.
///
/// Lands directly in [LessonRunnerScreen] — no intermediate "Start lesson" CTA.
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
        builder:
            (_) => LessonRunnerScreen(
              lessonId: lessonId,
              embeddedInShell: false,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LessonRunnerScreen(
      lessonId: lessonId,
      embeddedInShell: false,
    );
  }
}
