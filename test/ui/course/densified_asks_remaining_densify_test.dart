// LPT-628 remaining densify-tap arms (17) reach selectIdentifyDensifiedCoachLine.
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-01-01-03-checkpoint-layout':
      'The button has the D chip. Tap the small blind, one seat to its left.',
  'act-01-02-02-scaffolded-kicker': 'Same pair on the board. Tap your cards if your kicker wins, their cards if theirs wins, or Chop if you tie.',
  'act-01-02-02-unguided-board': 'Both checked down. Tap the board if both play it, or a player\'s cards if you think their holes win.',
  'act-01-05-01-unguided-pot': 'BTN opens — tap the pot before blinds act.',
  'act-04-07-02-guided':
      'Seat plays ~8% of hands and 3-bets rarely but large. Label — tap Nit.',
  // LPT-819: SoftPulse-quiet unguided densify — no Nit spoil.
  'act-04-07-02-unguided':
      'Seat folds forever, then check-raises a triple barrel — tap which type fits.',
  'act-04-08-02-guided':
      'Seat open-raises 60% and triple-barrels light. Label — tap Maniac.',
  // LPT-820: SoftPulse-quiet unguided densify — no Maniac spoil.
  'act-04-08-02-unguided':
      'Seat 3-bets light and never gives up rivers — tap which type fits.',
  // LPT-821: SoftPulse-quiet unguided densify — no Update / Freeze spoil.
  'act-04-09-01-unguided':
      'Former \'station\' starts folding three streets — tap which next step fits.',
  // LPT-822: SoftPulse-quiet unguided densify — no Low conf spoil.
  'act-04-06-01-unguided':
      'One dramatic call — tap how confident a type label is.',
  // LPT-675: Section 2 jump densify — no Cutoff spoil.
  'act-02-07-02-jump-pos':
      'Seat right before the button — pick it on the map.',
  // LPT-674: Section 3 jump densify — no correct tile spoil.
  'act-03-08-02-jump-table':
      'Pot 16, shorter 40bb — tap what you track first.',
  'act-03-08-02-jump-leak':
      'Gutshot vs a 2x pot bet — tap the matching price plan.',
  // LPT-673: Section 4 jump densify — no correct tile/value/exploit spoil.
  'act-04-10-02-jump-station':
      'Sticky caller three streets. Label + exploit direction — tap the matching plan.',
  'act-04-10-02-jump-nit':
      'Tiny range, huge check-raise. Label + line — tap the matching plan.',
  'act-04-10-02-jump-maniac':
      'Seat barrels forever. You have top pair. Label + line — tap the matching plan.',
  // LPT-672: Final assessment densify stems — no correct tile/exploit spoil.
  'act-07-12-01-cs':
      'Sticky calls three streets. Label + exploit — tap the matching plan.',
  'act-07-12-01-nit':
      'Tiny range, huge check-raise. Label + line — tap the matching plan.',
  'act-07-12-01-maniac':
      'Endless barrels, never folds. Label + line — tap the matching plan.',
  'act-07-12-01-tag':
      'Selective entry, disciplined barrels. Label + vs raise — tap the matching plan.',
  'act-07-12-01-lag':
      'Wide entry, sustained pressure, some folds. Label + line — tap the matching plan.',
  // LPT-717: Section 5 checkpoint densify — no correct tile spoil.
  'act-05-09-02-cp-multi':
      'Four-way pot priority — tap the matching priority.',
  'act-05-09-02-cp-tell':
      'Instant shove proves — tap the matching read.',
  'act-05-09-02-cp-stop':
      'Hit stop-loss. Do — tap the matching plan.',
};

/// Phrases that would spoil the Final five-type checkpoint answers (LPT-672).
const _finalFiveTypeSpoilers = <String, List<String>>{
  'act-07-12-01-cs': [
    'calling station',
    'thicker value',
    'fewer bluffs',
  ],
  'act-07-12-01-nit': ['nit', 'respect heat', 'steal elsewhere'],
  'act-07-12-01-maniac': ['maniac', 'widen catches', 'ego raises'],
  'act-07-12-01-tag': ['tag', 'respect raises', 'steal less'],
  'act-07-12-01-lag': ['lag', 'trap more', 'call wider'],
  'act-07-12-01-uncertain': ['low', 'lean baseline'],
  'act-07-12-01-retire': ['retire or update'],
};

