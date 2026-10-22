/// The felt deal runs once per step. Answer taps, Nice!/Oops!, Hint, undo
/// and rebuilds must never replay it (Kushal, nightly-2026-10-21c: tapping
/// NARROWER on the Section 4 jump step dealt every card again).
///
/// Why earlier fixes never held: every widget test runs with
/// [CardDealPace.instant] (the test binding forces it), so a remounted felt
/// "re-dealt" in zero time and no assertion could see it. Each past fix
/// (LPT-642, #1548, #1582, #1912) froze one remount path; the next layout
/// (PR #2952 drill scenes) opened another. These tests run the real lesson
/// runner with real deal pacing (scaled down), let the deal finish, then
/// answer and watch every frame: no dealt card may disappear, fade in again,
/// or have the coach say "Watch the deal." until the step changes.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/core/deal/felt_deal_ledger.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/dealt_card_reveal.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';

/// Starts [lessonId] at [activityId]; grades by the server bank.
class _StepService extends CourseService {
  _StepService(this.catalog, this.activityId, this.recommended) : super();

  final CourseCatalog catalog;
  final String activityId;
  final Map<String, String> recommended;
  Duration latency = const Duration(milliseconds: 300);

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    int? streakGoalDays,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
    bool restoreHeartOnComplete = false,
  }) async {
    final acts = catalog.activitiesForLesson(lessonId);
    final index = acts.indexWhere((a) => a.id == activityId);
    return StartCourseLessonResult(
      attempt: CourseAttemptSnapshot(
        attemptId: 'attempt-1',
        lessonId: lessonId,
        catalogVersion: catalog.catalogVersion,
        status: 'in_progress',
        activityIndex: index,
        currentActivityId: activityId,
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: index,
      ),
      resume: CourseResumePointer(
        attemptId: 'attempt-1',
        lessonId: lessonId,
        activityId: activityId,
        activityIndex: index,
      ),
      duplicate: false,
    );
  }

  @override
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    await Future<void>.delayed(latency);
    final accepted = choiceId == recommended[activityId];
    final lessonId = _lessonOf(catalog, activityId);
    final acts = catalog.activitiesForLesson(lessonId);
    final index = acts.indexWhere((a) => a.id == activityId);
    return SubmitCourseStepResult(
      attemptId: attemptId,
      activityId: activityId,
      grade: accepted ? SoftGrade.recommended : SoftGrade.questionable,
      feedback: accepted ? 'Nice.' : 'Not quite.',
      accepted: accepted,
      lifeLost: !accepted,
      livesRemaining: accepted ? 3 : 2,
      xpAwarded: accepted ? 10 : 0,
      remediationRequired: false,
      resume: CourseResumePointer(
        attemptId: attemptId,
        lessonId: lessonId,
        activityId: accepted && index + 1 < acts.length
            ? acts[index + 1].id
            : activityId,
        activityIndex: accepted ? index + 1 : index,
      ),
      duplicate: false,
    );
  }
}

String _lessonOf(CourseCatalog catalog, String activityId) {
  for (final s in catalog.sections) {
    for (final u in s.units) {
      for (final l in u.lessons) {
        if (l.activities.any((a) => a.id == activityId)) return l.id;
      }
    }
  }
  throw StateError(activityId);
}

Map<String, String> _recommendedIds() {
  final bank =
      jsonDecode(File('content/course/v2/course.json').readAsStringSync());
  final out = <String, String>{};
  void walk(Object? node) {
    if (node is List) {
      node.forEach(walk);
    } else if (node is Map) {
      final choices = node['choices'];
      if (node['id'] is String && choices is List) {
        for (final c in choices) {
          if (c is Map && (c['grading'] as Map?)?['grade'] == 'recommended') {
            out[node['id'] as String] = c['id'] as String;
          }
        }
      }
      node.values.forEach(walk);
    }
  }

  walk(bank);
  return out;
}

Widget _app(Widget child, CourseCatalog catalog) => ProviderScope(
  overrides: [
    soundServiceProvider.overrideWithValue(SoundService.silent()),
    courseCatalogProvider.overrideWith((ref) async => catalog),
    analyticsServiceProvider.overrideWithValue(
      AnalyticsService(enabled: false),
    ),
    onboardingControllerProvider.overrideWith(
      (ref) => OnboardingController(null),
    ),
    heroIdentityProvider.overrideWithValue(const HeroIdentity()),
  ],
  child: MaterialApp(theme: buildPokerTheme(), home: child),
);


