import 'package:flutter/material.dart';
import 'package:readpack/core/providers/theme_provider.dart';

class ReaderThemeHelpers {
  static Color getReaderBg(AppReaderTheme theme, bool isDark) {
    switch (theme) {
      case AppReaderTheme.sepia:
        return const Color(0xFFF5E6C8);
      case AppReaderTheme.dark:
        return const Color(0xFF1E293B);
      case AppReaderTheme.charcoal:
        return const Color(0xFF0F172A);
      case AppReaderTheme.light:
        return isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA);
    }
  }

  static Color getReaderTextColor(AppReaderTheme theme, bool isDark) {
    switch (theme) {
      case AppReaderTheme.sepia:
        return const Color(0xFF3A2A10);
      case AppReaderTheme.dark:
        return const Color(0xFFF1F5F9);
      case AppReaderTheme.charcoal:
        return const Color(0xFFCBD5E1);
      case AppReaderTheme.light:
        return isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    }
  }

  static TextStyle getReaderTextStyle(
    ThemeProvider themeProvider,
    Color readerTextColor,
  ) {
    String? family;
    switch (themeProvider.fontFamily) {
      case 'Sans':
        family = null; // System default Sans-Serif
        break;
      case 'Georgia':
        family = 'Georgia';
        break;
      case 'Mono':
        family = 'Monospace';
        break;
      case 'Serif':
      default:
        family = 'Serif';
        break;
    }
    return TextStyle(
      fontFamily: family,
      fontSize: (16 * themeProvider.fontSizeScale).clamp(12.0, 26.0),
      height: themeProvider.lineHeight,
      color: readerTextColor,
      letterSpacing: 0.15,
    );
  }

  static String formatTime(double totalSec) {
    final m = (totalSec / 60).floor();
    final s = (totalSec % 60).floor();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static List<String> paginateChapter(String content) {
    final rawParagraphs =
        content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    if (rawParagraphs.isEmpty) return [content];

    final List<String> pages = [];
    StringBuffer currentChunk = StringBuffer();
    int currentLength = 0;

    for (final p in rawParagraphs) {
      if (p.length > 600) {
        final sentences = p.split('. ');
        for (final s in sentences) {
          if (currentLength + s.length > 500 && currentLength > 0) {
            pages.add(currentChunk.toString().trim());
            currentChunk = StringBuffer();
            currentLength = 0;
          }
          currentChunk.write(s.endsWith('.') ? '$s ' : '$s. ');
          currentLength += s.length + (s.endsWith('.') ? 1 : 2);
        }
      } else {
        if (currentLength + p.length > 550 && currentLength > 0) {
          pages.add(currentChunk.toString().trim());
          currentChunk = StringBuffer();
          currentLength = 0;
        }
        if (currentChunk.isNotEmpty) {
          currentChunk.write('\n\n');
        }
        currentChunk.write(p);
        currentLength += p.length;
      }
    }
    if (currentChunk.isNotEmpty) {
      pages.add(currentChunk.toString().trim());
    }
    return pages.isEmpty ? [content] : pages;
  }
}
