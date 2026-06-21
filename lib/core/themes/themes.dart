import 'package:flutter/material.dart';

class AuthColors {
  AuthColors._();

  static const Color primary = Color(0xFF3BBFB8);
  static const Color primaryLight = Color(0xFF5DCFCA);
  static const Color primaryDark = Color(0xFF2A9D97);

  static const Color lightBgTop = Color(0xFFB8EEF0);
  static const Color lightBgBottom = Color(0xFFE8F4FB);
  static const Color lightCardBg = Colors.white;
  static const Color lightTextDark = Color(0xFF1A1A2E);
  static const Color lightTextMuted = Color(0xFF888888);
  static const Color lightTextHint = Color(0xFFAAAAAA);
  static const Color lightInputBg = Color(0xFFF5F6FA);
  static const Color lightInputBorder = Color(0xFFE8E8EE);
  static const Color lightInputIcon = Color(0xFFAAAAAA);
  static const Color lightDivider = Color(0xFFE0E0E0);

  static const Color darkBgTop = Color(0xFF1A2E2E);
  static const Color darkBgBottom = Color(0xFF0F1A1A);
  static const Color darkCardBg = Color(0xFF1E1E1E);
  static const Color darkTextDark = Color(0xFFEAEAEA);
  static const Color darkTextMuted = Color(0xFF9AA0A6);
  static const Color darkTextHint = Color(0xFF6B7280);
  static const Color darkInputBg = Color(0xFF2A2A2A);
  static const Color darkInputBorder = Color(0xFF3D3D3D);
  static const Color darkInputIcon = Color(0xFF6B7280);
  static const Color darkDivider = Color(0xFF3D3D3D);
}

class AuthTheme {
  AuthTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AuthColors.lightBgBottom,
      colorScheme: const ColorScheme.light(
        primary: AuthColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AuthColors.primaryLight,
        onPrimaryContainer: AuthColors.primaryDark,

        secondary: AuthColors.primaryDark,
        onSecondary: Colors.white,
        secondaryContainer: AuthColors.primaryLight,
        onSecondaryContainer: AuthColors.primaryDark,

        tertiary: AuthColors.primaryLight,
        onTertiary: Colors.white,

        surface: AuthColors.lightCardBg,
        onSurface: AuthColors.lightTextDark,
        onSurfaceVariant: AuthColors.lightTextMuted,
        surfaceContainerLowest: AuthColors.lightBgTop,
        surfaceContainerLow: AuthColors.lightBgBottom,
        surfaceContainer: AuthColors.lightInputBg,
        surfaceContainerHigh: AuthColors.lightCardBg,
        surfaceContainerHighest: AuthColors.lightInputBg,

        error: Colors.redAccent,
        onError: Colors.white,

        outline: AuthColors.lightInputIcon,
        outlineVariant: AuthColors.lightInputBorder,

        shadow: AuthColors.lightDivider,
        scrim: AuthColors.lightDivider,

        inverseSurface: AuthColors.lightTextHint,
        onInverseSurface: Colors.white,
        inversePrimary: AuthColors.primaryDark,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AuthColors.darkBgBottom,
      colorScheme: const ColorScheme.dark(
        primary: AuthColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AuthColors.primaryLight,
        onPrimaryContainer: AuthColors.primaryDark,

        secondary: AuthColors.primaryDark,
        onSecondary: Colors.white,
        secondaryContainer: AuthColors.primaryLight,
        onSecondaryContainer: AuthColors.primaryDark,

        tertiary: AuthColors.primaryLight,
        onTertiary: Colors.white,

        surface: AuthColors.darkCardBg,
        onSurface: AuthColors.darkTextDark,
        onSurfaceVariant: AuthColors.darkTextMuted,
        surfaceContainerLowest: AuthColors.darkBgBottom,
        surfaceContainerLow: AuthColors.darkBgTop,
        surfaceContainer: AuthColors.darkInputBg,
        surfaceContainerHigh: AuthColors.darkCardBg,
        surfaceContainerHighest: AuthColors.darkInputBg,

        error: Colors.redAccent,
        onError: Colors.white,

        outline: AuthColors.darkInputIcon,
        outlineVariant: AuthColors.darkInputBorder,

        shadow: AuthColors.darkDivider,
        scrim: AuthColors.darkDivider,

        inverseSurface: AuthColors.darkTextHint,
        onInverseSurface: Colors.white,
        inversePrimary: AuthColors.primaryDark,
      ),
    );
  }
}