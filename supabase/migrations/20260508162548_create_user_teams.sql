-- Tabla para los equipos de los usuarios
CREATE TABLE IF NOT EXISTS public.user_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    team_name TEXT NOT NULL,
    budget BIGINT NOT NULL DEFAULT 50000000, -- 50 millones de presupuesto inicial
    created_at TIMESTAMPTZ DEFAULT now(),
    
    -- Un usuario solo puede tener un equipo (por ahora)
    CONSTRAINT unique_user_team UNIQUE (user_id)
);

-- Activar RLS
ALTER TABLE public.user_teams ENABLE ROW LEVEL SECURITY;

-- Políticas de Seguridad
-- 1. Cualquiera puede ver los equipos de los demás (para el ranking)
CREATE POLICY "Cualquiera puede ver equipos" 
ON public.user_teams FOR SELECT 
USING (true);

-- 2. Solo el dueño puede editar su nombre de equipo
CREATE POLICY "Solo el dueño puede editar su equipo" 
ON public.user_teams FOR UPDATE 
USING (auth.uid() = user_id);

-- 3. El sistema crea el equipo (o el usuario al registrarse)
CREATE POLICY "Los usuarios pueden crear su propio equipo" 
ON public.user_teams FOR INSERT 
WITH CHECK (auth.uid() = user_id);