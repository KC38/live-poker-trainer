/// LPT-883 / LPT-884 / LPT-885 / LPT-886 / LPT-887 / LPT-888 / LPT-889 /
/// LPT-890 / LPT-891 / LPT-892 / LPT-893 / LPT-894 / LPT-895 / LPT-896 /
/// LPT-897 / LPT-898 / LPT-899 / LPT-900 / LPT-901 / LPT-902 / LPT-903 /
/// LPT-904 / LPT-905:
/// SoftPulse explain teaching captions (not Tap N of M).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_toy_hand.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

CourseActivity _authoredExplain({
  required String id,
  required List<String> targets,
}) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: ActivityStage.guided,
    renderer: ActivityRenderer.coachDialogue,
    estimatedSeconds: 30,
    accessibilityText: 'Test SoftPulse explain',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Tap the cues in order.',
    teachSpec: {
      'cues': [
        for (var i = 0; i < targets.length; i++)
          {
            'press': i + 1,
            'target': targets[i],
            'kind': 'soft_pulse',
          },
      ],
    },
  );
}

void main() {
  test('authoredSoftPulseExplainCaption teaches, never Tap N of M', () {
    expect(authoredSoftPulseExplainCaption('DRAW'), 'Need a card');
    expect(authoredSoftPulseExplainCaption('SHOWDOWN VALUE'), 'Weak made');
    expect(authoredSoftPulseExplainCaption('AIR'), 'Nothing yet');
    expect(authoredSoftPulseExplainCaption('FOLD EQUITY'), 'Bluff needs folds');
    expect(authoredSoftPulseExplainCaption('BRICK'), 'Blank runout');
    expect(authoredSoftPulseExplainCaption('BARREL'), 'Fire again');
    expect(authoredSoftPulseExplainCaption('CHECKED BACK'), 'No bet flop');
    expect(authoredSoftPulseExplainCaption('BET TURN'), 'Bet when helped');
    expect(authoredSoftPulseExplainCaption('PRICE'), 'Pot odds');
    expect(authoredSoftPulseExplainCaption('POT'), 'What it pays');
    expect(authoredSoftPulseExplainCaption('EQUITY'), 'Win chance');
    expect(authoredSoftPulseExplainCaption('BUTTON'), 'Acts last');
    expect(authoredSoftPulseExplainCaption('WHO ACTS'), 'Whose turn');
    expect(authoredSoftPulseExplainCaption('SAY'), 'Announce clearly');
    expect(authoredSoftPulseExplainCaption('BINDING'), 'Must follow through');
    expect(authoredSoftPulseExplainCaption('EARLIER SEATS'), 'Act before you');
    expect(authoredSoftPulseExplainCaption('YOUR TURN'), 'Then you decide');
    expect(authoredSoftPulseExplainCaption('BROADWAY'), 'Ten or higher');
    expect(authoredSoftPulseExplainCaption('SUITED ACE'), 'Ace same suit');
    expect(authoredSoftPulseExplainCaption('CONNECTORS'), 'Suited, adjacent');
    expect(authoredSoftPulseExplainCaption('TRASH'), 'Low unconnected');
    expect(authoredSoftPulseExplainCaption('STRONG'), 'Premium hands');
    expect(authoredSoftPulseExplainCaption('LIVE SIZE'), 'Bigger than min');
    expect(authoredSoftPulseExplainCaption('3-BET'), 'Re-raise open');
    expect(authoredSoftPulseExplainCaption('PLAYABLE'), 'Can call open');
    expect(authoredSoftPulseExplainCaption('IN POSITION'), 'Act after raiser');
    expect(authoredSoftPulseExplainCaption('EP'), 'Early seat');
    expect(authoredSoftPulseExplainCaption('COVER'), 'Protect hole cards');
    expect(authoredSoftPulseExplainCaption('WAIT'), 'Act in turn');
    expect(authoredSoftPulseExplainCaption('WIDER'), 'Open more hands');
    expect(authoredSoftPulseExplainCaption('SHORTER'), 'Min of the two');
    expect(authoredSoftPulseExplainCaption('EFFECTIVE'), 'Playable stack');
    expect(authoredSoftPulseExplainCaption('50BB'), 'Short / simple');
    expect(authoredSoftPulseExplainCaption('100BB'), 'Standard');
    expect(authoredSoftPulseExplainCaption('200BB'), 'Deep / room');
    expect(authoredSoftPulseExplainCaption('OPEN'), 'Someone raised');
    expect(
      authoredSoftPulseExplainCaption('PLAN'),
      'Fold, call, or 3-bet',
    );
    expect(authoredSoftPulseExplainCaption('DEEP'), 'Wider trees');
    expect(
      authoredSoftPulseExplainCaption('IMPLIED ODDS'),
      'They pay later',
    );
    expect(authoredSoftPulseExplainCaption('PREFLOP RAISER'), 'You opened');
    expect(authoredSoftPulseExplainCaption('C-BET'), 'Continue story');
    expect(authoredSoftPulseExplainCaption('CHIPS'), 'Then move chips');
    expect(authoredSoftPulseExplainCaption('BETS MATCHED'), 'All caught up');
    expect(authoredSoftPulseExplainCaption('NEXT STREET'), 'Deal continues');
    expect(authoredSoftPulseExplainCaption('BLINDS'), 'Forced bets first');
    expect(authoredSoftPulseExplainCaption('YOU ACT'), 'Open, call, or fold');
    expect(
      authoredSoftPulseExplainCaption('ENDING'),
      'Folds win or continue',
    );
    expect(authoredSoftPulseExplainCaption('UNKNOWN-TARGET-XYZ'), isEmpty);
    expect(
      authoredSoftPulseExplainCaption('DRAW'),
      isNot(matches(RegExp(r'^Tap \d+ of \d+$'))),
    );
    expect(
      authoredSoftPulseExplainCaption('FOLD EQUITY'),
      isNot(matches(RegExp(r'^Tap \d+ of \d+$'))),
    );
  });

  testWidgets(
    'LessonAuthoredCueExplainTable shows teaching captions at 375×812',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-02-01-02-explain-draws',
        targets: const ['DRAW', 'SHOWDOWN VALUE'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('DRAW'), findsWidgets);
      expect(find.text('SHOWDOWN VALUE'), findsWidgets);
      expect(find.text('Need a card'), findsOneWidget);
      expect(find.text('Weak made'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Recognize air AuthoredCueExplain captions AIR + FOLD EQUITY (LPT-884)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-02-01-03-explain-air',
        targets: const ['AIR', 'FOLD EQUITY'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('AIR'), findsWidgets);
      expect(find.text('FOLD EQUITY'), findsWidgets);
      expect(find.text('Nothing yet'), findsOneWidget);
      expect(find.text('Bluff needs folds'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Second barrel AuthoredCueExplain captions BRICK + BARREL (LPT-885)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-05-01-02-explain-barrel',
        targets: const ['BRICK', 'BARREL'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('BRICK'), findsWidgets);
      expect(find.text('BARREL'), findsWidgets);
      expect(find.text('Blank runout'), findsOneWidget);
      expect(find.text('Fire again'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Delayed aggression AuthoredCueExplain captions CHECKED BACK + BET TURN (LPT-886)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-05-01-03-explain-delay',
        targets: const ['CHECKED BACK', 'BET TURN'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('CHECKED BACK'), findsWidgets);
      expect(find.text('BET TURN'), findsWidgets);
      expect(find.text('No bet flop'), findsOneWidget);
      expect(find.text('Bet when helped'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Button and action seat AuthoredCueExplain captions BUTTON + WHO ACTS (LPT-888)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-01-01-02-explain-seat',
        targets: const ['BUTTON', 'WHO ACTS'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('BUTTON'), findsWidgets);
      expect(find.text('WHO ACTS'), findsWidgets);
      expect(find.text('Acts last'), findsOneWidget);
      expect(find.text('Whose turn'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Words are binding AuthoredCueExplain captions SAY + BINDING (LPT-889)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-01-01-03-explain-binds',
        targets: const ['SAY', 'BINDING'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('SAY'), findsWidgets);
      expect(find.text('BINDING'), findsWidgets);
      expect(find.text('Announce clearly'), findsOneWidget);
      expect(find.text('Must follow through'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Wait your turn AuthoredCueExplain captions EARLIER SEATS + YOUR TURN (LPT-891)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-01-02-03-explain-wait',
        targets: const ['EARLIER SEATS', 'YOUR TURN'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('EARLIER SEATS'), findsWidgets);
      expect(find.text('YOUR TURN'), findsWidgets);
      expect(find.text('Act before you'), findsOneWidget);
      expect(find.text('Then you decide'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Pot odds AuthoredCueExplain captions PRICE + POT + EQUITY (LPT-887)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-03-01-02-explain-price',
        targets: const ['PRICE', 'POT', 'EQUITY'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('PRICE'), findsWidgets);
      expect(find.text('POT'), findsWidgets);
      expect(find.text('EQUITY'), findsWidgets);
      expect(find.text('Pot odds'), findsOneWidget);
      expect(find.text('What it pays'), findsOneWidget);
      expect(find.text('Win chance'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'street-ends AuthoredCueExplain captions stay non-meta at phone width',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-01-04-01-03-explain-end',
        targets: const ['BETS MATCHED', 'NEXT STREET'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('Deal continues'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Broadways SoftPulse explain captions BROADWAY + SUITED ACE (LPT-892)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-02-01-02-explain-broadway',
        targets: const ['BROADWAY', 'SUITED ACE'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('BROADWAY'), findsWidgets);
      expect(find.text('SUITED ACE'), findsWidgets);
      expect(find.text('Ten or higher'), findsOneWidget);
      expect(find.text('Ace same suit'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Say your action SoftPulse explain captions SAY + CHIPS (LPT-893)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-06-01-02-explain-verbal',
        targets: const ['SAY', 'CHIPS'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('SAY'), findsWidgets);
      expect(find.text('CHIPS'), findsWidgets);
      expect(find.text('Announce clearly'), findsOneWidget);
      expect(find.text('Then move chips'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Connectors SoftPulse explain captions CONNECTORS + TRASH (LPT-894)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-02-01-03-explain-connectors',
        targets: const ['CONNECTORS', 'TRASH'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('CONNECTORS'), findsWidgets);
      expect(find.text('TRASH'), findsWidgets);
      expect(find.text('Suited, adjacent'), findsOneWidget);
      expect(find.text('Low unconnected'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Open strong SoftPulse explain captions STRONG + LIVE SIZE (LPT-895)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-03-01-02-explain-strong',
        targets: const ['STRONG', 'LIVE SIZE'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('STRONG'), findsWidgets);
      expect(find.text('LIVE SIZE'), findsWidgets);
      expect(find.text('Premium hands'), findsOneWidget);
      expect(find.text('Bigger than min'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );


  testWidgets(
    'Seat labels SoftPulse explain captions EP + HJ + CO + BTN (LPT-896)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-01-01-01-explain-seats',
        targets: const ['EP', 'HJ', 'CO', 'BTN'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('EP'), findsWidgets);
      expect(find.text('HJ'), findsWidgets);
      expect(find.text('CO'), findsWidgets);
      expect(find.text('BTN'), findsWidgets);
      expect(find.text('Early seat'), findsOneWidget);
      expect(find.text('Hijack seat'), findsOneWidget);
      expect(find.text('Cutoff seat'), findsOneWidget);
      expect(find.text('Button seat'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Protect SoftPulse explain captions COVER + WAIT (LPT-897)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-06-01-03-explain-protect',
        targets: const ['COVER', 'WAIT'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('COVER'), findsWidgets);
      expect(find.text('WAIT'), findsWidgets);
      expect(find.text('Protect hole cards'), findsOneWidget);
      expect(find.text('Act in turn'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Widen SoftPulse explain captions BUTTON + WIDER (LPT-898)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-03-01-03-explain-button',
        targets: const ['BUTTON', 'WIDER'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('BUTTON'), findsWidgets);
      expect(find.text('WIDER'), findsWidgets);
      expect(find.text('Acts last'), findsOneWidget);
      expect(find.text('Open more hands'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Shorter stack SoftPulse explain captions SHORTER + EFFECTIVE (LPT-899)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-05-01-02-explain-eff',
        targets: const ['SHORTER', 'EFFECTIVE'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('SHORTER'), findsWidgets);
      expect(find.text('EFFECTIVE'), findsWidgets);
      expect(find.text('Min of the two'), findsOneWidget);
      expect(find.text('Playable stack'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Call in position SoftPulse explain captions PLAYABLE + IN POSITION (LPT-900)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-04-01-02-explain-call',
        targets: const ['PLAYABLE', 'IN POSITION', 'CALL'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('PLAYABLE'), findsWidgets);
      expect(find.text('IN POSITION'), findsWidgets);
      expect(find.text('CALL'), findsWidgets);
      expect(find.text('Can call open'), findsOneWidget);
      expect(find.text('Act after raiser'), findsOneWidget);
      expect(find.text('Match the bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Value 3-bet SoftPulse explain caption 3-BET (LPT-901)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-04-01-03-explain-threebet',
        targets: const ['STRONG', '3-BET'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('STRONG'), findsWidgets);
      expect(find.text('3-BET'), findsWidgets);
      expect(find.text('Premium hands'), findsOneWidget);
      expect(find.text('Re-raise open'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Stack depth SoftPulse explain captions 50BB / 100BB / 200BB (LPT-902)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-05-01-03-explain-depth',
        targets: const ['50BB', '100BB', '200BB'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('50BB'), findsWidgets);
      expect(find.text('100BB'), findsWidgets);
      expect(find.text('200BB'), findsWidgets);
      expect(find.text('Short / simple'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Deep / room'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Face a raise SoftPulse explain captions OPEN + PLAN (LPT-903)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-02-07-01-02-explain-vsraise',
        targets: const ['OPEN', 'PLAN'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('OPEN'), findsWidgets);
      expect(find.text('PLAN'), findsWidgets);
      expect(find.text('Someone raised'), findsOneWidget);
      expect(find.text('Fold, call, or 3-bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Implied odds SoftPulse explain captions DEEP + IMPLIED ODDS (LPT-904)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-03-01-03-explain-implied',
        targets: const ['DEEP', 'IMPLIED ODDS'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('DEEP'), findsWidgets);
      expect(find.text('IMPLIED ODDS'), findsWidgets);
      expect(find.text('Wider trees'), findsOneWidget);
      expect(find.text('They pay later'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'C-bet SoftPulse explain captions PREFLOP RAISER + C-BET (LPT-905)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-04-01-02-explain-cbet',
        targets: const ['PREFLOP RAISER', 'C-BET'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('PREFLOP RAISER'), findsWidgets);
      expect(find.text('C-BET'), findsWidgets);
      expect(find.text('You opened'), findsOneWidget);
      expect(find.text('Continue story'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'toy-hand SoftPulse explain chips show teaching captions (LPT-890)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      var ack = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: LessonFrameScope(
              onLocalMiss: (_) {},
              child: SizedBox(
                width: 375,
                height: 500,
                child: LessonToyHandExplainTable(
                  onAllStepsTapped: () => ack += 1,
                  enabled: true,
                  showGuidance: true,
                ),
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('BLINDS'), findsWidgets);
      expect(find.text('YOU ACT'), findsWidgets);
      expect(find.text('ENDING'), findsWidgets);
      expect(find.text('Forced bets first'), findsOneWidget);
      expect(find.text('Open, call, or fold'), findsOneWidget);
      expect(find.text('Folds win or continue'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);

      for (final title in const ['BLINDS', 'YOU ACT', 'ENDING']) {
        await tester.tap(find.text(title).first);
        await tester.pump();
      }
      expect(ack, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
