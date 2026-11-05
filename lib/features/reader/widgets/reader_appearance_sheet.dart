import 'package:flutter/material.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/widgets/reader_appearance_chips.dart';
import 'package:readpack/features/reader/widgets/reader_appearance_sections.dart';
import 'package:readpack/helper/translation.dart';

class ReaderAppearanceSheet {
  static void show(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          final onSheetColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final l10n = AppLocalizations.of(context);

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onSheetColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n?.t('reader.reading_settings') ?? 'Унших тохиргоо',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ReaderFontSizeControl(
                    themeProvider: themeProvider,
                    onSheetColor: onSheetColor,
                    setSheetState: setSheetState,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                  // Themes Row
                  Text(
                    l10n?.t('reader.screen_theme') ?? 'Дэлгэцийн өнгө',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ReaderAppearanceChips.buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_white') ?? 'Цагаан',
                        theme: AppReaderTheme.light,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFFFAFAFA),
                        textColor: const Color(0xFF182350),
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.light);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_sepia') ?? 'Сепиа',
                        theme: AppReaderTheme.sepia,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFFF5E6C8),
                        textColor: const Color(0xFF3A2A10),
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.sepia);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_dark') ?? 'Харанхуй',
                        theme: AppReaderTheme.dark,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFF1E293B),
                        textColor: Colors.white,
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.dark);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_charcoal') ?? 'Нүүрс',
                        theme: AppReaderTheme.charcoal,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFF0F172A),
                        textColor: Colors.white,
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.charcoal);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Reading Mode Toggle
                  Text(
                    l10n?.t('reader.reading_mode') ?? 'Унших горим',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ReaderReadingModeControl(
                    themeProvider: themeProvider,
                    onSheetColor: onSheetColor,
                    setSheetState: setSheetState,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                  // Font Family Row
                  Text(
                    l10n?.t('reader.font_family') ?? 'Фонтын хэв маяг',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ReaderAppearanceChips.buildFontChip(
                        context,
                        'Serif',
                        l10n?.t('reader.font_serif') ?? 'Сонгодог (Serif)',
                        themeProvider,
                        setSheetState,
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildFontChip(
                        context,
                        'Sans',
                        l10n?.t('reader.font_sans') ?? 'Орчин үе (Sans)',
                        themeProvider,
                        setSheetState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ReaderAppearanceChips.buildFontChip(
                        context,
                        'Georgia',
                        'Georgia',
                        themeProvider,
                        setSheetState,
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildFontChip(
                        context,
                        'Mono',
                        l10n?.t('reader.font_mono') ?? 'Monospace',
                        themeProvider,
                        setSheetState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Line Height Controls
                  Text(
                    l10n?.t('reader.line_height') ?? 'Мөр хоорондын зай',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ReaderAppearanceChips.buildValueChip(
                          context,
                          '1.4x',
                          (themeProvider.lineHeight - 1.4).abs() < 0.05, () {
                        themeProvider.setLineHeight(1.4);
                        setSheetState(() {});
                      }),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildValueChip(
                          context,
                          '1.7x',
                          (themeProvider.lineHeight - 1.7).abs() < 0.05, () {
                        themeProvider.setLineHeight(1.7);
                        setSheetState(() {});
                      }),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildValueChip(
                          context,
                          '2.0x',
                          (themeProvider.lineHeight - 2.0).abs() < 0.05, () {
                        themeProvider.setLineHeight(2.0);
                        setSheetState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Margin Controls
                  Text(
                    l10n?.t('reader.margins') ?? 'Захаас авах зай',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ReaderAppearanceChips.buildValueChip(
                        context,
                        l10n?.t('reader.margin_narrow') ?? 'Нарийн',
                        (themeProvider.horizontalMargin - 14.0).abs() < 0.1,
                        () {
                          themeProvider.setHorizontalMargin(14.0);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildValueChip(
                        context,
                        l10n?.t('reader.margin_normal') ?? 'Хэвийн',
                        (themeProvider.horizontalMargin - 20.0).abs() < 0.1,
                        () {
                          themeProvider.setHorizontalMargin(20.0);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ReaderAppearanceChips.buildValueChip(
                        context,
                        l10n?.t('reader.margin_wide') ?? 'Өргөн',
                        (themeProvider.horizontalMargin - 28.0).abs() < 0.1,
                        () {
                          themeProvider.setHorizontalMargin(28.0);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
