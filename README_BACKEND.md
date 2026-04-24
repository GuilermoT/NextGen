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

Si `supabase start` falla, verifica que Docker esté en ejecución.

---

## Despliegue en Producción

Para hacer el primer deploy y enviar los cambios del esquema a Supabase, ejecuta:

```bash
supabase db push
```


---

## Ingesta de Datos (Seed)

Para poblar tu base de datos local con los equipos de LaLiga:

1. Pide la clave de la API al responsable de backend y ponla en tu archivo `.env`: 
`API_FOOTBALL_KEY=tu_clave`
2. Levanta las funciones locales (desde NextGen\nextgen_fantasy):
```bash
supabase functions serve --env-file .env
```
3. Poblar Equipos (Paso Obligatorio 1): Abre esta URL en tu navegador para insertar los 20 clubes:
```bash
http://127.0.0.1:54321/functions/v1/seed-clubs
```
4. Poblar Jugadores (Paso Obligatorio 2): Una vez insertados los equipos, abre esta URL para insertar los jugadores con lógica de mercado y barajado:
```bash
http://127.0.0.1:54321/functions/v1/seed-players
```

**Nota: Es fundamental seguir este orden (1º Equipos, 2º Jugadores). Si realizas un supabase db reset, deberás ejecutar ambos enlaces de nuevo para recuperar los datos.**