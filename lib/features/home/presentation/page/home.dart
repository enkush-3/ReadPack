import 'package:flutter/material.dart';
import 'package:readpack/features/shared/widgets/bottomnavbar.dart';

class HomePage extends StatefulWidget{
  const HomePage({
    super.key
  });

  @override
  State<HomePage> createState() => _StateHomePage();
}

class _StateHomePage extends State<HomePage> {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // body: SafeArea(
      //   child: SwipeablePages(
      //   ),
      // ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}