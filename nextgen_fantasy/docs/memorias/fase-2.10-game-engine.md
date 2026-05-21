# Fase 2.10 — TeamRepository con mock datasource y currentTeamProvider

**Desarrollador:** Marcos | **Fecha:** 07/05/2026 | **Rama:** feature/game-engine-flutter

## Qué se implementó

### Archivos nuevos

| Archivo | Responsabilidad |
|---|---|
| `lib/features/market/data/repositories/team_repository.dart` | Repositorio concreto que expone `fetchCurrentTeam` |
| `lib/features/market/presentation/providers/team_provider.dart` | Providers Riverpod: `teamRepositoryProvider` y `currentTeamProvider` |
| `lib/features/market/presentation/providers/team_provider.g.dart` | Generado por `riverpod_generator` (no editar a mano) |

### Archivo modificado

`lib/features/home/presentation/screens/home_screen.dart` — convertido de `StatelessWidget` a `ConsumerWidget` y conectado a `currentTeamProvider`.

---

### `TeamRepository`

```dart
class TeamRepository {
  const TeamRepository(SupabaseClient _client);

  Future<TeamModel?> fetchCurrentTeam(String userId) async { ... }
}
```

| Método | Retorno | Descripción |
|---|---|---|
| `fetchCurrentTeam(userId)` | `Future<TeamModel?>` | Devuelve el equipo del usuario. Usa mock con delay de 300ms. Retorna `null` si el usuario no tiene equipo. |

El mock devuelve un `TeamModel` fijo: nombre `'Los Galácticos FC'`, presupuesto del 45% del presupuesto inicial (`AppConstants.initialTeamBalance * 0.45` = 45.000.000).

El campo `_client` está declarado con directiva `// ignore: unused_field` porque el repositorio lo necesitará en cuanto la tabla `teams` exista. La query real está comentada en el método y es la que hay que descomentar (eliminando el bloque mock) en ese momento.

---

### Providers

```dart
@Riverpod(keepAlive: true)
TeamRepository teamRepository(TeamRepositoryRef ref) { ... }

@Riverpod(keepAlive: true)
Future<TeamModel?> currentTeam(CurrentTeamRef ref) async { ... }
```

`currentTeamProvider` observa `authNotifierProvider`: si el usuario cierra sesión, retorna `null` automáticamente. Si el usuario inicia sesión, recalcula el equipo.

---

### Cambios en `HomeScreen`

- Firma: `extends ConsumerWidget`, `build(BuildContext context, WidgetRef ref)`
- Lee: `ref.watch(currentTeamProvider).valueOrNull` — sin bloquear la UI si está cargando
- Muestra en el header: nombre del equipo (verde) y presupuesto formateado `'45.0M€'` (dorado) cuando el provider tiene datos
- Método privado `_formatBudget(int budget)` formatea el presupuesto en millones con un decimal

## Decisiones tomadas y por qué

1. **Mock inline en el repositorio, no en un datasource separado.** La fase 2.8 (`AuthRepository`) estableció el patrón de repositorio concreto sin capa de datasource separada. Mantener la misma estructura reduce la superficie de código y el número de archivos mientras el backend no existe. Cuando Jacobo entregue la tabla, el swap es una sustitución de 8 líneas dentro del mismo método, sin tocar interfaces ni providers.

2. **`keepAlive: true` en ambos providers.** El equipo del usuario no cambia durante una sesión normal. Marcar ambos providers como keepAlive evita refetches innecesarios al navegar entre pantallas. La invalidación explícita (cuando el presupuesto cambie por fichajes) se gestionará en fases futuras llamando a `ref.invalidate(currentTeamProvider)`.

3. **`valueOrNull` en HomeScreen en lugar de `when(data/loading/error)`.** La pantalla ya tiene una estructura visual completa. Usar `valueOrNull` permite que el layout se renderice inmediatamente con `null` como estado inicial y que los campos de equipo aparezcan en cuanto el provider resuelve, sin mostrar un spinner que rompería la experiencia de la pantalla de inicio.

4. **Delay artificial de 300ms en el mock.** Simula la latencia real de una query a Supabase. Necesario para que los estados de carga en el `AsyncValue` sean verificables durante el desarrollo y para que el equipo de UI pueda diseñar sobre comportamientos reales.

## Conexión con el código existente

- **Fase 2.7** (`supabase_provider.dart`): `teamRepositoryProvider` inyecta `supabaseClientProvider` para construir el `TeamRepository`, mismo patrón que `AuthRepository` en la fase 2.8.
- **Fase 2.8** (`auth_repository.dart`): `TeamRepository` replica exactamente la firma y patrón del repositorio de autenticación.
- **Fase 2.9** (`auth_notifier.dart`): `currentTeamProvider` observa `authNotifierProvider` para asociar el equipo al usuario de sesión. Si el usuario cambia, el equipo se recalcula.
- **Fase 2.2** (`team_model.dart`): `TeamRepository` retorna y construye `TeamModel` directamente.

**TODOs abiertos para fases futuras:**

- Fase 2.11 (`SquadRepository`): expondrá `currentSquadProvider` con la misma firma y lo conectará a `HomeScreen` para reemplazar la lista de jugadores hardcodeada.
- Fase 2.15 (Providers globales): si se centraliza `currentTeamProvider` en un barrel de providers, solo cambia el import en `HomeScreen`.
- Backend fase 1.6 (Jacobo): crear tabla `teams`. Cuando exista, eliminar `_mockTeam()` y descomentar la query real en `fetchCurrentTeam`.

## Cómo probar que esta fase funciona

```bash
# Desde la raíz del proyecto
cd nextgen_fantasy
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

En la app, tras hacer login con Google:
1. La `HomeScreen` debe mostrar en el header, debajo de "Jornada 32", el texto **"Los Galácticos FC"** en verde y **"45.0M€"** en dorado.
2. Si el nombre o el presupuesto no aparecen, verificar que `auth_notifier.g.dart` y `team_provider.g.dart` están generados.

Verificación desde código:

```dart
// En cualquier ConsumerWidget o ConsumerStatefulWidget:
final team = ref.watch(currentTeamProvider).valueOrNull;
print(team?.name);   // 'Los Galácticos FC'
print(team?.budget); // 45000000
```

## Dependencias desbloqueadas

- **Fase 2.11** (SquadRepository): puede ya asumir que `currentTeamProvider` existe y tomar `team.id` para construir la query de plantilla.
- **Guillermo** (UI): puede conectar `MarketScreen`, `LineupScreen` y `FinanceScreen` a `currentTeamProvider` para mostrar el nombre del equipo y el presupuesto en las cabeceras de cada sección.
- **Fase 2.15** (Providers globales): `currentTeamProvider` ya está disponible como punto central de estado del equipo; la fase 2.15 puede re-exportarlo en un barrel si se decide centralizar.

## Bloqueos encontrados y cómo se resolvieron

**Warning `unused_field` en `_client`.** El campo `SupabaseClient _client` fue declarado como preparación para la query real, pero el método mock no lo referencia. `flutter analyze` emite un warning. Resolución: directiva `// ignore: unused_field` con comentario explicando que es intencional. El warning desapareció y `flutter analyze` quedó en 0 errores (2 `info` preexistentes en `app.dart` y `app_router.dart`, no introducidos por esta fase).
