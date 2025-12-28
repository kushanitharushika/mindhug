import 'package:flutter/material.dart';

class ThemeManager {
  // Singleton
  static final ThemeManager instance = ThemeManager._internal();
  factory ThemeManager() => instance;
  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  void toggleTheme(bool isDark) {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
