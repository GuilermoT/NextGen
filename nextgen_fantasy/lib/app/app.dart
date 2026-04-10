// Widget raíz de la aplicación NextGen Fantasy.
//
// Estado actual: scaffold mínimo funcional.
//
// Pendiente en fases futuras:
// - Fase 0.D: integración con go_router para navegación declarativa
// - Fase 0.E: envuelto en ProviderScope para gestión de estado con Riverpod
// - Fase 3.1: AppTheme completo con paleta definitiva (Dev 3)

import 'package:flutter/material.dart';
import 'package:nextgen_fantasy/core/theme/app_theme.dart';

class NextGenFantasyApp extends StatelessWidget {
  const NextGenFantasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextGen Fantasy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        body: Center(
          child: Text(
            'NextGen Fantasy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
