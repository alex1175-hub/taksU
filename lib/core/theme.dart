import 'package:flutter/material.dart';

/// Material Design 3 con un solo color de acento: índigo.
class AppTheme {
  static const Color indigo = Color(0xFF3F51B5);

  static ThemeData claro() => _construir(Brightness.light);
  static ThemeData oscuro() => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(seedColor: indigo, brightness: brillo);
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
