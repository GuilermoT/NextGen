# Memoria Técnica 6: Motor de Mercado - Entidad de Equipos y Presupuestos

## 1. Diseño de Arquitectura (Fase 3)
Para iniciar la lógica transaccional del mercado de fichajes, se ha desplegado la entidad `public.user_teams`. Esta tabla actúa como la "cartera" y el contenedor principal de los activos de cada mánager en el juego.

## 2. Decisiones de Modelado de Datos
* **Integridad Referencial:** El campo `user_id` enlaza directamente con `public.profiles(id)` mediante una restricción `ON DELETE CASCADE`. Si un mánager elimina su cuenta, su equipo y presupuesto se purgan automáticamente del ecosistema.
* **Control de Duplicidades (Anti-Trampas):** Se ha aplicado un `CONSTRAINT unique_user_team UNIQUE (user_id)`. Las pruebas de integración en Supabase Studio validaron que la base de datos rechaza a nivel de motor (PostgreSQL) cualquier intento de crear un segundo equipo para un mismo mánager.
* **Inyección Económica:** El campo `budget` (tipo `BIGINT` para prevenir desbordamientos futuros) inicializa a cada nuevo equipo con un valor por defecto de 50.000.000. Este será el punto de validación clave para las futuras transacciones de jugadores.

## 3. Matriz de Seguridad (RLS)
Se han habilitado las políticas de Row Level Security (RLS) con el siguiente enfoque:
* **Lectura (`FOR SELECT`):** Pública (`true`). Es necesario que todos los usuarios puedan ver el presupuesto y nombre de los equipos rivales para fomentar la competitividad y habilitar futuras tablas de clasificación (Rankings).
* **Escritura (`FOR UPDATE`):** Restringida (`auth.uid() = user_id`). Garantiza que solo el propietario legítimo pueda modificar el `team_name` de su equipo.