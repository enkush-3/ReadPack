// lib/core/themes/book_theme.dart
import 'package:flutter/material.dart';
import 'package:readpack/core/themes/app_color.dart';
import 'package:readpack/core/themes/app_text_styles.dart';

class BookTheme {
  BookTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BookColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: BookColors.deepBlue,
        onPrimary: Colors.white,
        primaryContainer: BookColors.powderBlueLight,
        onPrimaryContainer: BookColors.deepBlueDark,
        secondary: BookColors.paleBrown,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFF3DFC0),
        onSecondaryContainer: BookColors.paleBrownDark,
        tertiary: BookColors.powderBlue,
        onTertiary: BookColors.deepBlue,
        tertiaryContainer: BookColors.powderBlueLight,
        onTertiaryContainer: BookColors.deepBlueDark,
        surface: BookColors.lightCardBg,
        onSurface: BookColors.lightTextPrimary,
        onSurfaceVariant: BookColors.lightTextSecondary,
        surfaceContainerLowest: BookColors.floralWhite,
        surfaceContainerLow: BookColors.floralWhiteDark,
        surfaceContainer: BookColors.lightInputBg,
        surfaceContainerHigh: BookColors.lightCardBg,
        surfaceContainerHighest: BookColors.floralWhiteDeep,
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
      textTheme: AppTextStyles.buildTextTheme(BookColors.lightTextPrimary),
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
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BookColors.lightInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BookColors.lightInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(14),
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
            borderRadius: BorderRadius.circular(14),
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
        primary: BookColors.powderBlue,
        onPrimary: BookColors.deepBlue,
        primaryContainer: BookColors.deepBlueLight,
        onPrimaryContainer: BookColors.powderBlueLight,
        secondary: BookColors.paleBrownLight,
        onSecondary: BookColors.deepBlueDark,
        secondaryContainer: BookColors.paleBrownDark,
        onSecondaryContainer: BookColors.floralWhiteDark,
        tertiary: BookColors.powderBlueLight,
        onTertiary: BookColors.deepBlueDark,
        tertiaryContainer: BookColors.deepBlue,
        onTertiaryContainer: BookColors.powderBlue,
        surface: BookColors.darkCardBg,
        onSurface: BookColors.darkTextPrimary,
        onSurfaceVariant: BookColors.darkTextSecondary,
        surfaceContainerLowest: BookColors.darkBg,
        surfaceContainerLow: BookColors.darkBgSecondary,
        surfaceContainer: BookColors.darkInputBg,
        surfaceContainerHigh: BookColors.darkCardBg,
        surfaceContainerHighest: Color(0xFF223060),
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
      textTheme: AppTextStyles.buildTextTheme(BookColors.darkTextPrimary),
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
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BookColors.darkInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BookColors.darkInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(14),
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
      textTheme: AppTextStyles.buildTextTheme(BookColors.sepiaText),
    );
  }
}