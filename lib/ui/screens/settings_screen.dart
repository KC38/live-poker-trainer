/// Settings: SFX, TTS, chip display, and help text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// Audio and display settings screen.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // The gradient backdrop sits between these tiles and the page
            // Material, which would swallow their ink; a transparent Material
            // gives them a nearer surface to paint on.
            Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Sound effects',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Cards, chips, knock, fold',
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 13,
                      ),
                    ),
                    value: settings.sfxEnabled,
                    onChanged: notifier.setSfx,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Music',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Quiet lounge ambient on Home',
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 13,
                      ),
                    ),
                    value: settings.musicEnabled,
                    onChanged: notifier.setMusic,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Coach voice',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Spoken feedback after each decision',
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 13,
                      ),
                    ),
                    value: settings.ttsEnabled,
                    onChanged: notifier.setTts,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chip display',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Stacks, pot, bets, and EV audit',
              style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 13),
            ),
            const SizedBox(height: 10),
            SegmentedButton<ChipDisplayMode>(
              segments: [
                for (final mode in ChipDisplayMode.values)
                  ButtonSegment(
                    value: mode,
                    label: Text(
                      mode == ChipDisplayMode.dollars
                          ? '\$'
                          : mode == ChipDisplayMode.bb
                              ? 'BB'
                              : 'Both',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              selected: {settings.chipDisplayMode},
              onSelectionChanged: (s) => notifier.setChipDisplayMode(s.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.bgDark
                      : AppColors.slate,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.gold
                      : AppColors.bgElevated,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
