/// Size-preset wrapper around [TableCard] for lesson trays and choice tiles.
///
/// Live Training seats, the board, and densified lesson felts all draw the
/// same face: corner rank + one centered suit. Prefer [TableCard] when you
/// already have a pixel width; use [MiniCard] only for the named footprints
/// below.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

/// Card footprints used across densified lesson trays.
enum MiniCardSize {
  /// Compact face for outcome-tile icons and packed rails.
  tiny,

  /// Default face for board rows and medium trays.
  small,

  /// Hero hole cards on densified teach felts and choice buttons.
  hero;

  /// Pixel footprint for this size (width drives [TableCard] height).
  Size get dimensions {
    final width = switch (this) {
      MiniCardSize.tiny => 18.0,
      MiniCardSize.small => 26.0,
      MiniCardSize.hero => 44.0,
    };
    return Size(width, width * tableCardAspect);
  }
}

/// A single face-up card using the shared [TableCard] design.
class MiniCard extends StatelessWidget {
  /// Creates a card face at a named [size].
  const MiniCard({
    super.key,
    required this.card,
    this.size = MiniCardSize.small,
    this.scale = 1,
    this.selected = false,
    this.highlighted = false,
    this.dimmed = false,
    this.orderBadge,
  });

  final CardModel card;

  /// Footprint to render at.
  final MiniCardSize size;

  /// Multiplier on [size], used to enlarge cards while reviewing a hand.
  final double scale;

  /// Gold ring when the learner has tapped this card.
  final bool selected;

  /// Soft gold cue for the next card to tap.
  final bool highlighted;

  /// Fade leftover cards that do not play.
  final bool dimmed;

  /// Optional 1-based order badge drawn on a selected card.
  final int? orderBadge;

  @override
  Widget build(BuildContext context) {
    return TableCard(
      card: card,
      width: size.dimensions.width * scale,
      selected: selected,
      highlighted: highlighted,
      dimmed: dimmed,
      orderBadge: orderBadge,
    );
  }
}
