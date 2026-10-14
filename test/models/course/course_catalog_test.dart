import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseCatalog catalog;
  late String rawCatalog;

  setUpAll(() async {
    rawCatalog = await rootBundle.loadString('assets/course/v2/catalog.json');
    catalog = CourseCatalog.fromJson(
      jsonDecode(rawCatalog) as Map<String, dynamic>,
    );
  });

  test('client catalog parses with live-cash scope and seven sections', () {
    expect(catalog.scope, 'live_cash_nlh');
    expect(catalog.coachId, 'rex');
    expect(catalog.catalogVersion, '2.0.0');
    expect(catalog.contentChecksum, isNotEmpty);
    expect(catalog.sections, hasLength(7));
    expect(catalog.playerTypes, hasLength(5));
    expect(catalog.sections[0].units, hasLength(8)); // LPT-83 suits+blinds units
    expect(catalog.sections[1].units, hasLength(7));
    // LPT-87+: curriculum splits keep their units; one lesson per concept.
    for (final retired in const [
      'lesson-01-01-03-blinds-and-button',
      'lesson-01-02-01-hand-ranks',
      'lesson-01-02-02-best-five-kickers',
      'lesson-01-03-01-fold-check-call',
      'lesson-01-03-02-bet-raise-allin',
      'lesson-01-04-01-streets-and-order',
      'lesson-01-05-01-winning-pots',
      // LPT-114..140: Section 2 + first Section 3 splits.
      'lesson-02-01-01-position-labels',
      'lesson-02-01-02-acting-order',
      'lesson-02-02-01-hand-families',
      'lesson-02-03-01-open-fold',
      'lesson-02-04-01-facing-raise',
      'lesson-02-05-01-effective-stack',
      'lesson-02-06-01-live-habits',
      'lesson-03-01-01-reading-live-table',
      // LPT-143..163: Section 3 postflop splits.
      'lesson-03-02-01-flop-hand-classes',
      'lesson-03-03-01-outs-and-price',
      'lesson-03-04-01-flop-decisions',
      'lesson-03-05-01-turn-decisions',
      'lesson-03-06-01-river-decisions',
      'lesson-03-07-01-multiway-fundamentals',
      'lesson-03-08-01-leak-repair',
      // s4a (LPT-169/172/176/179/182/215/218)
      'lesson-04-01-01-ranges-not-hands',
      'lesson-04-02-01-threebet-squeeze',
      'lesson-04-03-01-continuation-plans',
      'lesson-04-04-01-sizing-communicates',
      'lesson-04-05-01-spr-commitment',
      'lesson-04-09-01-type-identification',
      'lesson-04-10-01-exploit-checkpoints',
      // s4b (LPT-186/189/195/198/202/205/208/212)
      'lesson-04-06-01-observe-sticky-caller',
      'lesson-04-06-02-meet-calling-station',
      'lesson-04-07-01-observe-narrow-player',
      'lesson-04-07-02-meet-nit',
      'lesson-04-07-03-adjust-nit',
      'lesson-04-08-01-observe-wild-aggressor',
      'lesson-04-08-02-meet-maniac',
      'lesson-04-08-03-adjust-maniac',
      // s5 multiway / deep / session
      'lesson-05-01-01-multiway-ranges',
      'lesson-05-02-01-deep-stack-play',
      'lesson-05-03-01-implied-odds',
      'lesson-05-04-01-thin-value-bluffcatch',
      'lesson-05-05-01-lines-and-probes',
      'lesson-05-06-01-line-reading',
      'lesson-05-07-01-timing-sizing-evidence',
      'lesson-05-08-01-table-dynamics',
      'lesson-05-09-01-session-discipline',
      // s6a advanced solver concepts
      'lesson-06-01-01-range-nut-advantage',
      'lesson-06-02-01-equity-realization',
      'lesson-06-03-01-capped-uncapped',
      'lesson-06-04-01-polar-merged',
      'lesson-06-05-01-overbets-geometric',
      'lesson-06-06-01-blockers',
      'lesson-06-07-01-minimum-defense',
      'lesson-06-08-01-mixed-strategy',
      'lesson-06-09-01-threebet-fourbet',
      'lesson-06-10-01-difficult-folds',
      // LPT-batch-split-s6b-types
      'lesson-06-11-01-observe-selective',
      'lesson-06-11-02-meet-tag',
      'lesson-06-11-03-adjust-tag',
      'lesson-06-12-01-observe-wide-pressure',
      'lesson-06-12-02-meet-lag',
      'lesson-06-12-03-adjust-lag',
      'lesson-06-13-01-mix-five-types',
    ]) {
      expect(catalog.lessonById(retired), isNull, reason: retired);
      final successors = catalog.lessonSplitMap[retired];
      expect(successors, hasLength(greaterThanOrEqualTo(2)), reason: retired);
      for (final id in successors!) {
        expect(catalog.lessonById(id), isNotNull, reason: id);
      }
    }
    expect(
      catalog.lessonSplitMap['lesson-01-01-02-suits-and-ranks'],
      [
        'lesson-01-01-02-01-suits',
        'lesson-01-01-02-02-ranks',
        'lesson-01-01-02-03-pairs-and-suited',
      ],
    );
  });

  test('lesson and activity ids are unique and ordered', () {
    final lessonIds = catalog.lessonIdsInOrder;
    final activityIds = catalog.activityIdsInOrder;
    expect(lessonIds.toSet(), hasLength(lessonIds.length));
    expect(activityIds.toSet(), hasLength(activityIds.length));
    expect(lessonIds.first, 'lesson-01-01-01-your-two-cards');
    expect(lessonIds.last, 'lesson-07-12-01-five-type-final');
    expect(activityIds, contains('act-01-06-01-unguided-lab'));
    expect(activityIds, contains('act-02-07-01-unguided-lab'));
    expect(activityIds, contains('act-01-01-01-explain-hole-cards'));
  });

  test('client catalog json contains no private grading keys', () {
    for (final token in [
      '"grading"',
      '"correctSequence"',
      '"sequenceGrading"',
      '"handLabSpec"',
      '"betterChoiceId"',
      '"reversalRead"',
      '"missGrading"',
      '"acceptedMin"',
      '"acceptedMax"',
    ]) {
      expect(rawCatalog.contains(token), isFalse, reason: token);
    }
  });

  test('preflop seat-order lessons include CO between HJ and BTN', () {
    final scaffolded = catalog.activityById('act-01-04-01-scaffolded-order');
    expect(scaffolded, isNotNull);
    expect(scaffolded!.sequenceItems.map((item) => item.id).toList(), [
      'seat-utg',
      'seat-hj',
      'seat-co',
      'seat-btn',
    ]);

    final jump = catalog.activityById('act-01-06-02-jump-order');
    expect(jump, isNotNull);
    expect(jump!.sequenceItems.map((item) => item.id).toList(), [
      'j-utg',
      'j-hj',
      'j-co',
      'j-btn',
    ]);
  });

  test('player types are introduced before later refs', () {
    final introduced = <CoursePlayerTypeId>{};
    for (final section in catalog.sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          introduced.addAll(lesson.introducesPlayerTypes);
          for (final type in lesson.playerTypeRefs) {
            expect(
              introduced.contains(type),
              isTrue,
              reason: '${lesson.id} refs $type before intro',
            );
          }
        }
      }
    }
    expect(introduced, hasLength(5));
  });

  group('lessonById', () {
    test('exact id wins', () {
      final lesson = catalog.lessonById('lesson-01-01-01-your-two-cards');
      expect(lesson, isNotNull);
      expect(lesson!.id, 'lesson-01-01-01-your-two-cards');
    });

    test('unique numeric prefix resolves truncated openlesson ids', () {
      final first = catalog.lessonById('lesson-01-01-01');
      expect(first, isNotNull);
      expect(first!.id, 'lesson-01-01-01-your-two-cards');

      // post-split: lesson-06-11-01-* is ambiguous; use a still-unique SS-UU-LL.
      final warmup = catalog.lessonById('lesson-07-11-01');
      expect(warmup, isNotNull);
      expect(warmup!.id, 'lesson-07-11-01-live-warmup-prep');
    });

    test('ambiguous prefix returns null', () {
      expect(catalog.lessonById('lesson-01-01'), isNull);
      expect(catalog.lessonById('lesson-01'), isNull);
      // curriculum split turned observe-selective into three successors
      expect(catalog.lessonById('lesson-06-11-01'), isNull);
    });

    test('empty and unknown ids return null', () {
      expect(catalog.lessonById(''), isNull);
      expect(catalog.lessonById('lesson-99-99-99'), isNull);
    });
  });

  group('wire parsers fail closed', () {
    test('known stage, renderer, and player type ids map', () {
      expect(activityStageFromWire('jump_test'), ActivityStage.scaffolded);
      expect(activityStageFromWire('explain'), ActivityStage.guided);
      expect(
        assessmentRoleFromWire(legacyStage: 'jump_test'),
        AssessmentRole.jumpTest,
      );
      expect(
        assessmentRoleFromWire(assessmentRole: 'checkpoint'),
        AssessmentRole.checkpoint,
      );
      expect(
        assessmentRoleFromWire(assessmentRole: 'transfer'),
        AssessmentRole.transfer,
      );
      expect(
        activityRendererFromWire('full_table_hand_lab'),
        ActivityRenderer.fullTableHandLab,
      );
      expect(
        coursePlayerTypeIdFromWire('calling_station'),
        CoursePlayerTypeId.callingStation,
      );
    });

    test('unknown wire ids throw instead of guessing a lesson type', () {
      expect(() => activityStageFromWire('jump-test'), throwsFormatException);
      expect(
        () => activityRendererFromWire('mini_felt'),
        throwsFormatException,
      );
      expect(() => coursePlayerTypeIdFromWire('fish'), throwsFormatException);
    });

    test('choice amountBb keeps decimals and stays null when omitted', () {
      final sized = CourseChoice.fromJson(<String, dynamic>{
        'id': 'raise',
        'label': '3-bet to 18',
        'action': 'RAISE',
        'amountBb': 9,
      });
      expect(sized.amountBb, 9);
      expect(sized.action, 'RAISE');

      final fractional = CourseChoice.fromJson(<String, dynamic>{
        'id': 'open',
        'label': 'Open',
        'amountBb': 2.5,
      });
      expect(fractional.amountBb, 2.5);

      final bare = CourseChoice.fromJson(<String, dynamic>{
        'id': 'fold',
        'label': 'Fold',
      });
      expect(bare.amountBb, isNull);
      expect(bare.action, isNull);
    });
  });
}
