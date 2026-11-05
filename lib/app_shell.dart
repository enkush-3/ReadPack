import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/home/presentation/page/home.dart';
import 'package:readpack/features/home/widgets/continue_reading_card.dart';
import 'package:readpack/features/library/presentation/page/saved_page.dart';
import 'package:readpack/features/profile/presentation/page/profile_page.dart';
import 'package:readpack/features/search/presentation/page/search.dart';
import 'package:readpack/features/shared/widgets/bottomnavbar.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  int _previousIndex = 0;
  bool _showContinueReadingModal = true;
  late AnimationController _tabAnimController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _previousIndex = _selectedIndex;
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _tabAnimController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index >= 0 && index < 4 && index != _selectedIndex) {
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = index;
      });
      _tabAnimController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final continueBooks = bookProvider.continueReadingBooks;

    final pages = [
      HomePage(onNavigateTab: _onNavTap),
      SearchPage(onNavigateTab: _onNavTap),
      SavedPage(onNavigateTab: _onNavTap),
      const ProfilePage(),
    ];

    final direction = _selectedIndex >= _previousIndex ? 1.0 : -1.0;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onNavTap(0);
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _tabAnimController,
          builder: (context, child) {
            final curved = Curves.easeOutCubic.transform(_tabAnimController.value);
            final dx = (1.0 - curved) * 18.0 * direction;
            return Opacity(
              opacity: 0.35 + (0.65 * curved),
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              ),
            );
          },
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showContinueReadingModal && continueBooks.isNotEmpty)
              ContinueReadingCard(
                book: continueBooks.first,
                onTap: () {
                  final book = continueBooks.first;
                  Navigator.of(context).pushNamed(
                    Routes.reader,
                    arguments: {
                      'book': book,
                      'initialChapterIndex': book.currentChapterIndex,
                    },
                  );
                },
                onClose: () {
                  setState(() => _showContinueReadingModal = false);
                },
              ),
            BottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }
}