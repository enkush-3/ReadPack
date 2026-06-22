import 'package:flutter/material.dart';

class BookColors {
  BookColors._();

  // Primary palette from design
  static const Color deepBlue = Color(0xFF182350);
  static const Color deepBlueDark = Color(0xFF101840);
  static const Color deepBlueLight = Color(0xFF243575);

  static const Color powderBlue = Color(0xFFAFD2FA);
  static const Color powderBlueDark = Color(0xFF7BBAF7);
  static const Color powderBlueLight = Color(0xFFD0E8FD);

  static const Color floralWhite = Color(0xFFFEFAEF);
  static const Color floralWhiteDark = Color(0xFFF5EDD8);
  static const Color floralWhiteDeep = Color(0xFFEDE0C4);

  static const Color paleBrown = Color(0xFFB9915E);
  static const Color paleBrownDark = Color(0xFF8F6A3A);
  static const Color paleBrownLight = Color(0xFFD4B48C);

  // Light theme semantic colors
  static const Color lightBg = floralWhite;
  static const Color lightBgSecondary = floralWhiteDark;
  static const Color lightCardBg = Colors.white;
  static const Color lightTextPrimary = deepBlue;
  static const Color lightTextSecondary = Color(0xFF3A4A7A);
  static const Color lightTextMuted = Color(0xFF7A8AAA);
  static const Color lightTextHint = Color(0xFFAABBCC);
  static const Color lightInputBg = Color(0xFFF0F4FC);
  static const Color lightInputBorder = powderBlueLight;
  static const Color lightDivider = Color(0xFFDDE6F5);

  // Dark theme semantic colors (deep navy-based reading palette)
  static const Color darkBg = Color(0xFF0E1630);
  static const Color darkBgSecondary = Color(0xFF162040);
  static const Color darkCardBg = Color(0xFF1C2A50);
  static const Color darkTextPrimary = floralWhite;
  static const Color darkTextSecondary = Color(0xFFCDD8EE);
  static const Color darkTextMuted = Color(0xFF8896B8);
  static const Color darkTextHint = Color(0xFF4A5A7A);
  static const Color darkInputBg = Color(0xFF1A2645);
  static const Color darkInputBorder = Color(0xFF2A3A60);
  static const Color darkDivider = Color(0xFF253050);

  // Sepia / reading mode colors
  static const Color sepiaBg = Color(0xFFF5E6C8);
  static const Color sepiaBgSecondary = Color(0xFFEDD8A8);
  static const Color sepiaText = Color(0xFF3A2A10);
  static const Color sepiaTextMuted = Color(0xFF7A5A30);
}

class BookTheme {
  BookTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BookColors.lightBg,
      colorScheme: const ColorScheme.light(
        // Primary: Deep Blue (nav, buttons, headers)
        primary: BookColors.deepBlue,
        onPrimary: Colors.white,
        primaryContainer: BookColors.powderBlueLight,
        onPrimaryContainer: BookColors.deepBlueDark,

        // Secondary: Pale Brown (accents, highlights, chapter markers)
        secondary: BookColors.paleBrown,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFF3DFC0),
        onSecondaryContainer: BookColors.paleBrownDark,

        // Tertiary: Powder Blue (tags, badges, progress)
        tertiary: BookColors.powderBlue,
        onTertiary: BookColors.deepBlue,
        tertiaryContainer: BookColors.powderBlueLight,
        onTertiaryContainer: BookColors.deepBlueDark,

        // Surfaces
        surface: BookColors.lightCardBg,
        onSurface: BookColors.lightTextPrimary,
        onSurfaceVariant: BookColors.lightTextSecondary,
        surfaceContainerLowest: BookColors.floralWhite,
        surfaceContainerLow: BookColors.floralWhiteDark,
        surfaceContainer: BookColors.lightInputBg,
        surfaceContainerHigh: BookColors.lightCardBg,
        surfaceContainerHighest: BookColors.floralWhiteDeep,

