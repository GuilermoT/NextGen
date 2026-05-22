-- RPC: validate_lineup
-- Verifica que los 11 jugadores enviados desde la app pertenecen
-- realmente al equipo del mánager que hace la petición.
-- Devuelve TRUE si la alineación es válida, lanza excepción si no.
--
-- Parámetros:
--   p_team_id    UUID del equipo del mánager
--   p_player_ids Array de 11 UUIDs de jugadores

CREATE OR REPLACE FUNCTION public.validate_lineup(
  p_team_id    UUID,
  p_player_ids UUID[]
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_valid_count INT;
BEGIN
  -- 1. Verificar que el mánager es dueño del equipo
  IF NOT EXISTS (
    SELECT 1 FROM public.user_teams
    WHERE id = p_team_id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'No tienes permiso sobre este equipo';
  END IF;

  -- 2. Verificar que son exactamente 11 jugadores
  IF array_length(p_player_ids, 1) != 11 THEN
    RAISE EXCEPTION 'La alineación debe contener exactamente 11 jugadores. Recibidos: %',
      array_length(p_player_ids, 1);
  END IF;

  -- 3. Contar cuántos de los 11 pertenecen realmente al equipo
  SELECT COUNT(*) INTO v_valid_count
  FROM public.user_players
  WHERE team_id = p_team_id
    AND player_id = ANY(p_player_ids);

  -- 4. Si alguno no pertenece al equipo, rechazar
  IF v_valid_count != 11 THEN
    RAISE EXCEPTION 'Alineación inválida. % jugadores no pertenecen a tu equipo',
      11 - v_valid_count;
  END IF;

  RETURN true;
END;
$$;