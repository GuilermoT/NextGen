ALTER TABLE public.user_players ENABLE ROW LEVEL SECURITY;

-- Lectura pública para usuarios autenticados.
-- Necesario para rankings, plantillas de rivales y pantallas de mercado.
-- NOTA: purchase_price visible por todos en esta fase. Refinar con View en iteración futura.
CREATE POLICY "Authenticated users can view all team players"
  ON public.user_players
  FOR SELECT
  TO authenticated
  USING (true);