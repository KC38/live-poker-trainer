/// Curriculum catalog models for the learning platform.
///
/// Mirrors [content/curriculum/v1/schemas/curriculum.schema.json]. Generated
/// catalogs must not be hand-edited; load from the versioned JSON asset.
library;

/// Lesson presentation format.
enum LessonFormat {
  /// Short teaching content.
  concept,

  /// Curated spot or multi-decision drill.
  decisionDrill,

  /// Worked alternative / review.
  workedReview,

  /// Off-table judgment scenario.
  scenario,

  /// Unseen gated test.
  assessment,

  /// Full-hand server-authoritative lab.
  handLab,
}

/// Whether the live engine can grade this lesson today.
enum SimulationClaim {
  /// Deterministic engine + reviewed scenarios available.
  engineSupported,

  /// Teach conceptually until engine support ships.
  conceptualOnly,
}

/// Maps wire-format strings to [LessonFormat].
LessonFormat lessonFormatFromWire(String value) {
  switch (value) {
    case 'concept':
      return LessonFormat.concept;
    case 'decision_drill':
      return LessonFormat.decisionDrill;
    case 'worked_review':
      return LessonFormat.workedReview;
    case 'scenario':
      return LessonFormat.scenario;
    case 'assessment':
      return LessonFormat.assessment;
    case 'hand_lab':
      return LessonFormat.handLab;
    default:
      throw FormatException('Unknown lesson format: $value');
  }
}

/// Maps wire-format strings to [SimulationClaim].
SimulationClaim simulationClaimFromWire(String value) {
  switch (value) {
    case 'engine_supported':
      return SimulationClaim.engineSupported;
    case 'conceptual_only':
      return SimulationClaim.conceptualOnly;
    default:
      throw FormatException('Unknown simulation claim: $value');
  }
}

/// A measurable learning objective.
class CurriculumObjective {
  /// Creates an objective.
  const CurriculumObjective({
    required this.id,
    required this.title,
    required this.tagSelectors,
    required this.difficulty,
  });

  /// Stable objective id.
  final String id;

  /// Human-readable title.
  final String title;

  /// Deterministic tag selectors for practice matching.
  final Map<String, List<String>> tagSelectors;

  /// Difficulty band 1–5.
  final int difficulty;

  /// Parses a catalog objective map.
  factory CurriculumObjective.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tagSelectors'];
    final tags = <String, List<String>>{};
    if (rawTags is Map) {
      for (final entry in rawTags.entries) {
        final value = entry.value;
        tags[entry.key.toString()] = value is List
            ? value.map((e) => e.toString()).toList(growable: false)
            : const <String>[];
      }
    }
    return CurriculumObjective(
      id: json['id'] as String,
      title: json['title'] as String,
      tagSelectors: Map.unmodifiable(tags),
      difficulty: json['difficulty'] as int,
    );
  }
}

/// A single lesson within a unit.
class CurriculumLesson {
  /// Creates a lesson.
  const CurriculumLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.format,
    required this.objectiveIds,
    required this.estimatedMinutes,
    required this.mediaIds,
    required this.exerciseRefs,
    required this.simulationClaims,
    required this.prerequisites,
    required this.remediationLessonIds,
  });

  /// Stable lesson id.
  final String id;

  /// Order within the unit (1-based).
  final int order;

  /// Display title.
  final String title;

  /// Lesson format.
  final LessonFormat format;

  /// Linked objective ids.
  final List<String> objectiveIds;

  /// Estimated duration in minutes.
  final int estimatedMinutes;

  /// Media manifest ids.
  final List<String> mediaIds;

  /// Exercise content refs (empty until authored).
  final List<String> exerciseRefs;

  /// Engine support claim.
  final SimulationClaim simulationClaims;

  /// Prerequisite lesson ids.
  final List<String> prerequisites;

  /// Remediation lesson ids.
  final List<String> remediationLessonIds;

  /// Parses a catalog lesson map.
  factory CurriculumLesson.fromJson(Map<String, dynamic> json) {
    List<String> stringList(Object? value) {
      if (value is! List) return const <String>[];
      return value.map((e) => e.toString()).toList(growable: false);
    }

    return CurriculumLesson(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      format: lessonFormatFromWire(json['format'] as String),
      objectiveIds: stringList(json['objectiveIds']),
      estimatedMinutes: json['estimatedMinutes'] as int,
      mediaIds: stringList(json['mediaIds']),
      exerciseRefs: stringList(json['exerciseRefs']),
      simulationClaims:
          simulationClaimFromWire(json['simulationClaims'] as String),
      prerequisites: stringList(json['prerequisites']),
      remediationLessonIds: stringList(json['remediationLessonIds']),
    );
  }
}

/// A unit containing three lessons (teach / drill / checkpoint).
class CurriculumUnit {
  /// Creates a unit.
  const CurriculumUnit({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    required this.objectiveIds,
    required this.lessons,
  });

  /// Stable unit id.
  final String id;

  /// Order within the section.
  final int order;

  /// Display title.
  final String title;

