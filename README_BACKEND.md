# NextGen Backend — Supabase

Este documento describe la infraestructura de base de datos y la lógica serverless del proyecto utilizando Supabase.

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- Supabase CLI
- Docker (en ejecución)

---

## Entorno Local

Para levantar el entorno local de Supabase (basado en Docker), ejecuta:

```bash
supabase start
```

**Si `supabase start` falla, verifica que Docker esté en ejecución.**

---

## Despliegue en Producción

Para hacer el primer deploy y enviar los cambios del esquema a Supabase, ejecuta:

```bash
supabase db push
```

---

## Ingesta de Datos (Seed)

Para poblar tu base de datos local con los equipos de LaLiga:

### 1. Configuración de API Key

Regístrate en `dashboard.api-football.com`, obtén tu API Key gratuita y añádela en tu archivo `.env`:

```env
API_FOOTBALL_KEY=tu_clave
```

---

### 2. Interruptor de Entorno (Mocking)

Para evitar agotar la cuota de la API en desarrollo, añade esto en tu archivo `.env`:

```env
USE_MOCK_API=true
```

Si necesitas probar con datos reales, cambia el valor a:

```env
USE_MOCK_API=false
```

---

### 3. Levantar las funciones locales

Desde `NextGen\nextgen_fantasy`, ejecuta:

```bash
supabase functions serve --env-file .env
```

---

### 4. Poblar Equipos (Paso Obligatorio 1)

Abre esta URL en tu navegador para insertar los 20 clubes:

```bash
http://127.0.0.1:54321/functions/v1/seed-clubs
```

---

### 5. Poblar Jugadores (Paso Obligatorio 2)

Una vez insertados los equipos, abre esta URL para insertar los jugadores con lógica de mercado y barajado:

```bash
http://127.0.0.1:54321/functions/v1/seed-players
```


**Nota: Es fundamental seguir este orden (1º Equipos, 2º Jugadores). Si realizas un supabase db reset, deberás ejecutar ambos enlaces de nuevo para recuperar los datos.**



---

## Contratos de RPCs del Motor de Mercado

Referencia rápida para el equipo de Flutter. Todas las funciones se invocan
mediante `supabase.rpc()` y requieren usuario autenticado.

---

### `buy_player`
Ficha un jugador de forma atómica. Valida saldo, límite de plantilla y
disponibilidad del jugador en una única transacción.

| Parámetro | Tipo | Descripción |
|---|---|---|
| `p_team_id` | UUID | ID del equipo del mánager |
| `p_player_id` | UUID | ID del jugador a fichar |

**Retorna:** `void`

**Errores esperados:**
- `No tienes permiso sobre este equipo` — el equipo no pertenece al usuario autenticado
- `Jugador no encontrado` — el UUID no existe en `real_players`
- `Presupuesto insuficiente. Disponible: X, Necesario: Y` — saldo menor que `market_value`
- `Plantilla completa. Máximo 25 jugadores permitidos` — el equipo ya tiene 25 jugadores
- `Límite de posición alcanzado. Máximo X jugadores en posición Y` — cupo de esa posición completo

**Ejemplo Flutter:**
```dart
await supabase.rpc('buy_player', params: {
  'p_team_id': teamId,
  'p_player_id': playerId,
});
```

---

### `sell_player`
Vende un jugador de forma atómica. Devuelve el valor de mercado actual
al presupuesto del equipo.

| Parámetro | Tipo | Descripción |
|---|---|---|
| `p_team_id` | UUID | ID del equipo del mánager |
| `p_player_id` | UUID | ID del jugador a vender |

**Retorna:** `void`

**Errores esperados:**
- `No tienes permiso sobre este equipo` — el equipo no pertenece al usuario autenticado
- `Este jugador no pertenece a tu equipo` — el jugador no está en la plantilla

**Ejemplo Flutter:**
```dart
await supabase.rpc('sell_player', params: {
  'p_team_id': teamId,
  'p_player_id': playerId,
});
```

---

### `validate_lineup`
Verifica que los 11 jugadores enviados pertenecen al equipo del mánager
autenticado antes de guardar la alineación.

| Parámetro | Tipo | Descripción |
|---|---|---|
| `p_team_id` | UUID | ID del equipo del mánager |
| `p_player_ids` | UUID[] | Array con exactamente 11 UUIDs de jugadores |

**Retorna:** `boolean` — `true` si la alineación es válida

**Errores esperados:**
- `No tienes permiso sobre este equipo` — el equipo no pertenece al usuario autenticado
- `La alineación debe contener exactamente 11 jugadores. Recibidos: X` — array incorrecto
- `Alineación inválida. X jugadores no pertenecen a tu equipo` — jugadores ajenos

**Ejemplo Flutter:**
```dart
final result = await supabase.rpc('validate_lineup', params: {
  'p_team_id': teamId,
  'p_player_ids': listOf11PlayerIds,
});
```