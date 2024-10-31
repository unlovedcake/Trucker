import 'package:flutter/material.dart';
import 'package:trucker/themes/dark_mode.dart';
import 'package:trucker/themes/light_mode.dart';

/*
THEME PROVIDER

This helps us change the app from dark mode and light mode

 */

class ThemeProvider with ChangeNotifier {
  // initially, set it as light mode
  ThemeData _themeData = lightMode;

  // get the current theme
  ThemeData get themeData => _themeData;

  // is it dark mode currently?
  bool get isDarkMode => _themeData == darkMode;

  // set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    // update UI
    notifyListeners();
  }

  // toggle between dark and lightmode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
