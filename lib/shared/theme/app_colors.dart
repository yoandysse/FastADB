import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary backgrounds
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceHighlight = Color(0xFF21262D);

  // Accent / Brand
  static const Color accent = Color(0xFF00D084);
  static const Color primaryBlue = Color(0xFF1F6FEB);

  // Text
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF848D97);
  static const Color textDisabled = Color(0xFF484F58);

  // Status
  static const Color statusConnected = Color(0xFF3FB950);
  static const Color statusReconnecting = Color(0xFFD29922);
  static const Color statusOffline = Color(0xFF6E7681);
  static const Color statusError = Color(0xFFDA3633);

  // Borders / Dividers
  static const Color borderColor = Color(0xFF21262D);
  static const Color divider = Color(0xFF21262D);

  // Nav item active bg
  static const Color navActive = Color(0xFF1C2128);
}
