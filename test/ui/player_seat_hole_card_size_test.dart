/// Seat hole cards: the hero's are the largest cards on the table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

Widget _seat(
  PlayerModel player, {
  bool reveal = false,
  bool backs = false,
  TableFeatures features = TableFeatures.full,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: PlayerSeatWidget(
          player: player,
          bigBlind: 2,
          chipDisplayMode: ChipDisplayMode.dollars,
          isActive: false,
          revealHoleCards: reveal,
          showHoleBacks: backs,
          features: features,
        ),
      ),
    ),
  );
}

const _hero = PlayerModel(
  id: 0,
  name: 'You',
  archetype: PlayerArchetype.hero,
  stack: 200,
  isHero: true,
);

const _villain = PlayerModel(
  id: 1,
  name: 'Sam',
  archetype: PlayerArchetype.nit,
  stack: 200,
);

void main() {
  testWidgets('hero face-up cards are wider than a board card', (tester) async {
    await tester.pumpWidget(
      _seat(
        _hero.copyWith(
          holeCards: [CardModel.fromCode('Ah'), CardModel.fromCode('Kd')],
        ),
        reveal: true,
      ),
    );

    final cards = find.byType(TableCard);
    expect(cards, findsNWidgets(2));
    final size = tester.getSize(cards.first);
    expect(size.width, SeatMetrics.of(hero: true).cardWidth);
    expect(size.width, greaterThan(CommunityCardsView.cardWidth));
    expect(size.width, lessThan(66));
    expect(size.height, closeTo(size.width * tableCardAspect, 0.01));
  });

  testWidgets('villain face-up cards stay smaller than the board', (
    tester,
  ) async {
    await tester.pumpWidget(
      _seat(
        _villain.copyWith(
          holeCards: [CardModel.fromCode('Qs'), CardModel.fromCode('Jh')],
        ),
        reveal: true,
      ),
    );

    final cards = find.byType(TableCard);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getSize(cards.first).width,
      lessThan(CommunityCardsView.cardWidth),
    );
  });

  testWidgets('hero backs match the hero faces; villain backs are smaller', (
    tester,
  ) async {
    await tester.pumpWidget(_seat(_hero, backs: true));
    final heroBack = tester.getSize(find.byType(TableCardBack).first);
    expect(find.byType(TableCardBack), findsNWidgets(2));
    expect(heroBack.width, SeatMetrics.of(hero: true).cardWidth);

    await tester.pumpWidget(_seat(_villain, backs: true));
    final villainBack = tester.getSize(find.byType(TableCardBack).first);
    expect(villainBack.width, lessThan(heroBack.width / 2));
  });

  testWidgets('name and stack share one box; stack is the larger type', (
    tester,
  ) async {
    await tester.pumpWidget(_seat(_villain));

    final box = tester.getRect(find.byKey(const ValueKey('seat-box-1')));
    final name = tester.getRect(find.text('Sam'));
    final stack = tester.getRect(find.text(r'$200'));
    expect(box.contains(name.center), isTrue);
    expect(box.contains(stack.center), isTrue);
    final nameStyle = tester.widget<Text>(find.text('Sam')).style!;
    final stackStyle = tester.widget<Text>(find.text(r'$200')).style!;
    expect(stackStyle.fontSize, greaterThan(nameStyle.fontSize!));
  });

  testWidgets('hero hole cards clear the seat box with no overlap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _seat(
        _hero.copyWith(
          holeCards: [CardModel.fromCode('Ah'), CardModel.fromCode('Kd')],
        ),
        reveal: true,
      ),
    );

    final box = tester.getRect(find.byKey(const ValueKey('seat-box-0')));
    for (final card in find.byType(TableCard).evaluate()) {
      final cardRect = tester.getRect(find.byWidget(card.widget));
      expect(
        cardRect.overlaps(box),
        isFalse,
        reason: 'hole card $cardRect must not cover seat box $box',
      );
      expect(cardRect.bottom, lessThanOrEqualTo(box.top));
    }
  });

  testWidgets('villain hole cards clear the seat box with no overlap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _seat(
        _villain.copyWith(
          holeCards: [CardModel.fromCode('9h'), CardModel.fromCode('8s')],
        ),
        reveal: true,
      ),
    );

    final box = tester.getRect(find.byKey(const ValueKey('seat-box-1')));
    for (final card in find.byType(TableCard).evaluate()) {
      final cardRect = tester.getRect(find.byWidget(card.widget));
      expect(
        cardRect.overlaps(box),
        isFalse,
        reason: 'hole card $cardRect must not cover seat box $box',
      );
      expect(cardRect.bottom, lessThanOrEqualTo(box.top));
    }
  });

  testWidgets('type tag stays on the box and does not cover hole cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _seat(
        _villain.copyWith(
          holeCards: [CardModel.fromCode('9h'), CardModel.fromCode('8s')],
        ),
        reveal: true,
      ),
    );

    final tag = tester.getRect(find.text('NIT'));
    final box = tester.getRect(find.byKey(const ValueKey('seat-box-1')));
    expect(box.overlaps(tag) || box.contains(tag.center), isTrue);
    for (final card in find.byType(TableCard).evaluate()) {
      final cardRect = tester.getRect(find.byWidget(card.widget));
      expect(
        cardRect.overlaps(tag),
        isFalse,
        reason: 'type tag $tag must not cover hole card $cardRect',
      );
    }
  });

  test('seat metrics keep hole cards fully above the box', () {
    for (final hero in [true, false]) {
      final m = SeatMetrics.of(hero: hero);
      expect(m.cardTuck, 0);
      expect(m.tuck, 0);
      expect(m.cardsAbove, m.cardHeight + SeatMetrics.cardBoxGap * m.scale);
    }
  });

  testWidgets('player type and stats show only when the preset has them', (
    tester,
  ) async {
    await tester.pumpWidget(_seat(_villain));
    expect(find.text('NIT'), findsOneWidget);
    expect(find.text('13/10'), findsOneWidget);

    await tester.pumpWidget(
      _seat(
        _villain,
        features: const TableFeatures(playerTypes: false, stats: false),
      ),
    );
    expect(find.text('NIT'), findsNothing);
    expect(find.text('13/10'), findsNothing);
    expect(find.text(r'$200'), findsOneWidget);

    await tester.pumpWidget(
      _seat(_villain, features: const TableFeatures(stacks: false)),
    );
    expect(find.text(r'$200'), findsNothing);
  });
}
