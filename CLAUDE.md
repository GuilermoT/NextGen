# NextGen Fantasy — LaLiga Edition
## Memoria de Proyecto para Claude Code

### ¿Qué es este proyecto?
Aplicación móvil y web de Fantasy Football centrada en LaLiga española.
Frontend: Flutter (Dart). Backend: Supabase (PostgreSQL).
Repositorio: https://github.com/GuilermoT/NextGen

### Arquitectura
Clean Architecture obligatoria en todo el código Flutter:
- `data/` → llamadas a Supabase, caché local
- `domain/` → reglas de negocio del juego
- `presentation/` → pantallas y widgets

Carpetas de funcionalidades en `lib/features/`:
- `auth/` → registro y login
- `market/` → mercado de fichajes y cláusulas
- `lineup/` → gestión de alineaciones
- `finance/` → saldo, impuestos, sobornos, hipotecas
- `gamification/` → sobres de táctica, castigo al colista

### Ramas del repositorio
- `main` → solo recibe merges revisados y verificados
- `feature/ui-gamification-flutter` → UI, widgets, pantallas, animaciones
- `feature/game-engine-flutter` → estado (Riverpod), repositorios, modelos
- `feature/backend-supabase` → tablas, RLS, Auth, Edge Functions

### Sistema de fases
El proyecto avanza en fases atómicas. Cada fase tiene una sola responsabilidad.
Las fases 0.A a 0.H son secuenciales (un desarrollador). A partir de la Fase 1, trabajo en paralelo.

### Reglas que NUNCA se rompen
1. `flutter analyze` debe pasar con cero errores antes de cualquier commit.
2. Ninguna clave de API, URL de Supabase ni credencial va en el código fuente.
3. El archivo `.env` nunca se commitea. Solo `.env.example`.
4. No se instala ninguna dependencia que no esté especificada en el prompt de la fase activa.
5. No se escribe lógica de negocio hasta que la fase lo indique explícitamente.
6. Si `flutter analyze` devuelve warnings (no errores), se anotan en el mensaje del commit.

### Convención de commits (obligatoria)
Formato: `tipo(área): descripción en minúsculas`
Tipos válidos: feat · fix · refactor · chore · docs
Ejemplos:
- chore(setup): initialize flutter project base scaffold
- feat(auth): add google oauth sign-in repository
- fix(lineup): correct captain flag assignment