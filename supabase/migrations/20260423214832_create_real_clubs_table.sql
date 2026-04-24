CREATE TABLE public.real_clubs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    api_football_team_id INTEGER UNIQUE NOT NULL,
    name TEXT NOT NULL,
    short_name TEXT,
    logo_url TEXT,
    venue_name TEXT,
    season TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Seguridad RLS: Todo el mundo puede leer los equipos, pero solo el sistema (nuestra Edge Function) puede insertar o modificar
ALTER TABLE public.real_clubs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cualquiera puede leer los clubes" 
ON public.real_clubs 
FOR SELECT 
USING (true);