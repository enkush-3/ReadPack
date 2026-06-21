import 'package:flutter/material.dart';

class LinkText extends StatelessWidget {
  const LinkText({
    super.key,
    required this.normalText,
    required this.actionText,
    required this.onTap,
  });

  final String normalText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            text: normalText,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: actionText,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}