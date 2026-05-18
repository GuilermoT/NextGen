-- Garantiza a nivel de motor que el presupuesto nunca puede ser negativo.
-- Esta restricción actúa como red de seguridad independientemente del frontend.
ALTER TABLE public.user_teams
  ADD CONSTRAINT budget_non_negative CHECK (budget >= 0);