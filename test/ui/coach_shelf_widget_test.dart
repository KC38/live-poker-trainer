/// Unit tests for the AI coach shelf.
// ignore_for_file: use_null_aware_elements
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/exploit_action.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';

const _longIncorrect = CoachFeedback(
  verdict: CoachVerdict.incorrect,
  message:
      'Raising here bloats the pot against a station who calls with '
      'any pair and never folds to pressure. On the turn with king-high you '
      'have showdown value but no fold equity, so take the cheap price, '
      'keep the pot small, and let them pay you off when you improve.',
  optimalAction: ExploitAction.call,
  optimalSizingBb: 4,
  heroAction: 'RAISE',
  heroSizingBb: 8,
  evDeltaBb: -3.84,
);

const _sizedRaiseIncorrect = CoachFeedback(
  verdict: CoachVerdict.incorrect,
  message:
      'Right idea, wrong size preflop — you made it 16 BB, target 10 BB. '
      'Versus a LAG, pick a size that is awkward for their float range.',
  optimalAction: ExploitAction.raise,
  optimalSizingBb: 10,
  heroAction: 'RAISE',
  heroSizingBb: 16,
  evDeltaBb: -0.48,
);

const _longCorrect = CoachFeedback(
  verdict: CoachVerdict.correct,
  message:
      'Nice check — the maniac is still in and will barrel light on '
      'this wet board. You keep the pot small with medium strength and '
      'invite them to bluff into you on later streets.',
  optimalAction: ExploitAction.check,
  heroAction: 'CHECK',
  evDeltaBb: 0.4,
);

const _neutralPrompt = CoachFeedback(message: 'Your move.');

HeroActionEdge _serverEdge({
  required String actionKey,
  required String kind,
  required String verdict,
  required double evDeltaBb,
  required String optimalActionKey,
  double? amountTo,
}) {
  return HeroActionEdge.fromJson({
    'actionKey': actionKey,
    'kind': kind,
    'coaching': 'Server-authored coaching.',
    'verdict': verdict,
    'evDeltaBb': evDeltaBb,
    'optimalActionKey': optimalActionKey,
    'nextNodeId': 'next',
    if (amountTo != null) 'amountTo': amountTo,
  });
}

Widget _wrap(CoachFeedback feedback, {double? maxHeight}) {
  return MaterialApp(
    home: Scaffold(
      body: CoachShelfWidget(
        feedback: feedback,
        bigBlind: 2,
        chipDisplayMode: ChipDisplayMode.dollars,
        maxHeight: maxHeight,
      ),
    ),
  );
}

/// Host that can swap [CoachFeedback] without recreating the shelf.
class _FeedbackHost extends StatefulWidget {
  const _FeedbackHost({required this.initial, this.maxHeight});

  final CoachFeedback initial;
  final double? maxHeight;

  @override
  State<_FeedbackHost> createState() => _FeedbackHostState();
}

class _FeedbackHostState extends State<_FeedbackHost> {
  late CoachFeedback feedback = widget.initial;

  void update(CoachFeedback next) => setState(() => feedback = next);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CoachShelfWidget(
          feedback: feedback,
          bigBlind: 2,
          chipDisplayMode: ChipDisplayMode.dollars,
          maxHeight: widget.maxHeight,
        ),
      ),
    );
  }
}

