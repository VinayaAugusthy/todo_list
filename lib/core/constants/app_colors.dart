import 'package:flutter/material.dart';

/// Centralized app color constants.
abstract final class AppColors {
  AppColors._();

  // Primary / accent
  static const Color primary = Colors.red;
  static const Color primaryLight = Color(0xFFFFCDD2); // red.shade100
  static const Color primaryDark = Color(0xFFE57373); // red.shade300
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF4CAF50);
  static const Color amber = Color(0xFFFFC107);
}
