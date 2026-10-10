/// Unit tests for constrained lesson card deals.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_starting_hand_copy.dart';

bool _isSuited(List<String> codes) {
  final a = CardModel.fromCode(codes[0]);
  final b = CardModel.fromCode(codes[1]);
  return a.suit == b.suit && a.rank != b.rank;
}

bool _isOffsuit(List<String> codes) {
  final a = CardModel.fromCode(codes[0]);
  final b = CardModel.fromCode(codes[1]);
  return a.suit != b.suit && a.rank != b.rank;
}

bool _isPair(List<String> codes) {
  final a = CardModel.fromCode(codes[0]);
  final b = CardModel.fromCode(codes[1]);
  return a.rank == b.rank && a.suit != b.suit;
}

void main() {
  tearDown(() {
    debugLessonCardDealRandom = null;
    debugFreezeLessonSuitRemap = false;
    lessonDealAttemptSalt = '';
  });

  test('dealHoleHand preserves attributes across kinds', () {
    final rng = Random(7);
    for (var i = 0; i < 40; i++) {
      expect(_isSuited(dealHoleHand(LessonHoleKind.suitedNonPair, rng)), isTrue);
      expect(_isOffsuit(dealHoleHand(LessonHoleKind.offsuitNonPair, rng)), isTrue);
      expect(_isPair(dealHoleHand(LessonHoleKind.pocketPair, rng)), isTrue);
      final ace = dealHoleHand(LessonHoleKind.suitedAce, rng);
      expect(_isSuited(ace), isTrue);
      expect(ace.any((c) => c.startsWith('A')), isTrue);
      final broadway = dealHoleHand(LessonHoleKind.broadway, rng);
      expect(_isOffsuit(broadway), isTrue);
      for (final code in broadway) {
        expect('TJQKA'.contains(code[0]), isTrue);
      }
    }
  });

  test('suited seat plan shuffles cards and seats but keeps roles', () {
    final activity = CourseActivity(
      id: 'act-01-01-02-unguided-suited',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat whose hole cards share a suit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the suited hole cards.',
      choices: const [
        CourseChoice(id: 'suited-ah-kh', label: 'Ah Kh'),
        CourseChoice(id: 'offsuit-ah-kd', label: 'Ac Kd'),
        CourseChoice(id: 'pair-77', label: '7c 7d'),
      ],
    );

    final deals = [
      for (var seed = 0; seed < 24; seed++)
        dealHoleHandSeatPlan(activity, random: Random(seed))!,
    ];
    expect(deals.map((d) => d.correctSeatIndex).toSet().length, greaterThan(1));
    expect(
      deals.map((d) => d.heroCodes.join(' ')).toSet().length,
      greaterThan(1),
    );

    for (final deal in deals) {
      final byId = <String, List<String>>{
        deal.choiceIdsBySeat[0]: deal.heroCodes,
        deal.choiceIdsBySeat[1]: deal.villainHoleCodes[0],
        deal.choiceIdsBySeat[2]: deal.villainHoleCodes[1],
      };
      expect(_isSuited(byId['suited-ah-kh']!), isTrue);
      expect(_isOffsuit(byId['offsuit-ah-kd']!), isTrue);
      expect(_isPair(byId['pair-77']!), isTrue);
      expect(deal.choiceIdForSeat(deal.correctSeatIndex), 'suited-ah-kh');
      final all = [
        ...deal.heroCodes,
        ...deal.villainHoleCodes[0],
        ...deal.villainHoleCodes[1],
      ];
      expect(all.toSet().length, 6);
    }
  });

  test('pocket-pair seat plan keeps exactly one pair as the answer', () {
    final activity = CourseActivity(
      id: 'act-01-01-02-checkpoint-pair',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Tap the seat with a pocket pair.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the pocket pair.',
      choices: const [
        CourseChoice(id: 'pocket-pair', label: '9h 9d'),
        CourseChoice(id: 'suited-nine', label: 'Ah Kh'),
        CourseChoice(id: 'two-high', label: 'Ac Kd'),
      ],
    );
    for (var seed = 0; seed < 16; seed++) {
      final deal = dealHoleHandSeatPlan(activity, random: Random(seed))!;
      expect(deal.choiceIdForSeat(deal.correctSeatIndex), 'pocket-pair');
      final codes = deal.correctSeatIndex == 0
          ? deal.heroCodes
          : deal.villainHoleCodes[deal.correctSeatIndex - 1];
      expect(_isPair(codes), isTrue);
    }
  });

  test('one-of-each-suit board keeps suit order and unique ranks', () {
    final boards = [
      for (var seed = 0; seed < 20; seed++)
        dealOneOfEachSuitBoard(random: Random(seed)),
    ];
    expect(boards.map((b) => b.join(' ')).toSet().length, greaterThan(1));
    for (final board in boards) {
      expect(board.map((c) => c[c.length - 1]).toList(), ['h', 'd', 'c', 's']);
      expect(board.map((c) => c.substring(0, c.length - 1)).toSet().length, 4);
    }
  });

  test('showdown order deals vary cards and seat roles but keep ladder', () {
    const cases = <String, List<String>>{
      'act-01-02-01-unguided-compare': [
        'Full House',
        'Three of a Kind',
        'Two Pair',
      ],
      'act-01-02-01-checkpoint-winner': ['Flush', 'Straight', 'High Card'],
      'act-01-02-01-explain-ladder': ['High Card', 'One Pair', 'Flush'],
      'act-01-02-01-scaffolded-spot': ['One Pair', 'Straight', 'Flush'],
    };

    for (final entry in cases.entries) {
      final deals = [
        for (var seed = 0; seed < 12; seed++)
          dealShowdownOrderCards(entry.key, random: Random(seed))!,
      ];
      expect(
        deals.map((d) => d.boardCodes.join(' ')).toSet().length,
        greaterThan(1),
        reason: entry.key,
      );
      expect(
        deals.map((d) => d.seatIds.join(',')).toSet().length,
        greaterThan(1),
        reason: '${entry.key} seat shuffle',
      );
      for (final deal in deals) {
        expect(deal.correctOrder, ['you', 'sam', 'jo'], reason: entry.key);
        expect(
          deal.seatIds.toSet(),
          {'you', 'sam', 'jo'},
          reason: entry.key,
        );
        List<String> codesForRole(String role) {
          final idx = deal.seatIds.indexOf(role);
          if (idx == 0) return deal.heroCodes;
          return deal.villainHoleCodes[idx - 1];
        }

        String name(List<String> holes) {
          final cards = [
            for (final code in [...holes, ...deal.boardCodes])
              CardModel.fromCode(code),
          ];
          return DeckEvaluator.evaluate7Cards(cards).rankName;
        }

        expect(name(codesForRole('you')), entry.value[0], reason: entry.key);
        expect(name(codesForRole('sam')), entry.value[1], reason: entry.key);
        expect(name(codesForRole('jo')), entry.value[2], reason: entry.key);
      }
    }
  });

  test('suit remap keeps relative suits across hole and board', () {
    final remapped = permuteCardSuitGroups(
      [
        ['Ah', 'Kd'],
        ['Kh', '7c', '2d'],
      ],
      Random(3),
    );
    // Original hearts (Ah, Kh) share a suit after remap.
    expect(remapped[0][0][1], remapped[1][0][1]);
  });

  test('startingHandFamilyFromCodes buckets strategy holdings', () {
    expect(
      startingHandFamilyFromCodes(['7h', '2d']),
      LessonStartingHandFamily.junkOffsuit,
    );
    expect(
      startingHandFamilyFromCodes(['Kh', 'Kd']),
      LessonStartingHandFamily.premiumPair,
    );
    expect(
      startingHandFamilyFromCodes(['2h', '2d']),
      LessonStartingHandFamily.smallPair,
    );
    expect(
      startingHandFamilyFromCodes(['Ah', 'Kd']),
      LessonStartingHandFamily.offsuitBroadway,
    );
    expect(
      startingHandFamilyFromCodes(['Ah', '7d']),
      LessonStartingHandFamily.weakAceOffsuit,
    );
    expect(
      startingHandFamilyFromCodes(['Ah', '9h']),
      LessonStartingHandFamily.suitedAce,
    );
  });

  test('startingHandLabelFromCodes uses chart notation', () {
    expect(startingHandLabelFromCodes(['Kh', '9h']), 'K9s');
    expect(startingHandLabelFromCodes(['Th', '8h']), 'T8s');
    expect(startingHandLabelFromCodes(['Ah', 'Td']), 'ATo');
    expect(startingHandLabelFromCodes(['Qh', 'Qd']), 'QQ');
  });

  test('alignStartingHandCopy rewrites catalog combos to the dealt hand', () {
    expect(
      alignStartingHandCopy(
        text: 'Folds to you on the button with K9s. Action?',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Th', '8h'],
      ),
      'Folds to you on the button with T8s. Action?',
    );
    expect(
      alignStartingHandCopy(
        text: 'Open king-nine suited on the button.',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Th', '8h'],
      ),
      'Open ten-eight suited on the button.',
    );
    expect(
      alignStartingHandCopy(
        text: 'Queens on the button vs a CO open — reopen for value.',
        templateHero: const ['Qh', 'Qd'],
        dealtHero: const ['Kh', 'Kd'],
      ),
      'Kings on the button vs a CO open — reopen for value.',
    );
    expect(
      alignStartingHandCopy(
        text: '72o faces a BB 3-bet — leave without defending trash.',
        templateHero: const ['7h', '2d'],
        dealtHero: const ['9c', '3h'],
      ),
      '93o faces a BB 3-bet — leave without defending trash.',
    );
    expect(
      alignStartingHandCopy(
        text: 'A bet faces you with AA.',
        templateHero: const ['Ah', 'Ad'],
        dealtHero: const ['Kh', 'Kd'],
      ),
      'A bet faces you with KK.',
    );
  });

  test('dealStartingHandFamily stays in the requested family', () {
    final rng = Random(11);
    for (final family in LessonStartingHandFamily.values) {
      for (var i = 0; i < 12; i++) {
        final dealt = dealStartingHandFamily(family, rng);
        expect(
          startingHandFamilyFromCodes(dealt),
          family,
          reason: '$family deal $dealt',
        );
      }
    }
  });

  test('preflop isomorphic deal varies ranks inside family', () {
    final families = <String>{};
    final ranks = <String>{};
    for (var seed = 0; seed < 24; seed++) {
      final groups = isomorphicLessonCardGroups(
        [
          ['7h', '2d'],
          <String>[],
        ],
        Random(seed),
      );
      families.add(startingHandFamilyFromCodes(groups[0]).name);
      ranks.add(
        [
          for (final c in groups[0]) CardModel.fromCode(c).rank,
        ].join(','),
      );
    }
    expect(families, {'junkOffsuit'});
    expect(ranks.length, greaterThan(1));
  });

  test('postflop isomorphic deal preserves HandClass and draw outs', () {
    const cases = <List<List<String>>>[
      [
        ['Ah', 'Kd'],
        ['Qs', '7c', '2d'],
      ],
      [
        ['Ah', '9h'],
        ['Jh', '8h', '3c'],
      ],
    ];

    for (final spot in cases) {
      final hero = spot[0];
      final board = spot[1];
      final targetClass = HandClassifier.classify(
        FastEvaluator.encode(CardModel.fromCode(hero[0])),
        FastEvaluator.encode(CardModel.fromCode(hero[1])),
        [
          for (final code in board)
            FastEvaluator.encode(CardModel.fromCode(code)),
        ],
      );
      final targetOuts = HandClassifier.drawOuts(
        FastEvaluator.encode(CardModel.fromCode(hero[0])),
        FastEvaluator.encode(CardModel.fromCode(hero[1])),
        [
          for (final code in board)
            FastEvaluator.encode(CardModel.fromCode(code)),
        ],
      );

      for (var seed = 0; seed < 16; seed++) {
        final groups = isomorphicLessonCardGroups(
          [hero, board],
          Random(seed),
        );
        final gotClass = HandClassifier.classify(
          FastEvaluator.encode(CardModel.fromCode(groups[0][0])),
          FastEvaluator.encode(CardModel.fromCode(groups[0][1])),
          [
            for (final code in groups[1])
              FastEvaluator.encode(CardModel.fromCode(code)),
          ],
        );
        final gotOuts = HandClassifier.drawOuts(
          FastEvaluator.encode(CardModel.fromCode(groups[0][0])),
          FastEvaluator.encode(CardModel.fromCode(groups[0][1])),
          [
            for (final code in groups[1])
              FastEvaluator.encode(CardModel.fromCode(code)),
          ],
        );
        expect(
          gotClass,
          targetClass,
          reason: 'seed $seed → ${groups[0]} on ${groups[1]}',
        );
        expect(
          gotOuts,
          targetOuts,
          reason: 'outs seed $seed → ${groups[0]} on ${groups[1]}',
        );
        final all = [...groups[0], ...groups[1]];
        expect(all.toSet().length, all.length);
      }
    }
  });

  test('suitOnly isomorphic path keeps ranks', () {
    final groups = isomorphicLessonCardGroups(
      [
        ['Ah', '9d'],
        ['As', '7c', '2h'],
      ],
      Random(5),
      suitOnly: true,
    );
    expect(
      [for (final c in groups[0]) CardModel.fromCode(c).rank]..sort(),
      [9, 14],
    );
    expect(
      [for (final c in groups[1]) CardModel.fromCode(c).rank]..sort(),
      [2, 7, 14],
    );
  });

  test('shuffledLessonChoices is seeded and id-stable', () {
    const choices = [
      CourseChoice(id: 'fold', label: 'Fold'),
      CourseChoice(id: 'call', label: 'Call'),
      CourseChoice(id: 'raise', label: 'Raise'),
    ];
    final a = shuffledLessonChoices(
      choices,
      activityId: 'act-test',
      generation: 1,
    );
    final b = shuffledLessonChoices(
      choices,
      activityId: 'act-test',
      generation: 1,
    );
    expect(a.map((c) => c.id).toList(), b.map((c) => c.id).toList());
    expect(a.map((c) => c.id).toSet(), {'fold', 'call', 'raise'});

    final orders = <String>{};
    for (var gen = 0; gen < 16; gen++) {
      orders.add(
        shuffledLessonChoices(
          choices,
          activityId: 'act-test',
          generation: gen,
        ).map((c) => c.id).join(','),
      );
    }
    expect(orders.length, greaterThan(1));
  });

  test('coordinated remap keeps relative kickers across hero and villain', () {
    const hero = ['Ah', 'Qd'];
    const board = ['Kh', 'Kd', '7c', '3s', '2d'];
    const villain = ['As', 'Jd'];
    for (var seed = 0; seed < 20; seed++) {
      final groups = isomorphicLessonCardGroups(
        [hero, board, villain],
        Random(seed),
        coordinated: true,
      );
      final h = [
        CardModel.fromCode(groups[0][0]),
        CardModel.fromCode(groups[0][1]),
      ]..sort((a, b) => b.rank.compareTo(a.rank));
      final v = [
        CardModel.fromCode(groups[2][0]),
        CardModel.fromCode(groups[2][1]),
      ]..sort((a, b) => b.rank.compareTo(a.rank));
      final bCards = [
        for (final c in groups[1]) CardModel.fromCode(c),
      ];
      // Board still pairs (two equal top ranks from authored KK).
      final boardRanks = bCards.map((c) => c.rank).toList()..sort();
      expect(boardRanks[3], boardRanks[4]); // two highest equal (pair)
      // Hero's second card still outranks villain's second (Q > J).
      expect(h[1].rank, greaterThan(v[1].rank));
      // Shared top hole rank (ace) stays tied.
      expect(h[0].rank, v[0].rank);
    }
  });

  test('attempt salt changes the deal for the same activity generation', () {
    lessonDealAttemptSalt = 'attempt-a';
    final a = isomorphicLessonCardGroups(
      [
        ['7h', '2d'],
        <String>[],
      ],
      resolveLessonDealRandom(activityId: 'act-fold', generation: 1),
    );
    lessonDealAttemptSalt = 'attempt-b';
    final b = isomorphicLessonCardGroups(
      [
        ['7h', '2d'],
        <String>[],
      ],
      resolveLessonDealRandom(activityId: 'act-fold', generation: 1),
    );
    expect(a[0].join(' '), isNot(b[0].join(' ')));
  });

  test('retry generation stays in family but changes the preflop hand', () {
    const template = [
      ['7h', '2d'],
      <String>[],
    ];
    const family = LessonStartingHandFamily.junkOffsuit;
    final first = isomorphicLessonCardGroups(
      template,
      resolveLessonDealRandom(activityId: 'act-fold-retry', generation: 0),
    );
    expect(startingHandFamilyFromCodes(first[0]), family);

    final labels = <String>{startingHandLabelFromCodes(first[0])};
    for (var gen = 1; gen < 12; gen++) {
      final next = isomorphicLessonCardGroups(
        template,
        resolveLessonDealRandom(activityId: 'act-fold-retry', generation: gen),
      );
      expect(
        startingHandFamilyFromCodes(next[0]),
        family,
        reason: 'gen $gen ${next[0]}',
      );
      labels.add(startingHandLabelFromCodes(next[0]));
    }
    // Continue-after-miss bumps generation so the learner sees another
    // combo from the same family, not the missed layout again.
    expect(labels.length, greaterThan(1));
  });

  test('dealRankOrderSpot remaps ranks and keeps authored ids', () {
    const authored = [
      (id: 'rank-2', label: '2'),
      (id: 'rank-T', label: 'T'),
      (id: 'rank-A', label: 'A'),
    ];
    final a = dealRankOrderSpot(
      authoredItems: authored,
      activityId: 'act-ranks',
      generation: 0,
      distractorCode: 'Hs',
      random: Random(4),
    );
    final b = dealRankOrderSpot(
      authoredItems: authored,
      activityId: 'act-ranks',
      generation: 0,
      distractorCode: 'Hs',
      random: Random(21),
    );
    expect([for (final item in a.sequenceItems) item.id], [
      'rank-2',
      'rank-T',
      'rank-A',
    ]);
    expect(a.boardCodes.contains('Hs'), isTrue);
    expect(a.heroCodes.length, 2);
    expect(
      [for (final item in a.sequenceItems) item.label].join(','),
      isNot([for (final item in b.sequenceItems) item.label].join(',')),
    );
    expect(
      startingHandFamilyFromCodes(a.heroCodes),
      isNotNull,
    );
  });

  test('hole-hand seat roles deal inside starting-hand families', () {
    final deal = dealHoleHandSeatPlan(
      const CourseActivity(
        id: 'act-01-01-02-unguided-suited',
        order: 1,
        stage: ActivityStage.unguided,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 40,
        accessibilityText: 'suited',
        acceptedGrades: [SoftGrade.recommended],
        choices: [
          CourseChoice(id: 'suited-ah-kh', label: 'Suited'),
          CourseChoice(id: 'offsuit-ah-kd', label: 'Offsuit'),
          CourseChoice(id: 'pair-77', label: 'Pocket pair'),
        ],
      ),
      random: Random(5),
    )!;
    final seats = [deal.heroCodes, ...deal.villainHoleCodes];
    final byChoice = {
      for (var i = 0; i < deal.choiceIdsBySeat.length; i++)
        deal.choiceIdsBySeat[i]: seats[i],
    };
    expect(
      startingHandFamilyFromCodes(byChoice['suited-ah-kh']!),
      LessonStartingHandFamily.suitedNonPair,
    );
    expect(
      startingHandFamilyFromCodes(byChoice['offsuit-ah-kd']!),
      LessonStartingHandFamily.offsuitNonPair,
    );
    expect(
      startingHandFamilyFromCodes(byChoice['pair-77']!),
      LessonStartingHandFamily.mediumPair,
    );
  });

  test('dealtBestFiveSpot remaps choice sets with the holes', () {
    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Best'),
        CourseChoice(id: 'weak-kickers', label: 'Weak'),
        CourseChoice(id: 'ignore-ace', label: 'Ignore'),
      ],
    );
    final spot = dealtBestFiveSpot(activity, random: Random(9))!;
    final all = spot.allCodes.toSet();
    for (final set in spot.choiceSets.values) {
      expect(set.toSet().difference(all), isEmpty);
      expect(set.toSet().length, 5);
    }
    expect(
      mapBestFiveSelectionToChoiceId(
        selected: spot.choiceSets['best-pair-k']!.toSet(),
        spot: spot,
        choices: activity.choices,
      ),
      'best-pair-k',
    );
  });

  test('best-five explain/guided templates vary ranks across seeds', () {
    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Best'),
        CourseChoice(id: 'weak-kickers', label: 'Weak'),
        CourseChoice(id: 'ignore-ace', label: 'Ignore'),
      ],
    );
    final heroRankKeys = <String>{};
    final boardRankKeys = <String>{};
    for (var seed = 0; seed < 48; seed++) {
      final spot = dealtBestFiveSpot(activity, random: Random(seed))!;
      heroRankKeys.add(
        ([for (final c in spot.heroCodes) CardModel.fromCode(c).rank]..sort())
            .join(','),
      );
      boardRankKeys.add(
        ([for (final c in spot.boardCodes) CardModel.fromCode(c).rank]..sort())
            .join(','),
      );
      // Pair on board still pairs one hole (top pair teach).
      final heroRanks = {
        for (final c in spot.heroCodes) CardModel.fromCode(c).rank,
      };
      final boardRanks = {
        for (final c in spot.boardCodes) CardModel.fromCode(c).rank,
      };
      expect(heroRanks.intersection(boardRanks), isNotEmpty);
    }
    expect(heroRankKeys.length, greaterThan(1));
    expect(boardRankKeys.length, greaterThan(1));

    final explainKeys = <String>{};
    for (var seed = 0; seed < 48; seed++) {
      final deal = dealBestFiveExplainLayout(random: Random(seed));
      final heroRanks =
          [for (final c in deal.hero) CardModel.fromCode(c).rank]..sort();
      final boardRanks =
          [for (final c in deal.board) CardModel.fromCode(c).rank]..sort();
      explainKeys.add('${heroRanks.join(',')}|${boardRanks.join(',')}');
    }
    expect(explainKeys.length, greaterThan(1));
  });

  test('scaffolded kicker scene varies ranks across seeds', () {
    const hero = ['Ah', 'Qd'];
    const board = ['Kh', 'Kd', '7c', '3s', '2d'];
    const villain = ['As', 'Jd'];
    final keys = <String>{};
    for (var seed = 0; seed < 48; seed++) {
      final groups = isomorphicLessonCardGroups(
        [hero, board, villain],
        Random(seed),
        coordinated: true,
      );
      keys.add(
        [
          for (final g in groups)
            ([for (final c in g) CardModel.fromCode(c).rank]..sort()).join('-'),
        ].join('|'),
      );
    }
    expect(keys.length, greaterThan(1));
  });

  test('toy-hand streets keep the same hole suits as the board grows', () {
    const activityId = 'act-07-10-01-hand';
    final flop = dealtToyHandStepSpot(
      activityId: activityId,
      stepId: 'step-flop',
      generation: 4,
    )!;
    final turn = dealtToyHandStepSpot(
      activityId: activityId,
      stepId: 'step-turn',
      generation: 4,
    )!;
    final river = dealtToyHandStepSpot(
      activityId: activityId,
      stepId: 'step-river',
      generation: 4,
    )!;
    expect(flop.heroCodes, turn.heroCodes);
    expect(turn.heroCodes, river.heroCodes);
    expect(turn.boardCodes.take(3), flop.boardCodes);
    expect(river.boardCodes.take(4), turn.boardCodes);
  });
}
