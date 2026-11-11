import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/data/services/social_auth_service.dart';
import 'package:readpack/data/services/contact_normalizer.dart';
import 'package:readpack/features/auth/auth_error_message.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/iconbutton.dart';
import 'package:readpack/shared/widgets/inputfield.dart';
import 'package:readpack/shared/widgets/linktext.dart';
import 'package:readpack/shared/widgets/submitbutton.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;

  const SignInPage({super.key, required this.onSwitchToSignUp});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    String? errorMsg;
    bool isLoading = false;

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
                    'Бүртгэлтэй имэйл эсвэл утасны дугаараа оруулна уу.',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              InputField(
                controller: resetEmailController,
                hint:
                    l10n?.t('auth.contact_hint') ?? 'Имэйл эсвэл утасны дугаар',
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
              onPressed: isLoading
                  ? null
                  : () async {
                      final contact = resetEmailController.text.trim();
                      final isEmail = contact.contains('@');
                      if (contact.isEmpty ||
                          (isEmail && !contact.contains('.')) ||
                          (!isEmail &&
                              contact.replaceAll(RegExp(r'\D'), '').length <
                                  8)) {
                        setDialogState(() {
                          errorMsg =
                              l10n?.t('validation.email_invalid') ??
                              'Имэйл эсвэл утасны дугаараа зөв оруулна уу';
                        });
                        return;
                      }
                      setDialogState(() {
                        isLoading = true;
                        errorMsg = null;
                      });
                      try {
                        final challenge = await context
                            .read<BookProvider>()
                            .requestPasswordReset(
                              contact: isEmail
                                  ? contact
                                  : normalizePhoneNumber(contact),
                              contactType: isEmail ? 'email' : 'phone',
                            );
                        if (!mounted || !dialogCtx.mounted) return;
                        Navigator.of(dialogCtx).pop();
                        Navigator.of(context).pushNamed(
                          Routes.verify,
                          arguments: {
                            'purpose': 'forgot_password',
                            'target': contact,
                            'isPhone': !isEmail,
                            'challengeId': challenge.id,
                            'contactType': isEmail ? 'email' : 'phone',
                          },
                        );
                      } catch (error) {
                        setDialogState(() {
                          isLoading = false;
                          errorMsg = authErrorMessage(error, l10n);
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n?.t('auth.send_reset_link') ?? 'Код авах'),
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
    final isEmail = email.contains('@');
    if (email.isEmpty ||
        (isEmail && !email.contains('.')) ||
        (!isEmail && email.replaceAll(RegExp(r'\D'), '').length < 8)) {
      setState(
        () => _emailError =
            l10n?.t('validation.email_invalid') ??
            'Имэйл эсвэл утасны дугаараа зөв оруулна уу',
      );
      isValid = false;
    }
    if (password.length < 8) {
      setState(
        () => _passwordError =
            l10n?.t('validation.password_too_short') ??
            'Нууц үг хамгийн багадаа 6 тэмдэгт байна',
      );
      isValid = false;
    }

    if (!isValid) return;

    setState(() {
      _isLoading = true;
      _formError = null;
    });
    try {
      await context.read<BookProvider>().signInWithPassword(
        contact: isEmail ? email : normalizePhoneNumber(email),
        contactType: isEmail ? 'email' : 'phone',
        password: password,
      );
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(
          context,
        ).pushReplacementNamed(Routes.appshell, arguments: 0);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _formError = authErrorMessage(
            error,
            AppLocalizations.of(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Future<void> _loginWithSocial(String providerName) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _formError = null;
    });
    try {
      final provider = providerName.toLowerCase();
      final token = provider == 'google'
          ? await SocialAuthService.signInWithGoogle()
          : await SocialAuthService.signInWithFacebook();
      if (token == null || !mounted) return;
      await context.read<BookProvider>().signInWithProvider(
        provider: provider,
        token: token,
      );
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(
          context,
        ).pushReplacementNamed(Routes.appshell, arguments: 0);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _formError = authErrorMessage(error, l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final signinText = l10n?.t('auth.signin') ?? 'Нэвтрэх';
    final emailHint =
        l10n?.t('auth.contact_hint') ?? 'Имэйл эсвэл утасны дугаар';
    final passwordHint =
        l10n?.t('auth.password_hint') ?? 'Нууц үгээ оруулна уу';
    final noAccountText = l10n?.t('auth.no_account') ?? 'Бүртгэлгүй юу?';
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
          keyboardType: TextInputType.text,
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
        if (_formError != null) ...[
          Text(
            _formError!,
            style: TextStyle(color: colorScheme.error, fontSize: 13),
          ),
          const SizedBox(height: 12),
        ],
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
        const SizedBox(height: 12),
        SocialAuthButton(
          logolink: 'assets/public/logos/facebook.png',
          label: 'Facebook',
          action: () => _loginWithSocial('Facebook'),
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
