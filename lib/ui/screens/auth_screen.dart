/// Login / register gate — email+password and Google Sign-In.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/main.dart' show firebaseAvailable;
import 'package:live_poker_trainer/providers/auth_provider.dart';

/// Signed-out landing: create account or sign in.
class AuthScreen extends ConsumerStatefulWidget {
  /// Creates the auth screen.
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();

  bool _registerMode = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  bool get _busy => ref.watch(authControllerProvider).isLoading;

  Future<void> _submitEmail() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(authControllerProvider.notifier);
    try {
      if (_registerMode) {
        await controller.register(
          email: _email.text,
          password: _password.text,
          displayName: _displayName.text.trim().isEmpty
              ? null
              : _displayName.text.trim(),
        );
      } else {
        await controller.signInWithEmail(
          email: _email.text,
          password: _password.text,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    }
  }

  Future<void> _submitGoogle() async {
    setState(() => _error = null);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    }
  }

  String _friendlyError(Object error) {
    debugPrint('[auth_screen] error: $error');
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' => 'That email already has an account.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Use a password of at least 6 characters.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Email or password is incorrect.',
        'network-request-failed' => 'Network error — check your connection.',
        'missing-id-token' =>
          'Google Sign-In could not get an ID token. '
              'On Android, add the app SHA-1 in the Firebase console.',
        'operation-not-allowed' =>
          'This sign-in method is not enabled. '
              'Ask the project owner to enable Email/Password in Firebase Console → Authentication → Sign-in method.',
        'too-many-requests' =>
          'Too many attempts — wait a moment and try again.',
        'user-disabled' => 'This account has been disabled.',
        _ => error.message ?? 'Sign-in failed (${error.code}).',
      };
    }
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return 'Google Sign-In was cancelled.';
      }
      return 'Google Sign-In failed (${error.code}). '
          'On Android, confirm the SHA-1 is registered in Firebase.';
    }
    return 'Something went wrong ($error). Try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [
              Color(0xFF1A2E28),
              AppColors.bgMid,
              AppColors.bgDark,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/brand/logo_mark.png',
                        width: 64,
                        height: 64,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.style,
                          size: 48,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Exploitative\nPoker Lab',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),

                      const SizedBox(height: 10),
                      Text(
                        _registerMode
                            ? 'Create an account to sync progress across devices.'
                            : 'Sign in to continue training.',
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (!firebaseAvailable) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Firebase is not configured — sign-in is unavailable. '
                            'Continue as guest to train offline.',
                            style: GoogleFonts.manrope(
                              color: AppColors.gold,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      if (firebaseAvailable) ...[
                        if (_registerMode) ...[
                          TextFormField(
                            controller: _displayName,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Display name (optional)',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty || !value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: _registerMode
                              ? const [AutofillHints.newPassword]
                              : const [AutofillHints.password],
                          onFieldSubmitted: (_) =>
                              _busy ? null : _submitEmail(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Show' : 'Hide',
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.slate,
                              ),
                            ),
                          ),
                          validator: (v) {
                            final value = v ?? '';
                            if (value.length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _error!,
                            style: GoogleFonts.manrope(
                              color: AppColors.danger,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: _busy ? null : _submitEmail,
                          child: _busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.bgDark,
                                  ),
                                )
                              : Text(
                                  _registerMode
                                      ? 'Create account'
                                      : 'Sign in',
                                ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _submitGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => ref
                                .read(authControllerProvider.notifier)
                                .enterGuestMode(),
                        icon: const Icon(Icons.person_outline, size: 24),
                        label: const Text('Continue as guest'),
                      ),
                      if (firebaseAvailable) ...[
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                    _registerMode = !_registerMode;
                                    _error = null;
                                  }),
                          child: Text(
                            _registerMode
                                ? 'Already have an account? Sign in'
                                : 'Need an account? Register',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
