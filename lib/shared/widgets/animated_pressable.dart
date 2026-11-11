import 'package:flutter/material.dart';

class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final Curve curve;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.duration = const Duration(milliseconds: 150),
    this.curve = const Cubic(0.2, 0.0, 0.0, 1.0),
    this.borderRadius,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant AnimatedPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.onTap != null && widget.onTap == null) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHighlightChanged(bool highlighted) {
    if (widget.onTap == null) return;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 0;
      return;
    }
    if (highlighted) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: _onHighlightChanged,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: enabled,
          mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          borderRadius: widget.borderRadius,
          focusColor: scheme.primary.withValues(alpha: 0.12),
          hoverColor: scheme.primary.withValues(alpha: 0.08),
          splashColor: scheme.primary.withValues(alpha: 0.12),
          child: AnimatedBuilder(
            animation: _controller,
            child: widget.child,
            builder: (context, child) {
              final reduceMotion = MediaQuery.of(context).disableAnimations;
              final scale = reduceMotion
                  ? 1.0
                  : 1 - ((1 - widget.scaleDown) * _controller.value);
              return Transform.scale(scale: scale, child: child);
            },
          ),
        ),
      ),
    );
  }
}
