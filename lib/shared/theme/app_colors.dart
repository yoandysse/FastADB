import 'package:flutter/material.dart';

// ── Static dark palette constants (used by AppTheme registration) ─────────────

abstract class AppColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceHighlight = Color(0xFF21262D);

  static const Color accent = Color(0xFF2DA44E);
  static const Color primaryBlue = Color(0xFF1F6FEB);

  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF848D97);
  static const Color textDisabled = Color(0xFF484F58);

  static const Color statusConnected = Color(0xFF3FB950);
  static const Color statusReconnecting = Color(0xFFD29922);
  static const Color statusOffline = Color(0xFF6E7681);
  static const Color statusError = Color(0xFFDA3633);

  static const Color borderColor = Color(0xFF21262D);
  static const Color divider = Color(0xFF21262D);
  static const Color navActive = Color(0xFF1C2128);
}

// ── Static light palette constants ────────────────────────────────────────────

abstract class AppColorsLight {
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHighlight = Color(0xFFEEF1F4);

  static const Color accent = Color(0xFF2DA44E);
  static const Color primaryBlue = Color(0xFF0969DA);

  static const Color textPrimary = Color(0xFF24292F);
  static const Color textSecondary = Color(0xFF57606A);
  static const Color textDisabled = Color(0xFF8C959F);

  static const Color statusConnected = Color(0xFF1A7F37);
  static const Color statusReconnecting = Color(0xFF9A6700);
  static const Color statusOffline = Color(0xFF6E7781);
  static const Color statusError = Color(0xFFD1242F);

  static const Color borderColor = Color(0xFFD0D7DE);
  static const Color divider = Color(0xFFD8DEE4);
  static const Color navActive = Color(0xFFEEF1F4);
}

// ── ThemeExtension: context-aware palette ─────────────────────────────────────

class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceHighlight;
  final Color accent;
  final Color primaryBlue;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color statusConnected;
  final Color statusReconnecting;
  final Color statusOffline;
  final Color statusError;
  final Color borderColor;
  final Color divider;
  final Color navActive;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.accent,
    required this.primaryBlue,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.statusConnected,
    required this.statusReconnecting,
    required this.statusOffline,
    required this.statusError,
    required this.borderColor,
    required this.divider,
    required this.navActive,
  });

  static const dark = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceHighlight: AppColors.surfaceHighlight,
    accent: AppColors.accent,
    primaryBlue: AppColors.primaryBlue,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textDisabled: AppColors.textDisabled,
    statusConnected: AppColors.statusConnected,
    statusReconnecting: AppColors.statusReconnecting,
    statusOffline: AppColors.statusOffline,
    statusError: AppColors.statusError,
    borderColor: AppColors.borderColor,
    divider: AppColors.divider,
    navActive: AppColors.navActive,
  );

  static const light = AppPalette(
    background: AppColorsLight.background,
    surface: AppColorsLight.surface,
    surfaceHighlight: AppColorsLight.surfaceHighlight,
    accent: AppColorsLight.accent,
    primaryBlue: AppColorsLight.primaryBlue,
    textPrimary: AppColorsLight.textPrimary,
    textSecondary: AppColorsLight.textSecondary,
    textDisabled: AppColorsLight.textDisabled,
    statusConnected: AppColorsLight.statusConnected,
    statusReconnecting: AppColorsLight.statusReconnecting,
    statusOffline: AppColorsLight.statusOffline,
    statusError: AppColorsLight.statusError,
    borderColor: AppColorsLight.borderColor,
    divider: AppColorsLight.divider,
    navActive: AppColorsLight.navActive,
  );

  /// Shorthand: `AppPalette.of(context).background`
  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? dark;

  @override
  AppPalette copyWith({
    Color? background, Color? surface, Color? surfaceHighlight,
    Color? accent, Color? primaryBlue,
    Color? textPrimary, Color? textSecondary, Color? textDisabled,
    Color? statusConnected, Color? statusReconnecting,
    Color? statusOffline, Color? statusError,
    Color? borderColor, Color? divider, Color? navActive,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      accent: accent ?? this.accent,
      primaryBlue: primaryBlue ?? this.primaryBlue,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      statusConnected: statusConnected ?? this.statusConnected,
      statusReconnecting: statusReconnecting ?? this.statusReconnecting,
      statusOffline: statusOffline ?? this.statusOffline,
      statusError: statusError ?? this.statusError,
      borderColor: borderColor ?? this.borderColor,
      divider: divider ?? this.divider,
      navActive: navActive ?? this.navActive,
    );
  }

  @override
  AppPalette lerp(AppPalette other, double t) {
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHighlight: Color.lerp(surfaceHighlight, other.surfaceHighlight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      primaryBlue: Color.lerp(primaryBlue, other.primaryBlue, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      statusConnected: Color.lerp(statusConnected, other.statusConnected, t)!,
      statusReconnecting: Color.lerp(statusReconnecting, other.statusReconnecting, t)!,
      statusOffline: Color.lerp(statusOffline, other.statusOffline, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
    );
  }
}
