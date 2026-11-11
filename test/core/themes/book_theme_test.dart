import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/themes/app_color.dart';
import 'package:readpack/core/themes/themes.dart';

void main() {
  group('BookTheme', () {
    test('builds seeded Material 3 light and dark schemes', () {
      final light = BookTheme.lightTheme();
      final dark = BookTheme.darkTheme();

      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(
        light.colorScheme,
        ColorScheme.fromSeed(
          seedColor: BookColors.seed,
          brightness: Brightness.light,
        ),
      );
    });

    test('uses dynamic color schemes when supplied', () {
      final dynamicLight = ColorScheme.fromSeed(
        seedColor: const Color(0xFF006A60),
        brightness: Brightness.light,
      );
      final dynamicDark = ColorScheme.fromSeed(
        seedColor: const Color(0xFF006A60),
        brightness: Brightness.dark,
      );

      expect(
        BookTheme.lightTheme(colorScheme: dynamicLight).colorScheme,
        dynamicLight,
      );
      expect(
        BookTheme.darkTheme(colorScheme: dynamicDark).colorScheme,
        dynamicDark,
      );
    });

    test('keeps the sepia reader theme and readable foregrounds', () {
      final sepia = BookTheme.sepiaTheme;

      expect(sepia.brightness, Brightness.light);
      expect(sepia.scaffoldBackgroundColor, BookColors.sepiaSurface);
      expect(sepia.colorScheme.onSurface, BookColors.sepiaOnSurface);
      expect(
        _contrastRatio(sepia.colorScheme.onSurface, sepia.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('uses M3 card shape and 48dp controls', () {
      final theme = BookTheme.lightTheme();
      final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
      final buttonSize = theme.filledButtonTheme.style!.minimumSize!.resolve(
        {},
      );

      expect(shape.borderRadius, BorderRadius.circular(16));
      expect(buttonSize, const Size(48, 48));
    });

    test('fallback color pairs meet readable contrast', () {
      final light = BookTheme.lightTheme().colorScheme;
      final dark = BookTheme.darkTheme().colorScheme;

      expect(
        _contrastRatio(light.primary, light.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(light.surface, light.onSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(dark.primary, dark.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(dark.surface, dark.onSurface),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
