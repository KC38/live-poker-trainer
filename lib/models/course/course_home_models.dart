/// Home course map models and pure next-node / lock derivation.
library;

import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Mastery threshold for the "mastered" node state.
const kCourseMasteryThreshold = 0.85;

/// Visual / semantic kind of a Home path node.
enum CourseNodeKind { lesson, practice, checkpoint, reward, jumpTest, handLab }

/// Durable path node state (server completion + catalog prerequisites).
enum CourseNodeState {
  locked,
  available,
  active,
  completed,
  mastered,
  reviewDue,
}

/// One node on the Home winding path.
class CourseMapNode {
  /// Creates a map node.
  const CourseMapNode({
    required this.lessonId,
    required this.title,
    required this.summary,
    required this.kind,
    required this.state,
    required this.sectionId,
    required this.sectionTitle,
    required this.unitId,
    required this.unitTitle,
    required this.isNext,
    this.lockReason,
    this.mastery = 0,
  });

  final String lessonId;
  final String title;
  final String summary;
  final CourseNodeKind kind;
  final CourseNodeState state;
  final String sectionId;
  final String sectionTitle;
  final String unitId;
  final String unitTitle;
  final bool isNext;
  final String? lockReason;
  final double mastery;

  /// Accessibility label for icon-only nodes.
  String get semanticsLabel {
    final kindLabel = switch (kind) {
      CourseNodeKind.lesson => 'Lesson',
      CourseNodeKind.practice => 'Practice',
      CourseNodeKind.checkpoint => 'Checkpoint',
      CourseNodeKind.reward => 'Reward',
      CourseNodeKind.jumpTest => 'Jump test',
      CourseNodeKind.handLab => 'Hand lab',
    };
    final stateLabel = switch (state) {
      CourseNodeState.locked => 'locked',
      CourseNodeState.available => 'available',
      CourseNodeState.active => 'in progress',
      CourseNodeState.completed => 'completed',
      CourseNodeState.mastered => 'mastered',
      CourseNodeState.reviewDue => 'review due',
    };
    final next = isNext ? ', next up' : '';
    return '$kindLabel: $title, $stateLabel$next';
  }
}

/// Availability / load outcome for Home.
enum CourseHomeLoadStatus {
  ready,
  loading,
  disabled,
  offline,
  staleCatalog,
  empty,
  error,
}

/// Aggregated Home snapshot for the course map.
class CourseHomeSnapshot {
  /// Creates a snapshot.
  const CourseHomeSnapshot({
    required this.status,
    required this.nodes,
    required this.sections,
    this.streak = 0,
    this.lifetimeXp = 0,
    this.acceptedAccuracy = 0,
    this.nextLessonId,
    this.resume,
    this.rexLine,
    this.errorMessage,
    this.catalogVersion,
    this.serverCatalogVersion,
    this.startsEnabled = true,
  });

  final CourseHomeLoadStatus status;
  final List<CourseMapNode> nodes;
  final List<CourseSection> sections;
  final int streak;
  final int lifetimeXp;
  final double acceptedAccuracy;
  final String? nextLessonId;
  final CourseResumePointer? resume;
  final String? rexLine;
  final String? errorMessage;
  final String? catalogVersion;
  final String? serverCatalogVersion;

  /// When false, Home must not offer a new attempt. An in-progress node can
  /// still be resumed.
  final bool startsEnabled;

  CourseMapNode? get nextNode {
    final id = nextLessonId;
    if (id == null) return null;
    for (final node in nodes) {
      if (node.lessonId == id) return node;
    }
    return null;
  }
}

/// Server course profile fields needed by Home (subset of getCourseState).
class CourseProfileView {
  /// Creates a profile view.
  const CourseProfileView({
    required this.lifetimeXp,
    required this.currentStreak,
    required this.acceptedAccuracy,
    required this.completedLessonIds,
    required this.masteryByLessonId,
    required this.catalogVersion,
    this.resume,
    this.recommendedLessonId,
  });

