CREATE TABLE public.real_players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    api_football_player_id INTEGER UNIQUE NOT NULL,
    club_id UUID REFERENCES public.real_clubs(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    age INTEGER,
    position TEXT, 
    photo_url TEXT,
    market_value INTEGER DEFAULT 1000000, 
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Seguridad: Cualquiera puede ver jugadores, nadie puede borrarlos por error
ALTER TABLE public.real_players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de jugadores" 
ON public.real_players FOR SELECT 
USING (true);