/// Phrases that would spoil Section 2 jump densify answers (LPT-675).
const _sectionTwoJumpSpoilers = <String, List<String>>{
  'act-02-07-02-jump-pos': ['cutoff', 'cut-off', 'pick co', 'tap co'],
};

/// Phrases that would spoil Section 3 jump densify answers (LPT-674).
const _sectionThreeJumpSpoilers = <String, List<String>>{
  'act-03-08-02-jump-table': [
    'pot and effective',
    'pot · effective',
    'price frame',
  ],
  'act-03-08-02-jump-leak': ['fold', 'price is wrong'],
};

/// Phrases that would spoil Section 4 jump densify answers (LPT-673).
const _sectionFourJumpSpoilers = <String, List<String>>{
  'act-04-10-02-jump-range': ['stronger', 'narrower range'],
  'act-04-10-02-jump-spr': ['tap 4', 'pick 4', '— 4'],
  'act-04-10-02-jump-station': [
    'calling station',
    'thicker value',
    'fewer bluffs',
  ],
  'act-04-10-02-jump-nit': ['nit', 'respect the raise', 'steal more'],
  'act-04-10-02-jump-maniac': ['maniac', 'bluff-catch', 'ego raises'],
};

/// Phrases that would spoil Section 5 checkpoint densify answers (LPT-717).
const _sectionFiveCheckpointSpoilers = <String, List<String>>{
  'act-05-09-02-cp-multi': ['nut potential', 'pick nut'],
  'act-05-09-02-cp-tell': ['soft evidence', 'pick soft'],
  'act-05-09-02-cp-stop': ['honor stop', 'pick honor'],
};

/// SoftPulse-quiet Spot Nit / Maniac / Retire / Observation-certainty unguided
/// densify must not name the tile (LPT-819 / LPT-820 / LPT-821 / LPT-822; same
/// class as LPT-818).
const _spotTypeUnguidedSpoilers = <String, List<String>>{
  'act-04-06-01-unguided': ['low conf', 'low confidence', 'certain forever'],
  'act-04-07-02-unguided': ['nit', 'maniac'],
  'act-04-08-02-unguided': ['maniac', 'station'],
  'act-04-09-01-unguided': [
    'update/retire',
    'calling station model',
    'freeze',
  ],
};

