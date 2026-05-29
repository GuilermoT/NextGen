-- RPC: buy_player
-- Ejecuta un fichaje de forma atómica. Si cualquier validación falla,
-- toda la transacción se revierte automáticamente.
--
-- Parámetros:
--   p_team_id   UUID del equipo del mánager
--   p_player_id UUID del jugador a fichar

CREATE OR REPLACE FUNCTION public.buy_player(
  p_team_id   UUID,
  p_player_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_budget        BIGINT;
  v_market_value  BIGINT;
  v_player_count  INT;
  v_position      TEXT;
  v_position_count INT;
  v_max_allowed   INT;
BEGIN
  -- 1. Verificar que el mánager es dueño del equipo
  IF NOT EXISTS (
    SELECT 1 FROM public.user_teams
    WHERE id = p_team_id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'No tienes permiso sobre este equipo';
  END IF;

  -- 2. Leer presupuesto actual
  SELECT budget INTO v_budget
  FROM public.user_teams
  WHERE id = p_team_id;

  -- 3. Leer valor de mercado y posición del jugador
  SELECT market_value, position INTO v_market_value, v_position
  FROM public.real_players
  WHERE id = p_player_id;

  IF v_market_value IS NULL THEN
    RAISE EXCEPTION 'Jugador no encontrado';
  END IF;

  -- 4. Verificar fondos suficientes
  IF v_budget < v_market_value THEN
    RAISE EXCEPTION 'Presupuesto insuficiente. Disponible: %, Necesario: %',
      v_budget, v_market_value;
  END IF;

  -- 5. Verificar límite total de plantilla (máx. 25)
  SELECT COUNT(*) INTO v_player_count
  FROM public.user_players
  WHERE team_id = p_team_id;

  IF v_player_count >= 25 THEN
    RAISE EXCEPTION 'Plantilla completa. Máximo 25 jugadores permitidos';
  END IF;

  -- 6. Verificar límite por posición
  v_max_allowed := CASE v_position
    WHEN 'Goalkeeper' THEN 3
    WHEN 'Defender'   THEN 8
    WHEN 'Midfielder' THEN 8
    WHEN 'Attacker'   THEN 6
    ELSE 25
  END;

  SELECT COUNT(*) INTO v_position_count
  FROM public.user_players up
  JOIN public.real_players rp ON rp.id = up.player_id
  WHERE up.team_id = p_team_id
    AND rp.position = v_position;

  IF v_position_count >= v_max_allowed THEN
    RAISE EXCEPTION 'Límite de posición alcanzado. Máximo % jugadores en posición %',
      v_max_allowed, v_position;
  END IF;

  -- 7. Insertar jugador en la plantilla
  INSERT INTO public.user_players (team_id, player_id, purchase_price)
  VALUES (p_team_id, p_player_id, v_market_value);

  -- 8. Descontar presupuesto
  UPDATE public.user_teams
  SET budget = budget - v_market_value
  WHERE id = p_team_id;

END;
$$;