import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1C1C1E);
  static const Color primaryDark = Color(0xFF0A0A0B);
  static const Color primaryLight = Color(0xFFE8E8EA);
  static const Color accent = Color(0xFF3A3A3C);

  static const Color background = Color(0xFFF5F5F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color border = Color(0xFFE5E5EA);
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2C2C2E), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF636366), Color(0xFF1C1C1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> appointmentPalette = [
    Color(0xFF2C3E50),
    Color(0xFF854442),
    Color(0xFF4A4E69),
    Color(0xFF6B705C),
    Color(0xFF22333B),
    Color(0xFF5C5346),
  ];
}
