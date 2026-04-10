// Sistema de navegación declarativo de NextGen Fantasy.
//
// Usa go_router para gestionar rutas con soporte nativo de Deep Links.
// Los Deep Links son necesarios para las invitaciones a ligas privadas:
// cuando un manager comparte un enlace, la app debe abrirse directamente
// en la pantalla de unirse a esa liga específica.
//
// Estado actual: una sola ruta provisional (/).
//
// Pendiente en fases futuras:
// - Dev 3 (Fase 3.2): añadir rutas reales /splash /login /home /lineup /market /finance
// - Dev 2 (Fase 2.9): conectar el redirect guard al estado de autenticación de Supabase
//   para redirigir a /login si el usuario no tiene sesión activa

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          backgroundColor: Color(0xFF0A0A0F),
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
        );
      },
    ),
  ],
);
