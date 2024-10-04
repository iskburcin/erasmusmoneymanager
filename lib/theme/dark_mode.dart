import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.black87,
    primary: Colors.black12, 
    secondary: Colors.black54, 
    
    inversePrimary: Colors.grey.shade500
    ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[300],
    displayColor: Colors.white
  )
);