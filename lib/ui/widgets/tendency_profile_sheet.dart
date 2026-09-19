/// Bottom sheet showing a villain's visible modeled tendency card.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/tendency_profile_model.dart';

/// Opens detailed reads and modeled statistics for a live opponent.
class TendencyProfileSheet extends StatelessWidget {
  const TendencyProfileSheet({super.key, required this.player});

  final PlayerModel player;

  static Future<void> show(BuildContext context, PlayerModel player) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgMid,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TendencyProfileSheet(player: player),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = player.tendency;
    if (profile == null) return const SizedBox.shrink();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${player.name} · ${player.archetype.label}',
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${profile.confidence.toUpperCase()} CONFIDENCE · MODELED READ',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.goldMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            for (final read in profile.reads)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        read,
                        style: GoogleFonts.manrope(
                          color: AppColors.cream,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _Stats(profile: profile),
            const SizedBox(height: 14),
            Text(
              'These are bounded training tendencies, not observed casino '
              'statistics. Coaching uses only these visible reads and public '
              'hand information.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});

  final TendencyProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, double)>[
      ('VPIP', profile.vpip),
      ('PFR', profile.pfr),
      ('3-BET', profile.threeBet),
      ('AGGRESSION', profile.aggression),
      ('FOLD FLOP', profile.foldToFlopBet),
      ('FOLD TURN', profile.foldToTurnBet),
      ('FOLD RIVER', profile.foldToRiverBet),
      ('RIVER BLUFF', profile.bluffRiver),
      ('SHOWDOWN CALL', profile.showdownCall),
      ('SIZING TELL', profile.sizingTellStrength),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in entries)
          Container(
            width: 102,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.slateDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.$1,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.slate,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${entry.$2.toStringAsFixed(1)}%',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