        // Utility
        error: Color(0xFFB00020),
        onError: Colors.white,
        outline: BookColors.lightTextMuted,
        outlineVariant: BookColors.lightInputBorder,
        shadow: BookColors.lightDivider,
        scrim: BookColors.deepBlue,
        inverseSurface: BookColors.deepBlue,
        onInverseSurface: BookColors.floralWhite,
        inversePrimary: BookColors.powderBlue,
      ),
      textTheme: _buildTextTheme(BookColors.lightTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: BookColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: BookColors.deepBlue,
        unselectedItemColor: BookColors.lightTextMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: BookColors.lightCardBg,
        elevation: 2,
        shadowColor: BookColors.lightDivider,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BookColors.lightInputBg,
        hintStyle: const TextStyle(color: BookColors.lightTextHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BookColors.lightInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BookColors.lightInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BookColors.deepBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BookColors.deepBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BookColors.deepBlue,
          side: const BorderSide(color: BookColors.deepBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BookColors.paleBrown,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: BookColors.lightInputBg,
        selectedColor: BookColors.powderBlueLight,
        labelStyle: TextStyle(
          color: BookColors.deepBlue,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: BookColors.lightInputBorder),
        shape: StadiumBorder(),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: BookColors.deepBlue,
        inactiveTrackColor: BookColors.lightInputBorder,
        thumbColor: BookColors.deepBlue,
        overlayColor: Color(0x1A182350),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BookColors.paleBrown,
        linearTrackColor: BookColors.lightInputBorder,
      ),
      dividerTheme: const DividerThemeData(
        color: BookColors.lightDivider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: BookColors.lightTextSecondary,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BookColors.darkBg,
      colorScheme: const ColorScheme.dark(
        // Primary: Powder Blue (more readable on dark)
        primary: BookColors.powderBlue,
        onPrimary: BookColors.deepBlue,
        primaryContainer: BookColors.deepBlueLight,
        onPrimaryContainer: BookColors.powderBlueLight,

        // Secondary: Pale Brown accent
        secondary: BookColors.paleBrownLight,
        onSecondary: BookColors.deepBlueDark,
        secondaryContainer: BookColors.paleBrownDark,
        onSecondaryContainer: BookColors.floralWhiteDark,

        // Tertiary: Powder Blue light
        tertiary: BookColors.powderBlueLight,
        onTertiary: BookColors.deepBlueDark,
        tertiaryContainer: BookColors.deepBlue,
        onTertiaryContainer: BookColors.powderBlue,

        // Surfaces
        surface: BookColors.darkCardBg,
        onSurface: BookColors.darkTextPrimary,
        onSurfaceVariant: BookColors.darkTextSecondary,
        surfaceContainerLowest: BookColors.darkBg,
        surfaceContainerLow: BookColors.darkBgSecondary,
        surfaceContainer: BookColors.darkInputBg,
        surfaceContainerHigh: BookColors.darkCardBg,
        surfaceContainerHighest: Color(0xFF223060),

        // Utility
        error: Color(0xFFCF6679),
        onError: Colors.black,
        outline: BookColors.darkTextMuted,
        outlineVariant: BookColors.darkInputBorder,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: BookColors.floralWhite,
        onInverseSurface: BookColors.deepBlue,
        inversePrimary: BookColors.deepBlue,
      ),
      textTheme: _buildTextTheme(BookColors.darkTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: BookColors.darkBgSecondary,
        foregroundColor: BookColors.floralWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: BookColors.floralWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BookColors.darkBgSecondary,
        selectedItemColor: BookColors.powderBlue,
        unselectedItemColor: BookColors.darkTextMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: BookColors.darkCardBg,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BookColors.darkInputBg,
        hintStyle: const TextStyle(color: BookColors.darkTextHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BookColors.darkInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BookColors.darkInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BookColors.powderBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BookColors.powderBlue,
          foregroundColor: BookColors.deepBlue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BookColors.powderBlue,
          side: const BorderSide(color: BookColors.powderBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BookColors.paleBrownLight,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: BookColors.darkInputBg,
        selectedColor: BookColors.deepBlue,
        labelStyle: TextStyle(
          color: BookColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: BookColors.darkInputBorder),
        shape: StadiumBorder(),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: BookColors.powderBlue,
        inactiveTrackColor: BookColors.darkInputBorder,
        thumbColor: BookColors.powderBlue,
        overlayColor: Color(0x1AAFD2FA),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BookColors.paleBrownLight,
        linearTrackColor: BookColors.darkInputBorder,
      ),
      dividerTheme: const DividerThemeData(
        color: BookColors.darkDivider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: BookColors.darkTextSecondary,
      ),
      primaryIconTheme: const IconThemeData(
        color: BookColors.floralWhite,
      ),
    );
  }

  /// Sepia reading mode — warm parchment tones, easy on the eyes.
  /// Use this as an override when the user is actively reading a book.
  static ThemeData get sepiaTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BookColors.sepiaBg,
      colorScheme: const ColorScheme.light(
        primary: BookColors.paleBrownDark,
        onPrimary: Colors.white,
        primaryContainer: BookColors.floralWhiteDeep,
        onPrimaryContainer: BookColors.paleBrownDark,
        secondary: BookColors.deepBlue,
        onSecondary: Colors.white,
        surface: BookColors.sepiaBg,
        onSurface: BookColors.sepiaText,
        onSurfaceVariant: BookColors.sepiaTextMuted,
        surfaceContainerLowest: BookColors.sepiaBg,
        surfaceContainerLow: BookColors.sepiaBgSecondary,
        surfaceContainer: BookColors.floralWhiteDeep,
        surfaceContainerHigh: BookColors.floralWhiteDark,
        outline: BookColors.sepiaTextMuted,
        outlineVariant: BookColors.floralWhiteDeep,
        error: Color(0xFFB00020),
        onError: Colors.white,
        inverseSurface: BookColors.sepiaText,
        onInverseSurface: BookColors.sepiaBg,
        inversePrimary: BookColors.paleBrownLight,
      ),
      textTheme: _buildTextTheme(BookColors.sepiaText),
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(color: baseColor, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: TextStyle(color: baseColor, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(color: baseColor, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(color: baseColor, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: baseColor, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: baseColor, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: baseColor, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      titleMedium: TextStyle(color: baseColor, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: TextStyle(color: baseColor, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: TextStyle(color: baseColor, fontWeight: FontWeight.w400, height: 1.6),
      bodyMedium: TextStyle(color: baseColor, fontWeight: FontWeight.w400, height: 1.55),
      bodySmall: TextStyle(color: baseColor, fontWeight: FontWeight.w400, height: 1.5),
      labelLarge: TextStyle(color: baseColor, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelMedium: TextStyle(color: baseColor, fontWeight: FontWeight.w500, letterSpacing: 0.4),
      labelSmall: TextStyle(color: baseColor, fontWeight: FontWeight.w400, letterSpacing: 0.3),
    );
  }
}