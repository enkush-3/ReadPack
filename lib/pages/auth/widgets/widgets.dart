import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

Widget ReadPackLogo(BuildContext context, double baseSize) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final double padding = baseSize * 0.5;
  final double iconSize = baseSize * 1.5;
  final double readFontSize = baseSize * 1.7;
  final double pactFontSize = baseSize * 1.5;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(baseSize * 0.5),
        ),
        child: Icon(
          Icons.auto_stories,
          color: colorScheme.primary,
          size: iconSize,
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Read",
            style: GoogleFonts.playfairDisplay(
              fontSize: readFontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          Text(
            "Pact",
            style: GoogleFonts.playfairDisplay(
              fontSize: pactFontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget AuthHeader(BuildContext context, {
  required bool isLogin,
  required VoidCallback onToggle,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  Widget activeTab = Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    alignment: Alignment.center,
    child: Text(
      isLogin ? "Нэвтрэх" : "Бүртгүүлэх",
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    ),
  );

  Widget inactiveTab = Container(
    decoration: BoxDecoration(
      color: colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.only(
            bottomLeft: isLogin ? const Radius.circular(20) : Radius.zero,
            bottomRight: isLogin ? Radius.zero : const Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          isLogin ? "Бүртгүүлэх" : "Нэвтрэх",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    ),
  );

  return Row(
    children: [
      Expanded(child: isLogin ? activeTab : inactiveTab),
      Expanded(child: isLogin ? inactiveTab : activeTab)
    ],
  );
}

Widget buildInputField(context, {
  required String label,
  required String hint,
  required TextEditingController controller,
  bool isPassword = false,
  bool isObscured = false,
  VoidCallback? onToggleVisibility,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return TextFormField(
    controller: controller,
    obscureText: isPassword ? isObscured : false,
    keyboardType: keyboardType ?? TextInputType.text,
    validator: validator,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.7)),
      hintStyle: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      filled: true,
      fillColor: colorScheme.surface,
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onPressed: onToggleVisibility,
      )
          : null,
    ),
  );
}

Widget buildSubmitButton(context, {required String text, required VoidCallback onPressed}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SizedBox(
      height: 48,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}