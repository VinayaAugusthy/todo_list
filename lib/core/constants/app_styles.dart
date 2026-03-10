import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized text style constants using app colors.
abstract final class AppStyles {
  AppStyles._();

  static const double titleFontSize = 28;
  static const double linkFontSize = 15;

  static const TextStyle authTitle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle linkText = TextStyle(
    color: AppColors.link,
    fontWeight: FontWeight.bold,
    fontSize: linkFontSize,
  );

  static const TextStyle buttonText = TextStyle(color: AppColors.white);
}
