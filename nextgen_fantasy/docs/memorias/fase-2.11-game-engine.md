# Fase 2.11 — SquadRepository con mock datasource y currentSquadProvider

**Desarrollador:** Marcos | **Fecha:** 07/05/2026 | **Rama:** feature/game-engine-flutter

## Qué se implementó

### Archivos nuevos

| Archivo | Responsabilidad |
|---|---|
| `lib/features/lineup/data/repositories/squad_repository.dart` | Repositorio concreto que expone `fetchSquad(teamId)` |
| `lib/features/lineup/presentation/providers/squad_provider.dart` | Providers Riverpod: `squadRepositoryProvider` y `currentSquadProvider` |
| `lib/features/lineup/presentation/providers/squad_provider.g.dart` | Generado por `riverpod_generator` (no editar a mano) |

### Archivo modificado

`lib/features/home/presentation/screens/home_screen.dart` — conectado a `currentSquadProvider`, eliminados datos hardcodeados de jugadores, añadido helper `_positionLabel`.

---

### `SquadRepository`

```dart
class SquadRepository {
  const SquadRepository(SupabaseClient _client);

  Future<List<SquadPlayerModel>> fetchSquad(String teamId) async { ... }
}
```

| Método | Retorno | Descripción |
|---|---|---|
| `fetchSquad(teamId)` | `Future<List<SquadPlayerModel>>` | Devuelve la plantilla completa del equipo. 15 jugadores mock. Delay 300ms. |

El mock construye 15 `SquadPlayerModel` directamente, sin JSON de por medio, usando el helper privado `_make()`. La cláusula de cada jugador se calcula como `marketValue × 1.5`. Todos con `isOnMarket: false`.

Distribución de la plantilla mock:

| Pos | Jugadores |
|---|---|
| POR | Ter Stegen, Oblak |
| DEF | Carvajal, Rüdiger, Mendy, Jordi Alba |
| MED | Pedri, Bellingham, Koke, De Paul, Gavi |
| DEL | Lewandowski, Vinicius, Griezmann, Morata |

El `teamId` recibido como parámetro se inyecta en cada `SquadPlayerModel.teamId`, por lo que el mock nunca asume un ID fijo: funciona con cualquier valor que venga de `currentTeamProvider`.

La query real comentada usa `.select('*, real_players(*)')` que es el patrón de join ya definido en `SquadPlayerModel.fromJson` desde la fase 2.4. El swap es eliminar el bloque mock y descomentar las 4 líneas.

---

### Providers

```dart
@Riverpod(keepAlive: true)
SquadRepository squadRepository(SquadRepositoryRef ref) { ... }

@Riverpod(keepAlive: true)
Future<List<SquadPlayerModel>> currentSquad(CurrentSquadRef ref) async { ... }
```

`currentSquadProvider` encadena `currentTeamProvider.future` antes de ejecutar la query. Si el equipo está cargando, `currentSquadProvider` también queda en estado loading. Si el equipo es null (sin sesión), retorna lista vacía sin lanzar error.

El patrón de captura del repositorio antes del primer `await` es deliberado:
```dart
final repo = ref.watch(squadRepositoryProvider); // síncrono — antes del await
final team = await ref.watch(currentTeamProvider.future);
```
Esto garantiza que la dependencia con `squadRepositoryProvider` se registra en el framework antes de que el provider entre en modo asíncrono.

---

### Cambios en `HomeScreen`

- Eliminado: `const mockPlayers` con 5 entradas hardcodeadas.
- Añadido: `ref.watch(currentSquadProvider).valueOrNull ?? []` para obtener la plantilla.
- Añadido: método `_positionLabel(Position pos)` que convierte el enum al string que espera `PlayerCard`:

| `Position` | `PlayerCard.position` |
|---|---|
| `goalkeeper` | `'POR'` |
| `defender` | `'DEF'` |
| `midfielder` | `'MED'` |
| `forward` | `'DEL'` |

- Mientras `squad.isEmpty` (loading o sin equipo), se muestra `CircularProgressIndicator`.
- `points: 0.0` e `isCaptain: false` en todos los jugadores hasta que el sistema de puntuación y `LineupRepository` estén implementados.

## Decisiones tomadas y por qué

