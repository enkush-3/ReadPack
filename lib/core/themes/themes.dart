import 'package:flutter/material.dart';
import 'package:readpack/core/themes/app_color.dart';
import 'package:readpack/core/themes/app_text_styles.dart';

class BookTheme {
  BookTheme._();

  static const double cardRadius = 16;
  static const double controlRadius = 12;
  static const Size minimumTapTarget = Size(48, 48);

  static ColorScheme lightColorScheme({ColorScheme? dynamicScheme}) {
    return dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: BookColors.seed,
          brightness: Brightness.light,
        );
  }

  static ColorScheme darkColorScheme({ColorScheme? dynamicScheme}) {
    return dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: BookColors.seed,
          brightness: Brightness.dark,
        );
  }

  static ThemeData lightTheme({ColorScheme? colorScheme}) =>
      _buildTheme(lightColorScheme(dynamicScheme: colorScheme));

  static ThemeData darkTheme({ColorScheme? colorScheme}) =>
      _buildTheme(darkColorScheme(dynamicScheme: colorScheme));

  static ThemeData get sepiaTheme {
    final seeded = ColorScheme.fromSeed(
      seedColor: BookColors.sepiaPrimary,
      brightness: Brightness.light,
    );
    return _buildTheme(
      seeded.copyWith(
        primary: BookColors.sepiaPrimary,
        onPrimary: Colors.white,
        surface: BookColors.sepiaSurface,
        onSurface: BookColors.sepiaOnSurface,
        onSurfaceVariant: BookColors.sepiaOnSurfaceVariant,
        surfaceContainerLowest: BookColors.sepiaBackground,
        surfaceContainerLow: const Color(0xFFF4EBDD),
        surfaceContainer: const Color(0xFFF0E6D6),
        surfaceContainerHigh: const Color(0xFFECE0CC),
        surfaceContainerHighest: const Color(0xFFE6D8C2),
        outline: const Color(0xFF7A6955),
        outlineVariant: const Color(0xFFD4C5AF),
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme = AppTextStyles.buildTextTheme(scheme.onSurface);
    final outline = scheme.outlineVariant;
    final focus = scheme.primary;
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textTheme: textTheme,
      focusColor: focus.withValues(alpha: 0.12),
      hoverColor: focus.withValues(alpha: 0.08),
      highlightColor: focus.withValues(alpha: 0.12),
      splashColor: focus.withValues(alpha: 0.12),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: outline.withValues(alpha: 0.45)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.65)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: focus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: minimumTapTarget,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: controlShape,
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minimumTapTarget,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minimumTapTarget,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: controlShape,
          side: BorderSide(color: outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minimumTapTarget,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: minimumTapTarget,
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: const CircleBorder(),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.secondaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        side: BorderSide(color: outline.withValues(alpha: 0.6)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        showCheckmark: true,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.45),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
