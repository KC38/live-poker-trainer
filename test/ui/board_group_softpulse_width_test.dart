/// Board-group SoftPulse wraps dealt community cards only (LPT-68).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'board-group SoftPulse width matches three flop cards when slots off',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final community = [
        CardModel.fromCode('Td'),
        CardModel.fromCode('9h'),
        CardModel.fromCode('6c'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CommunityCardsView(
                community: community,
                pot: 6,
                street: Street.flop,
                bigBlind: 2,
                chipDisplayMode: ChipDisplayMode.dollars,
                features: TableFeatures.full.copyWith(boardSlots: false),
                highlightBoardGroup: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TableCard), findsNWidgets(3));
      expect(find.byType(TableCardSlot), findsNothing);
      expect(tester.takeException(), isNull);

      final groupGlow = find.descendant(
        of: find.byKey(const ValueKey<String>('felt-board-row')),
        matching: find.byWidgetPredicate(
          (widget) => widget is GlowHighlight && widget.active,
        ),
      );
      expect(groupGlow, findsOneWidget);

      final glowSize = tester.getSize(groupGlow);
      // SoftPulse wraps three cards + two gaps (padding paints outside the
      // layout box when reserveLayout is false). Must stay under five cards.
      const threeCardInner =
          3 * CommunityCardsView.cardWidth + 2 * CommunityCardsView.cardGap;
      expect(glowSize.width, lessThan(CommunityCardsView.naturalWidth));
      expect(glowSize.width, lessThanOrEqualTo(threeCardInner + 24));
      expect(glowSize.width, greaterThanOrEqualTo(threeCardInner));
    },
  );

  testWidgets(
    'board-group SoftPulse still excludes empty slots when outlines on',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final community = [
        CardModel.fromCode('Ah'),
        CardModel.fromCode('Kd'),
        CardModel.fromCode('Qc'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CommunityCardsView(
                community: community,
                pot: 6,
                street: Street.flop,
                bigBlind: 2,
                chipDisplayMode: ChipDisplayMode.dollars,
                features: TableFeatures.full.copyWith(boardSlots: true),
                highlightBoardGroup: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TableCard), findsNWidgets(3));
      expect(find.byType(TableCardSlot), findsNWidgets(2));

      final groupGlow = find.descendant(
        of: find.byKey(const ValueKey<String>('felt-board-row')),
        matching: find.byWidgetPredicate(
          (widget) => widget is GlowHighlight && widget.active,
        ),
      );
      final glowSize = tester.getSize(groupGlow);
      expect(glowSize.width, lessThan(CommunityCardsView.naturalWidth));
      expect(tester.takeException(), isNull);
    },
  );
}
