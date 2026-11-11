import 'package:flutter/material.dart';
import 'package:readpack/shared/widgets/animated_button.dart';

class SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedButton(
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        semanticLabel: label,
        child: Text(label),
      ),
    );
  }
}
