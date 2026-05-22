# Fase 2.13 — MarketRepository con mock datasource y providers de mercado

**Desarrollador:** Marcos | **Fecha:** 22/05/2026 | **Rama:** feature/game-engine-flutter

## Qué se implementó

### Archivos nuevos

| Archivo | Responsabilidad |
|---|---|
| `lib/features/market/data/repositories/market_repository.dart` | Repositorio concreto con los 6 métodos del mercado de fichajes |
| `lib/features/market/presentation/providers/market_provider.dart` | Providers Riverpod: `marketRepositoryProvider`, `marketListingsProvider`, `freeAgentsProvider` |
| `lib/features/market/presentation/providers/market_provider.g.dart` | Generado por `riverpod_generator` (no editar a mano) |

---

### `MarketRepository`

```dart
class MarketRepository {
  const MarketRepository(SupabaseClient _client);

  Future<List<SquadPlayerModel>> fetchMarketListings(String leagueId) async { ... }
  Future<List<PlayerModel>>      fetchFreeAgents(String leagueId) async { ... }
  Future<void> signFreeAgent({required TeamModel buyerTeam, required PlayerModel player, required int currentSquadSize}) async { ... }
  Future<void> triggerClause({required TeamModel buyerTeam, required SquadPlayerModel targetSquadPlayer, required int currentSquadSize}) async { ... }
  Future<void> listPlayerForSale({required SquadPlayerModel squadPlayer, required String ownerTeamId}) async { ... }
  Future<void> removePlayerFromMarket({required SquadPlayerModel squadPlayer, required String ownerTeamId}) async { ... }
}
```

| Método | Retorno | Descripción |
|---|---|---|
| `fetchMarketListings(leagueId)` | `Future<List<SquadPlayerModel>>` | Jugadores en venta de equipos rivales en la liga. Delay 300ms. |
| `fetchFreeAgents(leagueId)` | `Future<List<PlayerModel>>` | Jugadores reales sin equipo asignado en la liga. Delay 300ms. |
| `signFreeAgent(...)` | `Future<void>` | Ficha un agente libre al precio de `player.marketValue`. Delay 400ms. |
| `triggerClause(...)` | `Future<void>` | Ficha un jugador rival pagando `targetSquadPlayer.clause`. Delay 400ms. |
| `listPlayerForSale(...)` | `Future<void>` | Marca `isOnMarket = true` en el jugador propio. Delay 300ms. |
| `removePlayerFromMarket(...)` | `Future<void>` | Marca `isOnMarket = false` en el jugador propio. Delay 300ms. |

#### Reglas validadas — método privado `_validateSigning`

Compartido por `signFreeAgent` y `triggerClause`:

1. `budget >= cost` → `ArgumentError('Fondos insuficientes. Presupuesto: $budget, coste: $cost.')`
2. `currentSquadSize < maxStartersCount + maxBenchCount` (18) → `ArgumentError('Plantilla completa...')`
3. `playerStatus == 'active'` → `ArgumentError('El jugador $name no está disponible...')`

Validaciones exclusivas de `triggerClause`:

4. `buyerTeam.id != targetSquadPlayer.teamId` → `ArgumentError('No puedes activar la cláusula de un jugador de tu propio equipo.')`

Validaciones de `listPlayerForSale`:

5. `squadPlayer.teamId == ownerTeamId` → `ArgumentError('Solo puedes listar jugadores de tu propia plantilla.')`
6. `!squadPlayer.isOnMarket` → `ArgumentError('El jugador $name ya está en el mercado.')`

Validaciones de `removePlayerFromMarket`:

7. `squadPlayer.teamId == ownerTeamId` → `ArgumentError('Solo puedes retirar jugadores de tu propia plantilla.')`
8. `squadPlayer.isOnMarket` → `ArgumentError('El jugador $name no está en el mercado.')`

#### Mock data

`_mockMarketListings` devuelve 3 jugadores de equipos rivales (`mock-team-02` y `mock-team-03`) con IDs `mock-sp-rival-01/02/03` — distintos de los `mock-sp-01..15` del equipo propio para evitar colisiones.

