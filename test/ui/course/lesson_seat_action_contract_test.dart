/// Every lesson felt shows the action of every seat that acts before the
/// hero's decision (Kushal, Oct 21: "They should either be folding or
/// calling"). Runs across every catalog activity and multi-step hand step.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_felt_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

/// Violations for one spot; empty when the felt is consistent.
List<String> seatActionViolations(LessonActionSpot spot) {
  final layout = resolveLessonActionFeltLayout(spot);
  if (layout.headsUp) return const <String>[];
  final problems = <String>[];
  final dealer = layout.dealerIndex;
  if (dealer == null) return ['ring without a dealer seat'];
  final nineMax = layout.seatCount == 9;
  final heroPos = parseLessonActionHeroPosition(spot.streetLabel) ?? 'BTN';
  final folded = layout.foldedSeatIndexes.toSet();
  final acting = <int>{
    ...layout.seatActionLabels.keys,
    ...layout.callerSeatIndexes,
  };
  if (folded.contains(0)) problems.add('hero seat is folded');
  if (folded.intersection(acting).isNotEmpty) {
    problems.add('seat both folded and acting: ${folded.intersection(acting)}');
  }
  final preflop = spot.boardCodes.isEmpty;
  if (preflop) {
    String? actor;
    if (spot.facingBet) {
      actor = parseLessonActionVillainPosition(spot.villainLine) ?? 'UTG';
    } else if (!spot.openPot) {
      final lower = spot.villainLine?.toLowerCase() ?? '';
      if (lower.contains('blinds fold')) actor = 'BB';
      if (lower.contains('call') && lower.contains('open')) {
        actor = lessonVillainPositionExcludingHero(
          spot.villainLine,
          heroPosition: heroPos,
        );
      }
    }
    final acted = lessonPreflopSeatsActedBeforeHero(
      heroPosition: heroPos,
      dealerIndex: dealer,
      nineMax: nineMax,
      actorPosition: actor,
    );
    final live = <int>{layout.villainSeatIndex, ...acting};
    for (final seat in acted) {
      if (!folded.contains(seat) && !live.contains(seat)) {
        problems.add('seat $seat acted before hero but shows no action');
      }
    }
    if (spot.facingBet &&
        !layout.seatActionLabels.containsKey(layout.villainSeatIndex)) {
      problems.add('facing seat ${layout.villainSeatIndex} has no RAISE/BET');
    }
  } else {
    if (layout.villainSeatIndex == 0) {
      problems.add('postflop villain drawn in the hero seat');
    }
    final live = <int>{0, layout.villainSeatIndex, ...layout.callerSeatIndexes};
    for (var i = 1; i < layout.seatCount; i++) {
      if (!live.contains(i) && !folded.contains(i)) {
        problems.add('postflop seat $i neither live nor folded');
      }
    }
    if (folded.contains(layout.villainSeatIndex)) {
      problems.add('postflop villain seat is folded');
    }
  }
  return problems;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseCatalog catalog;

  setUpAll(() async {
    final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
    catalog = CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('every lesson felt shows an action for each seat before the hero', () {
    final violations = <String>[];
    var checked = 0;
    for (final section in catalog.sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            final spot = resolveLessonActionSpot(activity);
            if (spot != null) {
              checked++;
              for (final p in seatActionViolations(spot)) {
                violations.add('${activity.id}: $p');
              }
            }
            for (final step in activity.handSteps) {
              final stepSpot = resolveToyHandStepSpot(
                activityId: activity.id,
                stepId: step.id,
              );
              if (stepSpot == null) continue;
              checked++;
              for (final p in seatActionViolations(stepSpot)) {
                violations.add('${activity.id}/${step.id}: $p');
              }
            }
          }
        }
      }
    }
    expect(checked, greaterThan(100));
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  group('preflop fold-through (screenshot spot)', () {
    test('CO opens, hero BTN: UTG and HJ fold, blinds still to act', () {
      const spot = LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'CO opens to 6',
        streetLabel: 'Preflop · Button · KK',
        facingBet: true,
      );
      final layout = resolveLessonActionFeltLayout(spot);
      final dealer = layout.dealerIndex!;
      int seat(String p) =>
          lessonSixMaxSeatIndex(position: p, dealerIndex: dealer);
      expect(layout.foldedSeatIndexes, containsAll([seat('UTG'), seat('HJ')]));
      expect(layout.foldedSeatIndexes, isNot(contains(seat('SB'))));
      expect(layout.foldedSeatIndexes, isNot(contains(seat('BB'))));
      expect(layout.seatActionLabels[seat('CO')], 'RAISE');
      expect(seatActionViolations(spot), isEmpty);
    });

    test('BB 3-bets the BTN open: whole ring acted, only BB live', () {
      const spot = LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3 → 9 → 27',
        villainLine: 'BB 3-bets to 20',
        streetLabel: 'Preflop · BTN · 72o',
        facingBet: true,
      );
      final layout = resolveLessonActionFeltLayout(spot);
      final dealer = layout.dealerIndex!;
      int seat(String p) =>
          lessonSixMaxSeatIndex(position: p, dealerIndex: dealer);
      expect(
        layout.foldedSeatIndexes,
        unorderedEquals([seat('UTG'), seat('HJ'), seat('CO'), seat('SB')]),
      );
    });

    test('9-max CO open folds UTG through HJ', () {
      const spot = LessonActionSpot(
        heroCodes: ['Ah', 'Qd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'CO opens to 6',
        streetLabel: 'Preflop · Button · 9-max',
        facingBet: true,
      );
      final layout = resolveLessonActionFeltLayout(spot);
      expect(layout.foldedSeatIndexes, hasLength(5));
      expect(seatActionViolations(spot), isEmpty);
    });

    test('BB calls your open: earlier seats and SB fold, BB live', () {
      const spot = LessonActionSpot(
        heroCodes: ['Ah', 'Qd'],
        potLabel: 'Pot 13',
        villainLine: 'BB calls your open',
        streetLabel: 'Preflop · Heading to flop',
      );
      final layout = resolveLessonActionFeltLayout(spot);
      final dealer = layout.dealerIndex!;
      int seat(String p) =>
          lessonSixMaxSeatIndex(position: p, dealerIndex: dealer);
      expect(layout.villainSeatIndex, seat('BB'));
      expect(
        layout.foldedSeatIndexes,
        unorderedEquals([seat('UTG'), seat('HJ'), seat('CO'), seat('SB')]),
      );
    });
  });

  test('postflop villain never resolves to the hero seat', () {
    const spot = LessonActionSpot(
      heroCodes: ['Ah', 'Qd'],
      boardCodes: ['Kc', '7s', '2h'],
      potLabel: 'Pot 6.5',
      villainLine: 'BB called BTN open',
      streetLabel: 'Flop · K72r · AQ',
      openPot: true,
    );
    final layout = resolveLessonActionFeltLayout(spot);
    expect(layout.villainSeatIndex, isNot(0));
    expect(
      layout.villainSeatIndex,
      lessonSixMaxSeatIndex(position: 'BB', dealerIndex: layout.dealerIndex!),
    );
  });
}
