import 'package:flutter/material.dart';
import 'package:readpack/features/home/presentation/page/home.dart';
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

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onNavTap(int index) {
    if (index >= 0 && index < 4) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigateTab: _onNavTap),
      SearchPage(onNavigateTab: _onNavTap),
      SavedPage(onNavigateTab: _onNavTap),
      const ProfilePage(),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}