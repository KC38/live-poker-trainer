/// Settings: SFX, TTS, API key override, and help text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Sound effects'),
            subtitle: const Text('Cards, chips, knock, fold'),
            value: settings.sfxEnabled,
            onChanged: notifier.setSfx,
          ),
          SwitchListTile(
            title: const Text('Coach TTS'),
            subtitle: const Text('Gemini AUDIO voice (Puck)'),
            value: settings.ttsEnabled,
            onChanged: notifier.setTts,
          ),
          const Divider(height: 32),
          Text(
            'Gemini API',
            style: GoogleFonts.cinzel(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Model: ${Config.geminiModel}\n'
            'Key resolution: Settings override → --dart-define → .env\n'
            'Never commit real keys. Device override is local only.',
            style: GoogleFonts.inter(color: AppColors.slate, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Device API key override',
              hintText: 'Optional local override',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          Text(
            Config.hasGeminiKey
                ? 'API key detected'
                : 'No API key — Practice uses offline fallback spots',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: Config.hasGeminiKey ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
