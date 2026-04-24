# Fase 2.7 - supabaseClientProvider + DioConfig

**Desarrollador:** Marcos | **Fecha:** 2026-04-24 | **Rama:** feature/game-engine-flutter

## Qué se implementó

### 1. `lib/core/providers/supabase_provider.dart` (nuevo)

Provider Riverpod que expone el `SupabaseClient` singleton:

```dart
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
```

### 2. `lib/core/config/dio_config.dart` (reemplazado stub)

Cliente HTTP Dio con tres capas de configuración:

- **`BaseOptions`:** `baseUrl = SupabaseConfig.url + '/rest/v1'`, timeouts de 10s
- **`_AuthInterceptor`:** inyecta `apikey` en todas las peticiones y `Authorization: Bearer <token>` cuando hay sesión activa
- **`LogInterceptor`:** solo en `kDebugMode`, registra request/response completos

`flutter analyze`: **0 issues** tras los cambios.

## Decisiones tomadas y por qué

1. **`supabaseClientProvider` como `Provider` simple (no `@riverpod`):** `Supabase.instance.client` es un singleton ya inicializado en `main.dart` antes de `runApp()`. No hay asincronía ni estado que gestionar — un `Provider<SupabaseClient>` es suficiente y no necesita generación de código con `build_runner`. Los Notifiers de fases 2.8+ recibirán este provider via `ref.watch(supabaseClientProvider)`.

2. **`apikey` siempre presente, `Authorization` solo con sesión:** PostgREST de Supabase requiere `apikey` en todas las llamadas (incluso las públicas como `SELECT` en `real_players`). El `Authorization: Bearer` solo aplica a operaciones autenticadas (INSERT, UPDATE con RLS). Separar ambas cabeceras en el interceptor cubre ambos casos sin duplicar lógica en cada repositorio.

3. **`_AuthInterceptor` como clase privada en `dio_config.dart`:** El interceptor solo tiene sentido en el contexto de este cliente HTTP de Supabase. No es reutilizable fuera de `DioConfig`, por lo que es privado al archivo.

4. **`LogInterceptor` de Dio (no interceptor custom):** Dio incluye `LogInterceptor` built-in con opciones `requestBody: true, responseBody: true`. Evita código boilerplate de logging sin añadir dependencias.

5. **`createClient()` público (no `_createClient()` privado):** El stub original tenía el método privado. Los repositorios (fases 2.8–2.14) necesitan `DioConfig.createClient()` para obtener el cliente configurado. Se hace público manteniendo el constructor privado `DioConfig._()` para evitar instanciación de la clase.

## Conexión con el código existente

- **`main.dart`:** `Supabase.initialize()` se ejecuta antes de `runApp()`. El `supabaseClientProvider` puede leer `Supabase.instance.client` de forma segura desde cualquier provider.
- **`supabase_config.dart`:** `DioConfig` importa `SupabaseConfig` para leer `url` y `anonKey` desde `.env`. No duplica la lógica de lectura de variables de entorno.
- **Repositorios (fases 2.8–2.14):** Recibirán `SupabaseClient` via `ref.watch(supabaseClientProvider)` para llamadas directas a Supabase. `DioConfig.createClient()` se usará opcionalmente para endpoints REST que necesiten los interceptores.

## Cómo probar que esta fase funciona

```dart
// En cualquier ConsumerWidget o provider:
final client = ref.watch(supabaseClientProvider);
// client es el SupabaseClient inicializado, listo para queries

// DioConfig (usado en repositorios):
final dio = DioConfig.createClient();
// dio tiene baseUrl, apikey y Auth configurados automáticamente
// En modo debug, cada petición se loguea en consola
```
