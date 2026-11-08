import 'package:flutter/material.dart';

class BookColors {
  BookColors._();

  // Core brand palette: Clean Nordic Navy & Powder Ice Blue
  static const Color deepBlue = Color(0xFF182350);
  static const Color deepBlueDark = Color(0xFF101840);
  static const Color deepBlueLight = Color(0xFF243575);

  static const Color powderBlue = Color(0xFFAFD2FA);
  static const Color powderBlueDark = Color(0xFF7BBAF7);
  static const Color powderBlueLight = Color(0xFFD0E8FD);

  // Modern cool off-white & slate-mist (replaces old yellowish floralWhite)
  static const Color coolWhite = Color(0xFFF8FAFD);
  static const Color coolWhiteDark = Color(0xFFEDF2F8);
  static const Color coolWhiteDeep = Color(0xFFE2EBF5);

  // Backward compatibility aliases cleanly mapped to cool off-white
  static const Color floralWhite = coolWhite;
  static const Color floralWhiteDark = coolWhiteDark;
  static const Color floralWhiteDeep = coolWhiteDeep;

  // Modern slate blue & steel indigo (replaces old yellowish paleBrown)
  static const Color slateBlue = Color(0xFF2C4378);
  static const Color slateBlueDark = Color(0xFF1B2A52);
  static const Color slateBlueLight = Color(0xFF4A6595);

  // Backward compatibility aliases cleanly mapped to slate blue
  static const Color paleBrown = slateBlue;
  static const Color paleBrownDark = slateBlueDark;
  static const Color paleBrownLight = slateBlueLight;

  static const Color lightBg = coolWhite;
  static const Color lightBgSecondary = coolWhiteDark;
  static const Color lightCardBg = Colors.white;
  static const Color lightTextPrimary = deepBlue;
  static const Color lightTextSecondary = Color(0xFF3A4A7A);
  static const Color lightTextMuted = Color(0xFF7A8AAA);
  static const Color lightTextHint = Color(0xFFAABBCC);
  static const Color lightInputBg = Color(0xFFF0F4FC);
  static const Color lightInputBorder = powderBlueLight;
  static const Color lightDivider = Color(0xFFDDE6F5);

  static const Color darkBg = Color(0xFF0E1630);
  static const Color darkBgSecondary = Color(0xFF162040);
  static const Color darkCardBg = Color(0xFF1C2A50);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCDD8EE);
  static const Color darkTextMuted = Color(0xFF8896B8);
  static const Color darkTextHint = Color(0xFF4A5A7A);
  static const Color darkInputBg = Color(0xFF162244);
  static const Color darkInputBorder = Color(0xFF334878);
  static const Color darkDivider = Color(0xFF283862);

  static const Color sepiaBg = Color(0xFFF5E6C8);
  static const Color sepiaBgSecondary = Color(0xFFEDD8A8);
  static const Color sepiaText = Color(0xFF3A2A10);
  static const Color sepiaTextMuted = Color(0xFF7A5A30);
}
