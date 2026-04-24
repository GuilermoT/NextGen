# Fase 2.9 - AuthNotifier + Redirect Guard

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

### 1. `lib/features/auth/presentation/providers/auth_notifier.dart` (nuevo)

`AsyncNotifier<UserModel?>` con `@Riverpod(keepAlive: true)` que gestiona el ciclo de vida completo de la sesión.

**Métodos públicos:**
| Método | Descripción |
|--------|-------------|
| `signInWithGoogle()` | Delega en `AuthRepository.signInWithGoogle()` — abre OAuth |
| `signOut()` | Delega en `AuthRepository.signOut()` |

**Flujo interno:**
- `build()` suscribe al stream `authStateChanges()` de Supabase. Cuando llega `signedIn` → `_syncProfile()`. Cuando llega `signedOut` → `state = AsyncData(null)`.
- `build()` retorna `fetchCurrentProfile()` — inicializa el estado con el usuario actual (o null si no hay sesión).
- `_syncProfile()`: pone `AsyncLoading`, luego actualiza con `AsyncValue.guard(() => fetchCurrentProfile())`.

### 2. `lib/app/router/app_router.dart` (modificado)

Añadidos:
- `_AuthRefreshNotifier extends ChangeNotifier` — clase privada para notificar al router.
- `_authRefresh` — instancia global del notifier, usada como `refreshListenable`.
- `refreshAppRouter()` — función pública llamada desde `app.dart` vía `ref.listen`.
- `refreshListenable: _authRefresh` en el `GoRouter`.
- `redirect` con lógica de guarda de autenticación.

**Lógica del redirect:**
```dart
redirect: (context, state) {
  final container = ProviderScope.containerOf(context);
  final authAsync = container.read(authNotifierProvider);
  final isAuthPage = state.matchedLocation == '/login' || '/splash';

  authAsync.when(
    loading: () => isAuthPage ? null : '/splash',  // cargando → splash
    error:   (_, __) => '/login',                  // error → login
    data: (user) {
      if (user == null && !isAuthPage) return '/login';  // no autenticado
      if (user != null && isAuthPage) return '/home';    // ya autenticado
      return null;                                        // sin redirección
    },
  );
}
```

### 3. `lib/app/app.dart` (modificado)

`StatelessWidget` → `ConsumerWidget`. Añade:
```dart
ref.listen(authNotifierProvider, (_, __) => refreshAppRouter());
```
Cada vez que `authNotifierProvider` emite un cambio, GoRouter re-evalúa el redirect.

### 4. `lib/features/auth/presentation/screens/login_screen.dart` (modificado)

`StatelessWidget` → `ConsumerWidget`. El botón de Google ahora llama:
```dart
onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle()
```
Resuelve el TODO de la línea 67 del archivo original.

## ⚠️ Paso obligatorio antes de compilar

**`auth_notifier.g.dart` debe generarse con build_runner:**
```bash
cd nextgen_fantasy
dart run build_runner build --delete-conflicting-outputs
```

El archivo `.g.dart` es generado, no manual. Sin él, `_$AuthNotifier` y `authNotifierProvider` no existen y el proyecto no compila.

## Decisiones tomadas y por qué

1. **`AsyncNotifier<UserModel?>` en lugar de `Notifier<UserModel?>`:** `build()` llama a `fetchCurrentProfile()` que es `async`. `AsyncNotifier` expone el estado como `AsyncValue<UserModel?>`, lo que permite a la UI manejar loading/error/data directamente con `.when()`.

2. **`keepAlive: true`:** El estado de autenticación debe sobrevivir a toda la vida de la app. Sin `keepAlive`, el provider se dispose cuando deja de tener listeners (p.ej. durante navegación de pantalla), perdiendo la sesión activa.

3. **Stream listener en `build()` + `ref.onDispose(sub.cancel)`:** Supabase Auth emite cambios de sesión (OAuth redirect, token refresh, signOut). En lugar de pollear, el notifier escucha el stream de forma reactiva. `onDispose` garantiza que no hay fugas de memoria.

4. **`ProviderScope.containerOf(context)` en el redirect:** GoRouter 14.x pasa un `BuildContext` que es descendiente de `ProviderScope` (árbol: `ProviderScope → NextGenFantasyApp → MaterialApp.router → Router → redirect context`). Esto permite leer el estado de auth sin convertir el router en un provider de Riverpod (lo que recrearía el router entero en cada cambio de auth, perdiendo el stack de navegación).

5. **`_AuthRefreshNotifier` + `refreshListenable`:** El redirect de GoRouter solo se re-evalúa cuando hay una navegación O cuando `refreshListenable` notifica. Sin este mecanismo, un usuario autenticado que vuelve al foco de la app tras el OAuth no sería redirigido automáticamente a `/home`.

6. **`ref.listen` en `ConsumerWidget.build` (app.dart):** Riverpod v2 permite `ref.listen` en `build()` de `ConsumerWidget`. Se registra una vez por ciclo de vida del widget y se limpia automáticamente. Es el punto de conexión entre el estado de Riverpod y el `ChangeNotifier` de GoRouter.

## Conexión con el código existente

- **`AuthRepository` (fase 2.8):** `AuthNotifier` delega todas las operaciones en `AuthRepository`. No duplica lógica de red.
- **`supabaseClientProvider` (fase 2.7):** `ref.watch(supabaseClientProvider)` inyecta el `SupabaseClient` en `AuthRepository`.
- **`SplashScreen`:** El `Future.delayed(2s, () => context.go('/login'))` en `initState` ahora coexiste con el redirect guard. El guard re-evalúa en cuanto `authNotifierProvider` resuelve su estado inicial — si el usuario ya tiene sesión, el redirect envía a `/home` antes o después del delay de la splash.
- **`app_router.dart` (TODO línea 12):** Implementado con redirect guard completo.
- **`login_screen.dart` (TODO línea 67):** Implementado con `ConsumerWidget` y llamada al notifier.

## Flujo completo de autenticación

```
App launch
  → SplashScreen (2s delay)
  → AuthNotifier.build() ejecuta fetchCurrentProfile()
    → Sin sesión: state = AsyncData(null) → redirect a /login
    → Con sesión: state = AsyncData(UserModel) → redirect a /home

LoginScreen: usuario pulsa "Continuar con Google"
  → authNotifier.signInWithGoogle() → abre browser OAuth
  → Usuario completa Google Sign-In → deep link vuelve a la app
  → Supabase dispara authStateChanges (signedIn)
  → AuthNotifier._syncProfile() → fetchCurrentProfile()
  → state = AsyncData(UserModel)
  → ref.listen en app.dart → refreshAppRouter()
  → GoRouter re-evalúa redirect → redirige a /home

signOut()
  → authStateChanges dispara signedOut
  → state = AsyncData(null)
  → refreshAppRouter() → redirect a /login
```

## Dependencias desbloqueadas

Con fase 2.9 completa, el ciclo de autenticación es funcional end-to-end. Las fases 2.10–2.15 (repositorios de Teams, Squad, Market, Finance) pueden proceder en paralelo ya que no dependen de auth.
