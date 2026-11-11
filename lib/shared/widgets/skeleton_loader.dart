import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerPosition;
  bool _reduceMotion = false;
  bool _hasReadMotionPreference = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _shimmerPosition = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_hasReadMotionPreference && reduceMotion == _reduceMotion) return;
    _hasReadMotionPreference = true;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.surfaceContainerHighest;
    final highlightColor = scheme.surfaceContainerLow;
    final shape = BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );

    return ExcludeSemantics(
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: shape,
        clipBehavior: Clip.antiAlias,
        child: _reduceMotion
            ? null
            : AnimatedBuilder(
                animation: _shimmerPosition,
                builder: (context, child) => ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [
                      (_shimmerPosition.value - 0.4).clamp(0.0, 1.0),
                      _shimmerPosition.value.clamp(0.0, 1.0),
                      (_shimmerPosition.value + 0.4).clamp(0.0, 1.0),
                    ],
                    colors: [baseColor, highlightColor, baseColor],
                  ).createShader(bounds),
                  blendMode: BlendMode.srcATop,
                  child: child,
                ),
                child: ColoredBox(color: baseColor),
              ),
      ),
    );
  }
}

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 140, height: 192, borderRadius: 16),
          SizedBox(height: 8),
          SkeletonLoader(width: 120, height: 16, borderRadius: 4),
          SizedBox(height: 4),
          SkeletonLoader(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
