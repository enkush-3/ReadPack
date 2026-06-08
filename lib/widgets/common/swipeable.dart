import 'package:flutter/material.dart';

/// 4 хуудасны хооронд swipe хийх боломжтой wrapper widget
class SwipeablePages extends StatefulWidget {
  final int initialPage;
  final List<Widget> pages;
  final ValueChanged<int>? onPageChanged;
  final PageController? pageController;

  const SwipeablePages({
    super.key,
    this.initialPage = 0,
    required this.pages,
    this.onPageChanged,
    this.pageController,
  });

  @override
  State<SwipeablePages> createState() => _SwipeablePagesState();
}

class _SwipeablePagesState extends State<SwipeablePages> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController ?? PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    // Зөвхөн өөрсдийн үүсгэсэн controller-г dispose хийнэ
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: widget.onPageChanged,
      physics: const ClampingScrollPhysics(),
      children: widget.pages,
    );
  }

  /// Гадуурх controller-р хуудас солих
  void jumpToPage(int page) {
    _pageController.jumpToPage(page);
  }

  /// Гадуурх controller-р хуудас солих (animation-тай)
  void animateToPage(int page, {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.easeInOut}) {
    _pageController.animateToPage(
      page,
      duration: duration,
      curve: curve,
    );
  }
}