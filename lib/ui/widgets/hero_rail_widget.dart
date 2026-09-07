/// Hero rail — a dedicated band so hole cards are never covered.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/profile_avatar.dart';

/// Fixed-height hero band between the felt and the coach shelf.
///
/// Hero hole cards used to be drawn as part of the felt seat ring, where a
/// tall coach shelf could clip them. Giving the hero its own band makes
/// overlap structurally impossible.
class HeroRailWidget extends ConsumerWidget {
  /// Creates the hero rail.
  const HeroRailWidget({
    super.key,
    required this.game,
    required this.chipDisplayMode,
    this.isThinking = false,
    this.review = false,
  });

  final GameState game;

  /// Table amounts are currency-only; see [ChipDisplayMode.tableMode].
  final ChipDisplayMode chipDisplayMode;

  /// True while villains are still acting and it is not the hero's turn.
  final bool isThinking;

  /// True once the hand is over and the action dock has given up its band:
  /// the rail takes a slice of that space and shows larger hole cards.
  final bool review;

  /// Height reserved for this band, including padding.
  static const double height = 84;

  /// Taller band used while reviewing a finished hand.
  static const double reviewHeight = 102;

  /// Hole-card growth applied at full [review].
  static const double _reviewCardScale = 1.18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(heroIdentityProvider);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: review ? 1 : 0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => _buildRail(identity, t),
    );
  }

  /// Builds the rail at review progress [t] (0 = playing, 1 = reviewing).
  Widget _buildRail(HeroIdentity identity, double t) {
    final hero = game.hero;
    final heroIndex = game.players.indexWhere((p) => p.isHero);
    // Matches the action dock's visibility: promising "YOUR TURN" while the
    // replay still runs would point at controls that are not on screen.
    final isTurn =
        game.waitingForHero && !game.isHandOver && !hero.folded && !isThinking;
    final position = _positionLabel(heroIndex);

    return SizedBox(
      height: height + (reviewHeight - height) * t,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 2, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isTurn
                ? AppColors.goldBright.withValues(alpha: 0.9)
                : AppColors.slateDark.withValues(alpha: 0.9),
            width: isTurn ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(identity: identity, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          identity.railLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      if (position != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldMuted.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            position,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.bgDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ChipFormat.chips(hero.stack, game.bigBlind, chipDisplayMode),
                    maxLines: 1,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldBright,
                    ),
                  ),
                  if (hero.currentBet > Money.epsilon)
                    Text(
                      'in ${ChipFormat.chips(hero.currentBet, game.bigBlind, chipDisplayMode)}',
                      maxLines: 1,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        color: AppColors.slate,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final card in hero.holeCards)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: MiniCard(
                      key: ValueKey('hero-${game.handCount}-${card.code}'),
                      card: card,
                      size: MiniCardSize.hero,
                      scale: 1 + (_reviewCardScale - 1) * t,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  hero.folded
                      ? 'FOLDED'
                      : isTurn
                          ? 'YOUR TURN'
                          : isThinking
                              ? 'ACTION…'
                              : (hero.lastActionLabel ?? ''),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: hero.folded
                        ? AppColors.slate
                        : isTurn
                            ? AppColors.goldBright
                            : AppColors.slate,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _positionLabel(int heroIndex) {
    if (heroIndex < 0) return null;
    if (heroIndex == game.dealerIndex) return 'BTN';
    if (heroIndex == game.sbIndex) return 'SB';
    if (heroIndex == game.bbIndex) return 'BB';
    return null;
  }
}
