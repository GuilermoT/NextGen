// Sistema de diseño visual de NextGen Fantasy.
//
// Estado actual: tema provisional mínimo para que el proyecto compile.
//
// Pendiente en Fase 3.1 (Dev 3 — feature/ui-gamification-flutter):
// - Paleta de colores completa en modo oscuro y claro
// - Sistema tipográfico con TextTheme completo
// - Componentes de Material Design 3 personalizados

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF00C853);
  static const Color _backgroundDark = Color(0xFF0A0A0F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        surface: _backgroundDark,
      ),
    );
  }
}
