# Fase 2 — UI Gamification

**Rama:** `feature/ui-gamification-flutter`
**Fecha de cierre:** 2026-04-24
**Autor:** GuilermoT

## Qué se implementó

### Shared widgets (`lib/shared/widgets/`)
- `PlayerCard`: card de jugador con badge de posición con color semántico
  (POR=amarillo, DEF=azul, MED=verde, DEL=rojo), corona dorada para capitán,
  soporte de skeleton loader con `skeletonizer` e imagen con `cached_network_image`.
- `PointsBadge`: pill verde semitransparente para mostrar puntos de jornada.
- `RankingRow`: fila de clasificación con flechas de tendencia animadas y
  colores dorado/plata/bronce para posiciones 1-3.

### HomeScreen (`lib/features/home/presentation/screens/`)
Dashboard completo con: saludo + puntos de jornada, countdown a jornada 32,
scroll horizontal de PlayerCards con datos mock, tabla de clasificación con
RankingRows, botón de acceso a gamificación. Animaciones de entrada escalonadas
con `flutter_animate` (fadeIn + slideY/slideX).

### LoginScreen
Mejoras visuales: dos círculos decorativos con `AppColors.primaryGreen` al 7%
de opacidad para dar profundidad, logo G de Google renderizado con `ShaderMask`
más `SweepGradient` en los 4 colores corporativos (sin assets externos),
botón "Continuar como invitado" desactivado, cadena de animaciones escalonada
con 80ms de delay entre elementos.

### SplashScreen
Barra de progreso con `TweenAnimationBuilder` que se rellena en 1800ms,
animaciones de texto escalonadas: NEXTGEN (0ms) → FANTASY (200ms) →
LaLiga Edition (400ms) → barra (600ms).

### Gamification feature (`lib/features/gamification/presentation/`)
- `GamificationHubScreen`: pantalla hub con card de sobre de táctica y
  card de liga con podio y banner de colista.
- `SobreTacticaScreen`: animación de flip 3D con `AnimatedBuilder` más
  `Matrix4.rotationY` (600ms), estado inicial con pulso en loop, reveal
  de bonus tras el flip.
- `PodiumWidget`: podio clásico (2-1-3) con animaciones slideY
  escalonadas (0/150/300ms).
- `LastPlaceBanner`: banner rojo con animación de shake en loop.

### Router (`lib/app/router/`)
5º tab "Jugar" con `Icons.emoji_events`. Rutas añadidas:
`/home/gamification` y `/home/gamification/sobre`. Uso de `context.push()`
para la ruta del sobre para preservar el stack y permitir `context.pop()`.

## Decisiones técnicas

### Material 3 dark theme
Se eligió Material 3 (`useMaterial3: true`) por su sistema de `ColorScheme`
semántico que facilita mantener coherencia visual sin hardcodear colores.
El tema dark custom (`AppColors.backgroundDark = #0A0A0F`) da la estética
de app de fantasy premium similar a referencias como Sorare o Fotmob.

### flutter_animate vs alternativas
Se eligió `flutter_animate` (ya en pubspec) sobre `AnimationController` manual
por su API declarativa en cadena (`.fadeIn().slideY().animate()`), que reduce
el boilerplate significativamente en pantallas con múltiples elementos animados.
Para el flip de la carta se usó `AnimatedBuilder` más `Matrix4` directamente
porque `flutter_animate` no expone rotación en perspectiva 3D.

### skeletonizer
Se evaluó usar `skeletonizer` para todos los estados de carga pero se decidió
aplicarlo solo en `PlayerCard` (el widget con más densidad visual) porque
los demás widgets tienen suficiente espacio vacío que comunica el estado de
carga sin necesidad de skeleton explícito.

### Google logo sin assets
El logo G de Google se renderizó con `ShaderMask` más `SweepGradient` en lugar
de un asset SVG para evitar añadir archivos binarios a la rama de UI y no
depender de permisos de marca en producción. Solución 100% código Dart.

## Archivos creados / modificados
- `lib/shared/widgets/player_card.dart` — nuevo
- `lib/shared/widgets/points_badge.dart` — nuevo
- `lib/shared/widgets/ranking_row.dart` — nuevo
- `lib/features/home/presentation/screens/home_screen.dart` — modificado
- `lib/features/auth/presentation/screens/login_screen.dart` — modificado
- `lib/features/auth/presentation/screens/splash_screen.dart` — modificado
- `lib/features/gamification/presentation/screens/gamification_hub_screen.dart` — nuevo
- `lib/features/gamification/presentation/screens/sobre_tactica_screen.dart` — nuevo
- `lib/features/gamification/presentation/widgets/podium_widget.dart` — nuevo
- `lib/features/gamification/presentation/widgets/last_place_banner.dart` — nuevo
- `lib/app/router/app_router.dart` — modificado

## Commits de esta fase
- `75b356f` — feat(theme): material 3 dark theme system
- `931d81e` — feat(widgets): add shared player_card, points_badge, ranking_row
- `f76f551` — feat(home): replace placeholder with dashboard ui
- `f746219` — feat(auth): improve login screen visuals and animations
- `c01e7fd` — feat(auth): improve splash screen progress animation
- `9cd31c7` — feat(gamification): add hub, sobre tactica screens and podium widgets
