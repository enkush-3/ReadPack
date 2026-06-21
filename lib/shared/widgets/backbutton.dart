import 'package:flutter/material.dart';

class BackButton extends StatelessWidget {
  const BackButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.onPrimaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colorScheme.surface, size: 20),
      ),
    );
  }
}