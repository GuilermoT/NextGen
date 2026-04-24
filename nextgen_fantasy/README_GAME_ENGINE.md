# Game Engine Flutter — Rama `feature/game-engine-flutter`

**Dev:** Marcos | **Última actualización:** 2026-04-24

Documenta todo lo implementado en esta rama: modelos de dominio, infraestructura de red, repositorio de auth, y el sistema de estado con Riverpod. Lee la sección que te corresponde al final para saber si algo de esto requiere cambios en tu código.

---

## Qué hay en esta rama

La rama `feature/game-engine-flutter` contiene la capa de **estado y lógica de negocio** de la app. No toca UI directamente (excepto conectar providers a pantallas ya existentes). El código se organiza siguiendo Clean Architecture:

```
lib/
├── core/
│   ├── config/
│   │   └── dio_config.dart          ← cliente HTTP configurado (auth interceptor)
│   └── providers/
│       └── supabase_provider.dart   ← SupabaseClient como provider Riverpod
├── features/
│   ├── auth/
│   │   ├── data/repositories/
│   │   │   └── auth_repository.dart ← Google OAuth + fetch de profile
│   │   ├── domain/models/
│   │   │   └── user_model.dart      ← modelo UserModel
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_notifier.dart ← AsyncNotifier<UserModel?> keepAlive
│   │       └── screens/
│   │           └── login_screen.dart  ← MODIFICADO: botón Google conectado
│   ├── market/
│   │   └── domain/models/
│   │       └── team_model.dart      ← modelo TeamModel
│   ├── lineup/
│   │   └── domain/models/
│   │       ├── player_model.dart    ← modelo PlayerModel + enum Position
│   │       └── squad_player_model.dart ← modelo SquadPlayerModel (con JOIN)
│   └── finance/
│       └── domain/models/
│           ├── transaction_model.dart ← modelo TransactionModel + enum TransactionType
│           └── bribe_model.dart       ← modelo BribeModel + enum BribeStatus
└── app/
    ├── app.dart                     ← MODIFICADO: ConsumerWidget con router refresh
    └── router/
        └── app_router.dart          ← MODIFICADO: redirect guard de autenticación
```

---

## ⚠️ Paso obligatorio antes de compilar

`auth_notifier.dart` usa generación de código Riverpod. Sin este paso el proyecto **no compila**:

```bash
cd nextgen_fantasy
dart run build_runner build --delete-conflicting-outputs
```

Esto genera `lib/features/auth/presentation/providers/auth_notifier.g.dart`. No edites ese archivo — es auto-generado y se sobreescribe con cada build.

---

## Modelos de dominio (fases 2.1–2.6)

Todos los modelos siguen el mismo patrón: `@immutable`, constructor `const`, `fromJson` / `toJson`, `copyWith`, `==` / `hashCode` por valor.

### UserModel
**Archivo:** `lib/features/auth/domain/models/user_model.dart`  
**Tabla DB:** `public.profiles`

```dart
import 'package:nextgen_fantasy/features/auth/domain/models/user_model.dart';

// fromJson — mapeo directo desde tabla profiles:
final user = UserModel.fromJson({
  'id': 'uuid',
  'username': 'marcos',
  'avatar_url': null,   // nullable
  // 'balance' no existe aún en la tabla → usa 0 por defecto
});

// Campos disponibles:
user.id          // String  — uuid de auth.users / profiles
user.username    // String
user.avatarUrl   // String? — foto de perfil
user.balance     // int     — default 0 hasta que Jacobo añada la columna
```

---

### TeamModel
**Archivo:** `lib/features/market/domain/models/team_model.dart`  
**Tabla DB:** `public.teams` (pendiente — Jacobo fase 1.6)

```dart
import 'package:nextgen_fantasy/features/market/domain/models/team_model.dart';

final team = TeamModel.fromJson({
  'id': 'uuid',
  'league_id': 'uuid',
  'user_id': 'uuid',
  'name': 'Los Galácticos FC',
  'budget': 100000000,
});

team.budget   // int — presupuesto disponible del equipo fantasy
team.userId   // String — FK hacia profiles.id
```

