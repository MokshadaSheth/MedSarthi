import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primaryColor: const Color(0xFF4A6FA5),  // Softer blue from image 3
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF4A6FA5),
    secondary: Color(0xFF87A9E5),  // Earthy green from image
    surface: Colors.white,
    background: Color(0xFFC5EBF4),  // Very light grey
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF4A6FA5)),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 20, color: Color(0xFF555555)),
    bodyMedium: TextStyle(fontSize: 18, color: Color(0xFF555555)),
  ),
  cardTheme: CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4A6FA5),
    foregroundColor: Colors.white,
  ),
);