import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  ThemeData _currentTheme = lightTheme;

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    _currentTheme = isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepPurple,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple,
);
