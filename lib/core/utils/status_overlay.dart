import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/constants/app_colors.dart';

class StatusOverlay {
  // Wrap any widget with a dynamic status bar style
  static Widget statusBarOverlay({
    required BuildContext context,
    required Widget child,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDarkTheme ? Colors.black : AppColors.primaryBlue,
        statusBarIconBrightness:
            Brightness.light, // Icons remain light in both modes
        statusBarBrightness:
            Brightness.dark, // iOS compatibility - dark content on light bg
      ),
      child: child,
    );
  }
}
