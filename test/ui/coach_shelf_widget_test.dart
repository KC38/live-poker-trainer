/// Unit tests for the collapsible AI coach shelf.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
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
  evDeltaBb: -3.84,
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
    expect(find.textContaining('Best:'), findsNothing);
    expect(find.textContaining('You:'), findsNothing);

    final message = find.textContaining('Raising here bloats');
    final text = tester.widget<Text>(message);
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('expands to full advice and decision context', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.text('Show less'), findsOneWidget);
    expect(find.textContaining('Best:'), findsOneWidget);
    expect(find.textContaining('You: RAISE'), findsOneWidget);
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
    expect(find.textContaining('Best:'), findsNothing);
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
    expect(find.textContaining('Best:'), findsOneWidget);
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
    expect(find.textContaining('Best:'), findsNothing);
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
  });

  testWidgets('graded incorrect always shows an INCORRECT badge', (tester) async {
    await tester.pumpWidget(_wrap(_longIncorrect, maxHeight: 190));
    expect(find.text('INCORRECT'), findsWidgets);
    expect(find.text('CORRECT'), findsNothing);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();
    expect(find.text('INCORRECT'), findsWidgets);
    expect(find.textContaining('Best:'), findsOneWidget);
    expect(find.textContaining('You: RAISE'), findsOneWidget);
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
    expect(find.textContaining('Best:'), findsOneWidget);
  });
}
