import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readpack/helper/translation.dart';

class RefreshWrapper extends StatefulWidget {
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

  @override
  State<RefreshWrapper> createState() => _RefreshWrapperState();
}

class _RefreshWrapperState extends State<RefreshWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isRefreshing = false;
  double _pullDistance = 0.0;
  static const double _triggerThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isRefreshing = true;
    });
    _spinController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _spinController.stop();
        _spinController.reset();
        setState(() {
          _isRefreshing = false;
          _pullDistance = 0.0;
        });
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.extentBefore == 0 &&
          notification.scrollDelta != null &&
          notification.scrollDelta! < 0) {
        setState(() {
          _pullDistance =
              (_pullDistance - notification.scrollDelta!).clamp(0.0, 120.0);
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_pullDistance > 0 && !_isRefreshing) {
        setState(() {
          _pullDistance = 0.0;
        });
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        setState(() {
          _pullDistance =
              (_pullDistance - notification.overscroll).clamp(0.0, 120.0);
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = widget.color ?? colorScheme.primary;
    final pullFraction = (_pullDistance / _triggerThreshold).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        children: [
          // Underlying RefreshIndicator ensures native gesture compatibility
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: primaryColor,
            backgroundColor: widget.backgroundColor ?? colorScheme.surface,
            displacement: widget.displacement,
            strokeWidth: 2.5,
            child: widget.child,
          ),

          // Custom floating animated indicator on pull
          if (_pullDistance > 10 || _isRefreshing)
            Positioned(
              top: 12 + (_pullDistance * 0.35).clamp(0.0, 40.0),
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    final rotation = _isRefreshing
                        ? _spinController.value * 2 * math.pi
                        : pullFraction * math.pi;

                    final l10n = AppLocalizations.of(context);
                    final refreshingText =
                        l10n?.t('refresh.refreshing') ?? 'Шинэчилж байна...';
                    final releaseText =
                        l10n?.t('refresh.release') ?? 'Тавьж шинэчлэх';
                    final pullText =
                        l10n?.t('refresh.pull') ?? 'Татаж шинэчлэх';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withValues(
                              alpha: _isRefreshing ? 0.4 : 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: rotation,
                            child: Icon(
                              _isRefreshing
                                  ? Icons.auto_stories_rounded
                                  : Icons.refresh_rounded,
                              size: 18,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRefreshing
                                ? refreshingText
                                : (pullFraction >= 0.95
                                    ? releaseText
                                    : pullText),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}