`_mockFreeAgents` devuelve 5 jugadores con IDs `mock-fa-01..05` — nunca presentes en `SquadRepository._mockSquad`.

Las cláusulas mock siguen el patrón establecido en `SquadRepository._make`: `(marketValue * 1.5).round()`.

---

### Providers

```dart
@Riverpod(keepAlive: true)
MarketRepository marketRepository(MarketRepositoryRef ref) { ... }

@Riverpod(keepAlive: true)
Future<List<SquadPlayerModel>> marketListings(MarketListingsRef ref) async { ... }

@Riverpod(keepAlive: true)
Future<List<PlayerModel>> freeAgents(FreeAgentsRef ref) async { ... }
```

`marketListingsProvider` y `freeAgentsProvider` encadenan `currentTeamProvider.future` para obtener `team.leagueId`. Si el equipo es null, retornan lista vacía sin error — patrón idéntico a `currentSquadProvider` (fase 2.11).

Los métodos de escritura (`signFreeAgent`, `triggerClause`, etc.) **no tienen provider propio**: se llaman directamente sobre `ref.read(marketRepositoryProvider)` desde la UI. Tras cada mutación, la UI debe invalidar los providers afectados:

```dart
ref.invalidate(marketListingsProvider);
ref.invalidate(freeAgentsProvider);
ref.invalidate(currentSquadProvider);
ref.invalidate(currentTeamProvider);
```

## Decisiones tomadas y por qué

1. **`_validateSigning` extrae la lógica compartida entre `signFreeAgent` y `triggerClause`.** Ambas operaciones comprueban presupuesto, tamaño de plantilla y estado del jugador. Duplicar las tres comprobaciones habría creado deuda de mantenimiento. El método privado centraliza los `ArgumentError` con mensajes uniformes. Alternativa descartada: validar en el provider o en la UI — las reglas de negocio pertenecen al repositorio, igual que en `LineupRepository._validate`.

2. **Los métodos de escritura no exponen providers Riverpod propios.** El patrón del proyecto para operaciones de escritura es llamar al repositorio directamente e invalidar los providers de lectura afectados. Crear un `AsyncNotifier` para cada operación de mercado añadiría boilerplate innecesario en esta fase; ese refactor queda para la capa de integración INT-3 si la UI lo requiere.

3. **`triggerClause` no actualiza el presupuesto del equipo vendedor.** La transferencia económica al vendedor es responsabilidad de `FinanceRepository` (fase 2.14), que registrará la transacción de tipo `clauseTax`. Este repositorio solo modela el lado comprador para mantener la separación de responsabilidades. La query real comentada indica explícitamente este punto de extensión.

4. **`weeklyClauseTaxRate` y `bankruptcyThreshold` no se aplican aquí.** `MarketRepository` realiza únicamente la comprobación de presupuesto en el momento del fichaje. La acumulación semanal de la tasa sobre cláusulas y el umbral de quiebra son lógica de `FinanceRepository`. Implementarlos aquí habría requerido leer el historial de transacciones, creando una dependencia circular entre repositorios.

## Conexión con el código existente

- **Fase 2.11** (`squad_provider.dart`): `marketListingsProvider` y `freeAgentsProvider` siguen el patrón de `currentSquadProvider` — encadenan `currentTeamProvider.future` y retornan lista vacía si el equipo es null.
- **Fase 2.10** (`team_provider.dart`): ambos providers de mercado obtienen `team.leagueId` a través de `currentTeamProvider`.
- **Fase 2.7** (`supabase_provider.dart`): `marketRepositoryProvider` inyecta `supabaseClientProvider`, idéntico a todos los repositorios anteriores.
- **Fase 2.3** (`player_model.dart`): `freeAgentsProvider` retorna `List<PlayerModel>` — modelo ya existente.
- **Fase 2.4** (`squad_player_model.dart`): `marketListingsProvider` retorna `List<SquadPlayerModel>` — modelo ya existente.
- **Fase 2.2** (`team_model.dart`): `signFreeAgent` y `triggerClause` reciben `TeamModel` para acceder a `budget` e `id`.
- **Fase 2.5** (`transaction_model.dart`): los métodos de escritura no crean `TransactionModel` todavía — ese registro lo gestionará `FinanceRepository` (fase 2.14).
- **`AppConstants`**: `maxStartersCount + maxBenchCount` (18) define el límite de plantilla en `_validateSigning`.

