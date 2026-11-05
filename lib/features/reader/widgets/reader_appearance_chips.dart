import 'package:flutter/material.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReaderAppearanceChips {
  static Widget buildValueChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onSelect,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: AnimatedPressable(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildThemeChip(
    BuildContext context, {
    required String label,
    required AppReaderTheme theme,
    required AppReaderTheme currentTheme,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onSelect,
  }) {
    final isSelected = currentTheme == theme;

    return Expanded(
      child: AnimatedPressable(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildFontChip(
    BuildContext context,
    String familyKey,
    String label,
    ThemeProvider themeProvider,
    StateSetter setSheetState,
  ) {
    final isSelected = themeProvider.fontFamily == familyKey;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: AnimatedPressable(
        onTap: () {
          themeProvider.setFontFamily(familyKey);
          setSheetState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