1. **`_make()` construye `SquadPlayerModel` directamente, sin pasar por `fromJson`.** El mock no tiene JSON de Supabase — construir el modelo directamente es más limpio y evita serializar/deserializar datos ficticios. `fromJson` se ejercita en los tests de integración cuando la tabla real exista.

2. **`currentSquadProvider` encadena `currentTeamProvider.future` en lugar de `currentTeamProvider`.** Usar `.future` en vez de `AsyncValue` permite escribir el provider como async/await puro sin necesidad de un `when()` anidado. El resultado es código lineal y legible. La dependencia con el provider de equipo es explícita: si el equipo cambia (e.g., el usuario de alguna forma accede a otro equipo en el futuro), la plantilla se recalcula automáticamente.

3. **`isCaptain: false` para todos los jugadores.** El capitán es una decisión de alineación, no un atributo de la plantilla. `SquadPlayerModel` no tiene ese campo porque pertenece a la tabla `lineups` (fases 2.12 y backend 1.10). Asignar capitán aquí habría sido modelar mal el dominio.

4. **15 jugadores en el mock (11 titulares + 4 suplentes).** `AppConstants.maxStartersCount = 11` y `maxBenchCount = 7`. Se usan 4 suplentes para mantener el mock pequeño pero representativo de una plantilla real parcialmente construida.

## Conexión con el código existente

- **Fase 2.10** (`team_provider.dart`): `currentSquadProvider` observa `currentTeamProvider.future` para obtener el `teamId`. El `'mock-team-01'` del mock de `TeamRepository` es el ID que recibe `fetchSquad`, cerrando el ciclo entre ambas fases.
- **Fase 2.4** (`squad_player_model.dart`): `SquadPlayerModel.fromJson` espera el JSON con join `real_players(*)`. La query real comentada en `fetchSquad` genera exactamente ese formato.
- **Fase 2.3** (`player_model.dart`): `_make()` construye `PlayerModel` con los campos mínimos requeridos (`id`, `apiFootballPlayerId`, `name`, `position`, `marketValue`, `status`). Los campos opcionales (`clubId`, `photoUrl`, `age`, etc.) se omiten en el mock.

**TODOs abiertos para fases futuras:**

- **Fase 2.12** (`LineupRepository`): usará `currentSquadProvider` para obtener los jugadores disponibles y permitir al usuario seleccionar su once. La distinción titulares/suplentes reside aquí.
- **Backend fase 1.8** (Jacobo): crear tabla `squad_players` con campos `id, team_id, real_player_id, clause, is_on_market`. Cuando exista, eliminar `_mockSquad()` y `_make()`, descomentar la query real.
- **Sistema de puntos** (fase futura): `currentSquadProvider` expondrá la plantilla; un `scoreProvider` separado cruzará el `squadPlayer.id` con los puntos de jornada. `HomeScreen` conectará ambos cuando ese provider exista.

## Cómo probar que esta fase funciona

```bash
cd nextgen_fantasy
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

Tras login con Google, en `HomeScreen`:
1. El spinner desaparece en ~300ms y aparece la lista horizontal de jugadores.
2. Deben verse **15 tarjetas** de jugador con nombre y posición en español (POR/DEF/MED/DEL).
3. Todos muestran `0.0 pts` — correcto hasta que el sistema de scoring esté implementado.
4. El header sigue mostrando nombre del equipo y presupuesto (de la fase 2.10).

Verificación desde código:

```dart
final squad = ref.watch(currentSquadProvider).valueOrNull;
print(squad?.length);              // 15
print(squad?.first.player.name);   // 'Ter Stegen'
print(squad?.first.player.position); // Position.goalkeeper
print(squad?.last.clause);         // 22500000 (Morata: 15M * 1.5)
```

## Dependencias desbloqueadas

- **Fase 2.12** (LineupRepository): puede leer `currentSquadProvider` para construir el once del equipo y guardar la alineación.
- **Fase 2.13** (MarketRepository): puede leer `currentSquadProvider` para saber qué jugadores están disponibles para vender y cuáles están en el mercado.
- **Guillermo** (UI): puede conectar `LineupScreen` y `MarketScreen` a `currentSquadProvider` para mostrar la plantilla real en cada sección.
