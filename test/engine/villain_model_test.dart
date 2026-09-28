/// Size response of the archetype frequencies the coach uses to narrow ranges.
///
/// A bigger bet has to mean a stronger hand. If bluff frequency keeps rising
/// with size, or a weak pair still calls a huge overbet, the coach treats air
/// as the likely holding and recommends light re-raises.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/villain_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

void main() {
  group('VillainModel size response', () {
    test('air bluffs more near one-and-a-half pot than into a huge overbet', () {
      const arch = PlayerArchetype.maniac;
      final halfPot = VillainModel.betFrequency(arch, HandClass.air);
      final aroundPeak = VillainModel.betFrequency(
        arch,
        HandClass.air,
        betToPot: 1.5,
      );
      final huge = VillainModel.betFrequency(
        arch,
        HandClass.air,
        betToPot: 4,
      );

      expect(aroundPeak, greaterThan(halfPot));
      expect(huge, lessThan(halfPot));
      expect(huge, inInclusiveRange(0, 1));
    });

    test('a weak pair gives up an overbet while a monster still continues', () {
      const arch = PlayerArchetype.tag;
      final weakHalf = VillainModel.callFrequency(arch, HandClass.weakPair);
      final weak = VillainModel.callFrequency(
        arch,
        HandClass.weakPair,
        priceToPot: 4,
      );
      final monster = VillainModel.callFrequency(
        arch,
        HandClass.monster,
        priceToPot: 4,
      );

      expect(weak, lessThan(weakHalf * 0.25));
      expect(monster, greaterThan(0.5));
      expect(monster, greaterThan(weak * 5));
    });

    test('raises fall off faster than calls as the price grows', () {
      const arch = PlayerArchetype.tag;
      const hand = HandClass.topPair;
      final callHalf = VillainModel.callFrequency(arch, hand);
      final raiseHalf = VillainModel.raiseFrequency(arch, hand);
      final callBig = VillainModel.callFrequency(
        arch,
        hand,
        priceToPot: 2,
      );
      final raiseBig = VillainModel.raiseFrequency(
        arch,
        hand,
        priceToPot: 2,
      );

      expect(callHalf, greaterThan(0));
      expect(raiseHalf, greaterThan(0));
      expect(raiseBig / raiseHalf, lessThan(callBig / callHalf));
    });

    test('call plus raise cannot make a fold frequency negative', () {
      expect(
        VillainModel.continueFrequency(
          PlayerArchetype.callingStation,
          HandClass.monster,
        ),
        1,
      );
      expect(
        VillainModel.foldFrequency(
          PlayerArchetype.callingStation,
          HandClass.monster,
        ),
        0,
      );
    });

    test('a hero seat copies the tag frequencies', () {
      for (final handClass in HandClass.values) {
        expect(
          VillainModel.betFrequency(
            PlayerArchetype.hero,
            handClass,
            betToPot: 1.2,
          ),
          VillainModel.betFrequency(
            PlayerArchetype.tag,
            handClass,
            betToPot: 1.2,
          ),
        );
        expect(
          VillainModel.callFrequency(
            PlayerArchetype.hero,
            handClass,
            priceToPot: 2,
          ),
          VillainModel.callFrequency(
            PlayerArchetype.tag,
            handClass,
            priceToPot: 2,
          ),
        );
      }
    });

    test('a zero price and a zero bet size stay inside zero to one', () {
      for (final arch in PlayerArchetype.values) {
        for (final handClass in HandClass.values) {
          expect(
            VillainModel.callFrequency(arch, handClass, priceToPot: 0),
            inInclusiveRange(0, 1),
          );
          expect(
            VillainModel.raiseFrequency(arch, handClass, priceToPot: 0),
            inInclusiveRange(0, 1),
          );
          expect(
            VillainModel.foldFrequency(arch, handClass, priceToPot: 0),
            inInclusiveRange(0, 1),
          );
          expect(
            VillainModel.betFrequency(arch, handClass, betToPot: 0),
            inInclusiveRange(0, 1),
          );
        }
      }
    });
  });
}