---

### PlayerModel + enum Position
**Archivo:** `lib/features/lineup/domain/models/player_model.dart`  
**Tabla DB:** `public.real_players` ← **esta tabla ya existe y tiene ~60 jugadores reales**

```dart
import 'package:nextgen_fantasy/features/lineup/domain/models/player_model.dart';

// fromJson desde real_players (Supabase):
final player = PlayerModel.fromJson(supabaseRow);

player.name         // String  — nombre completo
player.position     // Position enum
player.marketValue  // int     — valor en euros
player.photoUrl     // String? — URL foto desde API-Football
player.status       // String  — 'active' por defecto
```

**Mapeo DB ↔ enum `Position`** — la DB usa nombres en inglés con mayúscula:

| DB (`real_players.position`) | Dart (`Position`) |
|------------------------------|-------------------|
| `'Goalkeeper'`               | `Position.goalkeeper` |
| `'Defender'`                 | `Position.defender`   |
| `'Midfielder'`               | `Position.midfielder` |
| `'Attacker'`                 | `Position.forward`    |

> **Para Guillermo:** `PlayerCard` usa `'POR'`, `'DEF'`, `'MED'`, `'DEL'`. La conversión de `Position` a esas abreviaciones la haré yo en el provider de alineación (fase 2.15). No cambies `PlayerCard`.

---

### SquadPlayerModel
**Archivo:** `lib/features/lineup/domain/models/squad_player_model.dart`  
**Tabla DB:** `public.squad_players` (pendiente — Jacobo fase 1.8)

Este modelo contiene un `PlayerModel` anidado. Para que `fromJson` funcione, la query de Supabase **debe** incluir el JOIN:

```dart
// En el repositorio (lo implemento yo):
final rows = await client
    .from('squad_players')
    .select('*, real_players(*)');   // ← JOIN obligatorio

// El fromJson espera 'real_players' como clave del objeto anidado:
final squadPlayer = SquadPlayerModel.fromJson(row);

squadPlayer.player.name      // PlayerModel completo
squadPlayer.clause           // int — valor de la cláusula
squadPlayer.isOnMarket       // bool

// toJson emite la FK, NO el objeto anidado (para escribir en DB):
squadPlayer.toJson()['real_player_id']  // String — el id del jugador
```

---

### TransactionModel + enum TransactionType
**Archivo:** `lib/features/finance/domain/models/transaction_model.dart`  
**Tabla DB:** `public.transactions` (pendiente — Jacobo fase 1.12)

```dart
import 'package:nextgen_fantasy/features/finance/domain/models/transaction_model.dart';

final tx = TransactionModel.fromJson(supabaseRow);

tx.type       // TransactionType enum
tx.amount     // int — positivo (ingreso) o negativo (gasto)
tx.createdAt  // DateTime — parseado desde ISO 8601
```

**Valores válidos de `type` en DB** — Jacobo debe usar exactamente estos strings en la columna:

| DB (`type`) | Dart (`TransactionType`) |
|-------------|--------------------------|
| `'signing'`    | `TransactionType.signing`   |
| `'sale'`       | `TransactionType.sale`      |
| `'clause_tax'` | `TransactionType.clauseTax` |
| `'bribe'`      | `TransactionType.bribe`     |
| `'penalty'`    | `TransactionType.penalty`   |

---

### BribeModel + enum BribeStatus
**Archivo:** `lib/features/finance/domain/models/bribe_model.dart`  
**Tabla DB:** `public.bribes` (pendiente — Jacobo fase 1.13)

```dart
import 'package:nextgen_fantasy/features/finance/domain/models/bribe_model.dart';

final bribe = BribeModel.fromJson(supabaseRow);

bribe.senderTeamId    // String UUID
bribe.receiverTeamId  // String UUID
bribe.targetPlayerId  // String UUID — FK a real_players, no objeto anidado
bribe.amount          // int
bribe.status          // BribeStatus enum
bribe.jornadaId       // String UUID
```

**Valores válidos de `status` en DB:**

