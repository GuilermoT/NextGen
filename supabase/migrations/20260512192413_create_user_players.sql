-- Tabla: user_players
-- Registra los jugadores adquiridos por cada mánager en el mercado de fichajes.

CREATE TABLE public.user_players (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id         UUID NOT NULL REFERENCES public.user_teams(id) ON DELETE CASCADE,
  player_id       UUID NOT NULL REFERENCES public.real_players(id) ON DELETE CASCADE,
  purchase_price  BIGINT NOT NULL,
  acquired_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Un jugador solo puede pertenecer a un equipo a la vez (anti-trampas)
  CONSTRAINT unique_player_ownership UNIQUE (player_id)
);