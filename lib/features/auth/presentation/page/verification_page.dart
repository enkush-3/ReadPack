import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/auth/auth_error_message.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/submitbutton.dart';

class VerificationPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const VerificationPage({super.key, this.arguments});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showNewPasswordFields = false;
  String? _challengeId;

  String get _purpose => widget.arguments?['purpose'] as String? ?? 'signup';
  String get _target => widget.arguments?['target'] as String? ?? '';
  bool get _isPhone => widget.arguments?['isPhone'] as bool? ?? false;
  String get _resolvedChallengeId =>
      _challengeId ?? (widget.arguments?['challengeId'] as String? ?? '');

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    if (_secondsRemaining > 0) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_resolvedChallengeId.isEmpty) {
        throw StateError('Баталгаажуулах хүсэлт олдсонгүй. Дахин эхлүүлнэ үү.');
      }
      final challenge = await context
          .read<BookProvider>()
          .resendVerificationCode(_resolvedChallengeId);
      if (!mounted) return;
      _challengeId = challenge.id;
      _startTimer();
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.t('auth.code_sent') ??
                'Шинэ баталгаажуулах код илгээгдлээ.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = authErrorMessage(
            error,
            AppLocalizations.of(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verifyOtp() async {
    if (_isLoading) return;
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(
        () => _errorMessage =
            AppLocalizations.of(context)?.t('auth.otp_length_error') ??
            '6 оронтой кодыг бүрэн оруулна уу',
      );
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    if (_purpose == 'signup') {
      if (_resolvedChallengeId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Баталгаажуулах хүсэлт олдсонгүй. Бүртгэлээ дахин эхлүүлнэ үү.';
        });
        return;
      }
      try {
        await context.read<BookProvider>().verifySignUp(
          challengeId: _resolvedChallengeId,
          code: code,
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        HapticFeedback.mediumImpact();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.onboarding, (route) => false);
      } catch (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = authErrorMessage(
              error,
              AppLocalizations.of(context),
            );
          });
        }
      }
    } else {
      // Forgot password flow
      setState(() {
        _isLoading = false;
        _showNewPasswordFields = true;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmNewPasswordController.text;

    if (newPass.length < 8) {
      setState(
        () => _errorMessage =
            AppLocalizations.of(context)?.t('validation.password_too_short') ??
            'Нууц үг хамгийн багадаа 8 тэмдэгт байна',
      );
      return;
    }
    if (newPass != confirmPass) {
      setState(
        () => _errorMessage =
            AppLocalizations.of(context)?.t('auth.password_mismatch') ??
            'Шинэ нууц үг хоорондоо таарахгүй байна',
      );
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_resolvedChallengeId.isEmpty ||
        _otpController.text.trim().length != 6) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Баталгаажуулах кодоо дахин шалгана уу.';
      });
      return;
    }
    try {
      await context.read<BookProvider>().resetPassword(
        challengeId: _resolvedChallengeId,
        code: _otpController.text.trim(),
        newPassword: newPass,
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.t('auth.password_reset_success') ??
                'Нууц үг шинэчлэгдлээ. Шинээр нэвтэрнэ үү.',
          ),
        ),
      );
      Navigator.of(context).pushReplacementNamed(Routes.auth);
    } catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = authErrorMessage(
            error,
            AppLocalizations.of(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _showNewPasswordFields
                          ? Icons.lock_reset_rounded
                          : (_isPhone
                                ? Icons.sms_outlined
                                : Icons.mark_email_read_outlined),
                      size: 38,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _showNewPasswordFields
                        ? (l10n?.t('auth.new_password_title') ??
                              'Шинэ нууц үг тохируулах')
                        : (l10n?.t('auth.verification_code') ??
                              'Баталгаажуулах код'),
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _showNewPasswordFields
                        ? (l10n?.t('auth.new_password_desc') ??
                              'Акаунтадаа ашиглах шинэ нууц үгээ оруулна уу.')
                        : (_target.isNotEmpty
                              ? (l10n?.t('auth.code_sent_to', {
                                      'contact': _target,
                                    }) ??
                                    'Бид $_target руу 6 оронтой баталгаажуулах код илгээлээ.')
                              : 'Таны бүртгэл рүү илгээсэн 6 оронтой кодыг оруулна уу.'),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (!_showNewPasswordFields) ...[
                    // Hidden text field for keyboard capture
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _otpController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (val) {
                              setState(() => _errorMessage = null);
                              if (val.length == 6) {
                                _verifyOtp();
                              }
                            },
                          ),
                        ),
                        // 6 visually distinct pin boxes
                        GestureDetector(
                          onTap: () => _focusNode.requestFocus(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final text = _otpController.text;
                              final digit = index < text.length
                                  ? text[index]
                                  : '';
                              final isCurrent = index == text.length;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 44,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent
                                        ? colorScheme.primary
                                        : (digit.isNotEmpty
                                              ? colorScheme.primary.withValues(
                                                  alpha: 0.5,
                                                )
                                              : colorScheme.outlineVariant
                                                    .withValues(alpha: 0.4)),
                                    width: isCurrent ? 2 : 1.2,
                                  ),
                                ),
                                child: Text(
                                  digit,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 6,
                      children: [
                        Text(
                          l10n?.t('auth.otp_not_received') ?? 'Код очоогүй юу?',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        AnimatedPressable(
                          onTap: _secondsRemaining == 0 ? _resendCode : null,
                          child: Text(
                            _secondsRemaining > 0
                                ? (l10n?.t('auth.resend_code_wait', {
                                        'seconds': '$_secondsRemaining',
                                      }) ??
                                      'Дахин код авах ($_secondsRemainingс)')
                                : (l10n?.t('auth.resend_code') ??
                                      'Дахин код илгээх'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _secondsRemaining > 0
                                  ? colorScheme.onSurface.withValues(alpha: 0.4)
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SubmitButton(
                      label: l10n?.t('auth.verify') ?? 'Баталгаажуулах',
                      isLoading: _isLoading,
                      onPressed: _verifyOtp,
                    ),
                  ] else ...[
                    // New password inputs for forgot password
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText:
                            l10n?.t('auth.new_password_label') ??
                            'Шинэ нууц үг',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmNewPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText:
                            l10n?.t('auth.confirm_new_password') ??
                            'Шинэ нууц үгээ баталгаажуулах',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SubmitButton(
                      label:
                          l10n?.t('auth.reset_password_submit') ??
                          'Нууц үг шинэчлэх',
                      isLoading: _isLoading,
                      onPressed: _resetPassword,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
