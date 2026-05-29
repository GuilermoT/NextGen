-- pgTAP: Tests de lógica activa del motor de mercado
-- Simula sesión de usuario real mediante set_config para que auth.uid()
-- devuelva el UUID del usuario de prueba en todos los tests.

BEGIN;
SELECT plan(11);

-- Simular sesión del usuario de prueba
SELECT set_config(
  'request.jwt.claims',
  '{"sub": "4e271d05-3338-4023-882e-24515060f6ce"}',
  true
);

-- -------------------------
-- TEST 2.1A: Compra exitosa
-- Esperado: jugador en user_players y budget reducido
-- -------------------------
SELECT lives_ok(
  $$
    SELECT public.buy_player(
      'ff3de1fb-1e2c-46ca-87ea-62997cd96016',
      'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305'
    )
  $$,
  'Test 2.1A PASS: compra exitosa de P.Guantes (2.978.135)'
);

SELECT is(
  (SELECT COUNT(*)::INT FROM public.user_players
   WHERE team_id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016'
   AND player_id = 'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305'),
  1,
  'Test 2.1A PASS: jugador insertado correctamente en user_players'
);

SELECT is(
  (SELECT budget FROM public.user_teams
   WHERE id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016'),
  (50000000 - 2978135)::BIGINT,
  'Test 2.1A PASS: budget descontado correctamente'
);

-- -------------------------
-- TEST 2.1B: Compra con presupuesto insuficiente
-- Bajamos el budget a 100 para forzar el fallo
-- -------------------------
UPDATE public.user_teams
SET budget = 100
WHERE id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016';

SELECT throws_ok(
  $$
    SELECT public.buy_player(
      'ff3de1fb-1e2c-46ca-87ea-62997cd96016',
      'ceafd216-ff14-4d8c-8569-0084ab4e9132'
    )
  $$,
  'P0001',
  NULL,
  'Test 2.1B PASS: compra bloqueada por presupuesto insuficiente'
);

-- -------------------------
-- TEST 2.2A: Venta exitosa
-- Restauramos budget y vendemos el jugador comprado en 2.1A
-- -------------------------
UPDATE public.user_teams
SET budget = 47021865::BIGINT
WHERE id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016';

SELECT lives_ok(
  $$
    SELECT public.sell_player(
      'ff3de1fb-1e2c-46ca-87ea-62997cd96016',
      'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305'
    )
  $$,
  'Test 2.2A PASS: venta exitosa de P.Guantes'
);

SELECT is(
  (SELECT COUNT(*)::INT FROM public.user_players
   WHERE team_id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016'
   AND player_id = 'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305'),
  0,
  'Test 2.2A PASS: jugador eliminado correctamente de user_players'
);

-- -------------------------
-- TEST 2.3B: Alineación con menos de 11 jugadores
-- Esperado: excepción "exactamente 11 jugadores"
-- -------------------------
SELECT throws_ok(
  $$
    SELECT public.validate_lineup(
      'ff3de1fb-1e2c-46ca-87ea-62997cd96016',
      ARRAY[
        '71112617-3d49-428b-8636-3ce380debe28',
        '1c932edd-5c79-4d4c-a745-cefd76327be4',
        '797c2a61-c11a-41a7-8ff4-cbab83593972'
      ]::UUID[]
    )
  $$,
  'P0001',
  NULL,
  'Test 2.3B PASS: alineación incompleta bloqueada'
);

-- -------------------------
-- TEST 2.1C: Compra con presupuesto EXACTO
-- Esperado: debe funcionar, no sobrar ni un euro
-- -------------------------
UPDATE public.user_teams
SET budget = 2978135::BIGINT
WHERE id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016';

SELECT lives_ok(
  $$
    SELECT public.buy_player(
      'ff3de1fb-1e2c-46ca-87ea-62997cd96016',
      'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305'
    )
  $$,
  'Test 2.1C PASS: compra exitosa con presupuesto exacto'
);

SELECT is(
  (SELECT budget FROM public.user_teams
   WHERE id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016'),
  0::BIGINT,
  'Test 2.1C PASS: budget queda en exactamente 0 tras compra ajustada'
);

-- Limpiamos para los siguientes tests
DELETE FROM public.user_players
WHERE team_id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016';

UPDATE public.user_teams
SET budget = 50000000::BIGINT
WHERE id = 'ff3de1fb-1e2c-46ca-87ea-62997cd96016';

-- -------------------------
-- TEST 2.3C: Alineación con 12 jugadores
-- Esperado: excepción "exactamente 11 jugadores"
-- -------------------------
SELECT throws_ok(
  $$
    SELECT public.validate_lineup(
      'ff3de1fb-1e2c-46ca-87ea-62997cd96016',
      ARRAY[
        '71112617-3d49-428b-8636-3ce380debe28',
        '1c932edd-5c79-4d4c-a745-cefd76327be4',
        '797c2a61-c11a-41a7-8ff4-cbab83593972',
        'ceafd216-ff14-4d8c-8569-0084ab4e9132',
        'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305',
        '71112617-3d49-428b-8636-3ce380debe28',
        '1c932edd-5c79-4d4c-a745-cefd76327be4',
        '797c2a61-c11a-41a7-8ff4-cbab83593972',
        'ceafd216-ff14-4d8c-8569-0084ab4e9132',
        'ba4f4fdd-2cc9-41a2-8c7b-b2ed2ad9c305',
        '71112617-3d49-428b-8636-3ce380debe28',
        '1c932edd-5c79-4d4c-a745-cefd76327be4'
      ]::UUID[]
    )
  $$,
  'P0001',
  NULL,
  'Test 2.3C PASS: alineación con 12 jugadores bloqueada'
);

-- -------------------------
-- TEST 2.4: Fluctuación con valor mínimo (suelo de 500.000)
-- Esperado: ningún jugador queda por debajo de 500.000
-- -------------------------
UPDATE public.real_players SET market_value = 500000::BIGINT;
SELECT public.fluctuate_market_values();

SELECT ok(
  (SELECT MIN(market_value) FROM public.real_players) >= 500000,
  'Test 2.4 PASS: ningún jugador cae por debajo del suelo de 500.000'
);

SELECT * FROM finish();
ROLLBACK;