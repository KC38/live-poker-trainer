/// Static multiple-choice exercise models aligned with Functions exercise bank.
library;

/// A labeled answer choice.
class ExerciseChoice {
  /// Creates a choice.
  const ExerciseChoice({required this.id, required this.text});

  /// Stable choice id (e.g. `a`).
  final String id;

  /// Display text.
  final String text;

  /// Parses a choice map.
  factory ExerciseChoice.fromJson(Map<String, dynamic> json) {
    return ExerciseChoice(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }
}

/// One multiple-choice question (client-safe or full authoring form).
class ExerciseQuestion {
  /// Creates a question.
  const ExerciseQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
    this.correctChoiceId,
    this.explanation,
  });

  /// Stable question id.
  final String id;

  /// Prompt shown to the learner.
  final String prompt;

  /// Answer choices.
  final List<ExerciseChoice> choices;

  /// Correct choice id when present (authoring / local fallback only).
  final String? correctChoiceId;

  /// Optional explanation.
  final String? explanation;

  /// Parses a question map.
  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'];
    final choices = rawChoices is List
        ? rawChoices
            .whereType<Map>()
            .map((e) => ExerciseChoice.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <ExerciseChoice>[];
    return ExerciseQuestion(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      choices: choices,
      correctChoiceId: json['correctChoiceId'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  /// Client-safe copy without the answer key.
  ExerciseQuestion get publicView => ExerciseQuestion(
        id: id,
        prompt: prompt,
        choices: choices,
        explanation: explanation,
      );
}

/// Bundled or server-returned exercise set for one lesson.
class LessonExercisesPayload {
  /// Creates a payload.
  const LessonExercisesPayload({
    required this.lessonId,
    required this.title,
    required this.questions,
    this.attemptId,
    this.catalogVersion,
  });

  /// Lesson id matching the curriculum catalog.
  final String lessonId;

  /// Display title.
  final String title;

  /// Ordered questions (preferably without correctChoiceId).
  final List<ExerciseQuestion> questions;

  /// Server attempt id when started via callable.
  final String? attemptId;

  /// Catalog version from startLesson.
  final String? catalogVersion;

  /// Parses a JSON exercise document (`questions` array).
  factory LessonExercisesPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['questions'] ?? json['exercises'];
    final questions = raw is List
        ? raw
            .whereType<Map>()
            .map(
              (e) => ExerciseQuestion.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(growable: false)
        : const <ExerciseQuestion>[];
    return LessonExercisesPayload(
      lessonId: (json['lessonId'] ?? json['id']) as String,
      title: json['title'] as String? ??
          (json['lessonId'] ?? json['id']) as String,
      questions: questions,
      attemptId: json['attemptId'] as String?,
      catalogVersion: json['catalogVersion'] as String?,
    );
  }

  /// Builds a payload from a startLesson callable response.
  factory LessonExercisesPayload.fromStartLesson(
    Map<String, dynamic> json,
  ) {
    final rawQuestions = json['questions'];
    final questions = rawQuestions is List
        ? rawQuestions
            .whereType<Map>()
            .map(
              (e) => ExerciseQuestion.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(growable: false)
        : const <ExerciseQuestion>[];
    return LessonExercisesPayload(
      lessonId: json['lessonId'] as String,
      title: json['title'] as String? ?? json['lessonId'] as String,
      questions: questions,
      attemptId: json['attemptId'] as String?,
      catalogVersion: json['catalogVersion'] as String?,
    );
  }

  /// Public-only questions for display.
  LessonExercisesPayload get publicView => LessonExercisesPayload(
        lessonId: lessonId,
        title: title,
        questions: questions.map((q) => q.publicView).toList(growable: false),
        attemptId: attemptId,
        catalogVersion: catalogVersion,
      );
}

/// Hardcoded first-lesson id for the guest-first vertical slice.
const String kFirstLessonId = 'lesson-00-01-01-cash-vs-tournaments';

/// Bundled exercise JSON for [lessonId], including answer keys for offline grading.
String lessonExercisesAssetPath(String lessonId) =>
    'assets/curriculum/exercises/$lessonId.json';

/// Asset path for the first authored lesson.
const String kFirstLessonExercisesAssetPath =
    'assets/curriculum/exercises/$kFirstLessonId.json';
