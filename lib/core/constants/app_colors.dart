import 'package:flutter/material.dart';

/// Parkinson Care App Colors - Blue Theme
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryBlue = Color(0xFF6C63FF);
  static const Color lightBlue = Color(0xFFE8E6FF);
  static const Color darkBlue = Color(0xFF5449CC);
  static const Color accentWhite = Color(0xFFF7F8FF);

  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color textOnPrimary = Colors.white;

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Border Colors
  static const Color border = Color(0xFFDEE2E6);
  static const Color divider = Color(0xFFE9ECEF);

  // SOS Emergency
  static const Color emergencyRed = Color(0xFFFF3B30);
  static const Color emergencyOrange = Color(0xFFFF9500);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF8B84FF),
    Color(0xFFA9A4FF),
    Color(0xFFC7C4FF),
    Color(0xFFE8E6FF),
  ];

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF5449CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [lightBlue, accentWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
