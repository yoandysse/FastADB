import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary colors
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color accent = Color(0xFF00D084);

  // Text colors
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textDisabled = Color(0xFF484F58);

  // Status colors
  static const Color statusConnected = Color(0xFF3FB950);
  static const Color statusReconnecting = Color(0xFFD29922);
  static const Color statusOffline = Color(0xFFDA3633);
  static const Color statusError = Color(0xFFF85149);

  // Borders
  static const Color borderColor = Color(0xFF30363D);

  // Interactive
  static const Color hoverLight = Color(0xFF1C2128);
  static const Color activeLight = Color(0xFF0D1117);
}
