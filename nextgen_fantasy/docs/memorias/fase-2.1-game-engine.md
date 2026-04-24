# Fase 2.1 - UserModel

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

Modelo de datos `UserModel` ubicado en `lib/features/auth/domain/models/user_model.dart`.

Campos del modelo:
- `id` → `String` (uuid, PK de `auth.users` y `profiles`)
- `username` → `String` (NOT NULL UNIQUE en DB)
- `avatarUrl` → `String?` (mapea `avatar_url` en DB, nullable)
- `balance` → `int` (default `0`, campo pendiente de añadir por Jacobo en `profiles`)

Métodos implementados:
- Constructor `const UserModel({...})` con `balance` opcional (default 0)
- `factory UserModel.fromJson(Map<String, dynamic> json)` — mapeo completo snake_case→camelCase
- `Map<String, dynamic> toJson()` — serialización de vuelta a snake_case
- `UserModel copyWith({...})` — actualizaciones parciales inmutables
- `==`, `hashCode`, `toString` — igualdad por valor y debug legible

## Conceptos nuevos asimilados

`@immutable` de `package:flutter/foundation.dart` es una anotación de lint (no runtime) que hace que el analizador de Dart alerte si algún campo del objeto no es `final`. Es la forma canónica Flutter de declarar value objects sin depender de librerías como `freezed`. Para un modelo simple sin uniones discriminadas, es la opción correcta y sin sobrecarga de build_runner.

## Decisiones tomadas y por qué

1. **`balance` con default `0` en constructor y `fromJson`:** La tabla `profiles` de Jacobo no tiene este campo todavía (auditoría lo confirma). El modelo lo incluye ya según el esquema acordado en el PDF. Cuando Jacobo añada la columna, el `fromJson` ya lo leerá correctamente sin cambios.

2. **`@immutable` en lugar de `freezed`:** El `pubspec.yaml` no incluye `freezed` ni `json_serializable`. Las reglas del proyecto prohíben añadir dependencias fuera del prompt de la fase activa. La implementación manual de `==`, `hashCode` y `copyWith` es equivalente y sin overhead de generación de código adicional.

3. **`Object.hash()` en lugar de `hashCode` manual:** Dart 2.14+ provee `Object.hash()` como forma idiomática y segura de componer hashcodes. Disponible en Dart SDK 3.x (el proyecto usa `^3.11.4`).

## Bloqueos encontrados y cómo se resolvieron

- **`flutter analyze` no ejecutable desde el entorno CI:** Flutter no está en el PATH del entorno del agente (Windows). Debe ejecutarse manualmente por el desarrollador con `flutter analyze` desde el terminal de VS Code o Android Studio antes del commit. El código es Dart válido sin imports externos no disponibles.
- **Campo `balance` ausente en DB:** Resuelto con `(json['balance'] as int?) ?? 0` — el operador `??` garantiza que si la clave no existe en el JSON de Supabase (que devuelve `null` para columnas inexistentes), el modelo use `0` como valor seguro.

## Cómo probar que esta fase funciona

**Para Guillermo (UI):** Este modelo no tiene provider aún — eso llega en Fase 2.8/2.9. Por ahora puedes instanciar el modelo directamente para verificar la compilación:

```dart
// Prueba rápida en cualquier widget (solo para verificar compilación):
const user = UserModel(
  id: 'test-uuid',
  username: 'Entrenador',
  avatarUrl: null,
  balance: 5000000,
);
print(user); // UserModel(id: test-uuid, username: Entrenador, ...)

// fromJson con datos de Supabase (tabla profiles):
final user2 = UserModel.fromJson({
  'id': 'abc-123',
  'username': 'marcos',
  'avatar_url': null,
  // 'balance' ausente → se usa 0 automáticamente
});

// copyWith:
final user3 = user2.copyWith(balance: 100000000);
```

**Dependencias desbloqueadas con esta fase:**
- Fase 2.8 (AuthRepository) ya puede importar `UserModel` para convertir respuestas de Supabase Auth.
- Fase 2.9 (AuthNotifier) ya puede declarar `AsyncValue<UserModel?>` como tipo de estado.
