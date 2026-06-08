import 'package:flutter/material.dart';
import 'package:readpact/pages/home/home.dart';
import 'widgets.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20)
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInputField(
                  context,
                  label: "И-мэйл хаяг",
                  hint: "email@example.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'И-мэйл хаягаа оруулна уу';
                    if (!value.contains('@')) return 'Зөв и-мэйл хаяг оруулна уу';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                buildInputField(
                  context,
                  label: "Нууц үг",
                  hint: "Нууц үгээ оруулна уу",
                  controller: _passwordController,
                  isPassword: true,
                  isObscured: _isPasswordObscured,
                  onToggleVisibility: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Нууц үгээ оруулна уу';
                    if (value.length < 6) return 'Нууц үг 6 тэмдэгтээс урт байх ёстой';
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InkWell(
                      onTap: () {
                        // TODO: Нууц үг сэргээх
                      },
                      hoverColor: colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline_rounded,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Нууц үг мартсан уу?",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildSubmitButton(context, text: 'Нэвтрэх', onPressed: _handleLogin),
        ],
      ),
    );
  }
}