/// Bottom sheet for editing the hero's display name and avatar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/services/avatar_store.dart';
import 'package:live_poker_trainer/ui/widgets/profile_avatar.dart';

/// Name and avatar editor.
///
/// Avatar changes apply immediately so the preview is the truth, while the
/// name is committed on save — typing should not rewrite the hero seat on
/// every keystroke.
class ProfileIdentitySheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const ProfileIdentitySheet({super.key, required this.identity});

  final HeroIdentity identity;

  /// Presents the sheet.
  static Future<void> show(BuildContext context, HeroIdentity identity) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => ProfileIdentitySheet(identity: identity),
    );
  }

  @override
  ConsumerState<ProfileIdentitySheet> createState() =>
      _ProfileIdentitySheetState();
}

class _ProfileIdentitySheetState extends ConsumerState<ProfileIdentitySheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.identity.seatName,
  );
  bool _picking = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  HeroProfileController get _controller =>
      ref.read(heroProfileControllerProvider.notifier);

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    final result = await _controller.pickAvatarFromLibrary();
    if (!mounted) return;
    setState(() => _picking = false);
    if (result.status == AvatarPickStatus.cancelled || result.isSaved) return;
    final message = result.message;
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    await _controller.setDisplayName(_name.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final identity = ref.watch(heroIdentityProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slateDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ProfileAvatar(identity: identity, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _name,
                    maxLength: HeroIdentity.maxNameLength,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      hintText: HeroIdentity.defaultDisplayName,
                      counterText: '',
                    ),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'This is the name and picture shown at your seat.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _picking ? null : _pickPhoto,
              icon: _picking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.goldBright,
                      ),
                    )
                  : const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(_picking ? 'Opening photos…' : 'Choose a photo'),
            ),
            const SizedBox(height: 18),
            Text(
              'OR PICK A BUILT-IN',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.slate,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final builtIn in BuiltInAvatar.values)
                  _AvatarChoice(
                    identity: identity,
                    builtIn: builtIn,
                    selected: identity.avatar.builtIn == builtIn,
                    onTap: () => _controller.selectBuiltInAvatar(builtIn),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!identity.avatar.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _controller.clearAvatar,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.slate,
                  ),
                  icon: const Icon(Icons.person_off_outlined, size: 16),
                  label: const Text('Remove picture'),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.identity,
    required this.builtIn,
    required this.selected,
    required this.onTap,
  });

  final HeroIdentity identity;
  final BuiltInAvatar builtIn;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${builtIn.label} avatar',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.goldBright : Colors.transparent,
              width: 2,
            ),
          ),
          child: ProfileAvatar(
            identity: identity.copyWith(avatar: AvatarRef.builtIn(builtIn)),
            size: 46,
            ring: false,
          ),
        ),
      ),
    );
  }
}
