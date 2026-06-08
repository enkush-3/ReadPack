import 'package:flutter/material.dart';

import 'widgets/widgets.dart';
import 'widgets/login.dart';
import 'widgets/register.dart';

class AuthPages extends StatefulWidget {
  @override
  State<AuthPages> createState() => _AuthPagesState();
}

class _AuthPagesState extends State<AuthPages> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ReadPackLogo(context, 30),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: AuthHeader(context, isLogin: _isLogin, onToggle: _toggleAuthMode),
              ),
              if (_isLogin)
                const LoginForm()
              else
                const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}