void main() {
  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id densify helper arm (LPT-628 remain)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      expect(line.toLowerCase(), isNot(contains('tap the best answer')));
    });
  }

  test(
    'Spot Nit/Maniac/Retire/Observation-certainty unguided densify stems '
    'do not spoil tiles (LPT-819/820/821/822)',
    () {
      for (final MapEntry(key: id, value: spoils)
          in _spotTypeUnguidedSpoilers.entries) {
        final resolved = selectIdentifyDensifiedCoachLine(id);
        expect(resolved, _lines[id], reason: id);
        final lower = (resolved ?? '').toLowerCase();
        for (final spoil in spoils) {
          expect(
            lower,
            isNot(contains(spoil)),
            reason: '$id must not contain "$spoil"',
          );
        }
      }
    },
  );

  test('Final five-type densify stems do not spoil correct tiles (LPT-672)', () {
    const expected = <String, String>{
      'act-07-12-01-cs':
          'Sticky calls three streets. Label + exploit — tap the matching plan.',
      'act-07-12-01-nit':
          'Tiny range, huge check-raise. Label + line — tap the matching plan.',
      'act-07-12-01-maniac':
          'Endless barrels, never folds. Label + line — tap the matching plan.',
      'act-07-12-01-tag':
          'Selective entry, disciplined barrels. Label + vs raise — tap the matching plan.',
      'act-07-12-01-lag':
          'Wide entry, sustained pressure, some folds. Label + line — tap the matching plan.',
      'act-07-12-01-uncertain':
          'Three mixed samples only. Confidence — tap the matching level.',
      'act-07-12-01-retire':
          'Old Calling Station now folds rivers and 3-bets light. Do — tap the matching next step.',
    };
    for (final MapEntry(key: id, value: line) in expected.entries) {
      final resolved = selectIdentifyDensifiedCoachLine(id);
      expect(resolved, line, reason: id);
      final lower = (resolved ?? '').toLowerCase();
      for (final spoil in _finalFiveTypeSpoilers[id]!) {
        expect(lower, isNot(contains(spoil)), reason: '$id must not contain "$spoil"');
      }
    }
  });

  test('Section 2 jump densify stems do not spoil Cutoff (LPT-675)', () {
    const expected = <String, String>{
      'act-02-07-02-jump-pos':
          'Seat right before the button — pick it on the map.',
    };
    for (final MapEntry(key: id, value: line) in expected.entries) {
      final resolved = selectIdentifyDensifiedCoachLine(id);
      expect(resolved, line, reason: id);
      final lower = (resolved ?? '').toLowerCase();
      for (final spoil in _sectionTwoJumpSpoilers[id]!) {
        expect(
          lower,
          isNot(contains(spoil)),
          reason: '$id must not contain "$spoil"',
        );
      }
    }
  });

  test('Section 3 jump densify stems do not spoil correct tiles (LPT-674)', () {
    const expected = <String, String>{
      'act-03-08-02-jump-table':
          'Pot 16, shorter 40bb — tap what you track first.',
      'act-03-08-02-jump-leak':
          'Gutshot vs a 2x pot bet — tap the matching price plan.',
    };
    for (final MapEntry(key: id, value: line) in expected.entries) {
      final resolved = selectIdentifyDensifiedCoachLine(id);
      expect(resolved, line, reason: id);
      final lower = (resolved ?? '').toLowerCase();
      for (final spoil in _sectionThreeJumpSpoilers[id]!) {
        expect(
          lower,
          isNot(contains(spoil)),
          reason: '$id must not contain "$spoil"',
        );
      }
    }
  });

  test('Section 4 jump densify stems do not spoil correct answers (LPT-673)', () {
    const expected = <String, String>{
      'act-04-10-02-jump-range':
          'UTG open is best described as — tap the matching range.',
      'act-04-10-02-jump-spr':
          'Stack 60bb, pot 15bb. SPR — tap the matching number.',
      'act-04-10-02-jump-station':
          'Sticky caller three streets. Label + exploit direction — tap the matching plan.',
      'act-04-10-02-jump-nit':
          'Tiny range, huge check-raise. Label + line — tap the matching plan.',
      'act-04-10-02-jump-maniac':
          'Seat barrels forever. You have top pair. Label + line — tap the matching plan.',
    };
    for (final MapEntry(key: id, value: line) in expected.entries) {
      final resolved = selectIdentifyDensifiedCoachLine(id);
      expect(resolved, line, reason: id);
      final lower = (resolved ?? '').toLowerCase();
      for (final spoil in _sectionFourJumpSpoilers[id]!) {
        expect(
          lower,
          isNot(contains(spoil)),
          reason: '$id must not contain "$spoil"',
        );
      }
    }
  });

  test(
    'Section 5 checkpoint densify stems do not spoil correct tiles (LPT-717)',
    () {
      const expected = <String, String>{
        'act-05-09-02-cp-multi':
            'Four-way pot priority — tap the matching priority.',
        'act-05-09-02-cp-tell':
            'Instant shove proves — tap the matching read.',
        'act-05-09-02-cp-stop':
            'Hit stop-loss. Do — tap the matching plan.',
      };
      for (final MapEntry(key: id, value: line) in expected.entries) {
        final resolved = selectIdentifyDensifiedCoachLine(id);
        expect(resolved, line, reason: id);
        final lower = (resolved ?? '').toLowerCase();
        for (final spoil in _sectionFiveCheckpointSpoilers[id]!) {
          expect(
            lower,
            isNot(contains(spoil)),
            reason: '$id must not contain "$spoil"',
          );
        }
      }
    },
  );
}
