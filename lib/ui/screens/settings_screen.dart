/// Settings: SFX, TTS, API key override, and help text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// Audio and secrets settings screen.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(
      text: ref.read(settingsProvider).geminiKeyOverride,
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Sound effects',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Cards, chips, knock, fold',
                style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 13),
              ),
              value: settings.sfxEnabled,
              onChanged: notifier.setSfx,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Coach voice',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Spoken feedback after each decision',
                style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 13),
              ),
              value: settings.ttsEnabled,
              onChanged: notifier.setTts,
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
            const SizedBox(height: 20),
            Divider(color: AppColors.slateDark.withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            Text(
              'Gemini API',
              style: GoogleFonts.cinzel(
                color: AppColors.goldMuted,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Model: ${Config.geminiModel}\n'
              'Key: Settings override → --dart-define → .env\n'
              'Never commit real keys. Device override stays local.\n'
              'Coach voice uses Gemini AUDIO when a key is present, '
              'otherwise device TTS.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Device API key override',
                hintText: 'Optional local override',
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async {
                await notifier.setGeminiKeyOverride(_keyController.text.trim());
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Config.hasGeminiKey
                          ? 'API key saved on device'
                          : 'Key cleared — using .env / dart-define',
                    ),
                  ),
                );
              },
              child: const Text('Save key override'),
            ),
            const SizedBox(height: 12),
            Text(
              Config.hasGeminiKey
                  ? 'API key detected'
                  : 'No API key — coaching uses heuristics + device voice',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Config.hasGeminiKey
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
