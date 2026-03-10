import 'package:flutter/material.dart';

/// Centralized app color constants.
abstract final class AppColors {
  AppColors._();

  // Primary / accent
  static const Color primary = Colors.red;
  static const Color primaryLight = Color(0xFFFFCDD2); // red.shade100
  static const Color primaryDark = Color(0xFFE57373); // red.shade300

  // Button
  static const Color buttonActive = primary;
  static const Color buttonDisabled = primaryLight;
  static const Color white = Colors.white;
  static const Color loadingIndicator = primaryDark;

  // Link / emphasis text
  static const Color link = primary;
}