  final int lifetimeXp;
  final int currentStreak;
  final double acceptedAccuracy;
  final List<String> completedLessonIds;
  final Map<String, double> masteryByLessonId;
  final String catalogVersion;
  final CourseResumePointer? resume;
  final String? recommendedLessonId;

  /// Parses getCourseState `profile` map.
  factory CourseProfileView.fromJson(Map<String, dynamic> json) {
    final masteryRaw = json['masteryByLessonId'];
    final mastery = <String, double>{};
    if (masteryRaw is Map) {
      for (final entry in masteryRaw.entries) {
        mastery[entry.key.toString()] = (entry.value as num?)?.toDouble() ?? 0;
      }
    }
    final completedRaw = json['completedLessonIds'];
    final completed = <String>[];
    if (completedRaw is List) {
      for (final item in completedRaw) {
        completed.add(item.toString());
      }
    }
    CourseResumePointer? resume;
    final resumeRaw = json['resume'];
    if (resumeRaw is Map) {
      final map = Map<String, dynamic>.from(resumeRaw);
      final attemptId = map['attemptId']?.toString() ?? '';
      final lessonId = map['lessonId']?.toString() ?? '';
      if (attemptId.isNotEmpty && lessonId.isNotEmpty) {
        resume = CourseResumePointer(
          attemptId: attemptId,
          lessonId: lessonId,
          activityId: map['activityId']?.toString() ?? '',
          activityIndex: (map['activityIndex'] as num?)?.toInt() ?? 0,
        );
      }
    }
    return CourseProfileView(
      lifetimeXp: (json['lifetimeXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      acceptedAccuracy: (json['acceptedAccuracy'] as num?)?.toDouble() ?? 0,
      completedLessonIds: List.unmodifiable(completed),
      masteryByLessonId: Map.unmodifiable(mastery),
      catalogVersion: json['catalogVersion']?.toString() ?? '',
      resume: resume,
      recommendedLessonId: json['recommendedLessonId']?.toString(),
    );
  }
}

/// Derives [CourseNodeKind] from public lesson content.
CourseNodeKind deriveCourseNodeKind(CourseLesson lesson) {
  final stages = lesson.activities.map((a) => a.stage).toSet();
  final renderers = lesson.activities.map((a) => a.renderer).toSet();
  if (stages.contains(ActivityStage.jumpTest)) {
    return CourseNodeKind.jumpTest;
  }
  if (renderers.contains(ActivityRenderer.fullTableHandLab)) {
    return CourseNodeKind.handLab;
  }
  if (lesson.id.contains('-reward-') ||
      lesson.title.toLowerCase().contains('reward')) {
    return CourseNodeKind.reward;
  }
  if (stages.length == 1 && stages.contains(ActivityStage.checkpoint)) {
    return CourseNodeKind.checkpoint;
  }
  if (lesson.id.contains('-practice-') ||
      lesson.title.toLowerCase().contains('practice')) {
    return CourseNodeKind.practice;
  }
  if (lesson.activities.isNotEmpty &&
      lesson.activities.last.stage == ActivityStage.checkpoint &&
      !stages.contains(ActivityStage.explain) &&
      !stages.contains(ActivityStage.guided)) {
    return CourseNodeKind.checkpoint;
  }
  return CourseNodeKind.lesson;
}

/// Builds Home map nodes from catalog + server state.
CourseHomeSnapshot buildCourseHomeSnapshot({
  required CourseCatalog catalog,
  required CourseFlags flags,
  required bool available,
  CourseProfileView? profile,
  CourseAttemptSnapshot? openAttempt,
  List<String> reviewLessonIds = const [],
  String? errorMessage,
  bool offline = false,
}) {
  if (offline) {
    return CourseHomeSnapshot(
      status: CourseHomeLoadStatus.offline,
      nodes: const [],
      sections: catalog.sections,
      errorMessage: errorMessage ?? 'You appear to be offline.',
      rexLine: 'Reconnect when you can. Your progress waits on the server.',
    );
  }
  if (errorMessage != null && profile == null) {
    return CourseHomeSnapshot(
      status: CourseHomeLoadStatus.error,
      nodes: const [],
      sections: catalog.sections,
      errorMessage: errorMessage,
      rexLine: 'Something glitched on my side. Retry when you are ready.',
    );
  }
  if (!available || !flags.courseEnabled) {
    return CourseHomeSnapshot(
      status: CourseHomeLoadStatus.disabled,
      nodes: const [],
      sections: catalog.sections,
      errorMessage: 'Course is temporarily unavailable.',
      rexLine: 'Course path is paused. Live Training and Profile still work.',
      catalogVersion: catalog.catalogVersion,
      serverCatalogVersion: flags.catalogVersion,
    );
  }
  if (flags.catalogVersion.isNotEmpty &&
      flags.catalogVersion != catalog.catalogVersion) {
    return CourseHomeSnapshot(
      status: CourseHomeLoadStatus.staleCatalog,
      nodes: const [],
      sections: catalog.sections,
      errorMessage: 'Update the app to continue the course path.',
      rexLine: 'Your app catalog is behind the server. Update, then come back.',
      catalogVersion: catalog.catalogVersion,
      serverCatalogVersion: flags.catalogVersion,
    );
  }

  final completed = profile?.completedLessonIds.toSet() ?? <String>{};
  final mastery = profile?.masteryByLessonId ?? const <String, double>{};
  final reviews = reviewLessonIds.toSet();
  final activeLessonId =
      openAttempt?.lessonId ??
      (profile?.resume != null ? profile!.resume!.lessonId : null);
  final startsOpen = flags.courseStartsEnabled;
  final lessonTitles = <String, String>{};
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        lessonTitles[lesson.id] = lesson.title;
      }
    }
  }

  final nodes = <CourseMapNode>[];
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        final kind = deriveCourseNodeKind(lesson);
        final masteryScore = mastery[lesson.id] ?? 0;
        final isComplete = completed.contains(lesson.id);
        late final CourseNodeState state;
        String? lockReason;
        if (activeLessonId == lesson.id) {
          state = CourseNodeState.active;
        } else if (!startsOpen) {
          if (isComplete && masteryScore >= kCourseMasteryThreshold) {
            state = CourseNodeState.mastered;
          } else if (isComplete) {
            state = CourseNodeState.completed;
          } else {
            state = CourseNodeState.locked;
            lockReason = 'New course attempts are paused.';
          }
        } else if (reviews.contains(lesson.id)) {
          state = CourseNodeState.reviewDue;
        } else if (isComplete && masteryScore >= kCourseMasteryThreshold) {
          state = CourseNodeState.mastered;
        } else if (isComplete) {
          state = CourseNodeState.completed;
        } else {
          final missing = lesson.prerequisites
              .where((id) => !completed.contains(id))
              .toList(growable: false);
          if (missing.isEmpty) {
            state = CourseNodeState.available;
          } else {
            state = CourseNodeState.locked;
            final firstMissing = missing.first;
            final title = lessonTitles[firstMissing] ?? 'the previous lesson';
            lockReason = 'Finish "$title" first.';
          }
        }
        nodes.add(
          CourseMapNode(
            lessonId: lesson.id,
            title: lesson.title,
            summary: lesson.summary,
            kind: kind,
            state: state,
            sectionId: section.id,
            sectionTitle: section.title,
            unitId: unit.id,
            unitTitle: unit.title,
            isNext: false,
            lockReason: lockReason,
            mastery: masteryScore,
          ),
        );
      }
    }
  }

  if (nodes.isEmpty) {
    return CourseHomeSnapshot(
      status: CourseHomeLoadStatus.empty,
      nodes: const [],
      sections: catalog.sections,
      streak: profile?.currentStreak ?? 0,
      lifetimeXp: profile?.lifetimeXp ?? 0,
      acceptedAccuracy: profile?.acceptedAccuracy ?? 0,
      rexLine:
          'No lessons published yet. Check back after the next content wave.',
      catalogVersion: catalog.catalogVersion,
      serverCatalogVersion: flags.catalogVersion,
      startsEnabled: startsOpen,
    );
  }

  final nextId =
      startsOpen
          ? _selectNextLessonId(
            nodes: nodes,
            activeLessonId: activeLessonId,
            recommendedLessonId: profile?.recommendedLessonId,
          )
          : (activeLessonId != null &&
                  nodes.any((node) => node.lessonId == activeLessonId)
              ? activeLessonId
              : null);
  final withNext = [
    for (final node in nodes)
      CourseMapNode(
        lessonId: node.lessonId,
        title: node.title,
        summary: node.summary,
        kind: node.kind,
        state: node.state,
        sectionId: node.sectionId,
        sectionTitle: node.sectionTitle,
        unitId: node.unitId,
        unitTitle: node.unitTitle,
        isNext: node.lessonId == nextId,
        lockReason: node.lockReason,
        mastery: node.mastery,
      ),
  ];

  final resume =
      openAttempt != null
          ? CourseResumePointer(
            attemptId: openAttempt.attemptId,
            lessonId: openAttempt.lessonId,
            activityId: openAttempt.currentActivityId,
            activityIndex: openAttempt.activityIndex,
          )
          : (profile?.resume != null &&
                  activeLessonId == profile!.resume!.lessonId
              ? profile.resume
              : null);

  return CourseHomeSnapshot(
    status: CourseHomeLoadStatus.ready,
    nodes: List.unmodifiable(withNext),
    sections: catalog.sections,
    streak: profile?.currentStreak ?? 0,
    lifetimeXp: profile?.lifetimeXp ?? 0,
    acceptedAccuracy: profile?.acceptedAccuracy ?? 0,
    nextLessonId: nextId,
    resume: resume,
    rexLine:
        !startsOpen && resume == null
            ? 'New lessons are paused. Live Training and Profile still work.'
            : _rexLineFor(
              nodes: withNext,
              nextId: nextId,
              hasResume: resume != null,
            ),
    catalogVersion: catalog.catalogVersion,
    serverCatalogVersion: flags.catalogVersion,
    startsEnabled: startsOpen,
  );
}

