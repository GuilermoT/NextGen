import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color backgroundDark = Color(0xFF0A0A0F); // fondo principal de la app
  static const Color surfaceDark = Color(0xFF141420); // superficie de sheets/nav bar
  static const Color cardDark = Color(0xFF1E1E2E); // fondo de cards de jugador/equipo
  static const Color primaryGreen = Color(0xFF00C853); // color de marca primario, botones CTA
  static const Color primaryGreenDark = Color(0xFF00873A); // variante oscura del verde primario
  static const Color accentGold = Color(0xFFFFD700); // capitán y bonus especiales
  static const Color dangerRed = Color(0xFFFF3B30); // deuda y penalizaciones
  static const Color warningAmber = Color(0xFFFF9500); // advertencias y alertas
  static const Color successGreen = Color(0xFF34C759); // operaciones exitosas
  static const Color textPrimary = Color(0xFFFFFFFF); // texto principal sobre fondos oscuros
  static const Color textSecondary = Color(0xFF8E8EA0); // texto secundario y subtítulos
  static const Color textDisabled = Color(0xFF48484A); // texto deshabilitado e inactivo
  static const Color borderColor = Color(0xFF2C2C3E); // bordes de cards y separadores
  static const Color goalColor = Color(0xFF00C853); // goles en scorecard de jugador
  static const Color assistColor = Color(0xFF007AFF); // asistencias en scorecard de jugador
  static const Color cardColor = Color(0xFF1E1E2E); // alias de cardDark para widgets legacy
}
