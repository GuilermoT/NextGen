# Fase 2.8 - AuthRepository

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

`lib/features/auth/data/repositories/auth_repository.dart` (nuevo)

Repositorio que encapsula toda la comunicación con Supabase Auth y la tabla `profiles`.

### Métodos

| Método | Retorno | Descripción |
|--------|---------|-------------|
| `signInWithGoogle()` | `Future<void>` | Abre el flujo OAuth de Google vía browser |
| `signOut()` | `Future<void>` | Cierra sesión del usuario actual |
| `authStateChanges()` | `Stream<AuthState>` | Stream de cambios de sesión (escuchado por AuthNotifier) |
| `fetchCurrentProfile()` | `Future<UserModel?>` | Lee la fila del usuario autenticado en `profiles`, null si no hay sesión |

## Decisiones tomadas y por qué

1. **No se implementa `signIn(email, password)`:** La `LoginScreen` tiene el botón de email con `onPressed: null` (deshabilitado por diseño). Solo el botón de Google tiene TODO para conectar. Añadir un método sin consumidor sería YAGNI.

2. **`signInWithGoogle()` retorna `Future<void>` (no `UserModel`):** El flujo OAuth de Google abre un browser externo. El resultado de la autenticación llega de forma asíncrona vía `authStateChanges()`, no como retorno directo de la función. El `AuthNotifier` (fase 2.9) escucha ese stream y llama a `fetchCurrentProfile()` cuando recibe evento `signedIn`.

3. **`fetchCurrentProfile()` consulta la tabla `profiles` (no `auth.users`):** `UserModel` necesita `username`, que viene del trigger `handle_new_user` que escribe en `profiles` al registrarse. `_client.auth.currentUser` solo da metadatos OAuth de Google, no el `username` canónico de la app. La query usa `.single()` que lanza excepción si no hay fila — garantiza que no retornamos un `UserModel` parcial si el trigger no ha corrido.

4. **Tabla `profiles` no tiene columna `balance`:** La migración `20260417111327_initial_schema.sql` define solo `id`, `username`, `avatar_url`, `created_at`. `UserModel.fromJson` ya tiene `balance: (json['balance'] as int?) ?? 0` como fallback — cuando Jacobo añada la columna, el modelo la leerá automáticamente.

5. **`AuthRepository` recibe `SupabaseClient` en constructor:** Sigue el patrón de inyección de dependencias. El `AuthNotifier` (fase 2.9) construirá el repositorio leyendo `ref.watch(supabaseClientProvider)`.

## Conexión con el código existente

- **`user_model.dart`:** `fetchCurrentProfile()` construye `UserModel` via `UserModel.fromJson()`. Mapping: `id → id`, `username → username`, `avatar_url → avatarUrl`, `balance → balance (default 0)`.
- **`supabase_provider.dart` (fase 2.7):** `AuthNotifier` (fase 2.9) leerá `ref.watch(supabaseClientProvider)` para pasar `SupabaseClient` al constructor de `AuthRepository`.
- **`login_screen.dart` (línea 67):** El TODO espera `ref.read(authNotifierProvider.notifier).signInWithGoogle()`. El `AuthNotifier` delegará en `AuthRepository.signInWithGoogle()`.
- **`app_router.dart` (línea 12):** El TODO de redirect guard en fase 2.9 consultará el estado del `AuthNotifier` para decidir si redirigir a `/login` o a `/home`.
- **`splash_screen.dart`:** Actualmente navega a `/login` tras 2 segundos. En fase 2.9, el redirect guard en el router reemplazará esa lógica.
- **Trigger `handle_new_user`** (migración `20260417123548`): Crea automáticamente la fila en `profiles` al registrarse. `fetchCurrentProfile()` asume que la fila existe cuando hay sesión activa.

## Cómo probar que esta fase funciona

```dart
// En un ConsumerWidget (cuando AuthNotifier esté implementado en 2.9):
final repo = AuthRepository(ref.watch(supabaseClientProvider));

// Verificar que el stream emite eventos:
repo.authStateChanges().listen((event) {
  print('Auth event: ${event.event}'); // AuthChangeEvent.signedIn / signedOut
});

// Verificar fetch de perfil (requiere sesión activa):
final user = await repo.fetchCurrentProfile();
print(user?.username); // nombre del usuario desde tabla profiles
print(user?.balance);  // 0 hasta que Jacobo añada columna balance
```

## Dependencias desbloqueadas

- **Fase 2.9 (AuthNotifier):** Puede construir un `@Riverpod(keepAlive: true)` que escuche `authStateChanges()` y exponga `UserModel?` al árbol de widgets.
- **`LoginScreen` (Guillermo):** Podrá conectar el botón de Google al `authNotifierProvider.notifier.signInWithGoogle()`.
- **`app_router.dart`:** Podrá añadir el redirect guard basado en el estado del `AuthNotifier`.
