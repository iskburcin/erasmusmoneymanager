import 'package:flutter/material.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;
  set themeData(ThemeData theme){
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme(){
    themeData = (_themeData == lightMode) ? darkMode: lightMode;}
}