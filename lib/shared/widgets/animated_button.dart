import 'package:flutter/material.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class AnimatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool isLoading;
  final String? semanticLabel;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.isLoading = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;
    final background = filled
        ? (enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.12))
        : Colors.transparent;
    final foreground = filled
        ? (enabled
              ? scheme.onPrimary
              : scheme.onSurface.withValues(alpha: 0.38))
        : (enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.38));

    return AnimatedPressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: semanticLabel,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: scheme.outline),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: foreground),
                      const SizedBox(width: 8),
                    ],
                    DefaultTextStyle(
                      style:
                          (Theme.of(context).textTheme.labelLarge ??
                                  const TextStyle())
                              .copyWith(color: foreground),
                      child: IconTheme(
                        data: IconThemeData(color: foreground),
                        child: child,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
