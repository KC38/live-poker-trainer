/// LPT-883 / LPT-884 / LPT-885 / LPT-886 / LPT-887 / LPT-888 / LPT-889 /
/// LPT-890 / LPT-891 / LPT-892 / LPT-893 / LPT-894 / LPT-895 / LPT-896 /
/// LPT-897 / LPT-898 / LPT-899 / LPT-900 / LPT-901 / LPT-902 / LPT-903 /
/// LPT-904 / LPT-905 / LPT-906 / LPT-907 / LPT-908 / LPT-909 / LPT-910 /
/// LPT-911 / LPT-912 / LPT-913 / LPT-914 / LPT-915 / LPT-916 / LPT-917 /
/// LPT-918 / LPT-919 / LPT-925 / LPT-926 / LPT-927 / LPT-931 / LPT-932 /
/// LPT-933 / LPT-934:
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
    expect(authoredSoftPulseExplainCaption('STORY'), 'Believable line');
    expect(authoredSoftPulseExplainCaption('BLUFF'), 'Make them fold');
    expect(authoredSoftPulseExplainCaption('BLUFF-CATCH'), 'Call to catch');
    expect(authoredSoftPulseExplainCaption('NUTS'), 'Chase the top');
    expect(authoredSoftPulseExplainCaption('POSITION'), 'Seat edge');
    expect(authoredSoftPulseExplainCaption('BAD PRICE'), 'Poor pot odds');
    expect(authoredSoftPulseExplainCaption('PASSIVE'), 'Never raise');
    expect(authoredSoftPulseExplainCaption('CROWD'), 'Spew multiway');
    expect(authoredSoftPulseExplainCaption('FEWER BLUFFS'), 'Cut air');
    expect(authoredSoftPulseExplainCaption('NARROWER'), 'Fewer hands');
    expect(authoredSoftPulseExplainCaption('CONTINUE'), 'Keep strong');
    expect(authoredSoftPulseExplainCaption('CALLERS'), 'Called the open');
    expect(authoredSoftPulseExplainCaption('SQUEEZE'), 'Re-raise big');
    expect(authoredSoftPulseExplainCaption('BOARD CHANGES'), 'Turn shifts');
    expect(authoredSoftPulseExplainCaption('STOP'), 'Give up bluff');
    expect(authoredSoftPulseExplainCaption('MEDIUM'), 'Medium strength');
    expect(authoredSoftPulseExplainCaption('SMALL POT'), 'Keep it small');
    expect(authoredSoftPulseExplainCaption('NEARBY'), 'Several sizes OK');
    expect(authoredSoftPulseExplainCaption('TINY'), 'Too small');
    expect(authoredSoftPulseExplainCaption('VALUE'), 'Get paid');
    expect(authoredSoftPulseExplainCaption('LOW SPR'), 'Pot vs stacks');
    expect(authoredSoftPulseExplainCaption('COMMIT'), 'Get it in');
    expect(authoredSoftPulseExplainCaption('HIGH SPR'), 'Room to play');
    expect(authoredSoftPulseExplainCaption('FLEXIBLE'), 'Keep pots small');
    expect(authoredSoftPulseExplainCaption('FOLDS TO BETS'), 'Fold frequency');
    expect(authoredSoftPulseExplainCaption('STICKY'), 'Calls often');
    expect(authoredSoftPulseExplainCaption('STICKY CALLS'), 'Calls every street');
    expect(authoredSoftPulseExplainCaption('RARE FOLDS'), 'Seldom folds');
    expect(authoredSoftPulseExplainCaption('OBSERVATION'), 'Not a verdict');
    expect(authoredSoftPulseExplainCaption('SAMPLES'), 'Build the count');
    expect(authoredSoftPulseExplainCaption('SAMPLE'), 'Tiny sample');
    expect(authoredSoftPulseExplainCaption('CONFIDENCE'), 'Keep it low');
    expect(authoredSoftPulseExplainCaption('RARELY FOLDS'), 'Station sticks');
    expect(authoredSoftPulseExplainCaption('GIVE UP'), 'No equity fold');
    expect(authoredSoftPulseExplainCaption('EVIDENCE'), 'Prove first');
    expect(authoredSoftPulseExplainCaption('UNKNOWN'), 'Stay cautious');
    expect(authoredSoftPulseExplainCaption('RARE ENTRY'), 'Seldom plays');
    expect(authoredSoftPulseExplainCaption('BIG AGGRESSION'), 'Bets hard');
    expect(authoredSoftPulseExplainCaption('EVERY STREET'), 'Bets all streets');
    expect(
      authoredSoftPulseExplainCaption('WEAK SHOWDOWNS'),
      'Weak at showdown',
    );
    expect(authoredSoftPulseExplainCaption('FREQUENCIES'), 'Count how often');
    expect(authoredSoftPulseExplainCaption('NO EGO'), 'No feelings');
    expect(authoredSoftPulseExplainCaption('CONSTANT RAISES'), 'Raises often');
    expect(
      authoredSoftPulseExplainCaption('NEVER GIVES UP'),
      'Never folds rivers',
    );
    expect(authoredSoftPulseExplainCaption('ONE HAND'), 'Exact combo');
    expect(authoredSoftPulseExplainCaption('RANGE'), 'Keep a range');
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
    'Credible bluffs SoftPulse explain captions STORY + BLUFF (LPT-906)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-06-01-02-explain-bluff',
        targets: const ['STORY', 'BLUFF'],
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
      expect(find.text('STORY'), findsWidgets);
      expect(find.text('BLUFF'), findsWidgets);
      expect(find.text('Believable line'), findsOneWidget);
      expect(find.text('Make them fold'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Bluff-catch SoftPulse explain captions BLUFF-CATCH + FOLD (LPT-907)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-06-01-03-explain-catch',
        targets: const ['BLUFF-CATCH', 'FOLD'],
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
      expect(find.text('BLUFF-CATCH'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Call to catch'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Nut potential SoftPulse explain captions NUTS + POSITION (LPT-908)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-07-01-03-explain-nuts',
        targets: const ['NUTS', 'POSITION'],
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
      expect(find.text('NUTS'), findsWidgets);
      expect(find.text('POSITION'), findsWidgets);
      expect(find.text('Chase the top'), findsOneWidget);
      expect(find.text('Seat edge'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Fold bad prices SoftPulse explain captions BAD PRICE + FOLD (LPT-909)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-08-01-02-explain-price',
        targets: const ['BAD PRICE', 'FOLD'],
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
      expect(find.text('BAD PRICE'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Poor pot odds'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Passive SoftPulse explain captions PASSIVE + CROWD (LPT-910)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-08-01-03-explain-passive',
        targets: const ['PASSIVE', 'CROWD'],
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
      expect(find.text('PASSIVE'), findsWidgets);
      expect(find.text('CROWD'), findsWidgets);
      expect(find.text('Never raise'), findsOneWidget);
      expect(find.text('Spew multiway'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Bluff less SoftPulse explain captions CROWD + FEWER BLUFFS (LPT-911)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-07-01-02-explain-crowd',
        targets: const ['CROWD', 'FEWER BLUFFS'],
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
      expect(find.text('CROWD'), findsWidgets);
      expect(find.text('FEWER BLUFFS'), findsWidgets);
      expect(find.text('Spew multiway'), findsOneWidget);
      expect(find.text('Cut air'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Action moves SoftPulse explain captions RAISE + NARROWER + CALL (LPT-912)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-01-01-02-explain-move',
        targets: const ['RAISE', 'NARROWER', 'CALL'],
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
      expect(find.text('RAISE'), findsWidgets);
      expect(find.text('NARROWER'), findsWidgets);
      expect(find.text('CALL'), findsWidgets);
      expect(find.text('Make it more'), findsOneWidget);
      expect(find.text('Fewer hands'), findsOneWidget);
      expect(find.text('Match the bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Facing a 3-bet SoftPulse explain captions 3-BET + FOLD + CONTINUE (LPT-913)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-02-01-02-explain-facing',
        targets: const ['3-BET', 'FOLD', 'CONTINUE'],
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
      expect(find.text('3-BET'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('CONTINUE'), findsWidgets);
      expect(find.text('Re-raise open'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.text('Keep strong'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Squeeze SoftPulse explain captions OPEN + CALLERS + SQUEEZE (LPT-914)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-02-01-03-explain-squeeze',
        targets: const ['OPEN', 'CALLERS', 'SQUEEZE'],
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
      expect(find.text('CALLERS'), findsWidgets);
      expect(find.text('SQUEEZE'), findsWidgets);
      expect(find.text('Someone raised'), findsOneWidget);
      expect(find.text('Called the open'), findsOneWidget);
      expect(find.text('Re-raise big'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Abort board-change SoftPulse explain captions BOARD CHANGES + STOP (LPT-915)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-03-01-02-explain-abort',
        targets: const ['BOARD CHANGES', 'STOP'],
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
      expect(find.text('BOARD CHANGES'), findsWidgets);
      expect(find.text('STOP'), findsWidgets);
      expect(find.text('Turn shifts'), findsOneWidget);
      expect(find.text('Give up bluff'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Match pot size SoftPulse explain captions MEDIUM + SMALL POT (LPT-916)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-03-01-03-explain-pot',
        targets: const ['MEDIUM', 'SMALL POT'],
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
      expect(find.text('MEDIUM'), findsWidgets);
      expect(find.text('SMALL POT'), findsWidgets);
      expect(find.text('Medium strength'), findsOneWidget);
      expect(find.text('Keep it small'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Nearby sizes SoftPulse explain captions NEARBY + STORY (LPT-917)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-04-01-02-explain-nearby',
        targets: const ['NEARBY', 'STORY'],
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
      expect(find.text('NEARBY'), findsWidgets);
      expect(find.text('STORY'), findsWidgets);
      expect(find.text('Several sizes OK'), findsOneWidget);
      expect(find.text('Believable line'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Avoid tiny sizes SoftPulse explain captions TINY + VALUE (LPT-918)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-04-01-03-explain-tiny',
        targets: const ['TINY', 'VALUE'],
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
      expect(find.text('TINY'), findsWidgets);
      expect(find.text('VALUE'), findsWidgets);
      expect(find.text('Too small'), findsOneWidget);
      expect(find.text('Get paid'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Commit at low SPR SoftPulse explain captions LOW SPR + COMMIT (LPT-919)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-05-01-02-explain-low',
        targets: const ['LOW SPR', 'COMMIT'],
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
      expect(find.text('LOW SPR'), findsWidgets);
      expect(find.text('COMMIT'), findsWidgets);
      expect(find.text('Pot vs stacks'), findsOneWidget);
      expect(find.text('Get it in'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Stay flexible high SPR SoftPulse explain captions HIGH SPR + FLEXIBLE (LPT-921)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-05-01-03-explain-high',
        targets: const ['HIGH SPR', 'FLEXIBLE'],
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
      expect(find.text('HIGH SPR'), findsWidgets);
      expect(find.text('FLEXIBLE'), findsWidgets);
      expect(find.text('Room to play'), findsOneWidget);
      expect(find.text('Keep pots small'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Tag low folding SoftPulse explain captions FOLDS TO BETS + STICKY (LPT-920)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-06-01-02-explain-folding',
        targets: const ['FOLDS TO BETS', 'STICKY'],
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
      expect(find.text('FOLDS TO BETS'), findsWidgets);
      expect(find.text('STICKY'), findsWidgets);
      expect(find.text('Fold frequency'), findsOneWidget);
      expect(find.text('Calls often'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Spot Calling Station SoftPulse explain captions STICKY CALLS + RARE FOLDS (LPT-922)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-06-02-02-explain-spot',
        targets: const ['STICKY CALLS', 'RARE FOLDS'],
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
      expect(find.text('STICKY CALLS'), findsWidgets);
      expect(find.text('RARE FOLDS'), findsWidgets);
      expect(find.text('Calls every street'), findsOneWidget);
      expect(find.text('Seldom folds'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Observation versus certainty SoftPulse explain captions OBSERVATION + SAMPLES (LPT-923)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-06-01-03-explain-certainty',
        targets: const ['OBSERVATION', 'SAMPLES'],
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
      expect(find.text('OBSERVATION'), findsWidgets);
      expect(find.text('SAMPLES'), findsWidgets);
      expect(find.text('Not a verdict'), findsOneWidget);
      expect(find.text('Build the count'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Small samples SoftPulse explain captions SAMPLE + CONFIDENCE (LPT-924)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-06-02-03-explain-sample',
        targets: const ['SAMPLE', 'CONFIDENCE'],
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
      expect(find.text('SAMPLE'), findsWidgets);
      expect(find.text('CONFIDENCE'), findsWidgets);
      expect(find.text('Tiny sample'), findsOneWidget);
      expect(find.text('Keep it low'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Bluff less SoftPulse explain captions RARELY FOLDS + GIVE UP (LPT-925)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-06-03-02-explain-bluffs',
        targets: const ['RARELY FOLDS', 'GIVE UP'],
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
      expect(find.text('RARELY FOLDS'), findsWidgets);
      expect(find.text('GIVE UP'), findsWidgets);
      expect(find.text('Station sticks'), findsOneWidget);
      expect(find.text('No equity fold'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Cite sticky SoftPulse explain captions EVIDENCE + UNKNOWN (LPT-926)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-06-03-03-explain-cite',
        targets: const ['EVIDENCE', 'UNKNOWN'],
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
      expect(find.text('EVIDENCE'), findsWidgets);
      expect(find.text('UNKNOWN'), findsWidgets);
      expect(find.text('Prove first'), findsOneWidget);
      expect(find.text('Stay cautious'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Strong aggression SoftPulse explain captions RARE ENTRY + BIG AGGRESSION (LPT-927)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-07-01-02-explain-aggression',
        targets: const ['RARE ENTRY', 'BIG AGGRESSION'],
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
      expect(find.text('RARE ENTRY'), findsWidgets);
      expect(find.text('BIG AGGRESSION'), findsWidgets);
      expect(find.text('Seldom plays'), findsOneWidget);
      expect(find.text('Bets hard'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Wait for samples SoftPulse explain captions TWO FOLDS + MORE HANDS (LPT-928)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-07-01-03-explain-wait',
        targets: const ['TWO FOLDS', 'MORE HANDS'],
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
      expect(find.text('TWO FOLDS'), findsWidgets);
      expect(find.text('MORE HANDS'), findsWidgets);
      expect(find.text('Tiny sample'), findsOneWidget);
      expect(find.text('Keep waiting'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Spot a Nit SoftPulse explain captions FEW HANDS + BIG RAISES (LPT-929)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-07-02-02-explain-spot',
        targets: const ['FEW HANDS', 'BIG RAISES'],
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
      expect(find.text('FEW HANDS'), findsWidgets);
      expect(find.text('BIG RAISES'), findsWidgets);
      expect(find.text('Narrow entry'), findsOneWidget);
      expect(find.text('Heavy bets'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Respect heavy SoftPulse explain captions NIT RAISES + CREDIT (LPT-930)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-07-03-02-explain-respect',
        targets: const ['NIT RAISES', 'CREDIT'],
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
      expect(find.text('NIT RAISES'), findsWidgets);
      expect(find.text('CREDIT'), findsWidgets);
      expect(find.text('Big after flop'), findsOneWidget);
      expect(find.text('Believe strength'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Constant aggression SoftPulse explain captions EVERY STREET + WEAK SHOWDOWNS (LPT-931)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-08-01-02-explain-pressure',
        targets: const ['EVERY STREET', 'WEAK SHOWDOWNS'],
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
      expect(find.text('EVERY STREET'), findsWidgets);
      expect(find.text('WEAK SHOWDOWNS'), findsWidgets);
      expect(find.text('Bets all streets'), findsOneWidget);
      expect(find.text('Weak at showdown'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Notes without ego SoftPulse explain captions FREQUENCIES + NO EGO (LPT-932)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-08-01-03-explain-ego',
        targets: const ['FREQUENCIES', 'NO EGO'],
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
      expect(find.text('FREQUENCIES'), findsWidgets);
      expect(find.text('NO EGO'), findsWidgets);
      expect(find.text('Count how often'), findsOneWidget);
      expect(find.text('No feelings'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Spot a Maniac SoftPulse explain captions CONSTANT RAISES + NEVER GIVES UP (LPT-933)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-08-02-02-explain-spot',
        targets: const ['CONSTANT RAISES', 'NEVER GIVES UP'],
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
      expect(find.text('CONSTANT RAISES'), findsWidgets);
      expect(find.text('NEVER GIVES UP'), findsWidgets);
      expect(find.text('Raises often'), findsOneWidget);
      expect(find.text('Never folds rivers'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No exact hand SoftPulse explain captions ONE HAND + RANGE (LPT-934)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-01-01-03-explain-exact',
        targets: const ['ONE HAND', 'RANGE'],
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
      expect(find.text('ONE HAND'), findsWidgets);
      expect(find.text('RANGE'), findsWidgets);
      expect(find.text('Exact combo'), findsOneWidget);
      expect(find.text('Keep a range'), findsOneWidget);
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