void main() {
  group('CoachFeedback.fromHeroEdge', () {
    test('maps correct server grading', () {
      final feedback = CoachFeedback.fromHeroEdge(
        edge: _serverEdge(
          actionKey: 'CHECK',
          kind: 'CHECK',
          verdict: 'correct',
          evDeltaBb: 0,
          optimalActionKey: 'CHECK',
        ),
      );

      expect(feedback.verdict, CoachVerdict.correct);
      expect(feedback.evDeltaBb, 0);
      expect(feedback.optimalAction, ExploitAction.check);
      expect(feedback.optimalActionLabel, 'CHECK');
      expect(feedback.heroAction, 'CHECK');
    });

    test('maps incorrect server grading', () {
      final feedback = CoachFeedback.fromHeroEdge(
        edge: _serverEdge(
          actionKey: 'FOLD',
          kind: 'FOLD',
          verdict: 'incorrect',
          evDeltaBb: -2.4,
          optimalActionKey: 'CALL',
        ),
      );

      expect(feedback.verdict, CoachVerdict.incorrect);
      expect(feedback.evDeltaBb, -2.4);
      expect(feedback.optimalAction, ExploitAction.call);
      expect(feedback.optimalActionLabel, 'CALL');
      expect(feedback.heroAction, 'FOLD');
    });

    test('maps close server grading', () {
      final feedback = CoachFeedback.fromHeroEdge(
        edge: _serverEdge(
          actionKey: 'CALL',
          kind: 'CALL',
          verdict: 'close',
          evDeltaBb: -0.5,
          optimalActionKey: 'RAISE_100',
        ),
      );

      expect(feedback.verdict, CoachVerdict.close);
      expect(feedback.evDeltaBb, -0.5);
      expect(feedback.optimalAction, ExploitAction.raise);
      expect(feedback.optimalActionLabel, 'RAISE');
      expect(feedback.heroAction, 'CALL');
    });

    test('humanizes opaque authored action keys', () {
      final feedback = CoachFeedback.fromHeroEdge(
        edge: _serverEdge(
          actionKey: 'act_hero_pf_3bet',
          kind: 'RAISE',
          verdict: 'correct',
          evDeltaBb: 0,
          optimalActionKey: 'act_hero_pf_3bet',
          amountTo: 14,
        ),
        bigBlind: 2,
      );

      expect(feedback.optimalActionLabel, 'RAISE');
      expect(feedback.heroAction, 'RAISE');
      expect(feedback.optimalSizingBb, 7);
      expect(feedback.heroSizingBb, 7);
    });
  });

  testWidgets('shows full advice and decision context by default', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));

    expect(find.text('Show more'), findsNothing);
    expect(find.text('Show less'), findsNothing);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('EV'), findsOneWidget);
    expect(find.text('RAISE · \$16'), findsOneWidget);
    expect(find.textContaining('-\$'), findsOneWidget);

    final message = find.textContaining('Raising here bloats');
    final text = tester.widget<Text>(message);
    expect(text.maxLines, isNull);
  });

  testWidgets('BEST and YOU show raise amounts without ellipsis', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_sizedRaiseIncorrect, maxHeight: 190));

    expect(find.text('RAISE · \$20'), findsOneWidget);
    expect(find.text('RAISE · \$32'), findsOneWidget);
    expect(find.text('RAISE …'), findsNothing);
    expect(find.textContaining('…'), findsNothing);
  });

  testWidgets('updates advice when a new coach line arrives', (tester) async {
    await tester.pumpWidget(
      const _FeedbackHost(initial: _longIncorrect, maxHeight: 190),
    );
    expect(find.textContaining('Raising here bloats'), findsOneWidget);

    final host = tester.state(find.byType(_FeedbackHost)) as _FeedbackHostState;
    host.update(_longCorrect);
    await tester.pumpAndSettle();

    expect(find.textContaining('Nice check'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('CHECK'), findsNWidgets(2)); // BEST + YOU
    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('respects height cap with scrolling', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 120));
    await tester.pumpAndSettle();

    final coach = tester.getSize(find.byType(CoachShelfWidget));
    expect(coach.height, lessThanOrEqualTo(120.5));
  });

  testWidgets('short neutral prompts omit decision stats', (tester) async {
    await tester.pumpWidget(_wrap(_neutralPrompt));
    expect(find.text('Show more'), findsNothing);
    expect(find.textContaining('Your move.'), findsOneWidget);
    expect(find.text('BEST'), findsNothing);
  });

  testWidgets('graded incorrect always shows an INCORRECT badge', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));
    expect(find.text('INCORRECT'), findsWidgets);
    expect(find.text('CORRECT'), findsNothing);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('RAISE · \$16'), findsOneWidget);
  });

  testWidgets('server close edge shows CLOSE and server decision details', (
    tester,
  ) async {
    final feedback = CoachFeedback.fromHeroEdge(
      edge: _serverEdge(
        actionKey: 'CALL',
        kind: 'CALL',
        verdict: 'close',
        evDeltaBb: -0.5,
        optimalActionKey: 'RAISE_100',
      ),
    );

    await tester.pumpWidget(_wrap(feedback));

    expect(find.text('CLOSE'), findsOneWidget);
    expect(find.text('RAISE'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);
    expect(find.text('-\$1'), findsOneWidget);
    expect(find.text('RAISE_100'), findsNothing);
    expect(find.textContaining('act_'), findsNothing);
  });

  testWidgets('opaque authored keys render as RAISE with size', (tester) async {
    final feedback = CoachFeedback.fromHeroEdge(
      edge: _serverEdge(
        actionKey: 'act_hero_pf_3bet',
        kind: 'RAISE',
        verdict: 'correct',
        evDeltaBb: 0,
        optimalActionKey: 'act_hero_pf_3bet',
        amountTo: 14,
      ),
      bigBlind: 2,
    );

    await tester.pumpWidget(_wrap(feedback));

    expect(find.text('RAISE · \$14'), findsNWidgets(2)); // BEST + YOU
    expect(find.text('act_hero_pf_3bet'), findsNothing);
    expect(find.text('+\$0'), findsOneWidget);
  });

  testWidgets('EV cell uses signed amount without EV Δ prefix', (tester) async {
    await tester.pumpWidget(_wrap(_longCorrect));
    await tester.pumpAndSettle();

    expect(find.text('EV'), findsOneWidget);
    expect(find.text('+\$0.80'), findsOneWidget);
    expect(find.textContaining('EV Δ'), findsNothing);
  });

  testWidgets('live grade replaces empty shelf without stacking bodies', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _FeedbackHost(initial: CoachFeedback(), maxHeight: 190),
    );
    expect(find.text('CORRECT'), findsNothing);

    final host = tester.state(find.byType(_FeedbackHost)) as _FeedbackHostState;
    host.update(
      const CoachFeedback(
        verdict: CoachVerdict.correct,
        message: 'Raise is right preflop. Ned over-folds to aggression.',
        optimalAction: ExploitAction.raise,
        optimalSizingBb: 6,
        heroAction: 'RAISE',
        heroSizingBb: 6,
        evDeltaBb: 0.3,
        decisionStreet: Street.preflop,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Raise is right'), findsOneWidget);
    expect(find.text('CORRECT'), findsOneWidget);
    expect(find.textContaining('Correct ·'), findsNothing);
    expect(find.textContaining('Previous ·'), findsNothing);
  });
}
