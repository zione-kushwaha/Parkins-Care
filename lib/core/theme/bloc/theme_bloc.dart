import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = "theme_mode";

  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeToggled>(_onThemeToggled);

    // Initialize theme on startup
    add(ThemeInitialized());
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;

      emit(
        ThemeLoaded(
          themeData: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          isDarkMode: isDarkMode,
        ),
      );
    } catch (e) {
      // Default to light theme if there's an error
      emit(ThemeLoaded(themeData: AppTheme.lightTheme, isDarkMode: false));
    }
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      final newIsDarkMode = !currentState.isDarkMode;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themeKey, newIsDarkMode);

        emit(
          ThemeLoaded(
            themeData: newIsDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            isDarkMode: newIsDarkMode,
          ),
        );
      } catch (e) {
        // If saving fails, still toggle the theme for this session
        emit(
          ThemeLoaded(
            themeData: newIsDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            isDarkMode: newIsDarkMode,
          ),
        );
      }
    }
  }
}
