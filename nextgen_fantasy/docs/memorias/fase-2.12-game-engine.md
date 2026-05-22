# Fase 2.12 — LineupRepository con mock datasource y currentLineupProvider

**Desarrollador:** Marcos | **Fecha:** 21/05/2026 | **Rama:** feature/game-engine-flutter

## Qué se implementó

### Archivos nuevos

| Archivo | Responsabilidad |
|---|---|
| `lib/features/lineup/domain/models/lineup_entry_model.dart` | Modelo de un jugador en la alineación: titular/suplente y capitán |
| `lib/features/lineup/domain/models/lineup_model.dart` | Modelo de la alineación completa con getters computados |
| `lib/features/lineup/data/repositories/lineup_repository.dart` | Repositorio concreto con `fetchCurrentLineup` y `saveLineup` |
| `lib/features/lineup/presentation/providers/lineup_provider.dart` | Providers Riverpod: `lineupRepositoryProvider` y `currentLineupProvider` |
| `lib/features/lineup/presentation/providers/lineup_provider.g.dart` | Generado por `riverpod_generator` (no editar a mano) |

### Archivo modificado

`lib/features/home/presentation/screens/home_screen.dart` — conectado a `currentLineupProvider`; `isCaptain` en `PlayerCard` ahora refleja el capitán real en lugar de `false` constante.

---

### `LineupEntryModel`

```dart
@immutable
class LineupEntryModel {
  final String id;
  final SquadPlayerModel squadPlayer;
  final bool isStarter;
  final bool isCaptain;
}
```

| Método | Retorno | Descripción |
|---|---|---|
| `fromJson(json)` | `LineupEntryModel` | Espera JSON con join `squad_players(*, real_players(*))` |
| `toJson()` | `Map<String, dynamic>` | Emite `squad_player_id` (FK), `is_starter`, `is_captain` para escrituras en `lineup_entries` |
| `copyWith(...)` | `LineupEntryModel` | Copia inmutable con campos opcionales sustituidos |

---

### `LineupModel`

```dart
@immutable
class LineupModel {
  final String id;
  final String teamId;
  final List<LineupEntryModel> entries;

  List<LineupEntryModel> get starters => entries.where((e) => e.isStarter).toList();
  List<LineupEntryModel> get bench    => entries.where((e) => !e.isStarter).toList();
  LineupEntryModel?       get captain => entries.firstWhere((e) => e.isCaptain, orElse: null);
}
```

| Getter | Retorno | Descripción |
|---|---|---|
| `starters` | `List<LineupEntryModel>` | Entradas con `isStarter == true`. Máximo 11. |
| `bench` | `List<LineupEntryModel>` | Entradas con `isStarter == false`. Máximo 7. |
| `captain` | `LineupEntryModel?` | Primera entrada con `isCaptain == true`, o null. |

`fromJson` espera el JSON de la query: `.select('*, lineup_entries(*, squad_players(*, real_players(*)))')`.
`toJson` solo emite los campos de la tabla `lineups`; las entradas se insertan por separado.
`operator ==` usa `listEquals` de `flutter/foundation.dart` para comparación profunda de `entries`.

---

### `LineupRepository`

```dart
class LineupRepository {
  const LineupRepository(SupabaseClient _client);

  Future<LineupModel?> fetchCurrentLineup(String teamId) async { ... }
  Future<void> saveLineup(LineupModel lineup) async { ... }
}
```

| Método | Retorno | Descripción |
|---|---|---|
| `fetchCurrentLineup(teamId)` | `Future<LineupModel?>` | Alineación guardada del equipo. Mock 4-3-3 con Bellingham como capitán. Delay 300ms. Retorna null si no hay alineación. |
| `saveLineup(lineup)` | `Future<void>` | Valida las reglas del juego y persiste. Lanza `ArgumentError` si fallan. Delay 300ms en mock. |

#### Reglas validadas en `_validate`

1. `starters.length == AppConstants.maxStartersCount` (11)
2. `bench.length <= AppConstants.maxBenchCount` (7)
3. Exactamente 1 entrada con `isCaptain == true`
4. El capitán es titular (`isCaptain == true && isStarter == true`)

El mock `_mockLineup` genera una alineación 4-3-3 a partir de los mismos 15 jugadores del mock de `SquadRepository` (fase 2.11). Los IDs `mock-sp-XX` son idénticos para garantizar coherencia entre ambos mocks.

**Distribución mock:**

| Rol | Jugador (ID) |
|---|---|
| POR titular | Ter Stegen (mock-sp-01) |
| DEF titulares | Carvajal (02), Rüdiger (03), Mendy (04), Jordi Alba (05) |
| MED titulares | Pedri (06), Bellingham (07) ★ capitán, Koke (08) |
| DEL titulares | Lewandowski (10), Vinicius (11), Griezmann (12) |
| Banquillo | Oblak (13), De Paul (09), Gavi (14), Morata (15) |

---

### Providers

```dart
@Riverpod(keepAlive: true)
LineupRepository lineupRepository(LineupRepositoryRef ref) { ... }

@Riverpod(keepAlive: true)
Future<LineupModel?> currentLineup(CurrentLineupRef ref) async { ... }
```