| DB (`status`)  | Dart (`BribeStatus`)    |
|----------------|-------------------------|
| `'pending'`    | `BribeStatus.pending`   |
| `'accepted'`   | `BribeStatus.accepted`  |
| `'rejected'`   | `BribeStatus.rejected`  |

---

## Infraestructura (fase 2.7)

### supabaseClientProvider
**Archivo:** `lib/core/providers/supabase_provider.dart`

Provider Riverpod que expone el singleton de Supabase. Todos los repositorios lo reciben en su constructor. No necesitas tocarlo.

```dart
import 'package:nextgen_fantasy/core/providers/supabase_provider.dart';

// En cualquier provider o notifier:
final client = ref.watch(supabaseClientProvider);
```

### DioConfig
**Archivo:** `lib/core/config/dio_config.dart`

Cliente HTTP con tres capas: `baseUrl` apuntando a `SupabaseConfig.url/rest/v1`, interceptor de auth (inyecta `apikey` siempre + `Authorization: Bearer` cuando hay sesión), y logging en modo debug. No necesitas tocarlo.

```dart
import 'package:nextgen_fantasy/core/config/dio_config.dart';

// Si un repositorio necesita Dio (en lugar del cliente Supabase directo):
final dio = DioConfig.createClient();
```

---

## Auth — repositorio y estado (fases 2.8–2.9)

### AuthRepository
**Archivo:** `lib/features/auth/data/repositories/auth_repository.dart`

No lo uses directamente desde la UI. `AuthNotifier` es el único consumidor.

| Método | Tipo retorno | Descripción |
|--------|-------------|-------------|
| `signInWithGoogle()` | `Future<void>` | Abre OAuth de Google |
| `signOut()` | `Future<void>` | Cierra sesión |
| `authStateChanges()` | `Stream<AuthState>` | Stream de eventos de sesión |
| `fetchCurrentProfile()` | `Future<UserModel?>` | Lee `profiles` para el usuario actual |

### AuthNotifier — el provider que usáis en la UI
**Archivo:** `lib/features/auth/presentation/providers/auth_notifier.dart`  
**Provider generado:** `authNotifierProvider` (tipo `AsyncValue<UserModel?>`)

Este es el punto de entrada para todo lo relacionado con autenticación en la UI:

```dart
import 'package:nextgen_fantasy/features/auth/presentation/providers/auth_notifier.dart';

// ─── Leer el estado de auth en cualquier ConsumerWidget ───────────────────
ref.watch(authNotifierProvider).when(
  loading: () => const CircularProgressIndicator(),
  error:   (e, _) => Text('Error: $e'),
  data:    (user) => user != null
      ? Text('Hola, ${user.username}')
      : const Text('No autenticado'),
);

// ─── Leer el usuario actual sin escuchar cambios ──────────────────────────
final user = ref.read(authNotifierProvider).value;  // UserModel? — puede ser null

// ─── Llamar acciones (botones, etc.) ─────────────────────────────────────
ref.read(authNotifierProvider.notifier).signInWithGoogle();
ref.read(authNotifierProvider.notifier).signOut();
```

**El provider es `keepAlive: true`** — el estado de sesión nunca se pierde mientras la app está viva, aunque navegues entre pantallas.

---

### Redirect guard en app_router.dart

**Archivo:** `lib/app/router/app_router.dart` — ya implementado, no requiere cambios.

El router redirige automáticamente según el estado de `authNotifierProvider`:

| Estado | En ruta protegida (`/home/*`) | En ruta de auth (`/login`, `/splash`) |
|--------|-------------------------------|---------------------------------------|
| `AsyncLoading` | → `/splash` | se queda |
| `AsyncError` | → `/login` | se queda |
| `user == null` | → `/login` | se queda |
| `user != null` | se queda | → `/home` |

**No tienes que hacer nada** para que la redirección funcione — ocurre automáticamente cuando el estado de `authNotifierProvider` cambia.

---

## Flujo de autenticación completo

