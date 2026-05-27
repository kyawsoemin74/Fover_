import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF090B12),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1DB954),
    onPrimary: Colors.black,
    secondary: Color(0xFF4D90FE),
    surface: Color(0xFF090B12),
    onSurface: Colors.white,
    onSurfaceVariant: Color(0xFF9CA3AF),
    surfaceContainerHighest: Color(0xFF141C2E),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF111827),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 0,
  ),
  textTheme: Typography.whiteMountainView.copyWith(
    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
    titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(fontSize: 13),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);
