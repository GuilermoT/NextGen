// Widget raíz de la aplicación NextGen Fantasy.
//
// Estado actual: MaterialApp.router conectado a go_router.
//
// Pendiente en fases futuras:
// - Fase 0.E: envuelto en ProviderScope para gestión de estado con Riverpod
// - Fase 3.1: AppTheme completo con paleta y tipografía definitivas (Dev 3)
// - Fase 3.2: rutas reales añadidas al router (Dev 3)

import 'package:flutter/material.dart';
import 'package:nextgen_fantasy/app/router/app_router.dart';
import 'package:nextgen_fantasy/core/theme/app_theme.dart';

class NextGenFantasyApp extends StatelessWidget {
  const NextGenFantasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NextGen Fantasy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
