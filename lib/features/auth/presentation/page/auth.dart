import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/auth/widgets/signin.dart';
import 'package:readpack/features/auth/widgets/signup.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/readpacklogo.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _showLogin = true;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Cubic(0.2, 0.0, 0.0, 1.0)),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchMode() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _showLogin = !_showLogin);
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.7),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopNav(),
              _buildSegmentedToggle(),
              Expanded(
                child: _buildAnimatedCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedToggle() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final signinText = l10n?.t('auth.signin') ?? 'Нэвтрэх';
    final signupText = l10n?.t('auth.signup') ?? 'Бүртгүүлэх';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showLogin ? null : _switchMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _showLogin ? colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _showLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    signinText,
                    style: TextStyle(
                      fontWeight:
                          _showLogin ? FontWeight.bold : FontWeight.w500,
                      color: _showLogin
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: !_showLogin ? null : _switchMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_showLogin ? colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_showLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    signupText,
                    style: TextStyle(
                      fontWeight:
                          !_showLogin ? FontWeight.bold : FontWeight.w500,
                      color: !_showLogin
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final skipText = l10n?.t('auth.skip') ?? 'Алгасах';
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canPop) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 2),
                ],
                const Flexible(child: ReadPackLogo(size: 36)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedPressable(
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.onboarding);
                },
                child: Tooltip(
                  message:
                      l10n?.t('onboarding.setup_goal_btn') ?? 'Зорилго тохируулах',
                  child: Container(
                    width: 38,
                    height: 38,
                    margin: EdgeInsets.only(right: canPop ? 0 : 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              if (!canPop)
                AnimatedPressable(
                  onTap: () {
                    context.read<BookProvider>().loginAsGuest();
                    Navigator.of(context).pushReplacementNamed(Routes.appshell);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skipText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: _showLogin
                ? SignInPage(onSwitchToSignUp: _switchMode)
                : SignUpPage(onSwitchToLogin: _switchMode),
          ),
        ),
      ),
    );
  }
}