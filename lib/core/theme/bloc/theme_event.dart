sealed class ThemeEvent {
  const ThemeEvent();
}

class ThemeToggled extends ThemeEvent {}

class ThemeInitialized extends ThemeEvent {}
