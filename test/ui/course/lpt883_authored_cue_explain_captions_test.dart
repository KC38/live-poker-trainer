/// LPT-883 / LPT-884 / LPT-885 / LPT-886 / LPT-887 / LPT-888 / LPT-889 /
/// LPT-890 / LPT-891 / LPT-892 / LPT-893 / LPT-894 / LPT-895 / LPT-896 /
/// LPT-897 / LPT-898 / LPT-899 / LPT-900 / LPT-901 / LPT-902 / LPT-903 /
/// LPT-904 / LPT-905 / LPT-906 / LPT-907 / LPT-908 / LPT-909 / LPT-910 /
/// LPT-911 / LPT-912 / LPT-913 / LPT-914 / LPT-915 / LPT-916 / LPT-917 /
/// LPT-918 / LPT-919 / LPT-925 / LPT-926 / LPT-927 / LPT-931 / LPT-932 /
/// LPT-933 / LPT-934 / LPT-935 / LPT-936 / LPT-937 / LPT-938 / LPT-939 /
/// LPT-940 / LPT-941 / LPT-942 / LPT-943 / LPT-944 / LPT-945 / LPT-946 /
/// LPT-950 / LPT-951 / LPT-952 / LPT-953 / LPT-954 / LPT-955 /
/// LPT-956 / LPT-957 / LPT-958 / LPT-959 / LPT-960 / LPT-961 /
/// LPT-962 / LPT-963 / LPT-964 / LPT-965 / LPT-966 / LPT-967 / LPT-968 /
/// LPT-969 / LPT-970 / LPT-971 / LPT-972 / LPT-973 / LPT-974 / LPT-975 /
/// LPT-976 / LPT-977 / LPT-978 / LPT-979 / LPT-980 / LPT-981 /
/// LPT-982 / LPT-983 / LPT-984 / LPT-985 / LPT-986 / LPT-987 /
/// LPT-988 / LPT-989 / LPT-990 / LPT-991 / LPT-992 /
/// LPT-993 / LPT-995 / LPT-996:
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
    expect(authoredSoftPulseExplainCaption('SHOWDOWNS'), 'Cards speak');
    expect(authoredSoftPulseExplainCaption('NEW EVIDENCE'), 'Seat changed');
    expect(authoredSoftPulseExplainCaption('RETIRE'), 'Drop old label');
    expect(authoredSoftPulseExplainCaption('TYPE'), 'Player model');
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
    expect(authoredSoftPulseExplainCaption('MULTIWAY'), 'Many players');
    expect(authoredSoftPulseExplainCaption('OOP'), 'Out of position');
    expect(authoredSoftPulseExplainCaption('SET'), 'Three of a kind');
    expect(authoredSoftPulseExplainCaption('ONE PAIR'), 'Weak made');
    expect(authoredSoftPulseExplainCaption('SPR'), 'Stack vs pot');
    expect(authoredSoftPulseExplainCaption('REVERSE'), 'Lose more later');
    expect(authoredSoftPulseExplainCaption('DOMINATED'), 'Second best');
    expect(authoredSoftPulseExplainCaption('NON-NUT'), 'Not the nuts');
    expect(authoredSoftPulseExplainCaption('SKIP'), 'Pass the draw');
    expect(authoredSoftPulseExplainCaption('FOLDS'), 'Folds too much');
    expect(authoredSoftPulseExplainCaption('PROBE'), 'Bet after check');
    expect(authoredSoftPulseExplainCaption('DONK'), 'Lead into raiser');
    expect(authoredSoftPulseExplainCaption('CAPPED'), 'Nuts unlikely');
    expect(authoredSoftPulseExplainCaption('UNCAPPED'), 'Nuts still live');
    expect(authoredSoftPulseExplainCaption('RE-PRICE'), 'Update the plan');
    expect(authoredSoftPulseExplainCaption('BIG'), 'Polarized size');
    expect(authoredSoftPulseExplainCaption('TELL'), 'Single cue');
    expect(authoredSoftPulseExplainCaption('MYTH'), 'Fake rule');
    expect(authoredSoftPulseExplainCaption('REJECT'), 'Ignore it');
    expect(authoredSoftPulseExplainCaption('GEAR'), 'Shifting play');
    expect(authoredSoftPulseExplainCaption('COOLER'), 'Not a leak');
    expect(authoredSoftPulseExplainCaption("CHASE"), "Don't chase");
    expect(authoredSoftPulseExplainCaption('RESET'), 'Step away');
    expect(authoredSoftPulseExplainCaption('BANKROLL'), 'Session cash');
    expect(authoredSoftPulseExplainCaption('STAKES'), 'Game size');
    expect(authoredSoftPulseExplainCaption('DECLINE'), 'Pass bigger');
    expect(authoredSoftPulseExplainCaption('TIRED'), 'Low energy');
    expect(authoredSoftPulseExplainCaption('WILD'), 'Chaotic table');
    expect(authoredSoftPulseExplainCaption('CASH OUT'), 'Leave now');
    expect(authoredSoftPulseExplainCaption('PAIRED'), 'Board pairs');
    expect(authoredSoftPulseExplainCaption('CALLER'), 'Wider range');
    expect(authoredSoftPulseExplainCaption('BARRELS'), 'Fire multi-street');
    expect(authoredSoftPulseExplainCaption('DISCOUNT'), 'Cut weak equity');
    expect(authoredSoftPulseExplainCaption('SEMI-BLUFF'), 'Bet with outs');
    expect(authoredSoftPulseExplainCaption('OUTS'), 'Cards that help');
    expect(authoredSoftPulseExplainCaption('THIN'), 'Extract light');
    expect(authoredSoftPulseExplainCaption('MERGED'), 'Medium-strong');
    expect(authoredSoftPulseExplainCaption('SIZE'), 'Size accordingly');
    expect(authoredSoftPulseExplainCaption('SHAPE'), 'Range shape');
    expect(authoredSoftPulseExplainCaption('MATCH'), 'Size fits shape');
    expect(authoredSoftPulseExplainCaption('HUGE'), 'Too big');
    expect(authoredSoftPulseExplainCaption('AVOID'), 'Skip random');
    expect(authoredSoftPulseExplainCaption('CATCH'), 'Bluff-catch hand');
    expect(authoredSoftPulseExplainCaption('UNBLOCK'), 'Keep their draws');
    expect(authoredSoftPulseExplainCaption('BLUFFS'), 'Missed draws live');
    expect(authoredSoftPulseExplainCaption('TWEAK'), 'Close choice only');
    expect(authoredSoftPulseExplainCaption('NO EV'), 'No fake decimals');
    expect(authoredSoftPulseExplainCaption('THIRD PAIR'), 'Weak pair');
    expect(authoredSoftPulseExplainCaption('SCARY'), 'Tough river');
    expect(authoredSoftPulseExplainCaption('MDF'), 'Exact percents');
    expect(authoredSoftPulseExplainCaption('INTUITION'), 'Decision-linked');
    expect(authoredSoftPulseExplainCaption('LESS'), 'Cut bluff mix');
    expect(authoredSoftPulseExplainCaption('RANDOM'), 'Theater mix');
    expect(authoredSoftPulseExplainCaption('PURPOSE'), 'Not coin-flip');
    expect(authoredSoftPulseExplainCaption('4BET'), 'Lower SPR');
    expect(authoredSoftPulseExplainCaption('CAREFUL'), 'Near-committed');
    expect(authoredSoftPulseExplainCaption('EGO'), 'Skip revenge');
    expect(authoredSoftPulseExplainCaption('DUE'), 'Never owed');
    expect(authoredSoftPulseExplainCaption('MISTAKE'), 'Avoidable leak');
    expect(authoredSoftPulseExplainCaption('REVIEW'), 'Judge the hand');
    expect(authoredSoftPulseExplainCaption('CALLED'), 'They call you');
    expect(authoredSoftPulseExplainCaption('GIVES UP'), 'Folds bad turns');
    expect(authoredSoftPulseExplainCaption('TWO HANDS'), 'Tiny sample');
    expect(authoredSoftPulseExplainCaption('NOTE BUNDLE'), 'Keep noting');
    expect(authoredSoftPulseExplainCaption('FOLDS MOST'), 'Seldom plays');
    expect(authoredSoftPulseExplainCaption('PLANNED BARRELS'), 'Barrels with plan');
    expect(authoredSoftPulseExplainCaption('ENTRY WIDTH'), 'Narrow vs wide');
    expect(
      authoredSoftPulseExplainCaption('DISCIPLINE'),
      'Gives up when called',
    );
    expect(authoredSoftPulseExplainCaption('CHECK-RAISE'), 'Believe it');
    expect(authoredSoftPulseExplainCaption('RARELY CALLS'), 'No light calls');
    expect(
      authoredSoftPulseExplainCaption('MANY HANDS'),
      'Across many spots',
    );
    expect(
      authoredSoftPulseExplainCaption('FOLDS SOMETIMES'),
      'Still folds some',
    );
    expect(
      authoredSoftPulseExplainCaption('WIDE OPENS'),
      'Opens many hands',
    );
    expect(
      authoredSoftPulseExplainCaption('RAISES'),
      'Raises and barrels',
    );
    expect(authoredSoftPulseExplainCaption('CALLS'), 'Just calls');
    expect(authoredSoftPulseExplainCaption('STRONG HAND'), 'Premium made');
    expect(
      authoredSoftPulseExplainCaption('LET THEM BET'),
      'Keep them betting',
    );
    expect(
      authoredSoftPulseExplainCaption('NO BIG BLUFF'),
      'Skip hero bluffs',
    );
    expect(
      authoredSoftPulseExplainCaption('LET THEM'),
      'They keep pressing',
    );
    expect(
      authoredSoftPulseExplainCaption('NIT CHECK-RAISE'),
      'Value-heavy raise',
    );
    expect(
      authoredSoftPulseExplainCaption('LAG BARREL'),
      'Wide aggressor fires',
    );
    expect(
      authoredSoftPulseExplainCaption('TENDENCY'),
      'Player type note',
    );
    expect(
      authoredSoftPulseExplainCaption('LINE'),
      'Their betting story',
    );
    expect(
      authoredSoftPulseExplainCaption('DEAD PLAN'),
      'Thesis is dead',
    );
    expect(
      authoredSoftPulseExplainCaption('LET GO'),
      'Abandon the line',
    );
    expect(
      authoredSoftPulseExplainCaption('TEXTURE'),
      'Board shape',
    );
    expect(
      authoredSoftPulseExplainCaption('CONFIRM OR CANCEL'),
      'Keep or drop plan',
    );
    expect(
      authoredSoftPulseExplainCaption('GIVE-UP'),
      'Cards to kill',
    );
    expect(
      authoredSoftPulseExplainCaption('MAP'),
      'Before flop bet',
    );
    expect(
      authoredSoftPulseExplainCaption('BLOCKER'),
      'Remove hands',
    );
    expect(
      authoredSoftPulseExplainCaption('FEWER CALLS'),
      'They call less',
    );
    expect(
      authoredSoftPulseExplainCaption('NO STORY'),
      'Nothing to bet',
    );
    expect(
      authoredSoftPulseExplainCaption('HEADS-UP'),
      'Two players',
    );
    expect(
      authoredSoftPulseExplainCaption('THICK VALUE'),
      'Bet thicker',
    );
    expect(
      authoredSoftPulseExplainCaption('STEAL MORE'),
      'Bluff more often',
    );
    expect(
      authoredSoftPulseExplainCaption('SHORTER STACK'),
      'Min of the two',
    );
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
    'Confidence samples SoftPulse explain captions SAMPLES + SHOWDOWNS (LPT-935)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-09-01-02-explain-samples',
        targets: const ['SAMPLES', 'SHOWDOWNS'],
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
      expect(find.text('SAMPLES'), findsWidgets);
      expect(find.text('SHOWDOWNS'), findsWidgets);
      expect(find.text('Build the count'), findsOneWidget);
      expect(find.text('Cards speak'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Retire labels SoftPulse explain captions NEW EVIDENCE + RETIRE (LPT-936)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-09-01-03-explain-retire',
        targets: const ['NEW EVIDENCE', 'RETIRE'],
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
      expect(find.text('NEW EVIDENCE'), findsWidgets);
      expect(find.text('RETIRE'), findsWidgets);
      expect(find.text('Seat changed'), findsOneWidget);
      expect(find.text('Drop old label'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Combine factors SoftPulse explain captions TYPE + POSITION + STACK (LPT-937)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-04-10-01-02-explain-combine',
        targets: const ['TYPE', 'POSITION', 'STACK'],
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
      expect(find.text('TYPE'), findsWidgets);
      expect(find.text('POSITION'), findsWidgets);
      expect(find.text('STACK'), findsWidgets);
      expect(find.text('Player model'), findsOneWidget);
      expect(find.text('Seat edge'), findsOneWidget);
      expect(find.text('Commit the rest'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );


  testWidgets(
    'Tighten speculative SoftPulse explain captions MULTIWAY + OOP + FOLD (LPT-938)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-01-01-02-explain-speculative',
        targets: const ['MULTIWAY', 'OOP', 'FOLD'],
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
      expect(find.text('MULTIWAY'), findsWidgets);
      expect(find.text('OOP'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Many players'), findsOneWidget);
      expect(find.text('Out of position'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Thick value SoftPulse explain captions CALLERS + SET + BET (LPT-939)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-01-01-03-explain-value',
        targets: const ['CALLERS', 'SET', 'BET'],
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
      expect(find.text('CALLERS'), findsWidgets);
      expect(find.text('SET'), findsWidgets);
      expect(find.text('BET'), findsWidgets);
      expect(find.text('Called the open'), findsOneWidget);
      expect(find.text('Three of a kind'), findsOneWidget);
      expect(find.text('Put chips in'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Fold light deep SoftPulse explain captions DEEP + ONE PAIR + FOLD (LPT-940)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-02-01-02-explain-stack-off',
        targets: const ['DEEP', 'ONE PAIR', 'FOLD'],
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
      expect(find.text('ONE PAIR'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Wider trees'), findsOneWidget);
      expect(find.text('Weak made'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Plan high SPR SoftPulse explain captions SPR + TURN + RIVER (LPT-941)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-02-01-03-explain-plan',
        targets: const ['SPR', 'TURN', 'RIVER'],
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
      expect(find.text('SPR'), findsWidgets);
      expect(find.text('TURN'), findsWidgets);
      expect(find.text('RIVER'), findsWidgets);
      expect(find.text('Stack vs pot'), findsOneWidget);
      expect(find.text('Fourth card'), findsOneWidget);
      expect(find.text('Fifth card'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Reverse implied SoftPulse explain captions REVERSE + DOMINATED + FOLD (LPT-942)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-03-01-02-explain-reverse',
        targets: const ['REVERSE', 'DOMINATED', 'FOLD'],
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
      expect(find.text('REVERSE'), findsWidgets);
      expect(find.text('DOMINATED'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Lose more later'), findsOneWidget);
      expect(find.text('Second best'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Skip dominated draws SoftPulse explain captions NON-NUT + MULTIWAY + SKIP (LPT-943)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-03-01-03-explain-draws',
        targets: const ['NON-NUT', 'MULTIWAY', 'SKIP'],
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
      expect(find.text('NON-NUT'), findsWidgets);
      expect(find.text('MULTIWAY'), findsWidgets);
      expect(find.text('SKIP'), findsWidgets);
      expect(find.text('Not the nuts'), findsOneWidget);
      expect(find.text('Many players'), findsOneWidget);
      expect(find.text('Pass the draw'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Skip thin overfolders SoftPulse explain captions NIT + FOLDS + CHECK (LPT-944)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-04-01-03-explain-overfold',
        targets: const ['NIT', 'FOLDS', 'CHECK'],
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
      expect(find.text('NIT'), findsWidgets);
      expect(find.text('FOLDS'), findsWidgets);
      expect(find.text('CHECK'), findsWidgets);
      expect(find.text('Working label'), findsOneWidget);
      expect(find.text('Folds too much'), findsOneWidget);
      expect(find.text('Pass the street'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Probes SoftPulse explain captions PROBE + DELAY + PLAN (LPT-945)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-05-01-02-explain-probe',
        targets: const ['PROBE', 'DELAY', 'PLAN'],
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
      expect(find.text('PROBE'), findsWidgets);
      expect(find.text('DELAY'), findsWidgets);
      expect(find.text('PLAN'), findsWidgets);
      expect(find.text('Bet after check'), findsOneWidget);
      expect(find.text('Hold fire'), findsOneWidget);
      expect(find.text('Fold, call, or 3-bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Donk bets SoftPulse explain captions DONK + STRONG + AIR (LPT-946)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-05-01-03-explain-donk',
        targets: const ['DONK', 'STRONG', 'AIR'],
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
      expect(find.text('DONK'), findsWidgets);
      expect(find.text('STRONG'), findsWidgets);
      expect(find.text('AIR'), findsWidgets);
      expect(find.text('Lead into raiser'), findsOneWidget);
      expect(find.text('Premium hands'), findsOneWidget);
      expect(find.text('Nothing yet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Capped lines SoftPulse explain captions CHECK + CAPPED + UNCAPPED (LPT-947)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-06-01-02-explain-capped',
        targets: const ['CHECK', 'CAPPED', 'UNCAPPED'],
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
      expect(find.text('CHECK'), findsWidgets);
      expect(find.text('CAPPED'), findsWidgets);
      expect(find.text('UNCAPPED'), findsWidgets);
      expect(find.text('Pass the street'), findsOneWidget);
      expect(find.text('Nuts unlikely'), findsOneWidget);
      expect(find.text('Nuts still live'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Drop stale SoftPulse explain captions FLOP + TURN + RE-PRICE (LPT-948)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-06-01-03-explain-stale',
        targets: const ['FLOP', 'TURN', 'RE-PRICE'],
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
      expect(find.text('FLOP'), findsWidgets);
      expect(find.text('TURN'), findsWidgets);
      expect(find.text('RE-PRICE'), findsWidgets);
      expect(find.text('Three cards'), findsOneWidget);
      expect(find.text('Fourth card'), findsOneWidget);
      expect(find.text('Update the plan'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Sizing SoftPulse explain captions TINY + BIG + RANGE (LPT-949)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-07-01-02-explain-sizing',
        targets: const ['TINY', 'BIG', 'RANGE'],
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
      expect(find.text('BIG'), findsWidgets);
      expect(find.text('RANGE'), findsWidgets);
      expect(find.text('Too small'), findsOneWidget);
      expect(find.text('Polarized size'), findsOneWidget);
      expect(find.text('Keep a range'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No magic tells SoftPulse explain captions TELL + MYTH + REJECT (LPT-950)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-07-01-03-explain-magic',
        targets: const ['TELL', 'MYTH', 'REJECT'],
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
      expect(find.text('TELL'), findsWidgets);
      expect(find.text('MYTH'), findsWidgets);
      expect(find.text('REJECT'), findsWidgets);
      expect(find.text('Single cue'), findsOneWidget);
      expect(find.text('Fake rule'), findsOneWidget);
      expect(find.text('Ignore it'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Gear changes SoftPulse explain caption GEAR (LPT-951)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-08-01-02-explain-gears',
        targets: const ['GEAR', 'CHANGE', 'SAMPLE'],
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
      expect(find.text('GEAR'), findsWidgets);
      expect(find.text('CHANGE'), findsWidgets);
      expect(find.text('SAMPLE'), findsWidgets);
      expect(find.text('Shifting play'), findsOneWidget);
      expect(find.text('Board shifts'), findsOneWidget);
      expect(find.text('Tiny sample'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Skip emotional pots SoftPulse explain captions COOLER + CHASE + RESET '
    '(LPT-952)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-08-01-03-explain-reset',
        targets: const ['COOLER', 'CHASE', 'RESET'],
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
      expect(find.text('COOLER'), findsWidgets);
      expect(find.text('CHASE'), findsWidgets);
      expect(find.text('RESET'), findsWidgets);
      expect(find.text('Not a leak'), findsOneWidget);
      expect(find.text("Don't chase"), findsOneWidget);
      expect(find.text('Step away'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Bankroll SoftPulse explain captions BANKROLL + STAKES + DECLINE '
    '(LPT-953)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-09-01-02-explain-bankroll',
        targets: const ['BANKROLL', 'STAKES', 'DECLINE'],
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
      expect(find.text('BANKROLL'), findsWidgets);
      expect(find.text('STAKES'), findsWidgets);
      expect(find.text('DECLINE'), findsWidgets);
      expect(find.text('Session cash'), findsOneWidget);
      expect(find.text('Game size'), findsOneWidget);
      expect(find.text('Pass bigger'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'End sessions SoftPulse explain captions TIRED + WILD + CASH OUT '
    '(LPT-954)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-05-09-01-03-explain-quit',
        targets: const ['TIRED', 'WILD', 'CASH OUT'],
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
      expect(find.text('TIRED'), findsWidgets);
      expect(find.text('WILD'), findsWidgets);
      expect(find.text('CASH OUT'), findsWidgets);
      expect(find.text('Low energy'), findsOneWidget);
      expect(find.text('Chaotic table'), findsOneWidget);
      expect(find.text('Leave now'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Nut advantage SoftPulse explain captions PAIRED + CALLER (LPT-955)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-01-01-02-explain-nuts',
        targets: const ['NUTS', 'PAIRED', 'CALLER'],
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
      expect(find.text('PAIRED'), findsWidgets);
      expect(find.text('CALLER'), findsWidgets);
      expect(find.text('Chase the top'), findsOneWidget);
      expect(find.text('Board pairs'), findsOneWidget);
      expect(find.text('Wider range'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Discount OOP SoftPulse explain captions BARRELS + DISCOUNT (LPT-956)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-02-01-02-explain-oop',
        targets: const ['OOP', 'BARRELS', 'DISCOUNT'],
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
      expect(find.text('OOP'), findsWidgets);
      expect(find.text('BARRELS'), findsWidgets);
      expect(find.text('DISCOUNT'), findsWidgets);
      expect(find.text('Out of position'), findsOneWidget);
      expect(find.text('Fire multi-street'), findsOneWidget);
      expect(find.text('Cut weak equity'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Aggression SoftPulse explain captions SEMI-BLUFF + OUTS (LPT-957)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-02-01-03-explain-aggro',
        targets: const ['SEMI-BLUFF', 'FOLDS', 'OUTS'],
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
      expect(find.text('SEMI-BLUFF'), findsWidgets);
      expect(find.text('FOLDS'), findsWidgets);
      expect(find.text('OUTS'), findsWidgets);
      expect(find.text('Bet with outs'), findsOneWidget);
      expect(find.text('Folds too much'), findsOneWidget);
      expect(find.text('Cards that help'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Attack caps SoftPulse explain captions THIN (LPT-958)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-03-01-03-explain-attack',
        targets: const ['CAPPED', 'THIN', 'BLUFF'],
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
      expect(find.text('CAPPED'), findsWidgets);
      expect(find.text('THIN'), findsWidgets);
      expect(find.text('BLUFF'), findsWidgets);
      expect(find.text('Nuts unlikely'), findsOneWidget);
      expect(find.text('Extract light'), findsOneWidget);
      expect(find.text('Make them fold'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Merged thin SoftPulse explain captions MERGED (LPT-959)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-04-01-02-explain-merged',
        targets: const ['MERGED', 'MEDIUM', 'VALUE'],
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
      expect(find.text('MERGED'), findsWidgets);
      expect(find.text('MEDIUM'), findsWidgets);
      expect(find.text('VALUE'), findsWidgets);
      expect(find.text('Medium-strong'), findsOneWidget);
      expect(find.text('Medium strength'), findsOneWidget);
      expect(find.text('Get paid'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Matched shapes SoftPulse explain captions SIZE/SHAPE/MATCH (LPT-960)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-04-01-03-explain-mismatch',
        targets: const ['SIZE', 'SHAPE', 'MATCH'],
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
      expect(find.text('SIZE'), findsWidgets);
      expect(find.text('SHAPE'), findsWidgets);
      expect(find.text('MATCH'), findsWidgets);
      expect(find.text('Size accordingly'), findsOneWidget);
      expect(find.text('Range shape'), findsOneWidget);
      expect(find.text('Size fits shape'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No random huge SoftPulse explain captions HUGE + AVOID (LPT-961)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-05-01-03-explain-random',
        targets: const ['HUGE', 'MEDIUM', 'AVOID'],
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
      expect(find.text('HUGE'), findsWidgets);
      expect(find.text('MEDIUM'), findsWidgets);
      expect(find.text('AVOID'), findsWidgets);
      expect(find.text('Too big'), findsOneWidget);
      expect(find.text('Medium strength'), findsOneWidget);
      expect(find.text('Skip random'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Catch with unblockers SoftPulse explain captions (LPT-962)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-06-01-02-explain-unblock',
        targets: const ['CATCH', 'UNBLOCK', 'BLUFFS'],
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
      expect(find.text('CATCH'), findsWidgets);
      expect(find.text('UNBLOCK'), findsWidgets);
      expect(find.text('BLUFFS'), findsWidgets);
      expect(find.text('Bluff-catch hand'), findsOneWidget);
      expect(find.text('Keep their draws'), findsOneWidget);
      expect(find.text('Missed draws live'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Blockers without fake EV SoftPulse explain captions (LPT-963)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-06-01-03-explain-ev',
        targets: const ['TWEAK', 'NO EV'],
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
      expect(find.text('TWEAK'), findsWidgets);
      expect(find.text('NO EV'), findsWidgets);
      expect(find.text('Close choice only'), findsOneWidget);
      expect(find.text('No fake decimals'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Fold dominated trash SoftPulse explain captions (LPT-964)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-07-01-02-explain-trash',
        targets: const ['THIRD PAIR', 'SCARY', 'FOLD'],
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
      expect(find.text('THIRD PAIR'), findsWidgets);
      expect(find.text('SCARY'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Weak pair'), findsOneWidget);
      expect(find.text('Tough river'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );


  testWidgets(
    'No fake MDF math SoftPulse explain captions (LPT-965)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-07-01-03-explain-mdf',
        targets: const ['MDF', 'INTUITION'],
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
      expect(find.text('MDF'), findsWidgets);
      expect(find.text('INTUITION'), findsWidgets);
      expect(find.text('Exact percents'), findsOneWidget);
      expect(find.text('Decision-linked'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Types reduce mixing SoftPulse explain captions (LPT-966)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-08-01-02-explain-types',
        targets: const ['TYPE', 'STATION', 'LESS'],
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
      expect(find.text('TYPE'), findsWidgets);
      expect(find.text('STATION'), findsWidgets);
      expect(find.text('LESS'), findsWidgets);
      expect(find.text('Player model'), findsOneWidget);
      expect(find.text('Working label'), findsOneWidget);
      expect(find.text('Cut bluff mix'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No pure random SoftPulse explain captions (LPT-967)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-08-01-03-explain-random',
        targets: const ['RANDOM', 'PURPOSE'],
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
      expect(find.text('RANDOM'), findsWidgets);
      expect(find.text('PURPOSE'), findsWidgets);
      expect(find.text('Theater mix'), findsOneWidget);
      expect(find.text('Not coin-flip'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Tighten up in 4-bet pots SoftPulse explain captions (LPT-968)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-09-01-01-explain-fourbet',
        targets: const ['4BET', 'STRONG', 'CAREFUL'],
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
      expect(find.text('4BET'), findsWidgets);
      expect(find.text('STRONG'), findsWidgets);
      expect(find.text('CAREFUL'), findsWidgets);
      expect(find.text('Lower SPR'), findsOneWidget);
      expect(find.text('Premium hands'), findsOneWidget);
      expect(find.text('Near-committed'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No ego 4-bets SoftPulse explain captions (LPT-969)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-09-01-03-explain-ego',
        targets: const ['4BET', 'EGO', 'AVOID'],
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
      expect(find.text('4BET'), findsWidgets);
      expect(find.text('EGO'), findsWidgets);
      expect(find.text('AVOID'), findsWidgets);
      expect(find.text('Lower SPR'), findsOneWidget);
      expect(find.text('Skip revenge'), findsOneWidget);
      expect(find.text('Skip random'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Cooler or mistake SoftPulse explain captions (LPT-970)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-10-01-02-explain-cooler',
        targets: const ['COOLER', 'MISTAKE', 'REVIEW'],
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
      expect(find.text('COOLER'), findsWidgets);
      expect(find.text('MISTAKE'), findsWidgets);
      expect(find.text('REVIEW'), findsWidgets);
      expect(find.text('Not a leak'), findsOneWidget);
      expect(find.text('Avoidable leak'), findsOneWidget);
      expect(find.text('Judge the hand'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No ego call-downs SoftPulse explain captions (LPT-971)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-10-01-03-explain-ego',
        targets: const ['DUE', 'EGO', 'FOLD'],
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
      expect(find.text('DUE'), findsWidgets);
      expect(find.text('EGO'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Never owed'), findsOneWidget);
      expect(find.text('Skip revenge'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Note disciplined aggression SoftPulse explain captions (LPT-972)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-11-01-02-explain-discipline',
        targets: const ['CALLED', 'GIVES UP'],
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
      expect(find.text('CALLED'), findsWidgets);
      expect(find.text('GIVES UP'), findsWidgets);
      expect(find.text('They call you'), findsOneWidget);
      expect(find.text('Folds bad turns'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Wait for samples SoftPulse explain captions (LPT-973)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-11-01-03-explain-wait',
        targets: const ['TWO HANDS', 'NOTE BUNDLE'],
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
      expect(find.text('TWO HANDS'), findsWidgets);
      expect(find.text('NOTE BUNDLE'), findsWidgets);
      expect(find.text('Tiny sample'), findsOneWidget);
      expect(find.text('Keep noting'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Spot a TAG SoftPulse explain captions (LPT-974)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-11-02-02-explain-spot',
        targets: const ['FOLDS MOST', 'PLANNED BARRELS'],
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
      expect(find.text('FOLDS MOST'), findsWidgets);
      expect(find.text('PLANNED BARRELS'), findsWidgets);
      expect(find.text('Seldom plays'), findsOneWidget);
      expect(find.text('Barrels with plan'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'TAG or Maniac SoftPulse explain captions (LPT-975)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-11-02-03-explain-maniac',
        targets: const ['ENTRY WIDTH', 'DISCIPLINE'],
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
      expect(find.text('ENTRY WIDTH'), findsWidgets);
      expect(find.text('DISCIPLINE'), findsWidgets);
      expect(find.text('Narrow vs wide'), findsOneWidget);
      expect(find.text('Gives up when called'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'No light bluffs SoftPulse explain captions (LPT-976)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-11-03-02-explain-checkraise',
        targets: const ['CHECK-RAISE', 'FOLD'],
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
      expect(find.text('CHECK-RAISE'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Believe it'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Bet thin SoftPulse explain captions (LPT-977)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-11-03-03-explain-thin',
        targets: const ['RARELY CALLS', 'CHECK'],
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
      expect(find.text('RARELY CALLS'), findsWidgets);
      expect(find.text('CHECK'), findsWidgets);
      expect(find.text('No light calls'), findsOneWidget);
      expect(find.text('Pass the street'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Note sustained pressure SoftPulse explain captions (LPT-978)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-12-01-02-explain-pressure',
        targets: const ['BARRELS', 'MANY HANDS'],
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
      expect(find.text('BARRELS'), findsWidgets);
      expect(find.text('MANY HANDS'), findsWidgets);
      expect(find.text('Fire multi-street'), findsOneWidget);
      expect(find.text('Across many spots'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Planned not Maniac SoftPulse explain captions (LPT-979)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-12-01-03-explain-plan',
        targets: const ['FOLDS SOMETIMES', 'PLAN'],
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
      expect(find.text('FOLDS SOMETIMES'), findsWidgets);
      expect(find.text('PLAN'), findsWidgets);
      expect(find.text('Still folds some'), findsOneWidget);
      expect(find.text('Fold, call, or 3-bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Spot a LAG SoftPulse explain captions (LPT-980)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-12-02-02-explain-spot',
        targets: const ['WIDE OPENS', 'BARRELS'],
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
      expect(find.text('WIDE OPENS'), findsWidgets);
      expect(find.text('BARRELS'), findsWidgets);
      expect(find.text('Opens many hands'), findsOneWidget);
      expect(find.text('Fire multi-street'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'LAG or Calling Station SoftPulse explain captions (LPT-981)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-12-02-03-explain-station',
        targets: const ['RAISES', 'CALLS'],
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
      expect(find.text('RAISES'), findsWidgets);
      expect(find.text('CALLS'), findsWidgets);
      expect(find.text('Raises and barrels'), findsOneWidget);
      expect(find.text('Just calls'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Trap strong hands SoftPulse explain captions (LPT-982)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-12-03-02-explain-trap',
        targets: const ['STRONG HAND', 'LET THEM BET'],
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
      expect(find.text('STRONG HAND'), findsWidgets);
      expect(find.text('LET THEM BET'), findsWidgets);
      expect(find.text('Premium made'), findsOneWidget);
      expect(find.text('Keep them betting'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Fewer fancy bluffs SoftPulse explain captions (LPT-983)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-12-03-03-explain-fancy',
        targets: const ['NO BIG BLUFF', 'LET THEM'],
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
      expect(find.text('NO BIG BLUFF'), findsWidgets);
      expect(find.text('LET THEM'), findsWidgets);
      expect(find.text('Skip hero bluffs'), findsOneWidget);
      expect(find.text('They keep pressing'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Same cards Nit fold SoftPulse explain captions (LPT-984)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-13-01-02-explain-nit',
        targets: const ['NIT CHECK-RAISE', 'FOLD'],
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
      expect(find.text('NIT CHECK-RAISE'), findsWidgets);
      expect(find.text('FOLD'), findsWidgets);
      expect(find.text('Value-heavy raise'), findsOneWidget);
      expect(find.text('Give up'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Same cards LAG call SoftPulse explain captions (LPT-985)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-13-01-03-explain-lag',
        targets: const ['LAG BARREL', 'CALL'],
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
      expect(find.text('LAG BARREL'), findsWidgets);
      expect(find.text('CALL'), findsWidgets);
      expect(find.text('Wide aggressor fires'), findsOneWidget);
      expect(find.text('Match the bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Cite the tendency SoftPulse explain captions (LPT-986)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-06-13-01-04-explain-cite',
        targets: const ['TENDENCY', 'LINE'],
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
      expect(find.text('TENDENCY'), findsWidgets);
      expect(find.text('LINE'), findsWidgets);
      expect(find.text('Player type note'), findsOneWidget);
      expect(find.text('Their betting story'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Abandon dead plans SoftPulse explain captions (LPT-987)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-01-01-03-explain-abandon',
        targets: const ['DEAD PLAN', 'LET GO'],
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
      expect(find.text('DEAD PLAN'), findsWidgets);
      expect(find.text('LET GO'), findsWidgets);
      expect(find.text('Thesis is dead'), findsOneWidget);
      expect(find.text('Abandon the line'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Update on the flop SoftPulse explain captions (LPT-988)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-01-01-02-explain-update',
        targets: const ['TEXTURE', 'CONFIRM OR CANCEL'],
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
      expect(find.text('TEXTURE'), findsWidgets);
      expect(find.text('CONFIRM OR CANCEL'), findsWidgets);
      expect(find.text('Board shape'), findsOneWidget);
      expect(find.text('Keep or drop plan'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Bet with a map SoftPulse explain captions (LPT-989)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-02-01-03-explain-map',
        targets: const ['CONTINUE', 'GIVE-UP', 'MAP'],
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
      expect(find.text('CONTINUE'), findsWidgets);
      expect(find.text('GIVE-UP'), findsWidgets);
      expect(find.text('MAP'), findsWidgets);
      expect(find.text('Keep strong'), findsOneWidget);
      expect(find.text('Cards to kill'), findsOneWidget);
      expect(find.text('Before flop bet'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Blocker bluffs SoftPulse explain captions (LPT-990)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-03-01-02-explain-blockers',
        targets: const ['BLOCKER', 'FEWER CALLS'],
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
      expect(find.text('BLOCKER'), findsWidgets);
      expect(find.text('FEWER CALLS'), findsWidgets);
      expect(find.text('Remove hands'), findsOneWidget);
      expect(find.text('They call less'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Check trash SoftPulse explain captions (LPT-991)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-03-01-03-explain-check',
        targets: const ['NO STORY', 'CHECK'],
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
      expect(find.text('NO STORY'), findsWidgets);
      expect(find.text('CHECK'), findsWidgets);
      expect(find.text('Nothing to bet'), findsOneWidget);
      expect(find.text('Pass the street'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Plan single-raised pots SoftPulse explain captions (LPT-992)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-04-01-02-explain-srp',
        targets: const ['HEADS-UP', 'C-BET'],
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
      expect(find.text('HEADS-UP'), findsWidgets);
      expect(find.text('C-BET'), findsWidgets);
      expect(find.text('Two players'), findsOneWidget);
      expect(find.text('Continue story'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Value thicker multiway SoftPulse explain captions (LPT-993)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-05-01-02-explain-value',
        targets: const ['MULTIWAY', 'THICK VALUE'],
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
      expect(find.text('MULTIWAY'), findsWidgets);
      expect(find.text('THICK VALUE'), findsWidgets);
      expect(find.text('Many players'), findsOneWidget);
      expect(find.text('Bet thicker'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Widen HU bluffs SoftPulse explain captions (LPT-995)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-05-01-03-explain-hu',
        targets: const ['HEADS-UP', 'STEAL MORE'],
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
      expect(find.text('HEADS-UP'), findsWidgets);
      expect(find.text('STEAL MORE'), findsWidgets);
      expect(find.text('Two players'), findsOneWidget);
      expect(find.text('Bluff more often'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'Recalculate effective SoftPulse explain captions (LPT-996)',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-07-06-01-03-explain-effective',
        targets: const ['SHORTER STACK', 'PLAN'],
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
      expect(find.text('SHORTER STACK'), findsWidgets);
      expect(find.text('PLAN'), findsWidgets);
      expect(find.text('Min of the two'), findsOneWidget);
      expect(find.text('Fold, call, or 3-bet'), findsOneWidget);
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
