// Constantes globales derivadas directamente del documento de especificaciones.
// No modificar estos valores sin revisar el documento de requisitos primero.

class AppConstants {
  AppConstants._();

  // Temporada activa
  static const String currentSeason = '2025-2026';

  // Economía del juego
  // Fuente: sección 4.1 del documento de requisitos — tasa semanal del 1%
  static const double weeklyClauseTaxRate = 0.01;

  // Fuente: sección 3.3 — penalización del 20% por alineación incompleta
  static const double incompleteLineupPenaltyRate = 0.20;

  // Fuente: sección 4.2 — umbral del 30% para activar estado de hipoteca
  static const double bankruptcyThreshold = 0.30;

  // Fuente: sección 4.1 — saldo inicial de cada equipo (100 millones)
  static const double initialTeamBalance = 100000000;

  // Fuente: sección 3.2 — once inicial más banquillo
  static const int maxStartersCount = 11;
  static const int maxBenchCount = 7;
}
