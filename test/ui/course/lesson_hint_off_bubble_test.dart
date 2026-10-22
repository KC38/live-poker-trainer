/// Disabled Hint explains itself: haptic + a friendly reason bubble anchored
/// to the button (Kushal: hints intentionally off must say why).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hint_off_bubble.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

final _catalog = CourseCatalog.fromJson(
  jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
      as Map<String, dynamic>,
);

Iterable<CourseActivity> get _activities sync* {
  for (final s in _catalog.sections) {
    for (final u in s.units) {
      for (final l in u.lessons) {
        yield* l.activities;
      }
    }
  }
}

CourseActivity _first(bool Function(CourseActivity a) test) =>
    _activities.firstWhere(test);

void main() {
  group('lessonFrameHintOffReason', () {
    test('jump tests, checkpoints and transfers name the test', () {
      expect(
        lessonFrameHintOffReason(
          _first((a) => a.assessmentRole == AssessmentRole.jumpTest),
        ),
        kHintOffJumpTest,
      );
      expect(
        lessonFrameHintOffReason(
          _first((a) => a.assessmentRole == AssessmentRole.checkpoint),
        ),
        kHintOffCheckpoint,
      );
      expect(
        lessonFrameHintOffReason(
          _first((a) => a.assessmentRole == AssessmentRole.transfer),
        ),
        kHintOffTransfer,
      );
    });

    test('cue already on the table says so', () {
      final shown = _first(
        (a) =>
            a.assessmentRole == null &&
            a.renderer != ActivityRenderer.coachDialogue &&
            !lessonFrameNoHintIds.contains(a.id) &&
            lessonFrameHintShownByDefault(a),
      );
      expect(lessonFrameHintOffReason(shown), kHintOffAlreadyShowing);
    });

    test('steps with nothing to hint say so', () {
      final quiet = _first((a) => a.renderer == ActivityRenderer.coachDialogue);
      final explain = _activities.firstWhere(
        (a) => a.id == 'act-07-10-01-explain',
      );
      expect(lessonFrameHintOffReason(explain), kHintOffNothingToHint);
      expect(lessonFrameHintOffReason(quiet), kHintOffNothingToHint);
      // Capstone hands are transfer tests: the test reason wins.
      final hand = _activities.firstWhere((a) => a.id == 'act-07-10-01-hand');
      expect(lessonFrameHintOffReason(hand), kHintOffTransfer);
    });

    test('every step either allows Hint or has a reason', () {
      for (final a in _activities) {
        final reason = lessonFrameHintOffReason(a);
        expect(reason == null, lessonFrameCanHint(a), reason: a.id);
      }
    });
  });

  group('LessonToolRow disabled Hint', () {
    late List<String> haptics;

    setUp(() {
      haptics = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              haptics.add(call.arguments as String);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    Future<int> pumpRow(
      WidgetTester tester, {
      required bool canHint,
      String? reason,
    }) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var hints = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(
                  child: SizedBox.expand(key: ValueKey('elsewhere')),
                ),
                LessonToolRow(
                  onUndo: () {},
                  onRedo: () {},
                  onHint: () => hints++,
                  canUndo: false,
                  canRedo: false,
                  canHint: canHint,
                  hintOffReason: reason,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      return hints;
    }

    for (final reason in [
      kHintOffJumpTest,
      kHintOffCheckpoint,
      kHintOffTransfer,
      kHintOffAlreadyShowing,
      kHintOffNothingToHint,
    ]) {
      testWidgets('tap explains: $reason', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpRow(tester, canHint: false, reason: reason);
        final hint = find.text('HINT');
        final before = tester.getRect(hint);
        final button = tester.getRect(
          find.ancestor(of: hint, matching: find.byType(InkWell)),
        );
        final rowBefore = tester.getRect(find.byType(LessonToolRow));

        await tester.tap(hint);
        await tester.pump();

        // Light haptic, then the reason in a bubble over the button.
        expect(haptics, ['HapticFeedbackType.selectionClick']);
        expect(find.text(reason), findsOneWidget);
        expect(find.bySemanticsLabel(reason), findsOneWidget);
        final bubble = tester.getRect(
          find.byKey(LessonHintOffBubble.bubbleKey),
        );
        // Fits the 375-wide phone, sits above the button, ends at its edge.
        expect(bubble.left, greaterThanOrEqualTo(0));
        expect(bubble.right, lessThanOrEqualTo(375));
        expect(bubble.top, greaterThanOrEqualTo(0));
        expect(bubble.bottom, lessThanOrEqualTo(button.top));
        expect(bubble.right, moreOrLessEquals(button.right, epsilon: 1));
        // No layout shift.
        expect(tester.getRect(hint), before);
        expect(tester.getRect(find.byType(LessonToolRow)), rowBefore);

        // Auto-dismiss in 2–3 s.
        await tester.pump(const Duration(milliseconds: 1900));
        expect(find.text(reason), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 800));
        expect(find.text(reason), findsNothing);
        semantics.dispose();
      });
    }

    testWidgets('a tap elsewhere dismisses the bubble', (tester) async {
      await pumpRow(tester, canHint: false, reason: kHintOffCheckpoint);
      await tester.tap(find.text('HINT'));
      await tester.pump();
      expect(find.text(kHintOffCheckpoint), findsOneWidget);
      await tester.tapAt(const Offset(187, 200));
      await tester.pump();
      expect(find.text(kHintOffCheckpoint), findsNothing);
      // Nothing left running.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('tapping again restarts the bubble and buzzes again', (
      tester,
    ) async {
      await pumpRow(tester, canHint: false, reason: kHintOffJumpTest);
      await tester.tap(find.text('HINT'));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.tap(find.text('HINT'));
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text(kHintOffJumpTest), findsOneWidget);
      expect(haptics, hasLength(2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(kHintOffJumpTest), findsNothing);
    });

    testWidgets('enabled Hint still reveals the hint, no bubble', (
      tester,
    ) async {
      var hints = 0;
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: LessonToolRow(
                onUndo: () {},
                onRedo: () {},
                onHint: () => hints++,
                canUndo: false,
                canRedo: false,
                canHint: true,
                hintOffReason: kHintOffJumpTest,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('HINT'));
      await tester.pump();
      expect(hints, 1);
      expect(find.byKey(LessonHintOffBubble.bubbleKey), findsNothing);
      expect(haptics, isEmpty);
    });

    testWidgets('disabled without a reason stays silent', (tester) async {
      final hints = await pumpRow(tester, canHint: false);
      await tester.tap(find.text('HINT'));
      await tester.pump();
      expect(hints, 0);
      expect(find.byKey(LessonHintOffBubble.bubbleKey), findsNothing);
      expect(haptics, isEmpty);
    });
  });
}
