# Memoria Técnica 2: Integración de API-Football y Secretos

## 1. Seguridad de Credenciales
* [cite_start]Se ha evitado el almacenamiento de credenciales en el código fuente[cite: 42].
* [cite_start]Se ha configurado la variable de entorno `API_FOOTBALL_KEY` en un archivo `.env` local, el cual está excluido del control de versiones[cite: 43].
* [cite_start]Se ha creado una plantilla `.env.example` para facilitar la configuración al resto del equipo[cite: 44].

## 2. Implementación de la Entidad `real_clubs`
* [cite_start]Se creó una nueva migración SQL para la tabla `real_clubs`[cite: 48].
* [cite_start]Se optó por el uso de UUID como clave primaria para mantener la consistencia con el resto del sistema, y se mapeó el `api_football_team_id` como clave única (`UNIQUE`) para evitar la inserción de equipos duplicados[cite: 49].
* [cite_start]Se detectó que, tras crear tablas mediante migraciones locales, es obligatorio ejecutar `supabase db reset` para refrescar la memoria caché de la API (PostgREST)[cite: 52].

## 3. Desarrollo Serverless (`seed-clubs`)
* [cite_start]Se desarrolló una función en TypeScript bajo el entorno Deno para automatizar la extracción de datos desde el endpoint `/teams` de API-Football[cite: 54].
* [cite_start]Para permitir ejecuciones de seed locales directamente desde el navegador, se configuró la directiva `verify_jwt = false` en el archivo `config.toml`[cite: 55].
* [cite_start]Durante las pruebas se descubrió que el plan gratuito de la API restringe el acceso a la temporada futura (2025)[cite: 56].
* [cite_start]Se resolvió aplicando un pivote en la lógica de ingesta para apuntar a la temporada 2024 (LaLiga ID 140)[cite: 57, 58].