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