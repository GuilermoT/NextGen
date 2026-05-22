-- pgTAP: Tests de restricciones pasivas del motor de mercado
-- Verifica que las constraints de la base de datos bloquean
-- operaciones maliciosas independientemente del frontend.

BEGIN;
SELECT plan(3);

-- -------------------------
-- Test 1.1: budget_non_negative
-- Un UPDATE que deje el saldo en negativo debe ser rechazado.
-- -------------------------
SELECT throws_ok(
  $$
    UPDATE public.user_teams
    SET budget = -100
    WHERE id = (SELECT id FROM public.user_teams LIMIT 1)
  $$,
  '23514',  -- código de error PostgreSQL para CHECK violation
  'new row for relation "user_teams" violates check constraint "budget_non_negative"',
  'Test 1.1 PASS: budget negativo bloqueado por CHECK constraint'
);

-- -------------------------
-- Test 1.2: unique_user_team
-- Un usuario no puede tener dos equipos simultáneamente.
-- -------------------------
SELECT throws_ok(
  $$
    INSERT INTO public.user_teams (user_id, team_name)
    SELECT user_id, 'Equipo Duplicado'
    FROM public.user_teams
    LIMIT 1
  $$,
  '23505',  -- código de error PostgreSQL para UNIQUE violation
  NULL,
  'Test 1.2 PASS: segundo equipo bloqueado por UNIQUE constraint'
);

-- -------------------------
-- Test 1.3: unique_player_ownership
-- El mismo jugador no puede pertenecer a dos equipos distintos.
-- -------------------------
SELECT throws_ok(
  $$
    INSERT INTO public.user_players (team_id, player_id, purchase_price)
    SELECT
      (SELECT id FROM public.user_teams ORDER BY created_at DESC LIMIT 1),
      player_id,
      purchase_price
    FROM public.user_players
    LIMIT 1
  $$,
  '23505',
  NULL,
  'Test 1.3 PASS: jugador duplicado bloqueado por UNIQUE constraint'
);

SELECT * FROM finish();
ROLLBACK;