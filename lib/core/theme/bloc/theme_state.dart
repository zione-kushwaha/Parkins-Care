
import 'package:flutter/material.dart';

sealed class ThemeState {
  const ThemeState();
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeData themeData;
  final bool isDarkMode;

  const ThemeLoaded({required this.themeData, required this.isDarkMode});

  ThemeLoaded copyWith({ThemeData? themeData, bool? isDarkMode}) {
    return ThemeLoaded(
      themeData: themeData ?? this.themeData,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
