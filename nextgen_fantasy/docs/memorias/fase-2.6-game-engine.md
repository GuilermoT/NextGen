# Fase 2.6 - BribeModel

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

Modelo de datos `BribeModel` y enum `BribeStatus` ubicados en `lib/features/finance/domain/models/bribe_model.dart`.

Mapea a la tabla `bribes` (pendiente de crear por Jacobo en fase 1.13).

### enum BribeStatus

```dart
enum BribeStatus { pending, accepted, rejected }
```

| Dart     | DB          | Significado                        |
|----------|-------------|------------------------------------|
| `pending`  | `'pending'`  | Soborno enviado, esperando respuesta |
| `accepted` | `'accepted'` | Receptor aceptó el soborno         |
| `rejected` | `'rejected'` | Receptor rechazó el soborno        |

Mapeo directo lowercase sin transformación — los valores DB coinciden exactamente con los nombres del enum.

### Campos del modelo

| Dart (camelCase)   | DB (snake_case)      | Tipo Dart     | Nullable |
|--------------------|----------------------|---------------|----------|
| `id`               | `id`                 | `String`      | no       |
| `senderTeamId`     | `sender_team_id`     | `String`      | no       |
| `receiverTeamId`   | `receiver_team_id`   | `String`      | no       |
| `targetPlayerId`   | `target_player_id`   | `String`      | no       |
| `amount`           | `amount`             | `int`         | no       |
| `status`           | `status`             | `BribeStatus` | no       |
| `jornadaId`        | `jornada_id`         | `String`      | no       |

`flutter analyze`: **0 issues** tras la adición.

## Decisiones tomadas y por qué

1. **`targetPlayerId` como `String` (no `PlayerModel` anidado):** A diferencia de `SquadPlayerModel`, el soborno solo necesita identificar al jugador objetivo, no mostrar sus datos. La `FinanceScreen` que gestiona sobornos referenciará el ID para operaciones de aceptar/rechazar. Si la UI necesita mostrar el nombre del jugador, lo resolverá con un JOIN en el repositorio o un lookup separado — no forma parte del dominio del soborno.

2. **`BribeStatus` con mapeo lowercase directo:** Los tres valores (`pending`, `accepted`, `rejected`) son palabras simples que no necesitan transformación snake_case. A diferencia de `clauseTax` → `clause_tax` en `TransactionType`, aquí no hay complejidad de casing.

3. **Todos los campos requeridos:** La tabla `bribes` del PDF no define ningún campo como nullable. Un soborno siempre tiene remitente, receptor, jugador objetivo, cantidad, estado y jornada. Sin defaults.

4. **`jornadaId` como `String` (no referencia a tabla `jornadas`):** Mismo patrón que `targetPlayerId` — solo la FK, no el objeto completo. El soborno pertenece a una jornada pero no necesita los datos de la jornada para operar.

## Cómo probar que esta fase funciona

```dart
// fromJson con datos de Supabase:
final bribe = BribeModel.fromJson({
  'id': 'bribe-uuid-001',
  'sender_team_id': 'team-a-uuid',
  'receiver_team_id': 'team-b-uuid',
  'target_player_id': 'player-uuid-vinicius',
  'amount': 5000000,
  'status': 'pending',
  'jornada_id': 'jornada-uuid-32',
});

print(bribe.status);           // BribeStatus.pending
print(bribe.amount);           // 5000000
print(bribe.senderTeamId);     // 'team-a-uuid'

// toJson (para escritura en DB):
print(bribe.toJson()['status']); // 'pending'

// copyWith — receptor acepta el soborno:
final accepted = bribe.copyWith(status: BribeStatus.accepted);
print(accepted.status);          // BribeStatus.accepted
print(accepted.toJson()['status']); // 'accepted'
```

**Dependencias desbloqueadas con esta fase:**
- Fase 2.14 (FinanceRepository) puede implementar `sendBribe()`, `acceptBribe()` y `rejectBribe()` con `BribeModel` como tipo de retorno/parámetro.
- `FinanceScreen` de Guillermo puede mostrar el estado de sobornos en curso y el historial.

## Estado del bloque de modelos

Con esta fase se completan los **6 modelos de dominio** (fases 2.1–2.6):

| Modelo              | Feature    | Estado |
|---------------------|------------|--------|
| `UserModel`         | auth       | ✅     |
| `TeamModel`         | market     | ✅     |
| `PlayerModel`       | lineup     | ✅     |
| `SquadPlayerModel`  | lineup     | ✅     |
| `TransactionModel`  | finance    | ✅     |
| `BribeModel`        | finance    | ✅     |

**Siguiente bloque:** infraestructura de providers y repositorios (fases 2.7–2.15).
