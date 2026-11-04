import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppReaderTheme {
  light,
  sepia,
  dark,
  charcoal,
}

class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'readpack_theme_mode';
  static const String _keyReaderTheme = 'readpack_reader_theme';
  static const String _keyFontSize = 'readpack_font_size';
  static const String _keyFontFamily = 'readpack_font_family';
  static const String _keyLocale = 'readpack_locale';
  static const String _keyIsPaginated = 'readpack_is_paginated';
  static const String _keyLineHeight = 'readpack_line_height';
  static const String _keyHorizontalMargin = 'readpack_horizontal_margin';

  ThemeMode _themeMode = ThemeMode.system;
  AppReaderTheme _readerTheme = AppReaderTheme.light;
  double _fontSizeScale = 1.0; // 0.85 to 1.4
  String _fontFamily = 'Serif';
  Locale _locale = const Locale('mn');
  bool _isPaginated = true;
  double _lineHeight = 1.7; // 1.4 to 2.2
  double _horizontalMargin = 20.0; // 12.0 to 32.0

  ThemeMode get themeMode => _themeMode;
  AppReaderTheme get readerTheme => _readerTheme;
  double get fontSizeScale => _fontSizeScale;
  String get fontFamily => _fontFamily;
  Locale get locale => _locale;
  bool get isPaginated => _isPaginated;
  double get lineHeight => _lineHeight;
  double get horizontalMargin => _horizontalMargin;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_keyThemeMode);
      if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[modeIndex];
      }

      final readerIndex = prefs.getInt(_keyReaderTheme);
      if (readerIndex != null &&
          readerIndex >= 0 &&
          readerIndex < AppReaderTheme.values.length) {
        _readerTheme = AppReaderTheme.values[readerIndex];
      }

      final fontScale = prefs.getDouble(_keyFontSize);
      if (fontScale != null) {
        _fontSizeScale = fontScale.clamp(0.8, 1.6);
      }

      final family = prefs.getString(_keyFontFamily);
      if (family != null) {
        _fontFamily = family;
      }

      final lang = prefs.getString(_keyLocale);
      if (lang != null) {
        _locale = Locale(lang);
      }

      final isPaginated = prefs.getBool(_keyIsPaginated);
      if (isPaginated != null) {
        _isPaginated = isPaginated;
      }

      final lh = prefs.getDouble(_keyLineHeight);
      if (lh != null) {
        _lineHeight = lh.clamp(1.3, 2.4);
      }

      final hm = prefs.getDouble(_keyHorizontalMargin);
      if (hm != null) {
        _horizontalMargin = hm.clamp(10.0, 36.0);
      }
      notifyListeners();
    } catch (_) {
      // Graceful fallback to defaults
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_keyThemeMode, mode.index);
    });
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setReaderTheme(AppReaderTheme theme) {
    _readerTheme = theme;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_keyReaderTheme, theme.index);
    });
  }

  void setFontSizeScale(double scale) {
    _fontSizeScale = scale.clamp(0.8, 1.6);
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_keyFontSize, _fontSizeScale);
    });
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_keyFontFamily, family);
    });
  }

  void setLocale(Locale loc) {
    _locale = loc;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_keyLocale, loc.languageCode);
    });
  }

  void setPaginated(bool paginated) {
    if (_isPaginated == paginated) return;
    _isPaginated = paginated;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_keyIsPaginated, paginated);
    });
  }

  void setLineHeight(double lineHeight) {
    _lineHeight = lineHeight.clamp(1.3, 2.4);
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_keyLineHeight, _lineHeight);
    });
  }

  void setHorizontalMargin(double margin) {
    _horizontalMargin = margin.clamp(10.0, 36.0);
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_keyHorizontalMargin, _horizontalMargin);
    });
  }
}
