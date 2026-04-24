# Fase 2.5 - TransactionModel

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

Modelo de datos `TransactionModel` y enum `TransactionType` ubicados en `lib/features/finance/domain/models/transaction_model.dart`.

Mapea a la tabla `transactions` (pendiente de crear por Jacobo en fase 1.12).

### enum TransactionType

```dart
enum TransactionType { signing, sale, clauseTax, bribe, penalty }
```

| Dart (camelCase) | DB (snake_case) | Significado               |
|------------------|-----------------|---------------------------|
| `signing`        | `'signing'`     | Fichaje de jugador        |
| `sale`           | `'sale'`        | Venta de jugador          |
| `clauseTax`      | `'clause_tax'`  | Impuesto semanal cláusula |
| `bribe`          | `'bribe'`       | Soborno enviado/recibido  |
| `penalty`        | `'penalty'`     | Penalización por alineación incompleta |

### Campos del modelo

| Dart (camelCase) | DB (snake_case) | Tipo Dart          | Nullable |
|------------------|-----------------|--------------------|----------|
| `id`             | `id`            | `String`           | no       |
| `teamId`         | `team_id`       | `String`           | no       |
| `type`           | `type`          | `TransactionType`  | no       |
| `amount`         | `amount`        | `int`              | no       |
| `description`    | `description`   | `String?`          | sí       |
| `createdAt`      | `created_at`    | `DateTime`         | no       |

`flutter analyze`: **0 issues** tras la adición.

## Conceptos nuevos asimilados

**`DateTime` en modelos Dart:** Este es el primer modelo con un campo `DateTime`. Supabase devuelve timestamps como strings ISO 8601 (`"2026-04-24T18:30:00.000Z"`). El patrón correcto es:
- `fromJson`: `DateTime.parse(json['created_at'] as String)` — parseo directo, lanza `FormatException` si el string no es ISO 8601 válido.
- `toJson`: `createdAt.toIso8601String()` — serialización estándar.

**Constructor `const` con `DateTime`:** El constructor se declara `const` para consistencia con el resto de modelos. En la práctica, las instancias creadas vía `fromJson` no serán `const` (porque `DateTime.parse()` no es const), pero el contrato de inmutabilidad lo garantiza `@immutable` + campos `final`.

## Decisiones tomadas y por qué

1. **`clauseTax` → `'clause_tax'` (snake_case en DB):** El enum Dart usa camelCase (`clauseTax`) pero la DB seguirá la convención snake_case del esquema. El mapeo explícito en `_typeFromString`/`_typeToString` desacopla ambas convenciones — si Jacobo decide otro nombre en la DB, solo cambia el string en estas dos funciones, no el tipo Dart.

2. **Fail-fast en `_typeFromString`:** El `default: throw ArgumentError(...)` detecta inmediatamente valores no reconocidos (ej. si Jacobo añade un tipo nuevo en la DB sin actualizar el enum Dart). Es preferible una excepción en `fromJson` a un estado inconsistente en la UI de finanzas.

3. **`description` nullable:** El PDF no exige descripción en todas las transacciones (una penalización automática no necesita texto, un soborno sí). La columna será `NULL` en DB para transacciones autogeneradas.

4. **Feature `finance/` para `TransactionModel`:** Las transacciones son el registro histórico del saldo del equipo. Su dominio natural es `finance/`, aunque algunas transacciones se originan en `market/` (fichajes/ventas). El repositorio `FinanceRepository` será el único que lea/escriba esta tabla.

## Cómo probar que esta fase funciona

```dart
// fromJson con datos reales de Supabase:
final tx = TransactionModel.fromJson({
  'id': 'tx-uuid-001',
  'team_id': 'team-uuid-123',
  'type': 'signing',
  'amount': -15000000,     // negativo → gasto
  'description': 'Fichaje de Vinícius Júnior',
  'created_at': '2026-04-24T18:30:00.000Z',
});

print(tx.type);        // TransactionType.signing
print(tx.amount);      // -15000000
print(tx.createdAt);   // 2026-04-24 18:30:00.000Z

// Tipo clauseTax con su mapping snake_case:
final taxTx = TransactionModel.fromJson({
  'id': 'tx-uuid-002',
  'team_id': 'team-uuid-123',
  'type': 'clause_tax',   // DB usa snake_case
  'amount': -250000,
  'description': null,
  'created_at': '2026-04-24T09:00:00.000Z',
});
print(taxTx.type);             // TransactionType.clauseTax
print(taxTx.toJson()['type']); // 'clause_tax' (vuelve a snake_case)

// copyWith (ej. corregir descripción):
final corrected = tx.copyWith(description: 'Fichaje internacional');
print(corrected.description); // 'Fichaje internacional'
```

**Dependencias desbloqueadas con esta fase:**
- Fase 2.14 (FinanceRepository) puede retornar `List<TransactionModel>` en `getTransactions()`.
- Fase 2.15 (`game_providers.dart`) puede tipar el historial de finanzas.
- `FinanceScreen` de Guillermo puede mostrar el historial real de movimientos del equipo.
