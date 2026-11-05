import 'package:flutter/material.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReaderFontSizeControl extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Color onSheetColor;
  final StateSetter setSheetState;
  final AppLocalizations? l10n;

  const ReaderFontSizeControl({
    super.key,
    required this.themeProvider,
    required this.onSheetColor,
    required this.setSheetState,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n?.t('reader.font_size') ?? 'Үсгийн хэмжээ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: onSheetColor,
          ),
        ),
        Row(
          children: [
            AnimatedPressable(
              onTap: () {
                themeProvider.setFontSizeScale(
                    (themeProvider.fontSizeScale - 0.1).clamp(0.8, 1.5));
                setSheetState(() {});
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: onSheetColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'A-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onSheetColor,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${(themeProvider.fontSizeScale * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSheetColor,
                ),
              ),
            ),
            AnimatedPressable(
              onTap: () {
                themeProvider.setFontSizeScale(
                    (themeProvider.fontSizeScale + 0.1).clamp(0.8, 1.5));
                setSheetState(() {});
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: onSheetColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'A+',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: onSheetColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReaderReadingModeControl extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Color onSheetColor;
  final StateSetter setSheetState;
  final AppLocalizations? l10n;

  const ReaderReadingModeControl({
    super.key,
    required this.themeProvider,
    required this.onSheetColor,
    required this.setSheetState,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedPressable(
            onTap: () {
              themeProvider.setPaginated(true);
              setSheetState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: themeProvider.isPaginated
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15)
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isPaginated
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: themeProvider.isPaginated
                        ? Theme.of(context).colorScheme.primary
                        : onSheetColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.t('reader.mode_paginated') ?? 'Хуудаслалттай',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: themeProvider.isPaginated
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: themeProvider.isPaginated
                          ? Theme.of(context).colorScheme.primary
                          : onSheetColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedPressable(
            onTap: () {
              themeProvider.setPaginated(false);
              setSheetState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: !themeProvider.isPaginated
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15)
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !themeProvider.isPaginated
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 16,
                    color: !themeProvider.isPaginated
                        ? Theme.of(context).colorScheme.primary
                        : onSheetColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.t('reader.mode_scroll') ?? 'Тасралтгүй',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: !themeProvider.isPaginated
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: !themeProvider.isPaginated
                          ? Theme.of(context).colorScheme.primary
                          : onSheetColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
