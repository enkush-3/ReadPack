import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/submitbutton.dart';

class VerificationPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const VerificationPage({
    super.key,
    this.arguments,
  });

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

  String get _purpose => widget.arguments?['purpose'] as String? ?? 'signup';
  String get _target => widget.arguments?['target'] as String? ?? '';
  String get _name => widget.arguments?['name'] as String? ?? '';
  bool get _isPhone => widget.arguments?['isPhone'] as bool? ?? false;

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

  void _resendCode() {
    if (_secondsRemaining > 0) return;
    _startTimer();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPhone
              ? 'Таны $_target дугаарт шинэ код илгээгдлээ: 123456'
              : 'Таны $_target хаяг руу шинэ код илгээгдлээ: 123456',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = '6 оронтой кодыг бүрэн оруулна уу');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (_purpose == 'signup') {
      final bookProvider = context.read<BookProvider>();
      final emailVal = _isPhone ? '$_target@readpack.app' : _target;
      final phoneVal = _isPhone ? _target : '';
      final usernameVal =
          '@${_name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';

      // Register fresh account with all 0 stats
      bookProvider.registerNewUser(
        email: emailVal,
        name: _name.isNotEmpty ? _name : 'Шинэ Уншигч',
        phoneNumber: phoneVal,
        username: usernameVal,
      );

      setState(() => _isLoading = false);
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бүртгэл амжилттай баталгаажлаа! Тавтай морил.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushReplacementNamed(Routes.onboarding);
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

    if (newPass.length < 6) {
      setState(
          () => _errorMessage = 'Шинэ нууц үг хамгийн багадаа 6 тэмдэгт байна');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Шинэ нууц үг хоорондоо таарахгүй байна');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isLoading = false);
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нууц үг амжилттай шинэчлэгдлээ. Шинээр нэвтэрнэ үү.'),
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.of(context).pushReplacementNamed(Routes.auth);
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
                        ? 'Шинэ нууц үг тохируулах'
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
                        ? 'Өөрийн акаунтад ашиглах шинэ найдвартай нууц үгээ оруулна уу.'
                        : (_target.isNotEmpty
                            ? 'Бид таны $_target хаяг руу 6 оронтой баталгаажуулах код илгээлээ.'
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
                              final digit =
                                  index < text.length ? text[index] : '';
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
                                            ? colorScheme.primary
                                                .withValues(alpha: 0.5)
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
                          'Код очоогүй юу? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        AnimatedPressable(
                          onTap: _secondsRemaining == 0 ? _resendCode : null,
                          child: Text(
                            _secondsRemaining > 0
                                ? 'Дахин код авах ($_secondsRemainingс)'
                                : 'Дахин код илгээх',
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
                        labelText: 'Шинэ нууц үг',
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
                        labelText: 'Шинэ нууц үгээ баталгаажуулах',
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
                      label: 'Нууц үг шинэчлэх',
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
