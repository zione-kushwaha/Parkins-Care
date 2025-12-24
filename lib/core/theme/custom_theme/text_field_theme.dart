import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';


class CTextFeildTheme {
  CTextFeildTheme._();

  // ✅ LIGHT THEME
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: TextStyle(
      fontSize: 14,
      color: AppColors.textPrimary.withValues(alpha: .8),
    ),
    border: _borderStyle(color: Colors.grey),
    enabledBorder: _borderStyle(color: Colors.grey),
    focusedBorder: _borderStyle(color: AppColors.primaryBlue),
    errorBorder: _borderStyle(color: AppColors.darkBlue),
    focusedErrorBorder: _borderStyle(color: AppColors.textPrimary.withValues(alpha: .8)),
  );

  // ✅ DARK THEME
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: Colors.white,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: Colors.white,
    ),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: TextStyle(
      fontSize: 14,
      color: Colors.white.withValues(alpha: .8),
    ),
    border: _borderStyle(color: Colors.grey),
    enabledBorder: _borderStyle(color: Colors.grey),
    focusedBorder: _borderStyle(color: AppColors.primaryBlue),
    errorBorder: _borderStyle(color: AppColors.primaryBlue),
    focusedErrorBorder: _borderStyle(color: Colors.black),
  );

  // ✅ Private helper to reduce repetition
  static OutlineInputBorder _borderStyle({required Color color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color: color),
    );
  }
}
