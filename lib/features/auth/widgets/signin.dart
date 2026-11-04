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

class SignInPage extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;

  const SignInPage({
    super.key,
    required this.onSwitchToSignUp,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController(text: 'enkush@readpack.app');
  final _passwordController = TextEditingController(text: 'readpack123');
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final l10n = AppLocalizations.of(context);
    bool isValid = true;
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
      context.read<BookProvider>().loginWithEmail(email, 'Enkush');
      Navigator.of(context).pushReplacementNamed(Routes.appshell);
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

    final signinText = l10n?.t('auth.signin') ?? 'Нэвтрэх';
    final emailHint = l10n?.t('auth.email_hint') ?? 'Имэйл хаягаа оруулна уу';
    final passwordHint =
        l10n?.t('auth.password_hint') ?? 'Нууц үгээ оруулна уу';
    final noAccountText =
        l10n?.t('auth.no_account') ?? 'Бүртгэлгүй юу?';
    final signupText = l10n?.t('auth.signup') ?? 'Бүртгүүлэх';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          signinText,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.t('auth.welcome_desc') ??
              'Тавтай морилно уу! Дуртай номоо үргэлжлүүлэн уншаарай.',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
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
          label: signinText,
          isLoading: _isLoading,
          onPressed: _validateAndSubmit,
        ),
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
          normalText: '$noAccountText ',
          actionText: signupText,
          onTap: widget.onSwitchToSignUp,
        ),
      ],
    );
  }
}