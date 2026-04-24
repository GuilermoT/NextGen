# Fase 2.2 - TeamModel

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

Modelo de datos `TeamModel` ubicado en `lib/features/market/domain/models/team_model.dart`.

Campos del modelo (mapean a tabla `teams`, pendiente de crear por Jacobo en fase 1.6):
- `id` → `String` (uuid, PK)
- `leagueId` → `String` (mapea `league_id`, FK → `leagues`)
- `userId` → `String` (mapea `user_id`, FK → `profiles`)
- `name` → `String` (nombre del equipo fantasy)
- `budget` → `int` (mapea `budget int4`, saldo del equipo)

Métodos implementados:
- Constructor `const TeamModel({...})` — todos los campos requeridos
- `factory TeamModel.fromJson(Map<String, dynamic> json)` — mapeo snake_case → camelCase
- `Map<String, dynamic> toJson()` — serialización de vuelta a snake_case
- `TeamModel copyWith({...})` — actualizaciones parciales inmutables
- `==`, `hashCode`, `toString`

`flutter analyze`: **0 issues** tras la adición.

## Conceptos nuevos asimilados

A diferencia de `UserModel`, donde `balance` tenía un valor por defecto en `fromJson` (columna inexistente), `TeamModel.budget` es un campo **requerido sin default** porque en el esquema acordado del PDF la columna `budget` sí existirá y tendrá siempre un valor definido (no nullable). Si Supabase devolviera `null`, el cast `as int` lanzaría una excepción — comportamiento correcto para detectar inconsistencias de esquema temprano.

## Decisiones tomadas y por qué

1. **`budget` como `int` requerido (sin `??`):** La tabla `teams` define `budget int4 NOT NULL` según el PDF. Un modelo que acepta silenciosamente `null` ocultaría bugs de esquema. Si hay un null inesperado, mejor que explote en `fromJson` que en un widget a las 2 AM.

2. **Feature `market/` para `TeamModel`:** El equipo (Team) es la unidad central del mercado de fichajes. Podría parecer que debería ir en `shared/`, pero el equipo es una entidad que se gestiona desde la feature de mercado (comprar/vender jugadores modifica el budget del equipo). La UI de mercado, el repositorio de mercado y el equipo pertenecen todos al mismo contexto de dominio.

## Bloqueos encontrados y cómo se resolvieron

- **Tabla `teams` inexistente:** Jacobo tiene pendiente la fase 1.6. El modelo se define según el esquema acordado. Cuando Jacobo cree la tabla, el `fromJson` funcionará sin cambios.
- **`flutter analyze` repite resolución de dependencias:** Las 39 dependencias con versiones más nuevas generan ruido en la salida pero no afectan al análisis. No se actualizan las versiones (regla del proyecto: no instalar dependencias no especificadas en el prompt de la fase activa).

## Cómo probar que esta fase funciona

```dart
// Instanciar TeamModel:
const team = TeamModel(
  id: 'team-uuid-123',
  leagueId: 'league-uuid-456',
  userId: 'user-uuid-789',
  name: 'Los Galácticos FC',
  budget: 100000000, // 100M€ (AppConstants.initialTeamBalance)
);
print(team.budget); // 100000000

// fromJson con datos de Supabase (cuando tabla teams exista):
final team2 = TeamModel.fromJson({
  'id': 'abc-123',
  'league_id': 'liga-456',
  'user_id': 'user-789',
  'name': 'Real Fantasy Madrid',
  'budget': 85000000,
});

// copyWith (ej. actualizar presupuesto tras compra):
final teamAfterBuy = team2.copyWith(budget: team2.budget - 5000000);
```

**Dependencias desbloqueadas con esta fase:**
- Fase 2.10 (TeamRepository) ya puede importar `TeamModel` como tipo de retorno.
- Fase 2.15 (game_providers.dart) ya puede tipificar `teamProvider` como `TeamModel?`.