  /// Short summary.
  final String summary;

  /// Linked objective ids.
  final List<String> objectiveIds;

  /// Lessons in this unit.
  final List<CurriculumLesson> lessons;

  /// Parses a catalog unit map.
  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final lessons = rawLessons is List
        ? rawLessons
            .whereType<Map>()
            .map(
              (e) => CurriculumLesson.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList(growable: false)
        : const <CurriculumLesson>[];
    final rawObjectives = json['objectiveIds'];
    return CurriculumUnit(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      objectiveIds: rawObjectives is List
          ? rawObjectives.map((e) => e.toString()).toList(growable: false)
          : const <String>[],
      lessons: lessons,
    );
  }
}

/// A curriculum section.
class CurriculumSection {
  /// Creates a section.
  const CurriculumSection({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    this.milestoneGateId,
    required this.units,
  });

  /// Stable section id.
  final String id;

  /// Order in the path.
  final int order;

  /// Display title.
  final String title;

  /// Short summary.
  final String summary;

  /// Optional milestone gate id.
  final String? milestoneGateId;

  /// Units in this section.
  final List<CurriculumUnit> units;

  /// Parses a catalog section map.
  factory CurriculumSection.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['units'];
    final units = rawUnits is List
        ? rawUnits
            .whereType<Map>()
            .map(
              (e) => CurriculumUnit.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(growable: false)
        : const <CurriculumUnit>[];
    return CurriculumSection(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      milestoneGateId: json['milestoneGateId'] as String?,
      units: units,
    );
  }
}

/// A milestone certification gate.
class MilestoneGate {
  /// Creates a gate.
  const MilestoneGate({
    required this.id,
    required this.title,
    required this.requiredObjectiveIds,
    required this.minDecisionSamples,
    required this.masteryThreshold,
    required this.criticalMistakeCap,
    required this.safetyCritical,
  });

  /// Stable gate id.
  final String id;

  /// Display title.
  final String title;

  /// Objectives that must be covered.
  final List<String> requiredObjectiveIds;

  /// Minimum unseen decisions required.
  final int minDecisionSamples;

  /// Mastery threshold 0–1.
  final double masteryThreshold;

  /// Max allowed critical mistakes.
  final int criticalMistakeCap;

  /// Whether this gate is a safety/integrity gate.
  final bool safetyCritical;

  /// Parses a catalog gate map.
  factory MilestoneGate.fromJson(Map<String, dynamic> json) {
    final rawObjectives = json['requiredObjectiveIds'];
    return MilestoneGate(
      id: json['id'] as String,
      title: json['title'] as String,
      requiredObjectiveIds: rawObjectives is List
          ? rawObjectives.map((e) => e.toString()).toList(growable: false)
          : const <String>[],
      minDecisionSamples: json['minDecisionSamples'] as int,
      masteryThreshold: (json['masteryThreshold'] as num).toDouble(),
      criticalMistakeCap: json['criticalMistakeCap'] as int,
      safetyCritical: json['safetyCritical'] as bool? ?? false,
    );
  }
}

/// Versioned curriculum catalog.
class CurriculumCatalog {
  /// Creates a catalog.
  const CurriculumCatalog({
    required this.catalogVersion,
    required this.minClientVersion,
    required this.sections,
    required this.objectives,
    required this.milestoneGates,
  });

  /// Catalog semver.
  final String catalogVersion;

  /// Minimum client version that may load this catalog.
  final String minClientVersion;

  /// Ordered sections.
  final List<CurriculumSection> sections;

  /// Objective definitions.
  final List<CurriculumObjective> objectives;

  /// Milestone gates.
  final List<MilestoneGate> milestoneGates;

  /// Total unit count.
  int get unitCount =>
      sections.fold(0, (sum, section) => sum + section.units.length);

  /// Total lesson count.
  int get lessonCount => sections.fold(
        0,
        (sum, section) =>
            sum +
            section.units.fold(0, (uSum, unit) => uSum + unit.lessons.length),
      );

  /// Finds a lesson by id, or null.
  CurriculumLesson? lessonById(String id) {
    for (final section in sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          if (lesson.id == id) return lesson;
        }
      }
    }
    return null;
  }

  /// Parses the root catalog JSON.
  factory CurriculumCatalog.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final rawObjectives = json['objectives'];
    final rawGates = json['milestoneGates'];
    return CurriculumCatalog(
      catalogVersion: json['catalogVersion'] as String,
      minClientVersion: json['minClientVersion'] as String,
      sections: rawSections is List
          ? rawSections
              .whereType<Map>()
              .map(
                (e) =>
                    CurriculumSection.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(growable: false)
          : const <CurriculumSection>[],
      objectives: rawObjectives is List
          ? rawObjectives
              .whereType<Map>()
              .map(
                (e) => CurriculumObjective.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(growable: false)
          : const <CurriculumObjective>[],
      milestoneGates: rawGates is List
          ? rawGates
              .whereType<Map>()
              .map(
                (e) => MilestoneGate.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(growable: false)
          : const <MilestoneGate>[],
    );
  }
}
