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