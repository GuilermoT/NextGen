# Fase 3 — UI Gamification

**Rama:** `feature/ui-gamification-flutter`
**Fecha de cierre:** 2026-05-08
**Autor:** GuilermoT

## Qué se implementó

### PlayerCard (`lib/shared/widgets/player_card.dart`)
El emoji 👑 del capitán pasa de ser un `Text` estático a uno animado con pulso
en loop usando `flutter_animate`:
`.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.85, end: 1.15, duration: 900.ms, curve: Curves.easeInOut)`
El mismo patrón de pulso que ya usaba el `?` en `SobreTacticaScreen`.

### RankingRow (`lib/shared/widgets/ranking_row.dart`)
Cuando `position == 1`, el row completo recibe un shimmer dorado en loop:
`.animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: AppColors.accentGold.withValues(alpha: 0.3))`
Para posiciones 2+ el comportamiento es idéntico al de la Fase 2.

### SobreTacticaScreen (`lib/features/gamification/presentation/screens/sobre_tactica_screen.dart`)
El bonus del reverso de la carta deja de estar hardcodeado. Cambios:
- Se añade la clase privada de fichero `_TacticBonus` con campos `titulo` y `descripcion`.
- Se declara `static const _bonuses` con 5 bonuses posibles en el estado del widget.
- En `initState` se selecciona uno aleatoriamente con `dart:math`:
  `_selectedBonus = _bonuses[math.Random().nextInt(_bonuses.length)];`
- `_buildCardBack` usa `_selectedBonus.titulo` (emoji + etiqueta del badge)
  y `_selectedBonus.descripcion` (texto descriptivo). La animación de flip 3D
  no se tocó.

Bonuses disponibles:
| Emoji | Título | Descripción |
|-------|--------|-------------|
| ⚡ | Doble puntuación | para delanteros esta jornada |
| 🛡️ | Escudo defensivo | defensas suman +3 por portería a cero |
| 🎯 | Penalti de oro | bonus x2 por cada penalti transformado |
| 🌟 | Capitán legendario | el capitán triplica sus puntos esta jornada |
| 🔥 | Racha imparable | jugadores con racha suman +5 extra |

## Decisiones técnicas

### flutter_animate en StatelessWidget
`PlayerCard` y `RankingRow` son `StatelessWidget`. `flutter_animate` gestiona
su propio ticker interno por lo que `.animate()` funciona sin necesidad de
convertir los widgets a `StatefulWidget`. Patrón ya validado en `_CardFront`
(también `StatelessWidget`) desde la Fase 2.

### Shimmer condicional en RankingRow
En lugar de añadir un parámetro `isLeader` o extraer un subwidget, se optó
por computar `final row = Container(...)` y devolver `row` sin decorar para
posiciones > 1, o decorado con shimmer para posición 1. Cero boilerplate extra.

### Clase _TacticBonus como privada de fichero
Se declaró como `_TacticBonus` (prefijo `_`) para mantenerla encapsulada en el
fichero de la pantalla. No necesita exportarse porque ningún otro widget la usa.
El constructor `const` permite la lista `static const _bonuses`, evitando
allocations en cada rebuild.

### dart:math ya importado
El fichero ya tenía `import 'dart:math' as math;` desde la Fase 2 (para el
flip 3D con `math.pi`). La inicialización del bonus usa `math.Random()` sin
necesidad de ningún import adicional.

## Archivos modificados
- `lib/shared/widgets/player_card.dart` — animación de pulso en corona del capitán
- `lib/shared/widgets/ranking_row.dart` — shimmer dorado condicional para posición 1
- `lib/features/gamification/presentation/screens/sobre_tactica_screen.dart` — bonus aleatorio

## Commits de esta fase
- `feat(widgets): animate captain crown in player_card`
- `feat(widgets): add gold shimmer to rank 1 in ranking_row`
- `feat(gamification): randomize bonus in sobre_tactica_screen`
- `docs(memorias): add fase-3-ui-gamification memory`
