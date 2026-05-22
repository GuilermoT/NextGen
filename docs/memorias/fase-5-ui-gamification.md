# Fase 5 — UI Gamification

**Rama:** `feature/ui-gamification-flutter`
**Fecha de cierre:** 22/05/2026
**Autor:** GuilermoT

## Qué se implementó

### RankingScreen (`lib/features/gamification/presentation/screens/ranking_screen.dart`)

Pantalla nueva de clasificación completa. `StatefulWidget` con selector de jornada y lista animada de equipos.

| Elemento | Detalle |
|----------|---------|
| `_selectedJornada` | `int`, inicializado en `32`; actualizado con `setState` en `_prevJornada` / `_nextJornada` |
| `_standings` | `static final Map<int, List<Map<String, dynamic>>>` con datos mock para jornadas 30, 31 y 32 (8 equipos cada una) |
| `_trend(String teamName)` | Compara posición del equipo en `_selectedJornada` vs jornada anterior; retorna `int` positivo (subió), negativo (bajó) o `0` (sin datos previos) |
| `_prevJornada / _nextJornada` | Navegan por `_jornadas = [30, 31, 32]`; la UI deshabilita el botón cuando se está en el extremo |
| Selector de jornada | `Row` centrado con `IconButton(Icons.chevron_left)` + `Text` + `IconButton(Icons.chevron_right)`; los botones de extremo se deshabilitan (`onPressed: null`) con color `AppColors.textDisabled` |
| Lista | `SingleChildScrollView > Column(key: ValueKey(_selectedJornada), ...)` con un `_buildRow` por equipo |
| `_buildRow` | Construye `RankingRow` + envuelve con `ColoredBox(color: AppColors.primaryGreen.withValues(alpha: 0.08))` si es el equipo propio + aplica `.animate().fadeIn().slideX(begin: 0.1)` con delay incremental de 40 ms por fila |

Equipos mock y evolución de posiciones entre jornadas:

| Equipo | J30 | J31 | J32 |
|--------|-----|-----|-----|
| Los Galácticos FC | 1 | 1 | 1 |
| Equipo Naranjito | 2 | 3 | 2 |
| Cracks del Bernabéu | 3 | 4 | 4 |
| Mi Equipo FC | 4 | 2 | 3 |
| Vikingos del Sur | 5 | 6 | 7 |
| Diablos Rojos FC | 6 | 5 | 5 |
| La Armada Azul | 7 | 7 | 6 |
| Furia Española | 8 | 8 | 8 |

### GamificationHubScreen (`lib/features/gamification/presentation/screens/gamification_hub_screen.dart`)

Se añade un `TextButton` con `foregroundColor: AppColors.primaryGreen` entre `PodiumWidget` y `LastPlaceBanner`:

```dart
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () => context.push('/home/gamification/ranking'),
    style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
    child: const Text('Ver clasificación completa →'),
  ),
),
```

No se modificó ningún otro elemento de este archivo.

### AppRouter (`lib/app/router/app_router.dart`)

Ruta nueva dentro del `ShellRoute` (después de `/home/gamification/sobre`):

```dart
GoRoute(
  path: '/home/gamification/ranking',
  builder: (context, state) => const RankingScreen(),
),
```

Import añadido: `ranking_screen.dart`. La ruta se accede con `context.push()` para preservar el stack y permitir `context.pop()` de vuelta al hub.

## Decisiones técnicas

### StatefulWidget para el selector de jornada

El selector modifica `_selectedJornada` en respuesta a pulsaciones del usuario, lo que requiere llamar a `setState`. Un `StatelessWidget` no puede mantener ese estado mutable entre eventos. Se descartó Riverpod para este estado porque es puramente local a la pantalla y no necesita persistirse ni compartirse con otros widgets.

### ValueKey en Column para reanimar la lista al cambiar jornada

`flutter_animate` ejecuta su secuencia de animación una sola vez por ciclo de vida del widget. Para que las animaciones de entrada (fadeIn + slideX) se reproduzcan de nuevo al cambiar de jornada, se asigna `key: ValueKey(_selectedJornada)` al `Column` que contiene las filas. Cuando `_selectedJornada` cambia y `setState` se llama, Flutter detecta una clave diferente, destruye el `Column` anterior y crea uno nuevo, disparando todas las animaciones desde cero. Se descartó usar un `AnimationController` manual porque requeriría convertir el widget a `TickerProviderStateMixin` y gestionar los controllers explícitamente; `ValueKey` consigue el mismo efecto con cero boilerplate.

### Resaltado del equipo propio con ColoredBox

Se usa `ColoredBox` en lugar de `Container(color: ...)` para el resaltado de "Mi Equipo FC" porque `ColoredBox` solo pinta un color plano sin caja de decoración, lo que es más eficiente. `RankingRow` tiene su propio `Container` con `BoxDecoration(border: ...)` pero sin color de fondo, por lo que el `ColoredBox` padre es visible a través de él. Para posición 1, el shimmer de `flutter_animate` (heredado de la Fase 3) se aplica sobre el `RankingRow` ya envuelto y los dos efectos conviven sin conflicto porque el shimmer es una capa de gradiente sobre el widget ya renderizado.

## Archivos modificados

- `lib/features/gamification/presentation/screens/ranking_screen.dart` — nuevo
- `lib/features/gamification/presentation/screens/gamification_hub_screen.dart` — modificado (TextButton añadido)
- `lib/app/router/app_router.dart` — modificado (import + ruta `/home/gamification/ranking`)

## Commits de esta fase

- `feat(gamification): add ranking_screen with jornada selector and animated list`
- `docs(memorias): add fase-5-ui-gamification memory`