String? _selectNextLessonId({
  required List<CourseMapNode> nodes,
  required String? activeLessonId,
  required String? recommendedLessonId,
}) {
  if (activeLessonId != null &&
      nodes.any((n) => n.lessonId == activeLessonId)) {
    return activeLessonId;
  }
  for (final node in nodes) {
    if (node.state == CourseNodeState.reviewDue) return node.lessonId;
  }
  if (recommendedLessonId != null) {
    for (final node in nodes) {
      if (node.lessonId == recommendedLessonId &&
          (node.state == CourseNodeState.available ||
              node.state == CourseNodeState.active)) {
        return node.lessonId;
      }
    }
  }
  for (final node in nodes) {
    if (node.state == CourseNodeState.available) return node.lessonId;
  }
  return null;
}

String _rexLineFor({
  required List<CourseMapNode> nodes,
  required String? nextId,
  required bool hasResume,
}) {
  if (hasResume) {
    return 'Pick up where you left off. The table is still waiting.';
  }
  CourseMapNode? next;
  for (final node in nodes) {
    if (node.lessonId == nextId) {
      next = node;
      break;
    }
  }
  if (next == null) {
    return 'Solid work. Review a node or open Live Training when you are ready.';
  }
  return switch (next.kind) {
    CourseNodeKind.jumpTest =>
      'Jump checks skip fluff. Show what you already know.',
    CourseNodeKind.handLab =>
      'Full table next. Watch seats, stacks, and who acts first.',
    CourseNodeKind.checkpoint =>
      'Checkpoint time. Transfer the skill without the training wheels.',
    CourseNodeKind.reward =>
      'Take the win. Specific habits beat generic praise.',
    CourseNodeKind.practice =>
      'Reps beat theory. One clean decision at a time.',
    CourseNodeKind.lesson =>
      'You are next to act on the path. One short lesson, then move.',
  };
}
