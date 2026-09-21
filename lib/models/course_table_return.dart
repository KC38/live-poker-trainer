/// How the player left a course-linked live table.
library;

/// Pop result from [PokerTableScreen] when the session is a course hand.
///
/// A finished calibration hand resumes the lesson result node. Leaving before
/// the hand is finished must not mark the lesson complete.
class CourseTableReturn {
  /// Creates a table-exit result.
  const CourseTableReturn({
    required this.completed,
    this.returnNodeId,
    this.lessonId,
    this.sessionId,
  });

  /// True when the hero's hand was finished before leaving.
  final bool completed;

  /// Node to resume. Calibration uses the lesson result, not the lesson id.
  final String? returnNodeId;

  /// Lesson that launched the table, when known.
  final String? lessonId;

  /// Live session id, required to record lesson completion.
  final String? sessionId;
}
