/// Archetype legend so seat badges are always decodable.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Bottom sheet explaining each seat badge and how to exploit it.
class ArchetypeLegendSheet extends StatelessWidget {
  /// Creates the legend sheet.
  const ArchetypeLegendSheet({super.key, this.seated = const []});

  /// Archetypes currently at the table, listed first.
  final List<PlayerArchetype> seated;

  /// Shows the legend as a bottom sheet.
  static Future<void> show(
    BuildContext context, {
    List<PlayerArchetype> seated = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => ArchetypeLegendSheet(seated: seated),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atTable = seated.toSet();
    final ordered = [
      ...ArchetypeRoster.villainPool.where(atTable.contains),
      ...ArchetypeRoster.villainPool.where((a) => !atTable.contains(a)),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slateDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Who is at your table',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.goldBright,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Each seat shows its archetype, then VPIP/PFR. '
              'Pick your line from the archetype.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                height: 1.4,
                color: AppColors.slate,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: ordered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _LegendRow(
                  archetype: ordered[i],
                  atTable: atTable.contains(ordered[i]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.archetype, required this.atTable});

  final PlayerArchetype archetype;
  final bool atTable;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: atTable ? 1 : 0.55,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: archetype.color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              archetype.shortLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.bgDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${archetype.label}  ·  VPIP '
                  '${archetype.vpip.toStringAsFixed(0)} / PFR '
                  '${archetype.pfr.toStringAsFixed(0)}'
                  '${atTable ? '  ·  at your table' : ''}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: atTable ? AppColors.gold : AppColors.slate,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  archetype.tell,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.cream,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