**TODOs abiertos para fases futuras:**

- **Backend fase 1.8** (Jacobo): cuando exista la tabla `squad_players` con columna `is_on_market`, descomentar la query real en `fetchMarketListings` y eliminar `_mockMarketListings`.
- **Backend fase 1.5** (Jacobo): cuando exista la tabla `real_players`, descomentar la query real en `fetchFreeAgents` y eliminar `_mockFreeAgents`.
- **Fase 2.14** (`FinanceRepository`): completar la transferencia económica al vendedor en `triggerClause` y registrar `TransactionType.signing` / `TransactionType.clauseTax`.
- **INT-3** (`MarketScreen`, Guillermo): conectar `marketListingsProvider` y `freeAgentsProvider` a la UI; llamar a `signFreeAgent` / `triggerClause` con los providers invalidados tras la operación.

## Cómo probar que esta fase funciona

```bash
cd nextgen_fantasy
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Verificación desde código Dart (por ejemplo en un test de integración o en un widget temporal):

```dart
// Leer listings de mercado
final listings = await ref.read(marketListingsProvider.future);
print(listings.length);                          // 3
print(listings.first.player.name);               // 'Kroos'
print(listings.first.isOnMarket);                // true
print(listings.any((p) => p.teamId == 'mock-team-01')); // false — no hay jugadores propios

// Leer agentes libres
final freeList = await ref.read(freeAgentsProvider.future);
print(freeList.length);                          // 5
print(freeList.first.name);                      // 'Rodrigo'

// Fichaje válido
final repo = ref.read(marketRepositoryProvider);
await repo.signFreeAgent(
  buyerTeam: team,       // budget: 45_000_000
  player: freeList.first, // marketValue: 12_000_000
  currentSquadSize: 15,
); // no lanza excepción

// Fichaje con fondos insuficientes
await repo.signFreeAgent(
  buyerTeam: team.copyWith(budget: 5_000_000),
  player: freeList[2], // Courtois marketValue: 22_000_000
  currentSquadSize: 15,
); // throws ArgumentError: 'Fondos insuficientes. Presupuesto: 5000000, coste: 22000000.'

// Activar cláusula propia — debe lanzar error
await repo.triggerClause(
  buyerTeam: team,
  targetSquadPlayer: listings.first.copyWith(teamId: team.id),
  currentSquadSize: 15,
); // throws ArgumentError: 'No puedes activar la cláusula de un jugador de tu propio equipo.'
```

## Dependencias desbloqueadas

- **Fase 2.14** (FinanceRepository): puede recibir el importe del fichaje o cláusula para registrar la transacción y calcular el impacto sobre presupuesto. La interfaz pública de `MarketRepository` ya expone todos los parámetros necesarios.
- **Fase 2.15** (Providers globales Riverpod): `marketRepositoryProvider`, `marketListingsProvider` y `freeAgentsProvider` completan el grafo de providers del dominio de mercado junto con `teamRepositoryProvider` y `currentTeamProvider` de la fase 2.10.
- **Guillermo** (INT-3, `MarketScreen`): puede leer `marketListingsProvider` para mostrar el mercado y llamar a `triggerClause` / `signFreeAgent` directamente sobre `marketRepositoryProvider`. Los mensajes de error ya están internacionalizados en español para mostrarse en la UI.
- **Backend** (Jacobo): los bloques de query comentados en cada método documentan exactamente las tablas (`squad_players`, `real_players`, `teams`), columnas (`is_on_market`, `real_player_id`, `team_id`, `clause`, `league_id`) y patrones de join necesarios para las migraciones de las fases 1.5 y 1.8.
