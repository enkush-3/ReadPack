import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/shared/widgets/navbutton.dart';
import 'package:readpack/helper/translation.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final bookProvider = context.watch<BookProvider>();
    final savedCount = bookProvider.savedBooks.length;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 48,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 4;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      left: selectedIndex * itemWidth + 4,
                      top: 2,
                      bottom: 2,
                      width: itemWidth - 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        NavigationButton(
                          icon: Icons.home_rounded,
                          label: l10n?.t('app.navbar.home') ?? 'Нүүр',
                          isSelected: selectedIndex == 0,
                          onTap: () => onTap(0),
                        ),
                        NavigationButton(
                          icon: Icons.explore_rounded,
                          label: l10n?.t('app.navbar.search') ?? 'Хайх',
                          isSelected: selectedIndex == 1,
                          onTap: () => onTap(1),
                        ),
                        NavigationButton(
                          icon: Icons.bookmark_rounded,
                          label: l10n?.t('app.navbar.save') ?? 'Хадгалсан',
                          isSelected: selectedIndex == 2,
                          badgeCount: savedCount,
                          onTap: () => onTap(2),
                        ),
                        NavigationButton(
                          icon: Icons.person_rounded,
                          label: l10n?.t('app.navbar.profile') ?? 'Профайл',
                          isSelected: selectedIndex == 3,
                          onTap: () => onTap(3),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}