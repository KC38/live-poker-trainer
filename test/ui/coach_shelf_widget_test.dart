/// Unit tests for the collapsible AI coach shelf.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';

const _longIncorrect = CoachFeedback(
  verdict: CoachVerdict.incorrect,
  message: 'Raising here bloats the pot against a station who calls with '
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
  message: 'Right idea, wrong size preflop — you made it 16 BB, target 10 BB. '
      'Versus a LAG, pick a size that is awkward for their float range.',
  optimalAction: ExploitAction.raise,
  optimalSizingBb: 10,
  heroAction: 'RAISE',
  heroSizingBb: 16,
  evDeltaBb: -0.48,
);

const _longCorrect = CoachFeedback(
  verdict: CoachVerdict.correct,
  message: 'Nice check — the maniac is still in and will barrel light on '
      'this wet board. You keep the pot small with medium strength and '
      'invite them to bluff into you on later streets.',
  optimalAction: ExploitAction.check,
  heroAction: 'CHECK',
  evDeltaBb: 0.4,
);

const _neutralPrompt = CoachFeedback(
  message: 'Your move.',
);

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

/// Host that can swap [CoachFeedback] without recreating shelf [State].
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
  testWidgets('defaults to collapsed preview with Show more', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));
    expect(find.text('Show more'), findsOneWidget);
    expect(find.text('Show less'), findsNothing);

    final message = find.textContaining('Raising here bloats');
    final text = tester.widget<Text>(message);
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('collapsed preview still peeks BEST / YOU / EV', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));

    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('EV'), findsOneWidget);
    expect(find.text('RAISE · \$16'), findsOneWidget);
    expect(find.textContaining('-\$'), findsOneWidget);
  });

  testWidgets('BEST and YOU show raise amounts without ellipsis', (tester) async {
    await tester.pumpWidget(_wrap(_sizedRaiseIncorrect, maxHeight: 190));

    // Collapsed peek must still show sizing (bb=2 → $20 best / $32 you).
    expect(find.text('RAISE · \$20'), findsOneWidget);
    expect(find.text('RAISE · \$32'), findsOneWidget);
    expect(find.text('RAISE …'), findsNothing);
    expect(find.textContaining('…'), findsNothing);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.text('RAISE · \$20'), findsOneWidget);
    expect(find.text('RAISE · \$32'), findsOneWidget);
  });

  testWidgets('expands to full advice and decision context', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.text('Show less'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('RAISE · \$16'), findsOneWidget);
    final message = find.textContaining('Raising here bloats');
    final text = tester.widget<Text>(message);
    expect(text.maxLines, isNull);
  });

  testWidgets('collapses again with Show less', (tester) async {
    await tester.pumpWidget(_wrap(_longCorrect, maxHeight: 190));
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();

    expect(find.text('Show more'), findsOneWidget);
    // Mini peek remains while graded.
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('CHECK'), findsNWidgets(2)); // BEST + YOU
  });

  testWidgets('stays expanded across a new coach line when already open',
      (tester) async {
    await tester.pumpWidget(
      const _FeedbackHost(initial: _longIncorrect, maxHeight: 190),
    );
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    final host = tester.state(find.byType(_FeedbackHost)) as _FeedbackHostState;
    host.update(_longCorrect);
    await tester.pumpAndSettle();

    expect(find.text('Show less'), findsOneWidget);
    expect(find.textContaining('Nice check'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('CHECK'), findsNWidgets(2)); // BEST + YOU
  });

  testWidgets('returns to collapsed preview for a new line when closed',
      (tester) async {
    await tester.pumpWidget(
      const _FeedbackHost(initial: _longIncorrect, maxHeight: 190),
    );
    expect(find.text('Show more'), findsOneWidget);

    final host = tester.state(find.byType(_FeedbackHost)) as _FeedbackHostState;
    host.update(_longCorrect);
    await tester.pumpAndSettle();

    expect(find.text('Show more'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
  });

  testWidgets('respects height cap while expanded', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 120));
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    final coach = tester.getSize(find.byType(CoachShelfWidget));
    expect(coach.height, lessThanOrEqualTo(120.5));
  });

  testWidgets('short neutral prompts do not force a collapser', (tester) async {
    await tester.pumpWidget(_wrap(_neutralPrompt));
    expect(find.text('Show more'), findsNothing);
    expect(find.textContaining('Your move.'), findsOneWidget);
    expect(find.text('BEST'), findsNothing);
  });

  testWidgets('graded incorrect always shows an INCORRECT badge', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));
    expect(find.text('INCORRECT'), findsWidgets);
    expect(find.text('CORRECT'), findsNothing);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();
    expect(find.text('INCORRECT'), findsWidgets);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('RAISE · \$16'), findsOneWidget);
  });

  testWidgets('autoExpand review keeps the verdict badge visible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoachShelfWidget(
            feedback: _longIncorrect,
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
            maxHeight: 220,
            autoExpand: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('INCORRECT'), findsWidgets);
    expect(find.text('Show less'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('EV'), findsOneWidget);
  });

  testWidgets('EV cell uses signed amount without EV Δ prefix', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoachShelfWidget(
            feedback: _longCorrect,
            bigBlind: 2,
            chipDisplayMode: ChipDisplayMode.dollars,
            autoExpand: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EV'), findsOneWidget);
    expect(find.text('+\$0.80'), findsOneWidget);
    expect(find.textContaining('EV Δ'), findsNothing);
  });

  testWidgets('historical tip shows one Previous badge and tip body',
      (tester) async {
    const historicalTip = CoachFeedback(
      verdict: CoachVerdict.correct,
      message: 'Sammy (LAG) bets preflop — \$12.00 to call, pot \$24.00.',
      optimalAction: ExploitAction.raise,
      optimalSizingBb: 6,
      heroAction: 'RAISE',
      heroSizingBb: 6,
      evDeltaBb: 0.4,
      decisionStreet: Street.preflop,
      isHistorical: true,
    );
    await tester.pumpWidget(_wrap(historicalTip, maxHeight: 190));
    await tester.pumpAndSettle();

    expect(find.textContaining('Previous · PREFLOP'), findsOneWidget);
    expect(find.text('CORRECT'), findsNothing);
    expect(find.textContaining('Sammy (LAG) bets'), findsOneWidget);
    expect(find.textContaining('Raise is right'), findsNothing);
    expect(find.text('BEST'), findsOneWidget);
  });

  testWidgets('live grade replaces tip without stacking tip text', (tester) async {
    await tester.pumpWidget(
      const _FeedbackHost(
        initial: CoachFeedback(
          message: 'Your turn preflop — \$2.00 vs Ned (Nit), pot \$3.00.',
        ),
        maxHeight: 190,
      ),
    );
    expect(find.textContaining('Your turn preflop'), findsOneWidget);
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

    expect(find.textContaining('Your turn preflop'), findsNothing);
    expect(find.textContaining('Raise is right'), findsOneWidget);
    expect(find.text('CORRECT'), findsOneWidget);
    expect(find.textContaining('Previous ·'), findsNothing);
  });
}
