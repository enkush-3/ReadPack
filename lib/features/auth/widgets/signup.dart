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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPhoneMode = false;
  bool _isLoading = false;
  String? _nameError;
  String? _contactError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = null;
      _contactError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final l10n = AppLocalizations.of(context);
    bool isValid = true;
    if (name.isEmpty) {
      setState(() => _nameError =
          l10n?.t('validation.name_too_short') ?? 'Бүтэн нэрээ оруулна уу');
      isValid = false;
    }

    if (_isPhoneMode) {
      if (phone.isEmpty || phone.replaceAll(RegExp(r'\D'), '').length < 8) {
        setState(() => _contactError = 'Утасны дугаараа зөв оруулна уу');
        isValid = false;
      }
    } else {
      if (email.isEmpty || !email.contains('@')) {
        setState(() => _contactError =
            l10n?.t('validation.email_invalid') ?? 'Имэйл хаягаа зөв оруулна уу');
        isValid = false;
      }
    }

    if (password.length < 6) {
      setState(() => _passwordError = l10n?.t('validation.password_too_short') ??
          'Нууц үг хамгийн багадаа 6 тэмдэгт байна');
      isValid = false;
    }

    if (confirmPassword.isNotEmpty && confirmPassword != password) {
      setState(() =>
          _confirmPasswordError = 'Нууц үг хоорондоо таарахгүй байна');
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final targetContact = _isPhoneMode ? phone : email;

    // Check if Routes.verify is registered and can be pushed
    try {
      Navigator.of(context).pushNamed(
        Routes.verify,
        arguments: {
          'purpose': 'signup',
          'target': targetContact,
          'name': name,
          'password': password,
          'isPhone': _isPhoneMode,
        },
      );
    } catch (_) {
      // Fallback for tests or environments without Routes.verify
      final bookProvider = context.read<BookProvider>();
      bookProvider.registerNewUser(
        name: name,
        email: _isPhoneMode ? '$phone@readpack.app' : email,
        phoneNumber: _isPhoneMode ? phone : '',
        username: '@${name.toLowerCase().replaceAll(' ', '')}',
      );
      Navigator.of(context).pushReplacementNamed(Routes.onboarding);
    }
  }

  void _continueAsGuest() {
    context.read<BookProvider>().loginAsGuest();
    Navigator.of(context).pushReplacementNamed(Routes.appshell);
  }

  void _loginWithSocial(String providerName) {
    final email = _emailController.text.trim().contains('@')
        ? _emailController.text.trim()
        : '${providerName.toLowerCase()}@readpack.app';
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : '$providerName Уншигч';
    context.read<BookProvider>().registerNewUser(
          email: email,
          name: name,
          username: '@${providerName.toLowerCase()}_reader',
        );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.onboarding);
    }
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
        const SizedBox(height: 20),

        // Toggle: Email vs Phone registration
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_isPhoneMode) {
                      setState(() {
                        _isPhoneMode = false;
                        _contactError = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isPhoneMode
                          ? colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_isPhoneMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Имэйл хаяг',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !_isPhoneMode
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: !_isPhoneMode
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isPhoneMode) {
                      setState(() {
                        _isPhoneMode = true;
                        _contactError = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isPhoneMode
                          ? colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _isPhoneMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Утасны дугаар',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isPhoneMode
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: _isPhoneMode
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        InputField(
          controller: _nameController,
          hint: nameHint,
          icon: Icons.person_outline_rounded,
          errorText: _nameError,
        ),
        const SizedBox(height: 14),

        if (!_isPhoneMode)
          InputField(
            controller: _emailController,
            hint: emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: _contactError,
          )
        else
          InputField(
            controller: _phoneController,
            hint: 'Утасны дугаараа оруулна уу (+976)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            errorText: _contactError,
          ),

        const SizedBox(height: 14),
        InputField(
          controller: _passwordController,
          hint: passwordHint,
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          errorText: _passwordError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        InputField(
          controller: _confirmPasswordController,
          hint: 'Нууц үгээ баталгаажуулна уу',
          icon: Icons.lock_rounded,
          isPassword: true,
          errorText: _confirmPasswordError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _validateAndSubmit(),
        ),
        const SizedBox(height: 22),
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
        const SizedBox(height: 18),
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
          normalText: '$haveAccountText ',
          actionText: signinText,
          onTap: widget.onSwitchToLogin,
        ),
      ],
    );
  }
}
