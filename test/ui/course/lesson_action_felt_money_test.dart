/// Pot and street-bet resolution for action-lesson felts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
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

    test('Raise to 15 charges the facing bet and grows the pot', () {
      const raise = CourseChoice(
        id: 'raise-15',
        label: 'Raise to 15',
        action: 'RAISE',
        amountBb: 9,
      );
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['As', '7c', '2d'],
          potLabel: 'Pot 10',
          villainLine: 'Villain bets 5',
          facingBet: true,
        ),
        choices: const [
          raise,
          CourseChoice(id: 'call', label: 'Call 5', action: 'CALL'),
          CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        ],
        selected: raise,
      );

      expect(money.streetBets, [15, 5]);
      expect(money.potTotal, 25);
      expect(money.heroActionLabel, 'RAISE');
      expect(money.villainActionLabel, 'BET');
      expect(lessonActionPotChipLabel(money), 'Pot 25');
    });

    test('a raise smaller than the facing bet is added on top', () {
      const raise = CourseChoice(
        id: 'min-raise',
        label: 'Raise 4',
        action: 'RAISE',
      );
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Jh', 'Td'],
          boardCodes: ['9c', '8s', '2h'],
          potLabel: 'Pot 10',
          villainLine: 'Villain bets 5',
          facingBet: true,
        ),
        choices: const [
          CourseChoice(id: 'call', label: 'Call 5', action: 'CALL'),
          raise,
        ],
        selected: raise,
      );

      expect(money.streetBets, [9, 5]);
      expect(money.potTotal, 19);
      expect(money.heroActionLabel, 'RAISE');
    });

    test('All-in adds the short stack on top of a larger bet', () {
      const shove = CourseChoice(
        id: 'shove-12',
        label: 'All-in 12',
        action: 'ALL_IN',
      );
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['7h', '2d'],
          potLabel: 'Pot 30',
          villainLine: 'Villain bets 20',
          facingBet: true,
          stackLabel: 'Stack 12',
        ),
        choices: const [
          shove,
          CourseChoice(id: 'call-20', label: 'Call 20', action: 'CALL'),
          CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        ],
        selected: shove,
      );

      expect(money.streetBets, [12, 20]);
      expect(money.potTotal, 42);
      expect(money.heroActionLabel, 'ALL-IN');
    });

    test('Check and Fold leave the facing bet and pot alone', () {
      const spot = LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['9c', '8s', '2h'],
        potLabel: 'Pot 10',
        villainLine: 'Villain bets 5',
        facingBet: true,
      );
      const choices = [
        CourseChoice(id: 'call', label: 'Call 5', action: 'CALL'),
        CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
      ];
      for (final selected in choices.skip(1)) {
        final money = resolveLessonActionFeltMoney(
          spot: spot,
          choices: choices,
          selected: selected,
        );
        expect(money.potTotal, 10);
        expect(money.streetBets, [0, 5]);
        expect(money.heroActionLabel, isNull);
      }
    });

    test('an open pot ignores a bet mentioned in the villain line', () {
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          potLabel: 'Pot 10',
          villainLine: 'Villain bets 5',
          facingBet: false,
          openPot: true,
        ),
        choices: const [
          CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
        ],
      );

      expect(money.potTotal, 10);
      expect(money.streetBets, [0, 0]);
      expect(money.villainActionLabel, isNull);
    });

    test('a one-seat table does not invent a villain street bet', () {
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Ah', 'Kd'],
          potLabel: 'Pot 10',
          villainLine: 'Villain bets 5',
          facingBet: true,
        ),
        choices: const [
          CourseChoice(id: 'call', label: 'Call 5', action: 'CALL'),
        ],
        seatCount: 0,
      );

      expect(money.streetBets, [0]);
      expect(money.potTotal, 10);
      expect(money.villainActionLabel, 'BET');
    });
  });

  group('pot and choice chip parsing', () {
    test('pot labels keep the live total and drop annotations', () {
      expect(parseLessonPotChips('Pot 3 → 9 → 29'), 29);
      expect(parseLessonPotChips('Pot 24 · 3-way'), 24);
      expect(parseLessonPotChips('Pot ~60 · SPR ~1'), 60);
      expect(parseLessonPotChips('Pot 1.5'), 1.5);
      expect(parseLessonPotChips('Pot'), isNull);
      expect(
        lessonActionPotChipLabel(
          const LessonActionFeltMoney(potTotal: 1.5, streetBets: []),
        ),
        'Pot 1.5',
      );
    });

    test('facing lines read the raise-to or bet size', () {
      expect(parseFacingBetChips('UTG 3-bets to 18'), 18);
      expect(parseFacingBetChips('SB re-raises to 40'), 40);
      expect(parseFacingBetChips('BTN opens to 6'), 6);
      expect(parseFacingBetChips('Villain bets 5'), 5);
      expect(parseFacingBetChips('Checked to you'), isNull);
      expect(parseFacingBetChips(null), isNull);
      expect(parseFacingBetChips(''), isNull);
    });

    test('choice chips prefer the label and fall back to big blinds', () {
      expect(
        parseChoiceChipAmount(
          const CourseChoice(
            id: 'raise',
            label: 'Raise to 15',
            action: 'RAISE',
            amountBb: 9,
          ),
        ),
        15,
      );
      expect(
        parseChoiceChipAmount(
          const CourseChoice(
            id: 'jam',
            label: 'Jam',
            action: 'RAISE',
            amountBb: 9,
          ),
        ),
        18,
      );
      expect(
        parseChoiceChipAmount(
          const CourseChoice(
            id: 'jam',
            label: 'Jam',
            action: 'RAISE',
            amountBb: 2.5,
          ),
          bigBlind: 1,
        ),
        2.5,
      );
      expect(
        parseChoiceChipAmount(
          const CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        ),
        isNull,
      );
    });

    test('a sizeless raise uses amountBb at the lesson big blind', () {
      const jam = CourseChoice(
        id: 'jam',
        label: 'Jam',
        action: 'RAISE',
        amountBb: 9,
      );
      final money = resolveLessonActionFeltMoney(
        spot: const LessonActionSpot(
          heroCodes: ['Ah', 'Kd'],
          potLabel: 'Pot 3 → 9',
          villainLine: 'BTN opens to 6',
          facingBet: true,
        ),
        choices: const [
          CourseChoice(id: 'call', label: 'Call 4', action: 'CALL'),
          jam,
        ],
        selected: jam,
      );

      expect(money.streetBets, [18, 6]);
      expect(money.potTotal, 25);
      expect(money.heroActionLabel, 'RAISE');
    });
  });

  test('applyLessonActionFeltMoney keeps stacks and clamps the main pot', () {
    final base = GameState(
      mode: GameMode.training,
      players: const [
        PlayerModel(
          id: 0,
          name: 'You',
          archetype: PlayerArchetype.hero,
          stack: 100,
          isHero: true,
          currentBet: 2,
        ),
        PlayerModel(
          id: 1,
          name: 'Sam',
          archetype: PlayerArchetype.tag,
          stack: 98,
          currentBet: 6,
          lastActionLabel: 'OLD',
        ),
        PlayerModel(
          id: 2,
          name: 'Jo',
          archetype: PlayerArchetype.nit,
          stack: 80,
          currentBet: 1,
          lastActionLabel: 'LIMP',
        ),
      ],
    );
    final applied = applyLessonActionFeltMoney(
      base,
      const LessonActionFeltMoney(
        potTotal: 25,
        streetBets: [18, 6],
        heroActionLabel: 'RAISE',
        villainActionLabel: 'BET',
      ),
    );

    expect(applied.players[0].currentBet, 18);
    expect(applied.players[0].stack, 84);
    expect(applied.players[0].lastActionLabel, 'RAISE');
    expect(applied.players[1].currentBet, 6);
    expect(applied.players[1].stack, 98);
    expect(applied.players[1].lastActionLabel, 'BET');
    expect(applied.players[2].currentBet, 0);
    expect(applied.players[2].stack, 81);
    expect(applied.players[2].lastActionLabel, isNull);
    expect(applied.mainPot, 1);
    expect(applied.highestBet, 18);
    expect(applied.displayPot, 25);

    final clamped = applyLessonActionFeltMoney(
      base,
      const LessonActionFeltMoney(potTotal: 5, streetBets: [6, 6]),
    );
    expect(clamped.mainPot, 0);
    expect(clamped.displayPot, 12);
    expect(clamped.players[0].lastActionLabel, isNull);
    expect(clamped.players[1].lastActionLabel, isNull);
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
    overrides: [heroIdentityProvider.overrideWithValue(const HeroIdentity())],
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
