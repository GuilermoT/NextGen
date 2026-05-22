-- Función: fluctuate_market_values
-- Actualiza el market_value de todos los jugadores aplicando una variación
-- aleatoria de +/- 10% cada 24 horas. Simula la dinámica real de un mercado.

CREATE OR REPLACE FUNCTION public.fluctuate_market_values()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.real_players
  SET market_value = GREATEST(
    -- Mínimo 500.000 para evitar jugadores sin valor
    500000,
    ROUND(market_value * (0.90 + (random() * 0.20)))
  );
END;
$$;

-- Cron Job: ejecuta la fluctuación cada 24 horas
SELECT cron.schedule(
  'fluctuate-market-daily',   -- nombre del job
  '0 3 * * *',                -- cada día a las 3:00 AM
  'SELECT public.fluctuate_market_values();'
);