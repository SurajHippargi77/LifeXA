import 'package:flutter/material.dart';

// ── Dark palette ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF0B1020);
  static const backgroundAlt = Color(0xFF111936);
  static const accent = Color(0xFF7C3AED);
  static const blue = Color(0xFF2563EB);
  static const cyan = Color(0xFF22D3EE);
  static const lavender = Color(0xFFA78BFA);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF64748B);
  static const cardBg = Color(0xFF111936);
  static const border = Color(0xFF24304F);
  static const error = Color(0xFFFC8181);
}

// ── Light palette ─────────────────────────────────────────────────────────────
class AppColorsLight {
  static const background = Color(0xFFF0F4FF);
  static const backgroundAlt = Color(0xFFE8EEFF);
  static const accent = Color(0xFF7C3AED);
  static const blue = Color(0xFF2563EB);
  static const cyan = Color(0xFF0891B2);
  static const lavender = Color(0xFF7C3AED);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const muted = Color(0xFF94A3B8);
  static const cardBg = Color(0xFFFFFFFF);
  static const border = Color(0xFFCBD5E1);
  static const error = Color(0xFFDC2626);
}

// ── Gradients ─────────────────────────────────────────────────────────────────
class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.accent, AppColors.blue, AppColors.cyan],
  );

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.background, AppColors.backgroundAlt, AppColors.background],
  );
}

// ── Radius / Spacing ──────────────────────────────────────────────────────────
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const card = 20.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

// ── ThemeData ─────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          primary: AppColors.accent,
          secondary: AppColors.cyan,
          surface: AppColors.cardBg,
        ),
        cardColor: AppColors.cardBg,
        dividerColor: AppColors.border,
        useMaterial3: true,
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColorsLight.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColorsLight.accent,
          brightness: Brightness.light,
          primary: AppColorsLight.accent,
          secondary: AppColorsLight.cyan,
          surface: AppColorsLight.cardBg,
        ),
        cardColor: AppColorsLight.cardBg,
        dividerColor: AppColorsLight.border,
        useMaterial3: true,
      );
}

// ── Theme helpers ─────────────────────────────────────────────────────────────
// Use these in widgets to get the right color for the current theme mode.
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bgColor =>
      isDark ? AppColors.background : AppColorsLight.background;
  Color get bgAlt =>
      isDark ? AppColors.backgroundAlt : AppColorsLight.backgroundAlt;
  Color get cardColor =>
      isDark ? AppColors.cardBg : AppColorsLight.cardBg;
  Color get borderColor =>
      isDark ? AppColors.border : AppColorsLight.border;
  Color get textPrimary =>
      isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get mutedColor =>
      isDark ? AppColors.muted : AppColorsLight.muted;
  Color get accentColor => AppColors.accent;
  Color get errorColor =>
      isDark ? AppColors.error : AppColorsLight.error;
}
