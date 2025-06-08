import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  primaryColor: const Color(0xFF5D9CEC),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF5D9CEC),
    secondary: Color(0xFF6889DA),
    surface: Color(0xFF222222),
    background: Color(0xFF121212),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 20, color: Color(0xFFCCCCCC)),
    bodyMedium: TextStyle(fontSize: 18, color: Color(0xFFCCCCCC)),
  ),
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    margin: EdgeInsets.symmetric(vertical: 8),
    color: Color(0xFF222222),
  ),

);