# NextGen Fantasy — LaLiga Edition

App móvil de Fantasy Football centrada en LaLiga española con mecánicas avanzadas: mercado dinámico de cláusulas, sistema financiero PvP (sobornos, hipotecas), sobres de táctica semanales y puntuación objetiva basada en datos reales.

**Stack:** Flutter 3.41 · Dart ^3.11.4 · Supabase (PostgreSQL + Auth + Edge Functions) · Riverpod v2 · Clean Architecture

---

## Prerrequisitos

| Herramienta | Versión mínima | Instalación |
|---|---|---|
| Flutter SDK | 3.41 | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Dart SDK | ^3.11.4 | Incluido con Flutter |
| Supabase CLI | última | `npm install -g supabase` |
| Docker Desktop | cualquier | [docker.com/get-started](https://www.docker.com/get-started) — necesario para réplica local |

---

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/GuilermoT/NextGen.git
cd NextGen
```

### 2. Configurar variables de entorno

```bash
cd nextgen_fantasy
cp .env.example .env
```

Edita `.env` con los valores reales (solicítalos al responsable de backend):

```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
API_FOOTBALL_KEY=tu_clave_api_football
```

> El archivo `.env` está en `.gitignore`. **Nunca lo subas al repositorio.**
> Consulta [README_BACKEND.md](README_BACKEND.md) para instrucciones de setup de Supabase.

### 3. Levantar Supabase local (opcional para desarrollo con DB local)

```bash
supabase start
```

Accede al dashboard local en `http://localhost:54323`.

### 4. Instalar dependencias Flutter

```bash
cd nextgen_fantasy
flutter pub get
```

### 5. Generar código Riverpod

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Este paso es obligatorio. Sin él, los providers generados con `@riverpod` (como `authNotifierProvider`) no existen y el proyecto no compila.

### 6. Ejecutar la aplicación

```bash
# Emulador Android o iOS conectado:
flutter run

# Chrome (web):
flutter run -d chrome

# Dispositivo físico específico:
flutter run -d <device-id>
```

---

## Arquitectura del proyecto

El proyecto sigue **Clean Architecture** de forma estricta. Cada feature tiene tres capas separadas:

```
nextgen_fantasy/
├── lib/
│   ├── app/
│   │   ├── app.dart              # Widget raíz — ConsumerWidget con router refresh
│   │   └── router/
│   │       └── app_router.dart   # GoRouter con ShellRoute + redirect guard de auth
│   │
│   ├── core/
│   │   ├── config/               # SupabaseConfig, DioConfig
│   │   ├── providers/            # supabaseClientProvider (singleton Riverpod)
│   │   ├── theme/                # AppColors, AppTheme (Material 3)
│   │   └── constants/
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/repositories/   # AuthRepository — Supabase Auth + OAuth
│   │   │   ├── domain/models/       # UserModel
│   │   │   └── presentation/        # AuthNotifier (Riverpod), LoginScreen, SplashScreen
│   │   ├── market/
│   │   │   └── domain/models/       # TeamModel
│   │   ├── lineup/
│   │   │   └── domain/models/       # PlayerModel (+ enum Position), SquadPlayerModel
│   │   ├── finance/
│   │   │   └── domain/models/       # TransactionModel, BribeModel
│   │   └── gamification/
│   │       └── presentation/        # GamificationHubScreen, SobreTacticaScreen, widgets
│   │
│   └── shared/
│       └── widgets/              # PlayerCard, PointsBadge, RankingRow
│
├── docs/
│   └── memorias/                 # Memorias técnicas por fase (ver abajo)
│
└── .env.example                  # Template de variables de entorno
```

**Regla:** ningún archivo rompe las capas — `presentation/` nunca importa directamente de `data/`, siempre a través de `domain/`.

---

## Variables de entorno

| Variable | Descripción | Dónde obtenerla |
|---|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase | Supabase Dashboard → Settings → API |
| `SUPABASE_ANON_KEY` | Clave pública anon/public | Supabase Dashboard → Settings → API |
| `API_FOOTBALL_KEY` | Clave API-Football para datos reales | Responsable de backend |

Las variables se leen en arranque vía `flutter_dotenv` y se acceden con `dotenv.env['VARIABLE']`.

---

## Estado del desarrollo

| Integración | Estado | Qué verifica |
|---|---|---|
| **INT-1 — Autenticación** | En progreso | Usuario se registra con Google OAuth, perfil creado en Supabase |
| **INT-2 — Equipo e Identidad** | Pendiente | Manager ve su equipo y saldo en HomeScreen |
| **INT-3 — Mercado** | Pendiente | MarketScreen lista jugadores reales con fotos cacheadas |
| **INT-4 — Alineación** | Pendiente | Manager guarda su once, fila en tabla `lineups` verificable |

**Fases del motor de juego completadas:** 2.1–2.9 (modelos de dominio + autenticación completa).
**Fases pendientes:** 2.10–2.15 (repositorios de juego + providers globales Riverpod).

---

## Guía de contribución

### Ramas

| Rama | Propósito |
|---|---|
| `main` | Solo recibe merges revisados. No se commitea directamente. |
| `feature/game-engine-flutter` | Marcos — modelos, repositorios, providers Riverpod |
| `feature/ui-gamification-flutter` | Guillermo — pantallas, widgets, animaciones |
| `feature/backend-supabase` | Jacobo — tablas, RLS, Edge Functions |

### Convención de commits

```
tipo(área): descripción en minúsculas sin punto final
```

Tipos: `feat` · `fix` · `refactor` · `chore` · `docs`

Cada fase cierra con exactamente **dos commits**:
1. `feat(área): descripción del código implementado`
2. `docs(memorias): add technical memory for phase X.X`

### Checklist pre-commit

- [ ] `flutter analyze` devuelve **cero errores**
- [ ] Ninguna clave de API ni credencial en el código fuente
- [ ] `.env` no está incluido en el commit
- [ ] Memoria técnica de la fase escrita y commiteada

---

## Documentación adicional

- [README_BACKEND.md](README_BACKEND.md) — Setup de Supabase, migraciones, seed de datos, Edge Functions
- [docs/memorias/](nextgen_fantasy/docs/memorias/) — Memorias técnicas por fase:
  - [Fase 2.1 — UserModel](nextgen_fantasy/docs/memorias/fase-2.1-game-engine.md)
  - [Fase 2.2 — TeamModel](nextgen_fantasy/docs/memorias/fase-2.2-game-engine.md)
  - [Fase 2.3 — PlayerModel + enum Position](nextgen_fantasy/docs/memorias/fase-2.3-game-engine.md)
  - [Fase 2.4 — SquadPlayerModel](nextgen_fantasy/docs/memorias/fase-2.4-game-engine.md)
  - [Fase 2.5 — TransactionModel](nextgen_fantasy/docs/memorias/fase-2.5-game-engine.md)
  - [Fase 2.6 — BribeModel](nextgen_fantasy/docs/memorias/fase-2.6-game-engine.md)
  - [Fase 2.7 — SupabaseClient Provider + DioConfig](nextgen_fantasy/docs/memorias/fase-2.7-game-engine.md)
  - [Fase 2.8 — AuthRepository](nextgen_fantasy/docs/memorias/fase-2.8-game-engine.md)
  - [Fase 2.9 — AuthNotifier + Redirect Guard](nextgen_fantasy/docs/memorias/fase-2.9-game-engine.md)