```
App launch
├── SplashScreen se muestra (2s)
├── AuthNotifier.build() corre: fetchCurrentProfile()
│   ├── Sin sesión → state = AsyncData(null) → redirect a /login
│   └── Con sesión → state = AsyncData(UserModel) → redirect a /home
│
LoginScreen: usuario pulsa "Continuar con Google"
├── authNotifier.signInWithGoogle() → abre browser OAuth
├── Usuario completa Google Sign-In → deep link vuelve a la app
├── Supabase dispara authStateChanges (signedIn)
├── AuthNotifier._syncProfile() → fetchCurrentProfile()
├── state = AsyncData(UserModel)
└── GoRouter re-evalúa redirect → navega a /home automáticamente

signOut()
├── authStateChanges dispara signedOut
├── state = AsyncData(null)
└── GoRouter re-evalúa redirect → navega a /login automáticamente
```

---

## Lo que ya está conectado (no requiere más trabajo de UI)

- **`LoginScreen`** — convertida a `ConsumerWidget`, botón Google conectado a `authNotifierProvider.notifier.signInWithGoogle()`.
- **`app_router.dart`** — redirect guard implementado, protege todas las rutas `/home/*`.
- **`app.dart`** — convertida a `ConsumerWidget`, escucha cambios de auth para refrescar el router.

---

## Para Guillermo — cómo conectar tus pantallas a mis providers

Las pantallas que tienen `TODO Dev 2` esperando mis providers:

### HomeScreen (`lib/features/home/presentation/screens/home_screen.dart`)

El TODO en línea 41 dice `conectar a currentTeamProvider`. Cuando termine la fase 2.15 (`game_providers.dart`), tendrás disponible `currentTeamProvider`. Para usarlo:

```dart
// Convierte HomeScreen a ConsumerWidget:
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(currentTeamProvider);  // disponible en fase 2.15
    // team es AsyncValue<TeamModel?>
  }
}
```

### LineupScreen y MarketScreen

Mismo patrón. Cuando esté la fase 2.15 expongo `squadProvider` (lista de `SquadPlayerModel`) y `marketPlayersProvider` (lista de `PlayerModel` en venta).

### PlayerCard — conversión Position → abreviatura

`PlayerCard` recibe `String position` con abreviaturas (`'POR'`, `'DEF'`, `'MED'`, `'DEL'`). Cuando conectes la alineación real, necesitarás convertir `Position` enum a esas abreviaturas. Hazlo así en el widget padre:

```dart
String _positionLabel(Position p) => switch (p) {
  Position.goalkeeper  => 'POR',
  Position.defender    => 'DEF',
  Position.midfielder  => 'MED',
  Position.forward     => 'DEL',
};

// Al llamar PlayerCard:
PlayerCard(
  playerName: squadPlayer.player.name,
  position:   _positionLabel(squadPlayer.player.position),  // ← conversión aquí
  points:     0.0,
  imageUrl:   squadPlayer.player.photoUrl,
);
```

### Leer datos del usuario autenticado en cualquier pantalla

```dart
// Dentro de cualquier ConsumerWidget:
final userAsync = ref.watch(authNotifierProvider);
final user = userAsync.value;  // UserModel? — null si no autenticado

// Mostrar el username en el header de HomeScreen:
Text('Hola, ${user?.username ?? 'Entrenador'} 👋')

// Cerrar sesión (botón de perfil, etc.):
ref.read(authNotifierProvider.notifier).signOut();
```

---

## Para Jacobo — lo que el código espera de las tablas

### `public.profiles` ← **ya existe** (migración 20260417111327)

Necesita una columna más:

```sql
ALTER TABLE public.profiles
ADD COLUMN balance integer NOT NULL DEFAULT 0;
```

`UserModel.fromJson` ya tiene `(json['balance'] as int?) ?? 0`, así que hasta que añadas la columna la app funciona con balance 0. Cuando la añadas, el modelo la leerá automáticamente.

---

### `public.teams` ← pendiente (tu fase 1.6)

`TeamModel.fromJson` espera estas columnas exactamente:

