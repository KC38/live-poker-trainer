/// Home: course path, status, and Rex coach.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course_table_return.dart';
import 'package:live_poker_trainer/models/live_access.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/widgets/heart_refill_sheet.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';
import 'package:live_poker_trainer/ui/home/course_section_picker.dart';
import 'package:live_poker_trainer/ui/home/course_status_bar.dart';
import 'package:live_poker_trainer/ui/home/rex_coach_card.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

/// Home tab — interactive live-cash course path.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the Home course root.
  const HomeScreen({super.key, this.focusRequests});

  /// Incremented by [AppShell] when the Home tab is selected or re-tapped so
  /// the path scrolls back to the next / in-progress lesson.
  final ValueNotifier<int>? focusRequests;

  /// Section 7 capstone. Tapping it opens the calibration table, not activity 0.
  static const calibrationLessonId = 'lesson-07-11-01-live-warmup-prep';

  /// Result node resumed after the calibration hand. Not the lesson id.
  static const calibrationResultNodeId =
      'result:lesson-07-11-01-live-warmup-prep';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _loggedStatus;
  final GlobalKey _focusLessonKey = GlobalKey();
  String? _autoFocusedLessonId;
  bool _autoFocusQueued = false;
  int _lastFocusRequest = 0;

  @override
  void initState() {
    super.initState();
    _lastFocusRequest = widget.focusRequests?.value ?? 0;
    widget.focusRequests?.addListener(_onFocusRequest);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusRequests != widget.focusRequests) {
      oldWidget.focusRequests?.removeListener(_onFocusRequest);
      _lastFocusRequest = widget.focusRequests?.value ?? 0;
      widget.focusRequests?.addListener(_onFocusRequest);
    }
  }

  @override
  void dispose() {
    widget.focusRequests?.removeListener(_onFocusRequest);
    super.dispose();
  }

  void _onFocusRequest() {
    final tick = widget.focusRequests?.value ?? 0;
    if (tick == _lastFocusRequest) return;
    _lastFocusRequest = tick;
    unawaited(_scrollFocusLessonIntoView(force: true));
  }

  void _scheduleAutoFocus(CourseHomeSnapshot snapshot) {
    if (snapshot.status != CourseHomeLoadStatus.ready) return;
    final id = snapshot.nextLessonId;
    if (id == null || id == _autoFocusedLessonId || _autoFocusQueued) return;
    _autoFocusQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFocusQueued = false;
      if (!mounted) return;
      final focusId =
          ref.read(courseHomeProvider).asData?.value.nextLessonId;
      if (focusId == null || focusId == _autoFocusedLessonId) return;
      _autoFocusedLessonId = focusId;
      unawaited(_scrollFocusLessonIntoView());
    });
  }

  Future<void> _scrollFocusLessonIntoView({bool force = false}) async {
    final target = _focusLessonKey.currentContext;
    if (target == null) return;
    if (!force && _isFocusLessonComfortablyVisible(target)) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.28,
    );
  }

  /// True when the focus lesson is already on the first screen of the path.
  bool _isFocusLessonComfortablyVisible(BuildContext target) {
    final renderObject = target.findRenderObject();
    if (renderObject == null || !renderObject.attached) return false;
    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) return true;
    final scrollable = Scrollable.maybeOf(target);
    final pixels = scrollable?.position.pixels ?? 0;
    final reveal = viewport.getOffsetToReveal(renderObject, 0.28).offset;
    if (pixels <= 1 && reveal <= 160) return true;
    return (reveal - pixels).abs() < 48;
  }

  @override
  Widget build(BuildContext context) {
    final asyncHome = ref.watch(courseHomeProvider);

    ref.listen(courseHomeProvider, (prev, next) {
      final snap = next.asData?.value;
      if (snap == null) return;
      final status = snap.status.name;
      if (_loggedStatus != status) {
        _loggedStatus = status;
        unawaited(
          ref.read(analyticsServiceProvider).logHomeCourseView(status: status),
        );
      }
      _scheduleAutoFocus(snap);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [Color(0xFF1A2E28), AppColors.bgMid, AppColors.bgDark],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: asyncHome.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading:
                () => const _HomeMessage(
                  title: 'Loading course',
                  body: 'Pulling your path from the server…',
                ),
            error:
                (error, _) => _HomeMessage(
                  title: 'Could not load course',
                  body: error.toString(),
                  actionLabel: 'Retry',
                  onAction:
                      () => ref.read(courseHomeProvider.notifier).refresh(),
                ),
            data: (snapshot) {
              _scheduleAutoFocus(snapshot);
              return _HomeBody(
                snapshot: snapshot,
                focusLessonKey: _focusLessonKey,
                onRetry:
                    () => ref.read(courseHomeProvider.notifier).refresh(),
                onNodeTap: (node) => _onNodeTap(snapshot, node),
                onOpenSections: () => _openSections(snapshot),
                onHeartsTap: () => _onHeartsTap(snapshot),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openSections(CourseHomeSnapshot snapshot) async {
    final sectionId = await CourseSectionPickerSheet.show(
      context,
      snapshot: snapshot,
    );
    if (!mounted || sectionId == null) return;
    final key = _HomeBody.sectionKeyFor(sectionId);
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _onHeartsTap(CourseHomeSnapshot snapshot) async {
    final action = await showHeartRefillSheet(
      context: context,
      livesRemaining: snapshot.hearts,
      livesMax: snapshot.livesMax,
      gems: snapshot.gems,
      livesNextRefillAtMs: snapshot.livesNextRefillAtMs,
      adClaimsRemainingToday: snapshot.adClaimsRemainingToday,
      nextAdClaimAtMs: snapshot.nextAdClaimAtMs,
    );
    if (!mounted || action == null) return;
    switch (action) {
      case HeartRefillAction.practice:
        final practiceId = _practiceLessonId(snapshot);
        if (practiceId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complete a lesson first, then practice to earn a heart.'),
            ),
          );
          return;
        }
        _openLesson(practiceId);
      case HeartRefillAction.ad:
        try {
          final service = ref.read(courseServiceProvider);
          final result = await watchAdAndClaimHeart(
            context: context,
            service: service,
          );
          if (!mounted) return;
          final home = ref.read(courseHomeProvider.notifier);
          home.applyHeartRefill(result);
          unawaited(home.refresh());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.heartsRestored > 0
                    ? 'Heart restored! ${result.livesRemaining}/${result.livesMax}'
                    : 'Hearts updated.',
              ),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$error')),
          );
        }
      case HeartRefillAction.gems:
        try {
          final service = ref.read(courseServiceProvider);
          final result = await service.refillHearts(
            method: 'gems',
            idempotencyKey: CourseService.newRequestKey('heart_gems'),
          );
          if (!mounted) return;
          final home = ref.read(courseHomeProvider.notifier);
          home.applyHeartRefill(result);
          unawaited(home.refresh());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hearts refilled! ${result.livesRemaining}/${result.livesMax}',
              ),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$error')),
          );
        }
    }
  }

  String? _practiceLessonId(CourseHomeSnapshot snapshot) {
    for (final node in snapshot.nodes.reversed) {
      if (node.state == CourseNodeState.completed) {
        return node.lessonId;
      }
    }
    return snapshot.resume?.lessonId ?? snapshot.nextLessonId;
  }

  void _onNodeTap(CourseHomeSnapshot snapshot, CourseMapNode node) {
    final analytics = ref.read(analyticsServiceProvider);
    if (node.state == CourseNodeState.locked) {
      unawaited(analytics.logHomeNodeLockedTap(lessonId: node.lessonId));
      final message = node.lockReason ?? 'Finish the previous lesson first.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (!snapshot.startsEnabled && node.state != CourseNodeState.active) {
      unawaited(analytics.logHomeNodeLockedTap(lessonId: node.lessonId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New course attempts are paused.')),
      );
      return;
    }
    unawaited(
      analytics.logHomeNodeOpen(
        lessonId: node.lessonId,
        nodeState: node.state.name,
      ),
    );
    if (snapshot.resume?.lessonId == node.lessonId) {
      unawaited(analytics.logHomeResume(lessonId: node.lessonId));
    }
    _openLesson(node.lessonId);
  }

  void _openLesson(String lessonId) {
    if (lessonId == HomeScreen.calibrationLessonId) {
      unawaited(_openCalibrationWarmUp(lessonId));
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            // Shell map lessons must not take the guest first-lesson
            // save-progress path — that early-return left Continue spinning
            // forever after Suits and ranks (and every later lesson).
            builder:
                (_) => LessonRunnerScreen(
                  lessonId: lessonId,
                  embeddedInShell: true,
                ),
          ),
        )
        .then((_) {
          if (!mounted) return;
          unawaited(ref.read(courseHomeProvider.notifier).refresh());
        });
  }

  Future<void> _openCalibrationWarmUp(String lessonId) async {
    ref
        .read(gameControllerProvider.notifier)
        .prepareTraining(
          courseContext: const CourseLiveContext(
            courseHandId: '',
            kind: 'calibration',
            lessonId: HomeScreen.calibrationLessonId,
            returnNodeId: HomeScreen.calibrationResultNodeId,
            scaffolding: 'reduced',
            rexPrompt: 'Calibration: one clean plan, less scaffolding.',
          ),
        );
    if (!mounted) return;
    final pop = await Navigator.of(context).push<Object?>(
      softFadeRoute(
        const PokerTableScreen(),
        name: AnalyticsScreens.pokerTable,
      ),
    );
    if (!mounted) return;
    final exit = pop is CourseTableReturn ? pop : null;
    if (exit != null && exit.completed) {
      await _presentCalibrationResult(exit, lessonId);
    }
    if (!mounted) return;
    unawaited(ref.read(courseHomeProvider.notifier).refresh());
  }

  /// Finished hands land on the lesson result. Unfinished exits never call this.
  Future<void> _presentCalibrationResult(
    CourseTableReturn exit,
    String lessonId,
  ) async {
    final sessionId = exit.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The calibration hand was not saved, so the lesson stays incomplete.',
          ),
        ),
      );
      return;
    }
    final snapshot = ref.read(courseHomeProvider).asData?.value;
    final title = _titleForLesson(snapshot, lessonId);
    try {
      final result = await ref
          .read(courseServiceProvider)
          .completeCalibrationWarmUp(
            lessonId: lessonId,
            sessionId: sessionId,
            catalogVersion: snapshot?.catalogVersion,
          );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder:
              (_) => LessonResultScreen(
                lessonTitle: title,
                result: result,
              ),
        ),
      );
    } on CourseServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the calibration lesson.')),
      );
    }
  }

  String _titleForLesson(CourseHomeSnapshot? snapshot, String lessonId) {
    final nodes = snapshot?.nodes ?? const <CourseMapNode>[];
    for (final node in nodes) {
      if (node.lessonId == lessonId) return node.title;
    }
    return 'Lesson';
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({
    required this.snapshot,
    required this.onRetry,
    required this.onNodeTap,
    required this.onOpenSections,
    required this.onHeartsTap,
    required this.focusLessonKey,
  });

  final CourseHomeSnapshot snapshot;
  final VoidCallback onRetry;
  final void Function(CourseMapNode node) onNodeTap;
  final VoidCallback onOpenSections;
  final VoidCallback onHeartsTap;
  final GlobalKey focusLessonKey;

  static final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{};
  static final Map<String, GlobalKey> _unitKeys = <String, GlobalKey>{};

  static GlobalKey sectionKeyFor(String sectionId) {
    return _sectionKeys.putIfAbsent(sectionId, GlobalKey.new);
  }

  static GlobalKey unitKeyFor(String unitId) {
    return _unitKeys.putIfAbsent(unitId, GlobalKey.new);
  }

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final GlobalKey _bannerKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  int _activeUnitIndex = 0;
  String? _unitsSignature;
  List<CoursePathUnit> _units = const [];

  CourseHomeSnapshot get snapshot => widget.snapshot;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reconcileUnits();
  }

  @override
  void didUpdateWidget(covariant _HomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.snapshot.nodes, snapshot.nodes) ||
        !identical(oldWidget.snapshot.sections, snapshot.sections)) {
      _reconcileUnits();
    }
  }

  void _reconcileUnits() {
    final sectionOrders = <String, int>{
      for (final section in snapshot.sections) section.id: section.order,
    };
    final units = coursePathUnits(
      nodes: snapshot.nodes,
      sectionOrders: sectionOrders,
    );
    final signature = units.map((u) => u.unitId).join('|');
    if (_unitsSignature == signature) {
      _units = units;
      return;
    }
    _unitsSignature = signature;
    _units = units;
    _activeUnitIndex = _initialUnitIndex(units, snapshot.nodes);
  }

  void _onScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncActiveUnit(_units);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (snapshot.status != CourseHomeLoadStatus.ready) {
      return _HomeMessage(
        title: _titleFor(snapshot.status),
        body:
            snapshot.errorMessage ??
            snapshot.rexLine ??
            'Course path unavailable.',
        actionLabel:
            snapshot.status == CourseHomeLoadStatus.disabled ? null : 'Retry',
        onAction:
            snapshot.status == CourseHomeLoadStatus.disabled
                ? null
                : widget.onRetry,
        rexLine: snapshot.rexLine,
      );
    }

    final sectionOrders = <String, int>{
      for (final section in snapshot.sections) section.id: section.order,
    };
    final sectionKeys = <String, GlobalKey>{
      for (final section in snapshot.sections)
        section.id: _HomeBody.sectionKeyFor(section.id),
    };
    final units = _units;
    final unitKeys = <String, GlobalKey>{
      for (final unit in units) unit.unitId: _HomeBody.unitKeyFor(unit.unitId),
    };
    final activeIndex =
        units.isEmpty ? 0 : _activeUnitIndex.clamp(0, units.length - 1);
    final activeUnit = units.isEmpty ? null : units[activeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: CourseStatusBar(
            streak: snapshot.streak,
            gems: snapshot.gems,
            hearts: snapshot.hearts,
            lifetimeXp: snapshot.lifetimeXp,
            acceptedAccuracy: snapshot.acceptedAccuracy,
            onCourseTap: widget.onOpenSections,
            onHeartsTap: widget.onHeartsTap,
          ),
        ),
        if (activeUnit != null)
          Padding(
            key: _bannerKey,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: CourseUnitBanner(
                key: ValueKey<String>(activeUnit.unitId),
                sectionOrder: activeUnit.sectionOrder,
                unitOrder: activeUnit.unitOrder,
                unitTitle: activeUnit.unitTitle,
                color: activeUnit.bannerColor,
                onTap: widget.onOpenSections,
              ),
            ),
          ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            key: const PageStorageKey<String>('home_course_scroll'),
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (snapshot.rexLine != null &&
                        !snapshot.nodes.any((node) => node.isNext)) ...[
                      const SizedBox(height: 2),
                      RexCoachCard(
                        line: snapshot.rexLine!,
                        onContinue:
                            snapshot.nextLessonId == null ||
                                    !snapshot.startsEnabled
                                ? null
                                : () {
                                  final next = snapshot.nextNode;
                                  if (next == null) return;
                                  widget.onNodeTap(next);
                                },
                        continueLabel: 'Start',
                      ),
                    ],
                    const SizedBox(height: 4),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 280),
                sliver: SliverToBoxAdapter(
                  child: CoursePathView(
                    nodes: snapshot.nodes,
                    onNodeTap: widget.onNodeTap,
                    sectionOrders: sectionOrders,
                    sectionKeys: sectionKeys,
                    unitKeys: unitKeys,
                    focusLessonKey: widget.focusLessonKey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _initialUnitIndex(
    List<CoursePathUnit> units,
    List<CourseMapNode> nodes,
  ) {
    for (final node in nodes) {
      if (!node.isNext) continue;
      final index = units.indexWhere((unit) => unit.unitId == node.unitId);
      if (index >= 0) return index;
    }
    return 0;
  }

  void _syncActiveUnit(List<CoursePathUnit> units) {
    if (units.isEmpty) return;
    final bannerContext = _bannerKey.currentContext;
    final bannerBox = bannerContext?.findRenderObject() as RenderBox?;
    if (bannerBox == null || !bannerBox.hasSize) return;

    final threshold =
        bannerBox.localToGlobal(Offset(0, bannerBox.size.height)).dy + 12;

    var active = 0;
    for (var i = 0; i < units.length; i++) {
      final key = _HomeBody.unitKeyFor(units[i].unitId);
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= threshold) {
        active = i;
      }
    }

    if (active != _activeUnitIndex) {
      setState(() => _activeUnitIndex = active);
    }
  }

  static String _titleFor(CourseHomeLoadStatus status) {
    return switch (status) {
      CourseHomeLoadStatus.disabled => 'Course unavailable',
      CourseHomeLoadStatus.offline => 'You are offline',
      CourseHomeLoadStatus.staleCatalog => 'Update required',
      CourseHomeLoadStatus.empty => 'No lessons yet',
      CourseHomeLoadStatus.error => 'Could not load course',
      CourseHomeLoadStatus.loading => 'Loading course',
      CourseHomeLoadStatus.ready => 'Home',
    };
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.rexLine,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? rexLine;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.goldBright),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (rexLine != null && rexLine != body) ...[
              const SizedBox(height: 16),
              RexCoachCard(line: rexLine!),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bgDark,
                  minimumSize: const Size(160, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
