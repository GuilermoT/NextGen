# Fase 2.3 - PlayerModel + enum Position

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

Modelo de datos `PlayerModel` y enum `Position` ubicados en `lib/features/lineup/domain/models/player_model.dart`.

Este es el primer modelo que mapea a una tabla **existente y poblada** en Supabase (`public.real_players`, ~60 jugadores reales de LaLiga temporada 2024 importados desde API-Football).

### enum Position

```dart
enum Position { goalkeeper, defender, midfielder, forward }
```

Dos funciones privadas de archivo manejan la conversión bidireccional con los valores de texto en DB:

| DB (text)      | Dart (enum)            |
|----------------|------------------------|
| `'Goalkeeper'` | `Position.goalkeeper`  |
| `'Defender'`   | `Position.defender`    |
| `'Midfielder'` | `Position.midfielder`  |
| `'Attacker'`   | `Position.forward`     |

**El mapeo crítico:** la DB usa `'Attacker'`, no `'Forward'`. El enum Dart usa `forward` (semánticamente más correcto en contexto fantasy).

### Campos del modelo (mapean a tabla `real_players`)

| Dart (camelCase)        | DB (snake_case)              | Tipo Dart | Nullable |
|-------------------------|------------------------------|-----------|----------|
| `id`                    | `id`                         | `String`  | no       |
| `apiFootballPlayerId`   | `api_football_player_id`     | `int`     | no       |
| `clubId`                | `club_id`                    | `String?` | sí       |
| `name`                  | `name`                       | `String`  | no       |
| `firstName`             | `first_name`                 | `String?` | sí       |
| `lastName`              | `last_name`                  | `String?` | sí       |
| `age`                   | `age`                        | `int?`    | sí       |
| `position`              | `position`                   | `Position`| no       |
| `photoUrl`              | `photo_url`                  | `String?` | sí       |
| `marketValue`           | `market_value`               | `int`     | no       |
| `status`                | `status`                     | `String`  | no       |

Métodos implementados:
- Constructor `const PlayerModel({...})` — campos requeridos + opcionales con `this.field`
- `factory PlayerModel.fromJson(Map<String, dynamic> json)` — mapeo completo con enum parsing
- `Map<String, dynamic> toJson()` — serialización de vuelta incluyendo `_positionToString`
- `PlayerModel copyWith({...})` — actualizaciones parciales inmutables
- `==`, `hashCode` (via `Object.hash` con 11 campos), `toString`

`flutter analyze`: **0 issues** tras la adición.

## Conceptos nuevos asimilados

**`switch` exhaustivo en Dart para enums:** A diferencia de las fases anteriores (campos primitivos), el mapeo enum→String usa `switch` con un caso por cada valor. Dart 3 hace el `switch` exhaustivo sobre enums en el cuerpo de función, por lo que no se necesita `default` en `_positionToString` — si se añade un valor al enum sin actualizar el switch, el compilador detecta el error. En `_positionFromString` sí existe `default` porque el input es un `String` libre (no tipado por el compilador), y lanza `ArgumentError` como fail-fast.

## Decisiones tomadas y por qué

1. **`position` no nullable en Dart (cast `as String` en fromJson):** La DB permite `NULL` (`position text NULL`) pero los ~60 jugadores importados de API-Football siempre tienen posición. Un null indicaría datos corruptos — mejor excepción en `fromJson` que comportamiento silencioso en la UI.

2. **`marketValue` con `?? 1000000` (default del PDF):** La columna tiene `DEFAULT 1000000` en DB, pero Supabase puede devolver `null` si la columna no se incluye en el SELECT o si el registro se insertó sin ella. El default en `fromJson` refleja el valor acordado en el PDF.

3. **`status` con `?? 'active'`:** Mismo razonamiento que `marketValue`. El DEFAULT de la columna es `'active'`.

4. **Funciones privadas de archivo (`_positionFromString`, `_positionToString`) en lugar de métodos estáticos o extensiones:** La conversión solo tiene sentido en el contexto de este modelo. Funciones de nivel de archivo con `_` son privadas a esta librería y evitan polución del namespace global. Una extensión sobre el enum sería equivalente pero más verbose para dos métodos.

5. **Feature `lineup/` para `PlayerModel`:** El jugador real es la entidad central de la alineación. Aunque `PlayerModel` se usa también en `MarketRepository`, vive en `lineup/` porque es allí donde se toman decisiones de dominio sobre posiciones (¿caben en la formación?) y donde la UI más lo consume.

## Bloqueos encontrados y cómo se resolvieron

- **Ninguno.** `real_players` existe, tiene esquema conocido y datos reales. `flutter analyze` pasó en el primer intento.

## Cómo probar que esta fase funciona

```dart
// Enum mapping:
print(_positionFromString('Attacker'));  // Position.forward
print(_positionFromString('Goalkeeper'));  // Position.goalkeeper

// Instanciar PlayerModel:
const player = PlayerModel(
  id: 'player-uuid-123',
  apiFootballPlayerId: 284467,
  clubId: 'club-uuid-real-madrid',
  name: 'Vinícius Júnior',
  firstName: 'Vinícius',
  lastName: 'Júnior',
  age: 24,
  position: Position.forward,
  photoUrl: 'https://media.api-sports.io/football/players/284467.png',
  marketValue: 180000000,
  status: 'active',
);
print(player.position);  // Position.forward
print(player.marketValue);  // 180000000

// fromJson con datos reales de Supabase (tabla real_players):
final player2 = PlayerModel.fromJson({
  'id': 'abc-123',
  'api_football_player_id': 284467,
  'club_id': 'club-uuid-456',
  'name': 'Vinícius Júnior',
  'first_name': 'Vinícius',
  'last_name': 'Júnior',
  'age': 24,
  'position': 'Attacker',    // ← DB usa 'Attacker', Dart mapea a Position.forward
  'photo_url': 'https://...',
  'market_value': 180000000,
  'status': 'active',
});
print(player2.position == Position.forward);  // true

// toJson (posición vuelve a 'Attacker' para DB):
print(player2.toJson()['position']);  // 'Attacker'

// copyWith (ej. actualizar valor de mercado):
final playerUpdated = player2.copyWith(marketValue: 200000000);
print(playerUpdated.marketValue);  // 200000000

// Jugador con market_value/status ausentes en JSON → usa defaults:
final playerMinimal = PlayerModel.fromJson({
  'id': 'xyz',
  'api_football_player_id': 1,
  'club_id': null,
  'name': 'Jugador Test',
  'first_name': null,
  'last_name': null,
  'age': null,
  'position': 'Defender',
  'photo_url': null,
  // market_value ausente → 1000000
  // status ausente → 'active'
});
print(playerMinimal.marketValue);  // 1000000
print(playerMinimal.status);       // 'active'
```

**Dependencias desbloqueadas con esta fase:**
- Fase 2.4 (SquadPlayerModel) ya puede importar `PlayerModel` como campo `player` (join con real_players).
- Fase 2.11 (SquadRepository) y 2.13 (MarketRepository) ya pueden usar `PlayerModel` como tipo de retorno en listas.
- Fase 2.15 (`game_providers.dart`) puede tipar la lista de jugadores del mercado.
