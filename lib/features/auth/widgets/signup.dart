import 'package:flutter/material.dart' hide IconButton;
import 'package:readpack/shared/widgets/inputfield.dart';
import 'package:readpack/shared/widgets/submitbutton.dart';
import 'package:readpack/shared/widgets/linktext.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/iconbutton.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key, required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.t('auth.signup'), style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        )),
        const SizedBox(height: 24),

        InputField(
          hint: l10n.t('auth.full_name_hint'),
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        InputField(
          hint: l10n.t('auth.email_hint'),
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 14),
        InputField(
        hint: l10n.t('auth.password_hint'),
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 28),

        SubmitButton(
          label: l10n.t('auth.signup'),
          onPressed: () {},
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              logolink: 'assets/public/logos/google.png',
              action: () {
                print('Google дарсан');
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              logolink: 'assets/public/logos/facebook.png',
              action: () {
                print('Facebook дарсан');
              },
            ),
          ],
        ),
        const SizedBox(height: 28),

        LinkText(
          normalText: l10n.t('auth.have_account'),
          actionText: l10n.t('auth.signin'),
          onTap: onSwitchToLogin,
        ),
      ],
    );
  }
}