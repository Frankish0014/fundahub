import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light({bool compact = false}) {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brand,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.accent,
      onSecondary: Color(0xFF1A1F1C),
      error: AppColors.danger,
      onError: AppColors.onPrimary,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1F1C),
      surfaceContainerHighest: Color(0xFFEEF1EF),
      onSurfaceVariant: Color(0xFF6B756F),
      outline: Color(0xFFE2E6E4),
      outlineVariant: Color(0xFFD0D7D3),
      tertiary: Color(0xFF1B7A4E),
      onTertiary: AppColors.onPrimary,
    );

    return _build(
      scheme: scheme,
      compact: compact,
      scaffold: const Color(0xFFF5F6F5),
      card: const Color(0xFFFFFFFF),
      border: const Color(0xFFE2E6E4),
      textPrimary: const Color(0xFF1A1F1C),
      textMuted: const Color(0xFF9AA49E),
      primary: AppColors.brand,
      overlay: SystemUiOverlayStyle.dark,
      inputFill: const Color(0xFFFFFFFF),
    );
  }

  static ThemeData dark({bool compact = false}) {
    const primary = Color(0xFF4CAF82);
    const scaffold = Color(0xFF101714);
    const card = Color(0xFF1B2621);
    const elevated = Color(0xFF24302B);
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Color(0xFF003822),
      secondary: AppColors.accent,
      onSecondary: Color(0xFF1A1F1C),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF1A1F1C),
      surface: card,
      onSurface: Color(0xFFF4F7F5),
      surfaceContainerHighest: elevated,
      onSurfaceVariant: Color(0xFFB8C2BC),
      outline: Color(0xFF334039),
      outlineVariant: Color(0xFF445049),
      tertiary: Color(0xFF4ADE80),
      onTertiary: Color(0xFF003822),
    );

    return _build(
      scheme: scheme,
      compact: compact,
      scaffold: scaffold,
      card: card,
      border: const Color(0xFF334039),
      textPrimary: const Color(0xFFF4F7F5),
      textMuted: const Color(0xFF8E9892),
      primary: primary,
      overlay: SystemUiOverlayStyle.light,
      inputFill: elevated,
    );
  }

  static ThemeData _build({
    required ColorScheme scheme,
    required bool compact,
    required Color scaffold,
    required Color card,
    required Color border,
    required Color textPrimary,
    required Color textMuted,
    required Color primary,
    required SystemUiOverlayStyle overlay,
    required Color inputFill,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      canvasColor: scaffold,
      cardColor: card,
      dividerColor: border,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    );

    TextStyle withColor(TextStyle? style) =>
        (style ?? const TextStyle()).copyWith(color: textPrimary);

    final textTheme = base.textTheme.copyWith(
      displayLarge: withColor(base.textTheme.displayLarge),
      displayMedium: withColor(base.textTheme.displayMedium),
      displaySmall: withColor(base.textTheme.displaySmall),
      headlineLarge: withColor(base.textTheme.headlineLarge),
      headlineMedium: withColor(base.textTheme.headlineMedium),
      headlineSmall: withColor(base.textTheme.headlineSmall),
      titleLarge: withColor(base.textTheme.titleLarge),
      titleMedium: withColor(base.textTheme.titleMedium),
      titleSmall: withColor(base.textTheme.titleSmall),
      bodyLarge: withColor(base.textTheme.bodyLarge),
      bodyMedium: withColor(base.textTheme.bodyMedium),
      bodySmall: withColor(base.textTheme.bodySmall).copyWith(color: textMuted),
      labelLarge: withColor(base.textTheme.labelLarge),
      labelMedium: withColor(base.textTheme.labelMedium),
      labelSmall: withColor(base.textTheme.labelSmall).copyWith(color: textMuted),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: border),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 24,
        ),
      ),
      listTileTheme: ListTileThemeData(
        // Transparent so parent cards own the fill (avoids invisible splash warnings).
        tileColor: Colors.transparent,
        iconColor: primary,
        textColor: textPrimary,
        selectedColor: textPrimary,
        selectedTileColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withValues(alpha: 0.25),
        selectionHandleColor: primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.brightness == Brightness.dark
              ? const Color(0xFF003822)
              : AppColors.onPrimary,
          disabledBackgroundColor: primary.withValues(alpha: 0.45),
          disabledForegroundColor: scheme.brightness == Brightness.dark
              ? const Color(0xFF003822).withValues(alpha: 0.7)
              : AppColors.onPrimary.withValues(alpha: 0.8),
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF244338)
            : const Color(0xFFE8F5EF),
        disabledColor: border,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        labelStyle: textTheme.bodyMedium!.copyWith(color: textPrimary),
        secondaryLabelStyle: textTheme.bodyMedium!.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        brightness: scheme.brightness,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF24302B)
            : const Color(0xFF1A1F1C),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.45);
          }
          return border;
        }),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      iconTheme: IconThemeData(color: textPrimary),
      primaryIconTheme: IconThemeData(color: primary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
