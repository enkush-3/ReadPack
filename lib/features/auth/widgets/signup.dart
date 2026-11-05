import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/iconbutton.dart';
import 'package:readpack/shared/widgets/inputfield.dart';
import 'package:readpack/shared/widgets/linktext.dart';
import 'package:readpack/shared/widgets/submitbutton.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const SignUpPage({
    super.key,
    required this.onSwitchToLogin,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    });

    final l10n = AppLocalizations.of(context);
    bool isValid = true;
    if (name.isEmpty) {
      setState(() => _nameError =
          l10n?.t('validation.name_too_short') ?? 'Бүтэн нэрээ оруулна уу');
      isValid = false;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError =
          l10n?.t('validation.email_invalid') ?? 'Имэйл хаягаа зөв оруулна уу');
      isValid = false;
    }
    if (password.length < 6) {
      setState(() => _passwordError = l10n?.t('validation.password_too_short') ??
          'Нууц үг хамгийн багадаа 6 тэмдэгт байна');
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() => _isLoading = false);
      context.read<BookProvider>().loginWithEmail(email, name);
      Navigator.of(context).pushReplacementNamed(Routes.onboarding);
    }
  }

  void _continueAsGuest() {
    context.read<BookProvider>().loginAsGuest();
    Navigator.of(context).pushReplacementNamed(Routes.appshell);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final signupText = l10n?.t('auth.signup') ?? 'Бүртгүүлэх';
    final nameHint = l10n?.t('auth.full_name_hint') ?? 'Бүтэн нэрээ оруулна уу';
    final emailHint = l10n?.t('auth.email_hint') ?? 'Имэйл хаягаа оруулна уу';
    final passwordHint =
        l10n?.t('auth.password_hint') ?? 'Нууц үгээ оруулна уу';
    final haveAccountText =
        l10n?.t('auth.have_account') ?? 'Бүртгэлтэй юу?';
    final signinText = l10n?.t('auth.signin') ?? 'Нэвтрэх';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          signupText,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.t('auth.signup_desc') ??
              'Шинэ бүртгэл үүсгэж, мянга мянган номын ертөнцөд нэгдээрэй.',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        InputField(
          controller: _nameController,
          hint: nameHint,
          icon: Icons.person_outline_rounded,
          errorText: _nameError,
        ),
        const SizedBox(height: 16),
        InputField(
          controller: _emailController,
          hint: emailHint,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
        ),
        const SizedBox(height: 16),
        InputField(
          controller: _passwordController,
          hint: passwordHint,
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          errorText: _passwordError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _validateAndSubmit(),
        ),
        const SizedBox(height: 24),
        SubmitButton(
          label: signupText,
          isLoading: _isLoading,
          onPressed: _validateAndSubmit,
        ),
        if (!Navigator.of(context).canPop()) ...[
          const SizedBox(height: 16),
          Center(
            child: AnimatedPressable(
              onTap: _continueAsGuest,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n?.t('auth.continue_as_guest') ?? 'Зочноор үргэлжлүүлэх →',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n?.t('auth.or') ?? 'эсвэл',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SocialAuthButton(
                logolink: 'assets/public/logos/google.png',
                label: 'Google',
                action: _continueAsGuest,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SocialAuthButton(
                logolink: 'assets/public/logos/facebook.png',
                label: 'Facebook',
                action: _continueAsGuest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LinkText(
          normalText: '$haveAccountText ',
          actionText: signinText,
          onTap: widget.onSwitchToLogin,
        ),
      ],
    );
  }
}