```sql
CREATE TABLE public.teams (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id   uuid NOT NULL REFERENCES leagues(id),
    user_id     uuid NOT NULL REFERENCES profiles(id),
    name        text NOT NULL,
    budget      integer NOT NULL   -- TeamModel.budget lo castea como int, NO nullable
);
```

---

### `public.squad_players` ← pendiente (tu fase 1.8)

`SquadPlayerModel.fromJson` espera este esquema + que el repositorio haga el JOIN con `real_players`:

```sql
CREATE TABLE public.squad_players (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id         uuid NOT NULL REFERENCES teams(id),
    real_player_id  uuid NOT NULL REFERENCES real_players(id),
    clause          integer NOT NULL,
    is_on_market    boolean NOT NULL DEFAULT false
);
```

---

### `public.transactions` ← pendiente (tu fase 1.12)

`TransactionModel.fromJson` espera este esquema. La columna `type` debe contener solo los valores de la tabla de arriba:

```sql
CREATE TABLE public.transactions (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id     uuid NOT NULL REFERENCES teams(id),
    type        text NOT NULL,
    -- valores válidos: 'signing', 'sale', 'clause_tax', 'bribe', 'penalty'
    amount      integer NOT NULL,
    description text NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- Recomendado: constraint para evitar tipos inválidos
ALTER TABLE public.transactions
ADD CONSTRAINT transactions_type_check
CHECK (type IN ('signing', 'sale', 'clause_tax', 'bribe', 'penalty'));
```

---

### `public.bribes` ← pendiente (tu fase 1.13)

`BribeModel.fromJson` espera este esquema:

```sql
CREATE TABLE public.bribes (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_team_id    uuid NOT NULL REFERENCES teams(id),
    receiver_team_id  uuid NOT NULL REFERENCES teams(id),
    target_player_id  uuid NOT NULL REFERENCES real_players(id),
    amount            integer NOT NULL,
    status            text NOT NULL DEFAULT 'pending',
    -- valores válidos: 'pending', 'accepted', 'rejected'
    jornada_id        uuid NOT NULL
);

ALTER TABLE public.bribes
ADD CONSTRAINT bribes_status_check
CHECK (status IN ('pending', 'accepted', 'rejected'));
```

---

## Commits de esta rama (sobre main)

```
34896eb feat(state): add AuthNotifier with keepAlive and google oauth flow
0f9393c feat(auth): add AuthRepository with google oauth and profile fetch
5cf1ffc feat(http): implement DioConfig with auth interceptor and debug logging
adc3728 feat(state): add supabaseClientProvider as Riverpod singleton provider
ef6710f feat(finance): add BribeModel domain model with BribeStatus enum
b1b439d feat(finance): add TransactionModel domain model with TransactionType enum
c42e82b feat(lineup): add SquadPlayerModel with nested PlayerModel join pattern
5365fb1 feat(lineup): add PlayerModel domain model with Position enum
c84fb60 feat(market): add TeamModel immutable domain model
7866662 feat(auth): add UserModel immutable domain model
```

---

## Documentación técnica detallada

Cada fase tiene su propia memoria técnica en `nextgen_fantasy/docs/memorias/`:

- [`fase-2.1`](docs/memorias/fase-2.1-game-engine.md) — UserModel
- [`fase-2.2`](docs/memorias/fase-2.2-game-engine.md) — TeamModel
- [`fase-2.3`](docs/memorias/fase-2.3-game-engine.md) — PlayerModel + enum Position
- [`fase-2.4`](docs/memorias/fase-2.4-game-engine.md) — SquadPlayerModel
- [`fase-2.5`](docs/memorias/fase-2.5-game-engine.md) — TransactionModel
- [`fase-2.6`](docs/memorias/fase-2.6-game-engine.md) — BribeModel
- [`fase-2.7`](docs/memorias/fase-2.7-game-engine.md) — supabaseClientProvider + DioConfig
- [`fase-2.8`](docs/memorias/fase-2.8-game-engine.md) — AuthRepository
- [`fase-2.9`](docs/memorias/fase-2.9-game-engine.md) — AuthNotifier + redirect guard