typedef _Step = ({String lessonId, CourseActivity activity});

List<_Step> _steps(CourseCatalog catalog) => [
  for (final section in catalog.sections)
    for (final unit in section.units)
      for (final lesson in unit.lessons)
        for (final activity in lesson.activities)
          (lessonId: lesson.id, activity: activity),
];

/// Cards currently painted by [DealtCardReveal] and their opacities.
List<double> _cardOpacities(WidgetTester tester) => [
  for (final w in tester.widgetList<AnimatedOpacity>(
    find.descendant(
      of: find.byType(DealtCardReveal),
      matching: find.byType(AnimatedOpacity),
    ),
  ))
    w.opacity,
];

bool _coachSaysWatch() => find
    .textContaining('watch the deal', findRichText: true)
    .evaluate()
    .isNotEmpty ||
    find.textContaining('Watch the deal', findRichText: true)
        .evaluate()
        .isNotEmpty;

/// Boots [step] in the lesson runner and lets the deal finish.
/// Returns false when the step has no felt.
Future<bool> _bootAndDeal(
  WidgetTester tester,
  CourseCatalog catalog,
  _Step step,
  Map<String, String> recommended,
) async {
  await tester.pumpWidget(
    _app(
      LessonRunnerScreen(
        key: UniqueKey(),
        lessonId: step.lessonId,
        courseService: _StepService(catalog, step.activity.id, recommended),
        startRequestId: 'deal-once-${step.activity.id}',
      ),
      catalog,
    ),
  );
  for (var i = 0; i < 60 && find.byType(LessonFrameScope).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  // Scaled pacing: a full six-max deal + board settles well inside 3 s.
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return find.byType(FeltTableView).evaluate().isNotEmpty;
}

LessonActivityController _controller(WidgetTester tester) => tester
    .widget<LessonFrameScope>(find.byType(LessonFrameScope))
    .activityController!;

/// Watches [frames] frames after [action]; returns the first replay seen.
Future<String?> _watch(
  WidgetTester tester, {
  required int before,
  required Future<void> Function() action,
  int frames = 25,
}) async {
  await action();
  for (var f = 0; f < frames; f++) {
    await tester.pump(const Duration(milliseconds: 60));
    if (find.byType(FeltTableView).evaluate().isEmpty) {
      return null; // Step left the table (e.g. Continue) — new deal is fine.
    }
    final opacities = _cardOpacities(tester);
    if (opacities.length < before) {
      return 'frame $f: ${opacities.length}/$before dealt cards visible';
    }
    final fading = opacities.where((o) => o < 1).length;
    if (fading > 0) return 'frame $f: $fading card(s) fading in again';
    if (_coachSaysWatch()) return 'frame $f: coach says "Watch the deal."';
  }
  return null;
}

/// Answers through the same path a tap uses: drill buttons when present,
/// else the controller (seat / card / action taps call selectChoice too).
Future<void> _answer(
  WidgetTester tester,
  CourseActivity activity,
  String choiceId,
) async {
  final index = activity.choices.indexWhere((c) => c.id == choiceId);
  final button = find.byKey(ValueKey<String>('drill-option-$index'));
  if (index >= 0 && button.evaluate().isNotEmpty) {
    await tester.tap(button, warnIfMissed: false);
    return;
  }
  _controller(tester).selectChoice(choiceId, autoSubmit: true);
}

Future<String?> _checkStep(
  WidgetTester tester,
  CourseCatalog catalog,
  _Step step,
  Map<String, String> recommended, {
  required bool wrong,
}) async {
  if (!await _bootAndDeal(tester, catalog, step, recommended)) return null;
  final activity = step.activity;
  final right = recommended[activity.id];
  final choiceId = wrong
      ? activity.choices
            .map((c) => c.id)
            .firstWhere((id) => id != right, orElse: () => '')
      : (right ?? '');
  final before = _cardOpacities(tester).length;
  if (before == 0) return null; // Table without a deal (pre-deal scene).
  final unsettled = _cardOpacities(tester).where((o) => o < 1).length;
  if (unsettled > 0) return 'deal did not settle ($unsettled fading)';

  // Hint (when offered) must not replay the deal.
  final hint = find.byTooltip('Hint');
  if (hint.evaluate().isNotEmpty) {
    final problem = await _watch(
      tester,
      before: before,
      frames: 10,
      action: () => tester.tap(hint, warnIfMissed: false),
    );
    if (problem != null) return 'Hint: $problem';
  }
  // A rebuild of the whole runner (setState above the stage) must not.
  final rebuilt = await _watch(
    tester,
    before: before,
    frames: 5,
    action: () async => _controller(tester).notifyListeners(),
  );
  if (rebuilt != null) return 'rebuild: $rebuilt';
  if (choiceId.isEmpty) return null;
  final answered = await _watch(
    tester,
    before: before,
    action: () => _answer(tester, activity, choiceId),
  );
  if (answered != null) {
    return '${wrong ? 'wrong' : 'right'} answer: $answered';
  }
  // Undo after Oops! (when offered) keeps the same hand on the felt.
  final undo = find.byTooltip('Undo');
  if (wrong && undo.evaluate().isNotEmpty) {
    final undone = await _watch(
      tester,
      before: before,
      frames: 10,
      action: () => tester.tap(undo, warnIfMissed: false),
    );
    if (undone != null) return 'undo: $undone';
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CourseCatalog catalog;
  late Map<String, String> recommended;
  final problems = <String, String>{};
  var checked = 0;

  setUpAll(() async {
    final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
    catalog = CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    recommended = _recommendedIds();
  });

  setUp(() {
    // Real pacing (the binding would force instant), 10x faster.
    CardDealPace.debugInstant = false;
    CardDealPace.testScale = 0.1;
  });

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  Future<void> run(WidgetTester tester, String id, {required bool wrong}) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final step = _steps(catalog).firstWhere((s) => s.activity.id == id);
    final problem = await _checkStep(
      tester,
      catalog,
      step,
      recommended,
      wrong: wrong,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    checked += 1;
    if (problem != null) problems['$id ${wrong ? 'wrong' : 'right'}'] = problem;
  }

  // Kushal's step plus one of each table step type. CI runs these.
  const representatives = <String>[
    'act-04-10-02-jump-range', // jump drill, NARROWER / ANY TWO (reported)
    'act-04-10-02-jump-spr', // number drill (SPR 4 / 2 / 8)
    'act-03-01-01-guided', // guided pot math drill
    'act-05-05-01-checkpoint', // checkpoint drill
    'act-04-06-02-guided', // player-type classify
    'act-03-03-01-guided', // outs card picker on the table
    'act-01-01-03-unguided-when', // blinds timing (pre-deal table)
    'act-01-04-01-unguided-end', // street end
    'act-01-01-01-scaffolded-private', // hole-card region tap
    'act-02-02-01-guided-pair', // hand family drill
    'act-05-05-01-scaffolded', // action buttons (turn probe)
    'act-05-01-01-scaffolded', // preflop action buttons, multiway
    'act-06-11-03-scaffolded', // action buttons vs player type
  ];

  for (final id in representatives) {
    for (final wrong in [true, false]) {
      testWidgets('deal runs once: $id (${wrong ? 'wrong' : 'right'})', (
        tester,
      ) async {
        problems.clear();
        await run(tester, id, wrong: wrong);
        expect(problems, isEmpty, reason: problems.toString());
      });
    }
  }

  // Full sweep over every lesson step (local / nightly: DEAL_ONCE_SWEEP=1).
  final sweep = Platform.environment['DEAL_ONCE_SWEEP'] == '1';
  // DEAL_ONCE_RAW=1 turns the ledger off: lists layouts that still remount.
  final raw = Platform.environment['DEAL_ONCE_RAW'] == '1';
  testWidgets('deal runs once on every lesson table step', (tester) async {
    FeltDealLedger.debugDisableResume = raw;
    addTearDown(() => FeltDealLedger.debugDisableResume = false);
    for (final step in _steps(catalog)) {
      for (final wrong in [true, false]) {
        await run(tester, step.activity.id, wrong: wrong);
      }
    }
    // ignore: avoid_print
    print('deal-once sweep: $checked runs, ${problems.length} problems');
    for (final e in problems.entries) {
      // ignore: avoid_print
      print('DEAL-ONCE ${e.key} :: ${e.value}');
    }
    expect(problems, isEmpty, reason: problems.entries.join('\n'));
  }, skip: !sweep);
}
