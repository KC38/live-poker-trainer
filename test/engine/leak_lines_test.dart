/// Repeat / improvement coach copy and the Gemini prompt leak context.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/leak_lines.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

MistakePattern _riverNitRaise() => MistakePattern.derive(
      street: Street.river,
      archetype: PlayerArchetype.nit,
      taken: ExploitAction.raise,
      best: ExploitAction.call,
      mismatch: CoachMismatch.tooAggressive,
    );

GameState _game() => GameState(
      players: [
        PlayerModel(
          id: 0,
          name: 'Hero',
          archetype: PlayerArchetype.hero,
          stack: 400,
          isHero: true,
          holeCards: [CardModel.fromCode('As'), CardModel.fromCode('Kd')],
        ),
        const PlayerModel(
          id: 1,
          name: 'Stan',
          archetype: PlayerArchetype.nit,
          stack: 400,
        ),
      ],
      mode: GameMode.training,
      street: Street.river,
    );

void main() {
  setUp(LeakLines.resetRotation);

  group('LeakLines.repeatPrefix', () {
    test('is empty for a first occurrence', () {
      final r = RepeatInfo(
        pattern: _riverNitRaise(),
        totalCount: 1,
        sessionCount: 1,
        tagTotalCount: 1,
      );
      expect(LeakLines.repeatPrefix(r, villainName: 'Stan'), isEmpty);
    });

    test('names the count, street, archetype, and better line', () {
      final r = RepeatInfo(
        pattern: _riverNitRaise(),
        totalCount: 3,
        sessionCount: 3,
        tagTotalCount: 3,
      );
      final seen = <String>{};
      for (var i = 0; i < 4; i++) {
        final line = LeakLines.repeatPrefix(r, villainName: 'Stan');
        seen.add(line);
        expect(line, anyOf(contains('third'), contains('3')));
        expect(line.toLowerCase(), contains('nit'));
        expect(line.toLowerCase(), contains('river'));
        expect(line.toLowerCase(), anyOf(contains('raised'), contains('call')));
      }
      // Phrasing rotates instead of repeating one stock sentence.
      expect(seen.length, greaterThan(1));
    });

    test('mentions the session count when it differs from the total', () {
      final r = RepeatInfo(
        pattern: _riverNitRaise(),
        totalCount: 5,
        sessionCount: 2,
        tagTotalCount: 5,
      );
      final line = LeakLines.repeatPrefix(r, villainName: 'Stan');
      expect(line, contains('2 this session'));
    });

    test('coarse-only repeats name the leak pattern', () {
      final r = RepeatInfo(
        pattern: _riverNitRaise(),
        totalCount: 1,
        sessionCount: 1,
        tagTotalCount: 4,
      );
      final line = LeakLines.repeatPrefix(r, villainName: 'Stan');
      expect(line.toLowerCase(), contains("raising into a nit's strength"));
      expect(line, contains('4'));
    });
  });

  group('LeakLines.improvementPrefix', () {
    test('acknowledges the fix and what the player used to do', () {
      const info = ImprovementInfo(
        matchedKey: 'river:nit:raise->call',
        tag: MistakeTag.raisingIntoNits,
        priorMistakes: 3,
        streak: 1,
        exactContext: true,
        lastWrongAction: ExploitAction.raise,
      );
      final line = LeakLines.improvementPrefix(
        info,
        taken: ExploitAction.call,
      );
      expect(
        line.toLowerCase(),
        anyOf(contains('raised'), contains('raising'), contains('leak')),
      );
      expect(
        line.toLowerCase(),
        anyOf(contains('calling'), contains('right')),
      );
    });

    test('streaks of two or more can be called out', () {
      const info = ImprovementInfo(
        matchedKey: 'river:nit:raise->call',
        tag: MistakeTag.raisingIntoNits,
        priorMistakes: 3,
        streak: 3,
        exactContext: true,
        lastWrongAction: ExploitAction.raise,
      );
      final seen = <String>{};
      for (var i = 0; i < 4; i++) {
        seen.add(LeakLines.improvementPrefix(info, taken: ExploitAction.call));
      }
      expect(seen.any((s) => s.startsWith('3 in a row')), isTrue);
    });
  });

  group('badges', () {
    test('format compactly', () {
      expect(LeakLines.repeatBadge(3), 'Repeat ×3');
      expect(LeakLines.improvementBadge(1), 'Improved');
      expect(LeakLines.improvementBadge(2), 'Improved ×2');
    });
  });

  group('LiveCoachGrade.toPrompt leak context', () {
    const grade = LiveCoachGrade(
      verdict: CoachVerdict.incorrect,
      message: '',
      villainArchetype: PlayerArchetype.nit,
      villainName: 'Stan',
      street: Street.river,
      heroActionLabel: 'RAISE',
      mismatch: CoachMismatch.tooAggressive,
      optimalAction: ExploitAction.call,
      heroAction: ExploitAction.raise,
    );

    test('omits leak history when there is none', () {
      expect(grade.toPrompt(_game()), isNot(contains('Leak history')));
    });

    test('includes repeat count and pattern for the AI coach', () {
      final repeat = RepeatInfo(
        pattern: _riverNitRaise(),
        totalCount: 3,
        sessionCount: 2,
        tagTotalCount: 3,
      );
      final prompt = grade.toPrompt(_game(), repeat: repeat);
      expect(prompt, contains('Leak history'));
      expect(prompt, contains('occurrence #3'));
      expect(prompt, contains('river:nit:raise->call'));
      expect(prompt, contains("Raising into a nit's strength"));
      expect(prompt, contains('2 in this session'));
      expect(prompt, contains('repeated mistake'));
    });

    test('includes improvement context for the AI coach', () {
      const info = ImprovementInfo(
        matchedKey: 'river:nit:raise->call',
        tag: MistakeTag.raisingIntoNits,
        priorMistakes: 3,
        streak: 2,
        exactContext: true,
        lastWrongAction: ExploitAction.raise,
      );
      final prompt = grade.toPrompt(_game(), improvement: info);
      expect(prompt, contains('previously raised'));
      expect(prompt, contains('3 times'));
      expect(prompt, contains('streak 2'));
      expect(prompt, contains('acknowledge the fix'));
    });
  });
}
