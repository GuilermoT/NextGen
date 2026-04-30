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

---

### Reglas que NUNCA se rompen
1. `flutter analyze` debe pasar con cero errores antes de cualquier commit.
2. Ninguna clave de API, URL de Supabase ni credencial va en el código fuente.
3. El archivo `.env` nunca se commitea. Solo `.env.example`.
4. No se instala ninguna dependencia que no esté especificada en el prompt de la fase activa.
5. No se escribe lógica de negocio hasta que la fase lo indique explícitamente.
6. Si `flutter analyze` devuelve warnings (no errores), se anotan en el mensaje del commit.
7. **Cada fase cierra con DOS commits: uno de código y uno de documentación.** No se puede mergear ni avanzar a la siguiente fase sin la memoria técnica commiteada.
8. **Los commits nunca llevan firma de Claude** (`Co-Authored-By: Claude Sonnet...`). El historial de git refleja únicamente al desarrollador humano como autor.

---

### Convención de commits (obligatoria)
Formato: `tipo(área): descripción en minúsculas`
Tipos válidos: feat · fix · refactor · chore · docs

Cada fase produce exactamente dos commits en este orden:
1. `feat(área): descripción de lo que se construyó` — el código de la fase
2. `docs(memorias): add technical memory for phase X.X` — la memoria técnica

Ejemplos:
- `feat(auth): add AuthRepository with google oauth and profile fetch`
- `docs(memorias): add technical memory for phase 2.8`
- `feat(lineup): add LineupRepository with saveLineup and getLineup`
- `docs(memorias): add technical memory for phase 2.12`

---

### Documentación técnica obligatoria por fase

Al cerrar **cada fase**, antes del segundo commit, el agente crea el archivo:

```
nextgen_fantasy/docs/memorias/fase-X.X-[area].md
```

El área sigue el patrón de las memorias existentes: `game-engine`, `backend`, `ui`.

#### Formato obligatorio (respetar exactamente)

El formato está basado en las memorias existentes en `nextgen_fantasy/docs/memorias/`.
Las secciones marcadas con **[OBLIGATORIA]** deben aparecer siempre.
Las marcadas con **[CONTEXTUAL]** se incluyen solo si hay contenido relevante.

```markdown
# Fase X.X — [Título de la fase]

**Desarrollador:** Marcos | **Fecha:** DD/MM/AAAA | **Rama:** feature/game-engine-flutter

## Qué se implementó  [OBLIGATORIA]

[Lista de archivos creados o modificados con su ruta completa.
Para cada archivo: métodos/clases añadidos, firma pública, comportamiento clave.
Usar tablas Markdown cuando hay varios métodos.]

## Decisiones tomadas y por qué  [OBLIGATORIA]

[Lista numerada. Cada entrada: decisión concreta → justificación técnica.
Incluir alternativas descartadas cuando la elección no sea obvia.]

## Conexión con el código existente  [OBLIGATORIA]

[Qué fases anteriores usa este código (con nombre de archivo y línea si aplica).
Qué TODOs o puntos de extensión deja abiertos para fases futuras.]

## Cómo probar que esta fase funciona  [OBLIGATORIA]

[Instrucciones ejecutables para que cualquier dev verifique el resultado.
Incluir código Dart de ejemplo cuando sea posible.]

## Dependencias desbloqueadas  [OBLIGATORIA]

[Qué fases siguientes quedan habilitadas con esta fase completa.
Qué puede hacer ahora Guillermo o Jacobo que antes no podía.]

## Conceptos nuevos asimilados  [CONTEXTUAL]

[Solo si hay conceptos técnicos no triviales que merezcan explicación para el equipo.]

## Bloqueos encontrados y cómo se resolvieron  [CONTEXTUAL]

[Solo si hubo problemas reales durante la implementación. Demuestra trabajo real.]
```

#### Reglas de estilo para las memorias (no negociables)

- El encabezado `**Desarrollador:** ... | **Fecha:** ... | **Rama:** ...` va en una sola línea.
- Los bloques de código Dart usan triple backtick con `dart`. Los de bash usan `bash`.
- Las tablas de métodos usan el formato `| Método | Retorno | Descripción |`.
- No se escriben secciones vacías. Si una sección CONTEXTUAL no aplica, se omite.
- El tono es técnico y directo. Sin introducción genérica, sin frases de relleno.
- Máximo nivel de detalle en "Qué se implementó": un dev externo debe poder entender la API pública sin leer el código.
- "Decisiones tomadas" debe responder al "por qué X y no Y". Mínimo 2 decisiones por fase.
- "Cómo probar" debe incluir instrucciones ejecutables, no solo descripción abstracta.

---

### Checklist universal pre-commit (ambos commits)
Antes de cualquier commit verificar:
- [ ] `flutter analyze` devuelve cero errores (ramas Flutter)
- [ ] Ninguna clave de API, URL de Supabase o credencial en el código fuente
- [ ] El archivo `.env` no está incluido en el commit
- [ ] El mensaje de commit sigue el formato convenido
- [ ] Para el segundo commit: la memoria técnica está en `nextgen_fantasy/docs/memorias/fase-X.X-[area].md`
- [ ] Los nombres de tablas y campos coinciden con el esquema acordado

---

### Estado actual del proyecto (2026-04-30)

**Fases completadas por Marcos (9/15):**
- 2.1 UserModel · 2.2 TeamModel · 2.3 PlayerModel+Position · 2.4 SquadPlayerModel
- 2.5 TransactionModel · 2.6 BribeModel · 2.7 SupabaseClient+DioConfig
- 2.8 AuthRepository · 2.9 AuthNotifier+RedirectGuard

**Próximas fases (Semana 4-5):**
- 2.10 TeamRepository · 2.11 SquadRepository · 2.12 LineupRepository
- 2.13 MarketRepository · 2.14 FinanceRepository · 2.15 Providers globales Riverpod

**Integraciones pendientes:** INT-2 (Equipo), INT-3 (Mercado), INT-4 (Alineación)
