import 'package:flutter/material.dart';

/// FundaHub design tokens. Call [bind] whenever the active brightness changes
/// (from [themeMode] + platform), so semantic colors never drift from ThemeData.
abstract final class AppColors {
  static Brightness _brightness = Brightness.light;

  static void bind(Brightness brightness) {
    _brightness = brightness;
  }

  /// Resolve brightness the same way MaterialApp picks light vs dark ThemeData.
  static Brightness resolveBrightness(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  static bool get isDark => _brightness == Brightness.dark;

  // Brand (safe in const contexts — dark green works on light surfaces)
  static const Color brand = Color(0xFF064433);
  static const Color primaryDark = Color(0xFF043528);
  static const Color accent = Color(0xFFE8A017);
  static const Color accentSoft = Color(0xFFFFF4DE);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFA32A2A);
  static const Color quoteAccent = Color(0xFF8D6E63);
  static const Color govBadge = Color(0xFFE8A017);

  /// Prefer this in widgets (brighter green in dark mode).
  static Color get primary => isDark ? const Color(0xFF4CAF82) : brand;

  static Color get mint =>
      isDark ? const Color(0xFF2A4338) : const Color(0xFFD4EDE3);
  static Color get mintSoft =>
      isDark ? const Color(0xFF20362E) : const Color(0xFFE8F5EF);
  static Color get verified =>
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B7A4E);
  static Color get verifiedBg =>
      isDark ? const Color(0xFF163528) : const Color(0xFFE6F6EE);

  static Color get deadline =>
      isDark ? const Color(0xFFF0B45A) : const Color(0xFFE08A1A);
  static Color get deadlineBg =>
      isDark ? const Color(0xFF3A2E18) : const Color(0xFFFFF1DE);

  static Color get background =>
      isDark ? const Color(0xFF101714) : const Color(0xFFF5F6F5);
  static Color get surface =>
      isDark ? const Color(0xFF1B2621) : const Color(0xFFFFFFFF);
  static Color get surfaceElevated =>
      isDark ? const Color(0xFF24302B) : const Color(0xFFFFFFFF);
  static Color get border =>
      isDark ? const Color(0xFF334039) : const Color(0xFFE2E6E4);
  static Color get borderStrong =>
      isDark ? const Color(0xFF445049) : const Color(0xFFD0D7D3);

  static Color get textPrimary =>
      isDark ? const Color(0xFFF4F7F5) : const Color(0xFF1A1F1C);
  static Color get textSecondary =>
      isDark ? const Color(0xFFB8C2BC) : const Color(0xFF6B756F);
  static Color get textMuted =>
      isDark ? const Color(0xFF8E9892) : const Color(0xFF9AA49E);

  static Color get avatarBg =>
      isDark ? const Color(0xFF2E3D36) : const Color(0xFFDCE4E0);
  static Color get navInactive =>
      isDark ? const Color(0xFF8E9892) : const Color(0xFF8A948E);
  static Color get interestChipBg =>
      isDark ? const Color(0xFF2A4A3C) : const Color(0xFFDFF0E7);
  static Color get interestChipText =>
      isDark ? const Color(0xFFC5F2D9) : const Color(0xFF0F5C45);
  static Color get quoteBg =>
      isDark ? const Color(0xFF2A241E) : const Color(0xFFF5EDE4);

  // Aliases for older const usages of the light brand green.
  static const Color primaryConst = brand;
}
