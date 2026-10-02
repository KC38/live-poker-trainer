/// Randomized preflop open-pot math for How pots are won.
///
/// Each attempt picks a BTN open-to size at 1/2. The correct pot is
/// blinds plus the open (SB + BB + open). Choice ids stay semantic so the
/// course bank can grade without listing every chip total.
library;

import 'dart:math';

import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';

/// Activity id for the randomized open-pot quiz.
const String kOpenPotActivityId = 'act-01-05-01-unguided-pot';

/// Semantic choice id for blinds + open.
const String kOpenPotCorrectChoiceId = 'pot-correct';

/// Semantic choice id that drops one blind.
const String kOpenPotMissBlindChoiceId = 'pot-miss-blind';

/// Semantic choice id that over-counts the open.
const String kOpenPotTooBigChoiceId = 'pot-too-big';

/// Live 1/2 open-to sizes the quiz rotates through.
const List<int> kLessonOpenToAmounts = <int>[5, 6, 7, 8, 9, 10];

/// One attempt's open size and the three chip-total answers.
class LessonOpenPotDeal {
  /// Creates a deal.
  const LessonOpenPotDeal({
    required this.openTo,
    required this.smallBlind,
    required this.bigBlind,
  });

  /// BTN open-to amount in chips.
  final int openTo;

  /// Posted small blind.
  final int smallBlind;

  /// Posted big blind.
  final int bigBlind;

  /// Pot before blinds act: both blinds plus the open.
  int get correctPot => smallBlind + bigBlind + openTo;

  /// Distractor that forgets the small blind.
  int get missBlindPot => correctPot - smallBlind;

  /// Distractor that doubles the open instead of adding blinds.
  int get tooBigPot => openTo * 2;

  /// Short felt caption without spoiling the total.
  String get caption =>
      '$smallBlind/$bigBlind · BTN opens $openTo · blinds still to act';

  /// Rex / coach line for this deal.
  String get coachLine =>
      'BTN opens to $openTo — pick the pot before blinds act.';

  /// Accessibility summary for this deal.
  String get accessibilityText =>
      'Tap $correctPot chips — blinds plus the open: '
      '$smallBlind + $bigBlind + $openTo.';

  /// Street bets for a six-max ring: hero at 0, BTN / SB / BB by index.
  List<double> streetBetsForSixMax({
    required int buttonIndex,
    required int smallBlindIndex,
    required int bigBlindIndex,
    int seatCount = 6,
  }) {
    final bets = List<double>.filled(seatCount, 0);
    if (buttonIndex >= 0 && buttonIndex < seatCount) {
      bets[buttonIndex] = openTo.toDouble();
    }
    if (smallBlindIndex >= 0 && smallBlindIndex < seatCount) {
      bets[smallBlindIndex] = smallBlind.toDouble();
    }
    if (bigBlindIndex >= 0 && bigBlindIndex < seatCount) {
      bets[bigBlindIndex] = bigBlind.toDouble();
    }
    return bets;
  }

  /// Rewrites catalog choice labels to this deal's chip totals.
  List<CourseChoice> labeledChoices(List<CourseChoice> authored) {
    return [
      for (final choice in authored)
        CourseChoice(
          id: choice.id,
          label: switch (choice.id) {
            kOpenPotCorrectChoiceId => '$correctPot chips',
            kOpenPotMissBlindChoiceId => '$missBlindPot chips',
            kOpenPotTooBigChoiceId => '$tooBigPot chips',
            _ => choice.label,
          },
          accessibilityText: switch (choice.id) {
            kOpenPotCorrectChoiceId => '$correctPot chips',
            kOpenPotMissBlindChoiceId => '$missBlindPot chips',
            kOpenPotTooBigChoiceId => '$tooBigPot chips',
            _ => choice.accessibilityText,
          },
          action: choice.action,
          amountBb: choice.amountBb,
        ),
    ];
  }
}

/// Picks an open-to size for this lesson attempt.
///
/// Stable for a given [activityId] + [generation] + attempt salt so coach,
/// felt, and choice labels all see the same open. Pass [random] only when a
/// test needs an explicit stream.
LessonOpenPotDeal dealLessonOpenPot({
  String activityId = kOpenPotActivityId,
  int generation = 0,
  Random? random,
  String? salt,
  int smallBlind = 1,
  int bigBlind = 2,
}) {
  final int openTo;
  if (random != null) {
    openTo = kLessonOpenToAmounts[random.nextInt(kLessonOpenToAmounts.length)];
  } else {
    // Fresh seeded RNG each call — never advance a shared debug Random.
    final rng = Random(
      lessonDealSeed(
        activityId,
        generation,
        salt ?? lessonDealAttemptSalt,
      ),
    );
    openTo = kLessonOpenToAmounts[rng.nextInt(kLessonOpenToAmounts.length)];
  }
  return LessonOpenPotDeal(
    openTo: openTo,
    smallBlind: smallBlind,
    bigBlind: bigBlind,
  );
}
