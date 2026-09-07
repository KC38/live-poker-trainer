/// Profile review: model parsing, markdown scrubbing, offline copy, and the
/// cache refresh policy that keeps the screen from calling the API on open.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/services/profile_coach.dart';

HandActionSample _act(
  Street street,
  HandActionKind kind, {
  bool isHero = false,
  double amountBb = 0,
  PlayerArchetype archetype = PlayerArchetype.tag,
}) =>
    HandActionSample(
      seat: isHero ? 0 : 3,
      street: street,
      kind: kind,
      isHero: isHero,
      archetype: isHero ? PlayerArchetype.hero : archetype,
      amountBb: amountBb,
    );

/// A loose-passive history: limp preflop, call two streets, no aggression.
HeroMetrics _loosePassive({int hands = 80}) {
  return HeroProfiler.compute([
    for (var i = 0; i < hands; i++)
      HeroHandSample(
        handId: i + 1,
        playedAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
        actions: [
          _act(Street.preflop, HandActionKind.raise, amountBb: 3),
          _act(Street.preflop, HandActionKind.call, isHero: true, amountBb: 3),
          _act(Street.flop, HandActionKind.bet, amountBb: 4),
          _act(Street.flop, HandActionKind.call, isHero: true, amountBb: 4),
          _act(Street.turn, HandActionKind.bet, amountBb: 8),
          _act(Street.turn, HandActionKind.call, isHero: true, amountBb: 8),
          _act(Street.river, HandActionKind.check),
          _act(Street.river, HandActionKind.check, isHero: true),
        ],
        wentToShowdown: true,
        heroNetBb: -15,
      ),
  ]);
}

