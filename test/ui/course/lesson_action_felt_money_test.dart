/// Pot and street-bet resolution for action-lesson felts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_felt_money.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  group('resolveLessonActionFeltMoney', () {
    const callChoices = [
      CourseChoice(id: 'call-5', label: 'Call 5', action: 'CALL'),
      CourseChoice(id: 'check-5', label: 'Check', action: 'CHECK'),
      CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
    ];

    test('facing half-pot bet shows villain chips and keeps pot at 10', () {
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Jh', 'Td'],
          boardCodes: ['9c', '8s', '2h'],
          potLabel: 'Pot 10',
          villainLine: 'Villain bets 5',
          facingBet: true,
        ),
        choices: callChoices,
      );

      expect(money.potTotal, 10);
      expect(money.streetBets, [0, 5]);
      expect(money.villainActionLabel, 'BET');
      expect(money.heroActionLabel, isNull);
    });

    test('calling the half-pot bet grows the pot to 15', () {
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Jh', 'Td'],
          boardCodes: ['9c', '8s', '2h'],
          potLabel: 'Pot 10',
          villainLine: 'Villain bets 5',
          facingBet: true,
        ),
        choices: callChoices,
        selected: callChoices.first,
      );

      expect(money.potTotal, 15);
      expect(money.streetBets, [5, 5]);
      expect(money.heroActionLabel, 'CALL');
    });

    test('open-pot bet shows hero chips and grows the pot', () {
      final bet = const CourseChoice(
        id: 'bet-half',
        label: 'Bet 5',
        action: 'BET',
      );
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['As', '7c', '2d'],
          potLabel: 'Pot 10',
          villainLine: 'Checked to you',
          facingBet: false,
          openPot: true,
        ),
        choices: [
          const CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          bet,
          const CourseChoice(id: 'raise', label: 'Raise', action: 'RAISE'),
        ],
        selected: bet,
      );

      expect(money.potTotal, 15);
      expect(money.streetBets, [5, 0]);
      expect(money.heroActionLabel, 'BET');
    });

    test('Pot 3 + open to 6 treats pot as collected blinds', () {
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['7h', '2d'],
          potLabel: 'Pot 3',
          villainLine: 'UTG opens to 6',
          facingBet: true,
        ),
        choices: const [
          CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
          CourseChoice(id: 'call', label: 'Call 6', action: 'CALL'),
        ],
      );

      expect(money.potTotal, 9);
      expect(money.streetBets, [0, 6]);
      expect(money.villainActionLabel, 'RAISE');
    });

    test('BB call amount infers chips already in', () {
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Ah', '7d'],
          potLabel: 'Pot 3 → 9',
          villainLine: 'BTN opens to 6',
          facingBet: true,
        ),
        choices: const [
          CourseChoice(id: 'call', label: 'Call 4', action: 'CALL'),
        ],
      );

      expect(money.streetBets, [2, 6]);
      expect(money.potTotal, 9);
    });
  });

  test('lessonTableStageGame posts street bets into display pot', () {
    final game = lessonTableStageGame(
      boardCodes: const ['9d', '8c', '2h'],
      villainCount: 1,
      streetBets: const [0, 5],
      potTotal: 10,
      villainActionLabel: 'BET',
    );

    expect(game.displayPot, 10);
    expect(game.mainPot, 5);
    expect(game.players[1].currentBet, 5);
    expect(game.players[1].lastActionLabel, 'BET');
  });

  testWidgets('framed unguided call shows bet then grows pot on Call', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-03-01-unguided-call',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Call',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'A bet is out — pick how you continue.',
      choices: const [
        CourseChoice(id: 'call-5', label: 'Call 5', action: 'CALL'),
        CourseChoice(id: 'check-5', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'fold-strong', label: 'Fold', action: 'FOLD'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(_framedAction(activity, controller));
    await tester.pumpAndSettle();

    expect(find.byType(LessonTableStage), findsOneWidget);
    expect(find.text('POT \$10'), findsOneWidget);
    expect(find.byType(StreetBetPill), findsOneWidget);
    expect(find.text('\$5'), findsWidgets);

    await tester.tap(find.text('CALL 5'));
    await tester.pumpAndSettle();

    expect(find.text('POT \$15'), findsOneWidget);
    expect(find.byType(StreetBetPill), findsNWidgets(2));
    controller.dispose();
  });

  testWidgets('framed guided bet shows hero bet and grows pot', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-03-02-guided-bet',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Bet 5',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Checked to you on the flop with top pair. Tap a value size.',
      choices: const [
        CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'bet-half', label: 'Bet 5', action: 'BET'),
        CourseChoice(id: 'raise', label: 'Raise', action: 'RAISE'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(_framedAction(activity, controller));
    await tester.pumpAndSettle();

    expect(find.text('POT \$10'), findsOneWidget);
    expect(find.byType(StreetBetPill), findsNothing);

    await tester.tap(find.text('BET 5'));
    await tester.pumpAndSettle();

    expect(find.text('POT \$15'), findsOneWidget);
    expect(find.byType(StreetBetPill), findsOneWidget);
    expect(find.text('\$5'), findsWidgets);
    controller.dispose();
  });
}

Widget _framedAction(
  CourseActivity activity,
  LessonActivityController controller,
) {
  final base = buildPokerTheme();
  return ProviderScope(
    overrides: [
      heroIdentityProvider.overrideWithValue(const HeroIdentity()),
    ],
    child: MaterialApp(
      theme: base.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId('lesson-01-03-01'),
          child: LessonFrameScope(
            onLocalMiss: (_) {},
            child: SizedBox(
              height: 640,
              child: PokerActionSizingActivity(
                activity: activity,
                controller: controller,
                showGuidance: false,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
