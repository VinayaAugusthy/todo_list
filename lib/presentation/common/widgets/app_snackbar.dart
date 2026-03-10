import 'package:flutter/material.dart';

import 'package:todo_list/core/constants/app_colors.dart';

abstract final class AppSnackBar {
  AppSnackBar._();

  static SnackBar success(String message) => SnackBar(
    content: Text(message),
    backgroundColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static SnackBar error(String message) => SnackBar(
    content: Text(message),
    backgroundColor: Colors.red.shade800,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