void main() {
  final now = DateTime.utc(2026, 6, 1);

  group('offline copy', () {
    test('a known style is described with its numbers', () {
      final summary = ProfileCoach.offlineSummary(_loosePassive(), now: now);

      expect(summary.isFromAi, isFalse);
      expect(summary.source, ProfileCoachSummary.offlineSource);
      expect(summary.modelId, isEmpty);
      expect(summary.styleSummary, isNotEmpty);
      expect(summary.handsPlayedAt, 80);
      expect(summary.styleId, PlayingStyle.loosePassive.name);
      expect(summary.adjustments, isNotEmpty);
      expect(summary.generatedAt, now);
    });

    test('a thin sample says so instead of inventing a read', () {
      final summary = ProfileCoach.offlineSummary(
        _loosePassive(hands: 3),
        now: now,
      );

      expect(summary.styleSummary, contains('Not enough hands'));
      expect(summary.styleId, PlayingStyle.forming.name);
      expect(summary.adjustments, isNotEmpty, reason: 'still tell them what to do');
    });

    test('an empty profile still produces usable copy', () {
      final summary = ProfileCoach.offlineSummary(
        HeroMetrics.empty(),
        now: now,
      );

      expect(summary.styleSummary, isNotEmpty);
      expect(summary.leaks, isEmpty);
      expect(summary.adjustments, isNotEmpty);
    });

    test('lists are capped so the card cannot grow without bound', () {
      final summary = ProfileCoach.offlineSummary(_loosePassive(), now: now);

      expect(summary.leaks.length, lessThanOrEqualTo(ProfileCoach.maxLines));
      expect(
        summary.adjustments.length,
        lessThanOrEqualTo(ProfileCoach.maxLines),
      );
    });
  });

  group('the model path', () {
    test('a good response is used, and tagged as coming from the model',
        () async {
      final coach = ProfileCoach(
        modelId: 'gemini-test',
        modelCall: ({required system, required user}) async => {
          'summary': 'You call too much and almost never raise.',
          'leaks': ['You never 3-bet.', 'You call rivers light.'],
          'adjustments': ['Raise your good hands preflop.'],
        },
      );

      final summary = await coach.summarize(_loosePassive(), now: now);

      expect(summary.isFromAi, isTrue);
      expect(summary.modelId, 'gemini-test');
      expect(summary.styleSummary, 'You call too much and almost never raise.');
      expect(summary.leaks, hasLength(2));
      expect(summary.adjustments, hasLength(1));
      expect(summary.handsPlayedAt, 80);
    });

    test('markdown the model was told not to use is scrubbed', () async {
      final coach = ProfileCoach(
        modelCall: ({required system, required user}) async => {
          'summary': '**You are loose-passive.**  Fix the `limping` habit.',
          'leaks': ['- You never 3-bet', '* Calling too wide'],
          'adjustments': ['## Raise more'],
        },
      );

      final summary = await coach.summarize(_loosePassive(), now: now);

      expect(summary.styleSummary, 'You are loose-passive. Fix the limping habit.');
      expect(summary.leaks, ['You never 3-bet', 'Calling too wide']);
      expect(summary.adjustments, ['Raise more']);
    });

    test('over-long lists are truncated to the display cap', () async {
      final coach = ProfileCoach(
        modelCall: ({required system, required user}) async => {
          'summary': 'A read.',
          'leaks': ['one', 'two', 'three', 'four', 'five'],
          'adjustments': ['a', 'b', 'c', 'd'],
        },
      );

      final summary = await coach.summarize(_loosePassive(), now: now);

      expect(summary.leaks, hasLength(ProfileCoach.maxLines));
      expect(summary.adjustments, hasLength(ProfileCoach.maxLines));
    });

    test('a null response falls back to offline copy', () async {
      final coach = ProfileCoach(
        modelCall: ({required system, required user}) async => null,
      );

      final summary = await coach.summarize(_loosePassive(), now: now);

      expect(summary.isFromAi, isFalse);
      expect(summary.styleSummary, isNotEmpty);
    });

    test('a response with no summary text falls back rather than showing '
        'an empty card', () async {
      final coach = ProfileCoach(
        modelCall: ({required system, required user}) async => {
          'summary': '   ',
          'leaks': ['ignored'],
        },
      );

      final summary = await coach.summarize(_loosePassive(), now: now);

      expect(summary.isFromAi, isFalse);
      expect(summary.leaks, isNot(contains('ignored')));
    });

    test('no model at all goes straight to offline copy', () async {
      final summary = await ProfileCoach().summarize(
        _loosePassive(),
        now: now,
      );

      expect(summary.isFromAi, isFalse);
    });
  });

  group('the prompt', () {
    test('carries the hand count, style, and rates that have a sample', () {
      final prompt = ProfileCoach.buildPrompt(_loosePassive());

      expect(prompt, contains('Hands logged: 80'));
      expect(prompt, contains(PlayingStyle.loosePassive.label));
      expect(prompt, contains(HeroMetricId.vpip.shortLabel));
    });

    test('withholds rates that are below their minimum sample', () {
      // Four hands: no rate has earned the right to be quoted.
      final prompt = ProfileCoach.buildPrompt(_loosePassive(hands: 4));

      expect(prompt, contains('Hands logged: 4'));
      expect(
        prompt,
        isNot(contains('${HeroMetricId.wtsd.shortLabel} ')),
        reason: 'the model must not quote noise back at the player',
      );
    });
  });

  group('the refresh policy', () {
    ProfileCoachSummary cached({
      int hands = 80,
      String styleId = 'loosePassive',
      String source = ProfileCoachSummary.geminiSource,
      DateTime? generatedAt,
    }) =>
        ProfileCoachSummary(
          styleSummary: 'A read.',
          leaks: const [],
          adjustments: const [],
          source: source,
          modelId: 'gemini-test',
          handsPlayedAt: hands,
          styleId: styleId,
          generatedAt: generatedAt ?? now,
        );

    test('a fresh summary for the same style is kept', () {
      expect(cached().needsRefresh(_loosePassive(), now), isFalse);
    });

    test('a handful of new hands is not worth an API call', () {
      final metrics = _loosePassive(
        hands: 80 + ProfileCoachSummary.refreshEveryHands - 1,
      );

      expect(cached().needsRefresh(metrics, now), isFalse);
    });

    test('enough new hands triggers a refresh', () {
      final metrics = _loosePassive(
        hands: 80 + ProfileCoachSummary.refreshEveryHands,
      );

      expect(cached().needsRefresh(metrics, now), isTrue);
    });

    test('a changed style label triggers a refresh immediately', () {
      expect(
        cached(styleId: 'tag').needsRefresh(_loosePassive(), now),
        isTrue,
      );
    });

    test('a stale summary is refreshed even with no new hands', () {
      final later = now.add(ProfileCoachSummary.maxAge * 2);

      expect(cached().needsRefresh(_loosePassive(), later), isTrue);
    });

    test('offline copy is upgraded as soon as a model is available', () {
      final offline = cached(source: ProfileCoachSummary.offlineSource);

      expect(offline.needsRefresh(_loosePassive(), now), isTrue);
    });
  });
}
