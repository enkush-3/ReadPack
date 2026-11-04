import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        color: baseColor, 
        fontSize: 57, 
        fontWeight: FontWeight.w700, 
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        color: baseColor, 
        fontSize: 45, 
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        color: baseColor, 
        fontSize: 36, 
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        color: baseColor, 
        fontSize: 32, 
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: baseColor, 
        fontSize: 28, 
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: baseColor, 
        fontSize: 24, 
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: baseColor, 
        fontSize: 22, 
        fontWeight: FontWeight.w600, 
        letterSpacing: 0.2,
      ),
      titleMedium: TextStyle(
        color: baseColor, 
        fontSize: 16, 
        fontWeight: FontWeight.w500, 
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        color: baseColor, 
        fontSize: 14, 
        fontWeight: FontWeight.w500, 
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color: baseColor, 
        fontSize: 16, 
        fontWeight: FontWeight.w400, 
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: baseColor, 
        fontSize: 14, 
        fontWeight: FontWeight.w400, 
        height: 1.55,
      ),
      bodySmall: TextStyle(
        color: baseColor, 
        fontSize: 12, 
        fontWeight: FontWeight.w400, 
        height: 1.5,
      ),
      labelLarge: TextStyle(
        color: baseColor, 
        fontSize: 14, 
        fontWeight: FontWeight.w600, 
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        color: baseColor, 
        fontSize: 12, 
        fontWeight: FontWeight.w500, 
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        color: baseColor, 
        fontSize: 11, 
        fontWeight: FontWeight.w400, 
        letterSpacing: 0.3,
      ),
    );
  }
}