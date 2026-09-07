/// Regression: consecutive deals and mid-hand continuations must not clone.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';

const _settings = GameSettingsModel(seatCount: 6);

void _drain(PokerEngine engine) {
  var guard = 0;
  while (guard++ < 512 && engine.nextEvent() != null) {}
}

String _heroCodes(GameState state) =>
    state.hero.holeCards.map((c) => c.code).join(',');

String _boardCodes(GameState state) =>
    state.community.map((c) => c.code).join(',');

void main() {
  group('deal uniqueness', () {
    test('N consecutive startHand deals never clone hole-card layouts', () {
      final engine = PokerEngine(settings: _settings, random: Random(20260907));
      final fingerprints = <String>[];

      for (var i = 0; i < 24; i++) {
        final dealt = i == 0
            ? engine.startHand(resolve: false)
            : engine.startHand(
                existingPlayers: engine.state.players,
                resolve: false,
              );
        final fp = PokerEngine.dealFingerprint(dealt);
        expect(
          fingerprints.contains(fp),
          isFalse,
          reason: 'deal $i cloned an earlier hole-card layout: $fp',
        );
        fingerprints.add(fp);
        expect(dealt.handCount, i + 1);
        expect(dealt.community, isEmpty);
        expect(dealt.isHandOver, isFalse);
      }
      expect(fingerprints.toSet().length, fingerprints.length);
    });

    test('fold then next hand changes hero cards, board, and pot path', () {
      final engine = PokerEngine(settings: _settings, random: Random(42));
      engine.startHand(resolve: false);
      _drain(engine);

      final firstHero = _heroCodes(engine.state);
      final firstDealer = engine.state.dealerIndex;
      if (!engine.state.isHandOver) {
        engine.submitHeroAction(const PokerAction(type: PokerActionType.fold));
        _drain(engine);
      }
      expect(engine.state.isHandOver, isTrue);

      engine.startHand(
        existingPlayers: engine.state.players,
        resolve: false,
      );
      _drain(engine);
      final secondHero = _heroCodes(engine.state);

      expect(secondHero, isNot(equals(firstHero)));
      expect(engine.state.dealerIndex, isNot(equals(firstDealer)));
      expect(engine.state.handCount, greaterThan(1));
      expect(engine.state.community, isEmpty);
      expect(engine.state.resultMessage, isNull);
    });

    test('mid-hand continuation keeps hole cards and advances pot/street', () {
      final engine = PokerEngine(
        settings: const GameSettingsModel(seatCount: 3),
        random: Random(99),
      );
      engine.startHand(resolve: false);
      _drain(engine);

      final holes = _heroCodes(engine.state);
      final potBefore = engine.state.totalPot;
      final streetBefore = engine.state.street;
      final fingerprintBefore = PokerEngine.dealFingerprint(engine.state);

      var guard = 0;
      while (!engine.state.isHandOver && guard++ < 40) {
        if (engine.state.waitingForHero) {
          final call = engine.state.callAmountFor(engine.state.hero);
          engine.submitHeroAction(
            call <= Money.epsilon
                ? const PokerAction(type: PokerActionType.check)
                : PokerAction(type: PokerActionType.call, amount: call),
          );
        }
        _drain(engine);
        // Hole cards must never be re-dealt mid-hand.
        expect(_heroCodes(engine.state), holes);
        expect(PokerEngine.dealFingerprint(engine.state), fingerprintBefore);
        if (engine.state.street != streetBefore || engine.state.isHandOver) {
          break;
        }
      }

      expect(
        engine.state.isHandOver ||
            engine.state.street != streetBefore ||
            !Money.same(engine.state.totalPot, potBefore) ||
            _boardCodes(engine.state).isNotEmpty,
        isTrue,
        reason: 'post-action continuation must progress the hand uniquely',
      );
    });

    test('production engine refuses to clone the prior deal fingerprint', () {
      // Unseeded engine: force the anti-clone path by dealing many hands.
      final engine = PokerEngine(settings: _settings);
      final seen = <String>{};
      for (var i = 0; i < 40; i++) {
        final dealt = i == 0
            ? engine.startHand(resolve: false)
            : engine.startHand(
                existingPlayers: engine.state.players,
                resolve: false,
              );
        final fp = PokerEngine.dealFingerprint(dealt);
        expect(seen.add(fp), isTrue, reason: 'clone at deal $i: $fp');
      }
    });
  });
}
