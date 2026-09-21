/// Public course catalog models for live cash NLH course v2.
///
/// Mirrors `assets/course/v2/catalog.json` produced by
/// `tools/course/validate_course.mjs`. Private grading lives only on the
/// server bank and must never appear in this tree.
library;

/// Stable production first-lesson id (Section 1 → Cards and the table).
const kFirstCourseLessonId = 'lesson-01-01-01-your-two-cards';

/// Bundled public catalog asset path.
const kCourseCatalogAssetPath = 'assets/course/v2/catalog.json';

/// Soft coaching grades shared with live training.
enum SoftGrade { recommended, strong, reasonable, questionable, clearMistake }

/// Maps wire-format grade strings.
SoftGrade softGradeFromWire(String value) {
  switch (value) {
    case 'recommended':
      return SoftGrade.recommended;
    case 'strong':
      return SoftGrade.strong;
    case 'reasonable':
      return SoftGrade.reasonable;
    case 'questionable':
      return SoftGrade.questionable;
    case 'clear_mistake':
      return SoftGrade.clearMistake;
    default:
      throw FormatException('Unknown soft grade: $value');
  }
}

/// Activity scaffolding stage.
enum ActivityStage {
  explain,
  guided,
  scaffolded,
  unguided,
  checkpoint,
  jumpTest,
}

/// Maps wire-format stage strings.
ActivityStage activityStageFromWire(String value) {
  switch (value) {
    case 'explain':
      return ActivityStage.explain;
    case 'guided':
      return ActivityStage.guided;
    case 'scaffolded':
      return ActivityStage.scaffolded;
    case 'unguided':
      return ActivityStage.unguided;
    case 'checkpoint':
      return ActivityStage.checkpoint;
    case 'jump_test':
      return ActivityStage.jumpTest;
    default:
      throw FormatException('Unknown activity stage: $value');
  }
}

/// Client activity renderer id.
enum ActivityRenderer {
  coachDialogue,
  selectIdentify,
  orderSequence,
  compareRank,
  numericPotPrice,
  pokerActionSizing,
  playerReadClassify,
  authoredMultiStepHand,
  fullTableHandLab,
}

/// Maps wire-format renderer strings.
ActivityRenderer activityRendererFromWire(String value) {
  switch (value) {
    case 'coach_dialogue':
      return ActivityRenderer.coachDialogue;
    case 'select_identify':
      return ActivityRenderer.selectIdentify;
    case 'order_sequence':
      return ActivityRenderer.orderSequence;
    case 'compare_rank':
      return ActivityRenderer.compareRank;
    case 'numeric_pot_price':
      return ActivityRenderer.numericPotPrice;
    case 'poker_action_sizing':
      return ActivityRenderer.pokerActionSizing;
    case 'player_read_classify':
      return ActivityRenderer.playerReadClassify;
    case 'authored_multi_step_hand':
      return ActivityRenderer.authoredMultiStepHand;
    case 'full_table_hand_lab':
      return ActivityRenderer.fullTableHandLab;
    default:
      throw FormatException('Unknown activity renderer: $value');
  }
}

/// Player type id.
enum CoursePlayerTypeId { callingStation, nit, maniac, tag, lag }

