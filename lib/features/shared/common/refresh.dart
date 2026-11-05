import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;

  const RefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
  });

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = color ?? colorScheme.primary;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: primaryColor,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      displacement: displacement,
      strokeWidth: 2.5,
      child: child,
    );
  }
}