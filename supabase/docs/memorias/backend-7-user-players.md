# Memoria Técnica 7: Entidad de Plantillas (user_players)

## 1. Propósito
Registra los jugadores adquiridos por cada mánager en el mercado de fichajes,
actuando como tabla de unión entre `user_teams` y `real_players`.

## 2. Decisiones de Modelado
* **Doble FK con CASCADE:** `team_id` apunta a `user_teams` y `player_id` a
  `real_players`. Si se elimina el equipo o el jugador maestro, el registro
  se purga automáticamente.
* **Control anti-trampas:** El constraint `UNIQUE (player_id)` garantiza a
  nivel de motor que un mismo jugador real no puede pertenecer a dos equipos
  simultáneamente. No es validación de frontend, es una restricción de base
  de datos.
* **`purchase_price` (BIGINT):** Se almacena el precio en el momento de la
  compra. El valor de mercado puede fluctuar después, pero el precio pagado
  queda registrado para histórico y estadísticas.
* **`acquired_at`:** Timestamp automático para auditoría y futuros rankings
  de actividad de mercado.