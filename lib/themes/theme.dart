import 'package:flutter/material.dart';

ThemeData themeData() {
  final colorScheme = ColorScheme.light(
    surface: const Color(0xFFafc082),
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  );
  return ThemeData(
    colorScheme: colorScheme,
  );
}