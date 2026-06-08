import 'package:flutter/material.dart';
import 'widgets.dart';
import 'Verify.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(
            email: _emailController.text,
            name: _nameController.text,
          ),
        ),
      );
    }
  }

  @override
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
                topLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInputField(
                  context,
                  label: "Таны нэр",
                  hint: "Таны нэр",
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Нэрээ оруулна уу';
                    }
                    if (value.trim().length < 2) {
                      return 'Нэр 2-оос дээш тэмдэгттэй байх ёстой';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

                buildInputField(
                  context,
                  label: "Нууц үг давтах",
                  hint: "Нууц үгээ дахин оруулна уу",
                  controller: _confirmPasswordController,
                  isPassword: true,
                  isObscured: _isConfirmPasswordObscured,
                  onToggleVisibility: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Нууц үгээ давтан оруулна уу';
                    if (value != _passwordController.text) return 'Нууц үг таарахгүй байна';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildSubmitButton(context, text: 'Бүртгүүлэх', onPressed: _handleRegister),
        ],
      ),
    );
  }
}