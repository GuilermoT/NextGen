# Fase 2.4 - SquadPlayerModel

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

Modelo de datos `SquadPlayerModel` ubicado en `lib/features/lineup/domain/models/squad_player_model.dart`.

Mapea a la tabla `squad_players` (pendiente de crear por Jacobo en fase 1.8). Es el modelo más complejo hasta ahora porque contiene un objeto `PlayerModel` anidado resultado de un JOIN con `real_players`.

Campos del modelo:
| Dart (camelCase) | DB (snake_case)    | Tipo Dart     | Nullable |
|------------------|--------------------|---------------|----------|
| `id`             | `id`               | `String`      | no       |
| `teamId`         | `team_id`          | `String`      | no       |
| `player`         | `real_player_id`*  | `PlayerModel` | no       |
| `clause`         | `clause`           | `int`         | no       |
| `isOnMarket`     | `is_on_market`     | `bool`        | no       |

*`real_player_id` es la FK en DB. En el modelo Dart guardamos el objeto `PlayerModel` completo.

Métodos implementados:
- Constructor `const SquadPlayerModel({...})` — todos los campos requeridos
- `factory SquadPlayerModel.fromJson(Map<String, dynamic> json)` — deserializa el JOIN Supabase
- `Map<String, dynamic> toJson()` — serializa emitiendo `real_player_id` (FK) en lugar del objeto
- `SquadPlayerModel copyWith({...})` — actualizaciones parciales inmutables
- `==`, `hashCode`, `toString`

`flutter analyze`: **0 issues** tras la adición.

## Conceptos nuevos asimilados

**Patrón JOIN de Supabase en `fromJson`:** Cuando se hace `.select('*, real_players(*)')` en el repositorio, PostgREST devuelve el JSON con la tabla relacionada anidada bajo su nombre:
```json
{
  "id": "squad-uuid",
  "team_id": "team-uuid",
  "real_player_id": "player-uuid",
  "clause": 20000000,
  "is_on_market": false,
  "real_players": {
    "id": "player-uuid",
    "name": "Vinícius Júnior",
    ...
  }
}
```
El `fromJson` extrae `json['real_players']` y lo pasa a `PlayerModel.fromJson()`.

**Asimetría lectura/escritura:** El modelo Dart almacena `PlayerModel player` (objeto completo) pero la DB solo persiste `real_player_id` (FK). El `toJson()` resuelve esta asimetría emitiendo `'real_player_id': player.id`.

## Decisiones tomadas y por qué

1. **`player` como `PlayerModel` (no `String realPlayerId`):** La UI siempre necesita los datos del jugador (nombre, posición, foto, valor). Guardar solo el ID obligaría a una segunda consulta en el repositorio o en el provider. El JOIN en Supabase es barato y el modelo refleja la realidad de uso.

2. **`clause` e `isOnMarket` sin defaults:** La tabla `squad_players` define ambas columnas como NOT NULL sin DEFAULT en el PDF. Un cast estricto `as int` y `as bool` detecta inconsistencias de esquema temprano.

3. **`toJson` emite `real_player_id`, no el objeto anidado:** Para operaciones de escritura (INSERT/UPDATE en `squad_players`), la DB solo acepta la FK. Incluir el objeto `real_players` anidado en el body causaría un error PostgREST.

## Cómo probar que esta fase funciona

```dart
// fromJson simulando respuesta Supabase con JOIN:
final squadPlayer = SquadPlayerModel.fromJson({
  'id': 'squad-uuid-001',
  'team_id': 'team-uuid-123',
  'real_players': {
    'id': 'player-uuid-456',
    'api_football_player_id': 284467,
    'club_id': 'club-uuid-789',
    'name': 'Vinícius Júnior',
    'first_name': 'Vinícius',
    'last_name': 'Júnior',
    'age': 24,
    'position': 'Attacker',
    'photo_url': null,
    'market_value': 180000000,
    'status': 'active',
  },
  'clause': 25000000,
  'is_on_market': false,
});

print(squadPlayer.player.name);       // 'Vinícius Júnior'
print(squadPlayer.player.position);   // Position.forward
print(squadPlayer.clause);            // 25000000
print(squadPlayer.isOnMarket);        // false

// toJson produce la FK, no el objeto anidado:
print(squadPlayer.toJson()['real_player_id']); // 'player-uuid-456'

// copyWith (ej. poner en mercado y actualizar cláusula):
final onMarket = squadPlayer.copyWith(isOnMarket: true, clause: 30000000);
print(onMarket.isOnMarket); // true
print(onMarket.clause);     // 30000000
```

**Dependencias desbloqueadas con esta fase:**
- Fase 2.11 (SquadRepository) puede retornar `List<SquadPlayerModel>` en `getSquad()`.
- Fase 2.13 (MarketRepository) puede recibir `squadPlayerId` y operar sobre el jugador completo.
- Fase 2.15 (`game_providers.dart`) puede tipar el provider `squad` como `List<SquadPlayerModel>`.
- `LineupScreen` y `MarketScreen` de Guillermo pueden consumir la plantilla completa con datos reales del jugador.
