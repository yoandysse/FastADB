import 'package:flutter/material.dart';
import 'app_colors.dart';

// Removes all page transition animations on every platform.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

const _noTransitionsTheme = PageTransitionsTheme(builders: {
  TargetPlatform.macOS: _NoTransitionsBuilder(),
  TargetPlatform.windows: _NoTransitionsBuilder(),
  TargetPlatform.linux: _NoTransitionsBuilder(),
  TargetPlatform.android: _NoTransitionsBuilder(),
  TargetPlatform.iOS: _NoTransitionsBuilder(),
});

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: _noTransitionsTheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: const [AppPalette.dark],
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.statusError,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.borderColor)),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.borderColor,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: _noTransitionsTheme,
      scaffoldBackgroundColor: AppColorsLight.background,
      extensions: const [AppPalette.light],
      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.accent,
        secondary: AppColorsLight.accent,
        surface: AppColorsLight.surface,
        error: AppColorsLight.statusError,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColorsLight.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColorsLight.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColorsLight.primaryBlue, width: 2)),
        labelStyle: const TextStyle(color: AppColorsLight.textSecondary),
        hintStyle: const TextStyle(color: AppColorsLight.textDisabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColorsLight.surface,
        surfaceTintColor: AppColorsLight.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColorsLight.borderColor)),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColorsLight.borderColor,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsLight.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColorsLight.surface,
        contentTextStyle: TextStyle(color: AppColorsLight.textPrimary),
      ),
    );
  }
}
