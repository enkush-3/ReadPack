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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    String? errorMsg;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n?.t('auth.reset_password_title') ?? 'Нууц үг сэргээх',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.t('auth.reset_password_desc') ??
                    'Имэйл хаягаа оруулна уу. Бид нууц үг сэргээх холбоос илгээх болно.',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              InputField(
                controller: resetEmailController,
                hint: l10n?.t('auth.email_hint') ?? 'Имэйл хаягаа оруулна уу',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                errorText: errorMsg,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n?.t('common.cancel') ?? 'Цуцлах'),
            ),
            FilledButton(
              onPressed: () {
                final mail = resetEmailController.text.trim();
                if (mail.isEmpty || !mail.contains('@')) {
                  setDialogState(() {
                    errorMsg = l10n?.t('validation.email_invalid') ??
                        'Имэйл хаягаа зөв оруулна уу';
                  });
                  return;
                }
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pushNamed(
                  Routes.verify,
                  arguments: {
                    'purpose': 'forgot_password',
                    'target': mail,
                    'isPhone': !mail.contains('@'),
                  },
                );
              },
              child: Text(
                l10n?.t('auth.send_reset_link') ?? 'Холбоос илгээх',
              ),
            ),
          ],
        ),
      ),
    );
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
      final localPart = email.split('@').first;
      final derivedName = localPart.isEmpty
          ? 'Enkush'
          : '${localPart[0].toUpperCase()}${localPart.substring(1)}';
      context.read<BookProvider>().loginWithEmail(email, derivedName);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(
          Routes.appshell,
          arguments: 0,
        );
      }
    }
  }

  void _continueAsGuest() {
    context.read<BookProvider>().loginAsGuest();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.appshell, arguments: 0);
    }
  }

  void _loginWithSocial(String providerName) {
    final email = _emailController.text.trim().contains('@')
        ? _emailController.text.trim()
        : '${providerName.toLowerCase()}@readpack.app';
    context.read<BookProvider>().loginWithEmail(email, '$providerName Уншигч');
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.appshell, arguments: 0);
    }
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
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _showForgotPasswordDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10n?.t('auth.forgot_password') ?? 'Нууц үгээ мартсан уу?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SubmitButton(
          label: signinText,
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
        const SizedBox(height: 18),
        SocialAuthButton(
          logolink: 'assets/public/logos/google.png',
          label: 'Google',
          action: () => _loginWithSocial('Google'),
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