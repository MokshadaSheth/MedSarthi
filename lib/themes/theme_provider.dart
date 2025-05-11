// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