`currentLineupProvider` encadena `currentTeamProvider.future` con el mismo patrón que `currentSquadProvider` en la fase 2.11. Si el equipo es null, retorna null sin lanzar error.

---

### Cambios en `HomeScreen`

- Añadido: `ref.watch(currentLineupProvider).valueOrNull`
- Añadido: `final captainId = lineup?.captain?.squadPlayer.id`
- Cambiado: `isCaptain: false` → `isCaptain: captainId == sp.id` en cada `PlayerCard`

El capitán (Bellingham en el mock) muestra ahora la corona animada de `PlayerCard` que implementó Guillermo en la fase 3 de UI.

## Decisiones tomadas y por qué

1. **`LineupEntryModel` embebe `SquadPlayerModel` completo en lugar de solo el ID.** En producción la query join trae todos los datos en una sola llamada. Almacenar el objeto completo permite que la UI acceda a nombre, posición y valor de mercado sin queries adicionales. El patrón es idéntico al de `SquadPlayerModel` que embebe `PlayerModel`.

2. **`saveLineup` valida en el repositorio, no en la capa de presentación.** Las reglas (11 titulares, 1 capitán, máximo 7 suplentes) son reglas de dominio derivadas de `AppConstants`. Colocarlas en el repositorio garantiza que ningún caller —UI, test o script— pueda persistir una alineación inválida. Alternativa descartada: validar en un provider Notifier. Añade boilerplate innecesario cuando el repositorio ya es el punto de escritura.

3. **`_mockSquad` duplicado en `LineupRepository` en lugar de depender de `SquadRepository`.** En producción ambos repositorios ejecutan queries independientes contra tablas distintas (`squad_players` vs `lineup_entries`). Introducir una dependencia entre repositorios para compartir el mock habría roto la separación de capas. La duplicación es temporal y está comentada explícitamente.

4. **`operator ==` en `LineupModel` usa `listEquals` de `flutter/foundation.dart`.** Comparación elemento a elemento necesaria para que Riverpod detecte cambios de estado correctamente cuando se llama a `ref.invalidate(currentLineupProvider)` en fases futuras. `Object.hashAll(entries)` es el complemento consistente.

## Conexión con el código existente

- **Fase 2.11** (`squad_provider.dart`): `currentLineupProvider` observa `currentTeamProvider.future` con el mismo patrón que `currentSquadProvider`. Los IDs `mock-sp-XX` son compartidos por ambos mocks.
- **Fase 2.10** (`team_provider.dart`): `currentLineupProvider` encadena `currentTeamProvider.future` para obtener el `teamId`.
- **Fase 2.7** (`supabase_provider.dart`): `lineupRepositoryProvider` inyecta `supabaseClientProvider`, mismo patrón que todos los repositorios anteriores.
- **UI fase 3** (`player_card.dart`): `isCaptain: captainId == sp.id` en `HomeScreen` activa la animación de corona que Guillermo implementó. Esta es la primera vez que ese campo recibe un valor real.

**TODOs abiertos para fases futuras:**

- **Backend fase 1.10** (Jacobo): crear tablas `lineups` y `lineup_entries`. Cuando existan, eliminar `_mockLineup`, `_mockSquad` y `_make` en `LineupRepository`, y descomentar las queries reales.
- **Fase 2.13** (`MarketRepository`): puede leer `currentLineupProvider` para saber qué jugadores son titulares y aplicar restricciones de mercado (e.g., no vender al capitán).
- **`LineupScreen`** (Guillermo, UI): puede conectar `currentLineupProvider` y `lineupRepositoryProvider` para construir el editor de alineación con arrastrar-y-soltar y cambio de capitán.

## Cómo probar que esta fase funciona

```bash
cd nextgen_fantasy
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

Tras login con Google, en `HomeScreen`:
1. Después del spinner (~300ms adicionales al de la plantilla), Bellingham aparece con la corona de capitán.
2. El resto de jugadores no muestran corona.
3. Los demás datos (nombre del equipo, presupuesto, lista de jugadores) siguen funcionando igual que en la fase 2.11.

Verificación desde código:

```dart
final lineup = ref.watch(currentLineupProvider).valueOrNull;
print(lineup?.starters.length);              // 11
print(lineup?.bench.length);                 // 4
print(lineup?.captain?.squadPlayer.player.name); // 'Bellingham'
print(lineup?.captain?.isStarter);           // true

// Validación — debe lanzar ArgumentError:
final repo = ref.read(lineupRepositoryProvider);
await repo.saveLineup(lineup!.copyWith(
  entries: lineup.entries.map((e) => e.copyWith(isCaptain: false)).toList(),
)); // throws: 'La alineación debe tener exactamente 1 capitán. Recibidos: 0.'
```

## Dependencias desbloqueadas

- **Fase 2.13** (MarketRepository): puede asumir que `currentLineupProvider` existe para cruzar datos de plantilla con estado de alineación.
- **Fase 2.14** (FinanceRepository): puede leer el capitán para aplicar posibles bonificaciones económicas por rendimiento.
- **Guillermo** (UI): puede construir `LineupScreen` llamando a `lineupRepositoryProvider.saveLineup(...)` y leyendo `currentLineupProvider` para mostrar el estado actual.
- **`HomeScreen`**: la corona de capitán es visible en cuanto el provider resuelve, sin cambios adicionales en la UI.