/// Maps wire-format player type ids.
CoursePlayerTypeId coursePlayerTypeIdFromWire(String value) {
  switch (value) {
    case 'calling_station':
      return CoursePlayerTypeId.callingStation;
    case 'nit':
      return CoursePlayerTypeId.nit;
    case 'maniac':
      return CoursePlayerTypeId.maniac;
    case 'tag':
      return CoursePlayerTypeId.tag;
    case 'lag':
      return CoursePlayerTypeId.lag;
    default:
      throw FormatException('Unknown player type: $value');
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw.map((e) => e.toString()).toList(growable: false);
}

/// Rex coach media line.
class CoachMediaRef {
  /// Creates a media ref.
  const CoachMediaRef({
    required this.id,
    required this.kind,
    required this.text,
    this.assetPath,
    this.altText,
  });

  /// Stable media id.
  final String id;

  /// Media kind (`dialogue`, `demonstration`, `hint`).
  final String kind;

  /// Short Rex sentence.
  final String text;

  /// Optional asset path.
  final String? assetPath;

  /// Accessibility alternate text.
  final String? altText;

  /// Parses JSON.
  factory CoachMediaRef.fromJson(Map<String, dynamic> json) {
    return CoachMediaRef(
      id: json['id'] as String,
      kind: json['kind'] as String,
      text: json['text'] as String,
      assetPath: json['assetPath'] as String?,
      altText: json['altText'] as String?,
    );
  }
}

/// Public choice (no grading).
class CourseChoice {
  /// Creates a choice.
  const CourseChoice({
    required this.id,
    required this.label,
    this.accessibilityText,
    this.action,
    this.amountBb,
  });

  /// Choice id.
  final String id;

  /// Display label.
  final String label;

  /// Accessibility text.
  final String? accessibilityText;

  /// Optional poker action.
  final String? action;

  /// Optional sizing in big blinds.
  final double? amountBb;

  /// Parses JSON.
  factory CourseChoice.fromJson(Map<String, dynamic> json) {
    return CourseChoice(
      id: json['id'] as String,
      label: json['label'] as String,
      accessibilityText: json['accessibilityText'] as String?,
      action: json['action'] as String?,
      amountBb: (json['amountBb'] as num?)?.toDouble(),
    );
  }
}

/// Authored multi-step hand street.
class CourseHandStep {
  /// Creates a hand step.
  const CourseHandStep({
    required this.id,
    required this.street,
    required this.prompt,
    this.accessibilityText,
    this.choices = const <CourseChoice>[],
  });

  /// Step id.
  final String id;

  /// Street label.
  final String street;

  /// Prompt.
  final String prompt;

  /// Accessibility summary.
  final String? accessibilityText;

  /// Public choices (no grading).
  final List<CourseChoice> choices;

  /// Parses JSON.
  factory CourseHandStep.fromJson(Map<String, dynamic> json) {
    final choices = <CourseChoice>[];
    final raw = json['choices'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          choices.add(CourseChoice.fromJson(item));
        } else if (item is Map) {
          choices.add(CourseChoice.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CourseHandStep(
      id: json['id'] as String,
      street: json['street'] as String,
      prompt: json['prompt'] as String,
      accessibilityText: json['accessibilityText'] as String?,
      choices: List.unmodifiable(choices),
    );
  }
}

/// Public activity node.
class CourseActivity {
  /// Creates an activity.
  const CourseActivity({
    required this.id,
    required this.order,
    required this.stage,
    required this.renderer,
    required this.estimatedSeconds,
    required this.accessibilityText,
    required this.acceptedGrades,
    this.lifeLossEligible = false,
    this.objectives = const <String>[],
    this.playerTypeRefs = const <CoursePlayerTypeId>[],
    this.coachMedia = const <CoachMediaRef>[],
    this.prompt,
    this.choices = const <CourseChoice>[],
    this.sequenceItems = const <CourseChoice>[],
    this.numericQuestion,
    this.numericUnit,
    this.handLabSpecId,
    this.handSteps = const <CourseHandStep>[],
  });

  /// Activity id.
  final String id;

  /// Order within the lesson.
  final int order;

  /// Stage.
  final ActivityStage stage;

  /// Renderer.
  final ActivityRenderer renderer;

  /// Estimated duration.
  final int estimatedSeconds;

  /// Accessibility summary.
  final String accessibilityText;

  /// Accepted soft grades.
  final List<SoftGrade> acceptedGrades;

  /// Server-only life policy; absent in client assets.
  final bool lifeLossEligible;

  /// Objective strings.
  final List<String> objectives;

  /// Player type refs.
  final List<CoursePlayerTypeId> playerTypeRefs;

  /// Coach media.
  final List<CoachMediaRef> coachMedia;

  /// Prompt text.
  final String? prompt;

  /// Choices.
  final List<CourseChoice> choices;

  /// Sequence / rank items.
  final List<CourseChoice> sequenceItems;

  /// Public numeric question.
  final String? numericQuestion;

  /// Numeric unit.
  final String? numericUnit;

  /// Server hand-lab id reference.
  final String? handLabSpecId;

  /// Authored multi-step streets (public choices only).
  final List<CourseHandStep> handSteps;

  /// Hint media lines for this activity.
  List<CoachMediaRef> get hintMedia =>
      coachMedia.where((m) => m.kind == 'hint').toList(growable: false);

  /// Primary Rex dialogue/demonstration line.
  ///
  /// Hints never count — showing hint text as the coach line spoils the
  /// interaction before the learner taps Hint.
  CoachMediaRef? get primaryCoachLine {
    for (final media in coachMedia) {
      if (media.kind == 'dialogue' || media.kind == 'demonstration') {
        return media;
      }
    }
    return null;
  }

  /// Parses JSON.
  factory CourseActivity.fromJson(Map<String, dynamic> json) {
    final grades = _stringList(
      json['acceptedGrades'],
    ).map(softGradeFromWire).toList(growable: false);
    final playerTypes = _stringList(
      json['playerTypeRefs'],
    ).map(coursePlayerTypeIdFromWire).toList(growable: false);
    final media = <CoachMediaRef>[];
    final rawMedia = json['coachMedia'];
    if (rawMedia is List) {
      for (final item in rawMedia) {
        if (item is Map<String, dynamic>) {
          media.add(CoachMediaRef.fromJson(item));
        } else if (item is Map) {
          media.add(CoachMediaRef.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final choices = <CourseChoice>[];
    final rawChoices = json['choices'];
    if (rawChoices is List) {
      for (final item in rawChoices) {
        if (item is Map<String, dynamic>) {
          choices.add(CourseChoice.fromJson(item));
        } else if (item is Map) {
          choices.add(CourseChoice.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final sequenceItems = <CourseChoice>[];
    final rawSeq = json['sequenceItems'];
    if (rawSeq is List) {
      for (final item in rawSeq) {
        if (item is Map<String, dynamic>) {
          sequenceItems.add(CourseChoice.fromJson(item));
        } else if (item is Map) {
          sequenceItems.add(
            CourseChoice.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final numeric = json['numericPrompt'];
    String? numericQuestion;
    String? numericUnit;
    if (numeric is Map) {
      numericQuestion = numeric['question']?.toString();
      numericUnit = numeric['unit']?.toString();
    }
    final handSteps = <CourseHandStep>[];
    final rawSteps = json['handSteps'];
    if (rawSteps is List) {
      for (final item in rawSteps) {
        if (item is Map<String, dynamic>) {
          handSteps.add(CourseHandStep.fromJson(item));
        } else if (item is Map) {
          handSteps.add(
            CourseHandStep.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return CourseActivity(
      id: json['id'] as String,
      order: json['order'] as int,
      stage: activityStageFromWire(json['stage'] as String),
      renderer: activityRendererFromWire(json['renderer'] as String),
      estimatedSeconds: json['estimatedSeconds'] as int,
      accessibilityText: json['accessibilityText'] as String,
      acceptedGrades: grades,
      lifeLossEligible: json['lifeLossEligible'] as bool? ?? false,
      objectives: _stringList(json['objectives']),
      playerTypeRefs: playerTypes,
      coachMedia: List.unmodifiable(media),
      prompt: json['prompt'] as String?,
      choices: List.unmodifiable(choices),
      sequenceItems: List.unmodifiable(sequenceItems),
      numericQuestion: numericQuestion,
      numericUnit: numericUnit,
      handLabSpecId: json['handLabSpecId'] as String?,
      handSteps: List.unmodifiable(handSteps),
    );
  }
}

/// Lesson node.
class CourseLesson {
  /// Creates a lesson.
  const CourseLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    required this.objectives,
    required this.prerequisites,
    required this.remediationLessonIds,
    required this.estimatedMinutes,
    required this.difficultyBand,
    required this.playerTypeRefs,
    required this.introducesPlayerTypes,
    required this.activities,
  });

  /// Lesson id.
  final String id;

  /// Order.
  final int order;

  /// Title.
  final String title;

  /// Summary.
  final String summary;

  /// Objectives.
  final List<String> objectives;

  /// Prerequisites.
  final List<String> prerequisites;

  /// Remediation lesson ids.
  final List<String> remediationLessonIds;

  /// Minutes.
  final int estimatedMinutes;

  /// Difficulty 1–5.
  final int difficultyBand;

  /// Player type refs.
  final List<CoursePlayerTypeId> playerTypeRefs;

  /// Player types introduced here.
  final List<CoursePlayerTypeId> introducesPlayerTypes;

  /// Activities.
  final List<CourseActivity> activities;

  /// Parses JSON.
  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    final activities = <CourseActivity>[];
    final raw = json['activities'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          activities.add(CourseActivity.fromJson(item));
        } else if (item is Map) {
          activities.add(
            CourseActivity.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return CourseLesson(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String,
      objectives: _stringList(json['objectives']),
      prerequisites: _stringList(json['prerequisites']),
      remediationLessonIds: _stringList(json['remediationLessonIds']),
      estimatedMinutes: json['estimatedMinutes'] as int,
      difficultyBand: json['difficultyBand'] as int,
      playerTypeRefs: _stringList(
        json['playerTypeRefs'],
      ).map(coursePlayerTypeIdFromWire).toList(growable: false),
      introducesPlayerTypes: _stringList(
        json['introducesPlayerTypes'],
      ).map(coursePlayerTypeIdFromWire).toList(growable: false),
      activities: List.unmodifiable(activities),
    );
  }
}

/// Unit.
class CourseUnit {
  /// Creates a unit.
  const CourseUnit({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    required this.lessons,
  });

  /// Unit id.
  final String id;

  /// Order.
  final int order;

  /// Title.
  final String title;

  /// Summary.
  final String summary;

  /// Lessons.
  final List<CourseLesson> lessons;

  /// Parses JSON.
  factory CourseUnit.fromJson(Map<String, dynamic> json) {
    final lessons = <CourseLesson>[];
    final raw = json['lessons'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          lessons.add(CourseLesson.fromJson(item));
        } else if (item is Map) {
          lessons.add(CourseLesson.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CourseUnit(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String,
      lessons: List.unmodifiable(lessons),
    );
  }
}

/// Section.
class CourseSection {
  /// Creates a section.
  const CourseSection({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    required this.experienceBand,
    required this.units,
  });

  /// Section id.
  final String id;

  /// Order.
  final int order;

  /// Title.
  final String title;

  /// Summary.
  final String summary;

  /// Experience band.
  final String experienceBand;

  /// Units.
  final List<CourseUnit> units;

  /// Parses JSON.
  factory CourseSection.fromJson(Map<String, dynamic> json) {
    final units = <CourseUnit>[];
    final raw = json['units'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          units.add(CourseUnit.fromJson(item));
        } else if (item is Map) {
          units.add(CourseUnit.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CourseSection(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String,
      experienceBand: json['experienceBand'] as String,
      units: List.unmodifiable(units),
    );
  }
}

/// Player type catalog entry.
class CoursePlayerType {
  /// Creates a player type.
  const CoursePlayerType({
    required this.id,
    required this.label,
    required this.introducedByLessonId,
    this.summary,
  });

  /// Id.
  final CoursePlayerTypeId id;

  /// Label.
  final String label;

  /// Introducing lesson id.
  final String introducedByLessonId;

  /// Summary.
  final String? summary;

  /// Parses JSON.
  factory CoursePlayerType.fromJson(Map<String, dynamic> json) {
    return CoursePlayerType(
      id: coursePlayerTypeIdFromWire(json['id'] as String),
      label: json['label'] as String,
      introducedByLessonId: json['introducedByLessonId'] as String,
      summary: json['summary'] as String?,
    );
  }
}

/// Public client catalog.
class CourseCatalog {
  /// Creates a catalog.
  const CourseCatalog({
    required this.catalogVersion,
    required this.minClientVersion,
    required this.scope,
    required this.coachId,
    required this.contentChecksum,
    required this.playerTypes,
    required this.sections,
  });

  /// Catalog semver.
  final String catalogVersion;

  /// Minimum app version.
  final String minClientVersion;

  /// Scope (`live_cash_nlh`).
  final String scope;

  /// Coach id (`rex`).
  final String coachId;

  /// Shared checksum with the server bank.
  final String contentChecksum;

  /// Player types.
  final List<CoursePlayerType> playerTypes;

  /// Sections.
  final List<CourseSection> sections;

  /// Depth-first lesson ids in catalog order.
  List<String> get lessonIdsInOrder {
    final ids = <String>[];
    for (final section in sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          ids.add(lesson.id);
        }
      }
    }
    return List.unmodifiable(ids);
  }

  /// Depth-first activity ids in catalog order.
  List<String> get activityIdsInOrder {
    final ids = <String>[];
    for (final section in sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            ids.add(activity.id);
          }
        }
      }
    }
    return List.unmodifiable(ids);
  }

  /// Parses JSON.
  factory CourseCatalog.fromJson(Map<String, dynamic> json) {
    final playerTypes = <CoursePlayerType>[];
    final rawTypes = json['playerTypes'];
    if (rawTypes is List) {
      for (final item in rawTypes) {
        if (item is Map<String, dynamic>) {
          playerTypes.add(CoursePlayerType.fromJson(item));
        } else if (item is Map) {
          playerTypes.add(
            CoursePlayerType.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final sections = <CourseSection>[];
    final rawSections = json['sections'];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          sections.add(CourseSection.fromJson(item));
        } else if (item is Map) {
          sections.add(CourseSection.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CourseCatalog(
      catalogVersion: json['catalogVersion'] as String,
      minClientVersion: json['minClientVersion'] as String,
      scope: json['scope'] as String,
      coachId: json['coachId'] as String,
      contentChecksum: json['contentChecksum'] as String,
      playerTypes: List.unmodifiable(playerTypes),
      sections: List.unmodifiable(sections),
    );
  }

  /// Section that contains [lessonId], if the catalog publishes it.
  CourseSection? sectionForLesson(String lessonId) {
    for (final section in sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          if (lesson.id == lessonId) return section;
        }
      }
    }
    return null;
  }

  /// Finds a lesson by id.
  CourseLesson? lessonById(String lessonId) {
    for (final section in sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          if (lesson.id == lessonId) return lesson;
        }
      }
    }
    return null;
  }

  /// Finds an activity by id across the catalog.
  CourseActivity? activityById(String activityId) {
    for (final section in sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            if (activity.id == activityId) return activity;
          }
        }
      }
    }
    return null;
  }

  /// Activities for [lessonId] sorted by order.
  List<CourseActivity> activitiesForLesson(String lessonId) {
    final lesson = lessonById(lessonId);
    if (lesson == null) return const <CourseActivity>[];
    final activities = [...lesson.activities]
      ..sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(activities);
  }
}
