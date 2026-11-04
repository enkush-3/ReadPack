import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    test('Initial defaults are correct', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.readerTheme, AppReaderTheme.light);
      expect(provider.fontSizeScale, 1.0);
      expect(provider.fontFamily, 'Serif');
      expect(provider.locale.languageCode, 'mn');
    });

    test('Theme toggle toggles dark and light mode', () {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.light);
      expect(provider.isDarkMode, false);

      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);

      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
    });

    test('Font size scaling clamps between 0.8 and 1.6', () {
      final provider = ThemeProvider();
      provider.setFontSizeScale(2.5);
      expect(provider.fontSizeScale, 1.6);

      provider.setFontSizeScale(0.2);
      expect(provider.fontSizeScale, 0.8);

      provider.setFontSizeScale(1.2);
      expect(provider.fontSizeScale, closeTo(1.2, 0.001));
    });

    test('Reader themes change accurately', () {
      final provider = ThemeProvider();
      provider.setReaderTheme(AppReaderTheme.sepia);
      expect(provider.readerTheme, AppReaderTheme.sepia);

      provider.setReaderTheme(AppReaderTheme.charcoal);
      expect(provider.readerTheme, AppReaderTheme.charcoal);
    });

    test('Locale switching changes correctly', () {
      final provider = ThemeProvider();
      provider.setLocale(const Locale('en'));
      expect(provider.locale.languageCode, 'en');

      provider.setLocale(const Locale('mn'));
      expect(provider.locale.languageCode, 'mn');
    });
  });
}
