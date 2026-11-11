import 'package:flutter/material.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final String? semanticLabel;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);

    return AnimatedPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      borderRadius: radius,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? scheme.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: child,
      ),
    );
  }
}
