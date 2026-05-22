-- RPC: sell_player
-- Ejecuta una venta de forma atómica. Devuelve el valor de mercado
-- actual del jugador al presupuesto del equipo.
--
-- Parámetros:
--   p_team_id   UUID del equipo del mánager
--   p_player_id UUID del jugador a vender

CREATE OR REPLACE FUNCTION public.sell_player(
  p_team_id   UUID,
  p_player_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_market_value BIGINT;
BEGIN
  -- 1. Verificar que el mánager es dueño del equipo
  IF NOT EXISTS (
    SELECT 1 FROM public.user_teams
    WHERE id = p_team_id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'No tienes permiso sobre este equipo';
  END IF;

  -- 2. Verificar que el jugador pertenece a este equipo
  IF NOT EXISTS (
    SELECT 1 FROM public.user_players
    WHERE team_id = p_team_id AND player_id = p_player_id
  ) THEN
    RAISE EXCEPTION 'Este jugador no pertenece a tu equipo';
  END IF;

  -- 3. Leer valor de mercado actual del jugador
  SELECT market_value INTO v_market_value
  FROM public.real_players
  WHERE id = p_player_id;

  -- 4. Eliminar jugador de la plantilla
  DELETE FROM public.user_players
  WHERE team_id = p_team_id AND player_id = p_player_id;

  -- 5. Ingresar valor de mercado actual al presupuesto
  UPDATE public.user_teams
  SET budget = budget + v_market_value
  WHERE id = p_team_id;

END;
$$;