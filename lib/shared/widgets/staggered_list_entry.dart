import 'dart:async';

import 'package:flutter/material.dart';

class StaggeredListEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final int delayPerItemMilliseconds;
  final Duration duration;

  const StaggeredListEntry({
    super.key,
    required this.child,
    required this.index,
    this.delayPerItemMilliseconds = 50,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<StaggeredListEntry> createState() => _StaggeredListEntryState();
}

class _StaggeredListEntryState extends State<StaggeredListEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _enterAnimation;
  Timer? _entryDelay;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _enterAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0, 0, 0.2, 1),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
      return;
    }

    final delay = Duration(
      milliseconds: widget.index * widget.delayPerItemMilliseconds,
    );
    _entryDelay = Timer(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _entryDelay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enterAnimation,
      child: widget.child,
      builder: (context, child) {
        final progress = MediaQuery.of(context).disableAnimations
            ? 1.0
            : _enterAnimation.value;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}
