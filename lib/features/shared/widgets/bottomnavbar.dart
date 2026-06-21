import 'package:flutter/material.dart';
import 'package:readpack/features/shared/widgets/navbutton.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap
  });

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),

       child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            color: colorScheme.surface,
            height: 40,
            child: Row(
              children: [
                NavigationButton(
                  icon: Icons.home_rounded,
                  label: 'Нүүр',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                NavigationButton(
                  icon: Icons.explore_rounded,
                  label: 'Хайх',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                NavigationButton(
                  icon: Icons.bookmark_rounded,
                  label: 'Хадгалсан',
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
                NavigationButton(
                  icon: Icons.person_rounded,
                  label: 'Профайл',
                  isSelected: selectedIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }



}