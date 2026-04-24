import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

// --- UTILIDAD: Algoritmo de Barajado (Fisher-Yates) ---
// Mezcla el array de forma aleatoria antes de la inserción
function shuffleArray(array: any[]) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

Deno.serve(async (req) => {
  try {
    // 1. Configuración del cliente Supabase con Service Role (permisos totales)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const apiFootballKey = Deno.env.get('API_FOOTBALL_KEY')
    if (!apiFootballKey) throw new Error("API_FOOTBALL_KEY no configurada")

    // 2. Obtener mapeo de equipos (Necesario para las Claves Foráneas)
    // Buscamos la relación entre el ID de la API y el UUID de nuestra base de datos
    const { data: clubs, error: clubsError } = await supabaseClient
      .from('real_clubs')
      .select('id, api_football_team_id')
    
    if (clubsError) throw clubsError
    const clubMap = Object.fromEntries(clubs?.map(c => [c.api_football_team_id, c.id]) || [])

    // 3. Ingesta por Chunks (Páginas de la API)
    // La cuenta gratuita nos limita, así que pedimos las 3 primeras páginas (~60 jugadores)
    let allPlayers: any[] = []
    const pagesToFetch = 3 

    for (let page = 1; page <= pagesToFetch; page++) {
      const response = await fetch(`https://v3.football.api-sports.io/players?league=140&season=2024&page=${page}`, {
        headers: { 
          'x-apisports-key': apiFootballKey, 
          'x-rapidapi-host': 'v3.football.api-sports.io' 
        }
      })
      const resData = await response.json()
      if (resData.response) {
        allPlayers = [...allPlayers, ...resData.response]
      }
    }

    // 4. Mapeo con Algoritmo de Valor de Mercado
    const mappedPlayers = allPlayers.map(item => {
      const stats = item.statistics[0];
      const teamId = stats.team.id;
      const position = stats.games.position;
      const age = item.player.age;

      // --- Lógica de Valor de Mercado ---
      // A) Base por posición
      let baseValue = 1000000; 
      if (position === 'Goalkeeper') baseValue = 2000000;
      if (position === 'Defender')   baseValue = 4000000;
      if (position === 'Midfielder') baseValue = 8000000;
      if (position === 'Attacker')   baseValue = 12000000;

      // B) Multiplicador de Élite (Real Madrid, Barça, Atlético de Madrid)
      const topTeams = [541, 529, 530]; 
      const prestigeMultiplier = topTeams.includes(teamId) ? 3.5 : 1.0;

      // C) Factor Edad (Prime: 22-29 años)
      const ageFactor = (age >= 22 && age <= 29) ? 1.5 : 0.8;

      // D) Variación aleatoria (+/- 10%) para evitar valores idénticos
      const randomVariation = 0.9 + (Math.random() * 0.2);

      const finalMarketValue = Math.floor(baseValue * prestigeMultiplier * ageFactor * randomVariation);

      return {
        api_football_player_id: item.player.id,
        club_id: clubMap[teamId], // UUID relacionado
        name: item.player.name,
        first_name: item.player.firstname,
        last_name: item.player.lastname,
        age: age,
        position: position,
        photo_url: item.player.photo,
        market_value: finalMarketValue
      };
    }).filter(p => p.club_id); // Filtramos si el equipo no está en nuestra DB

    // 5. Barajado (Shuffle) para aleatorizar el mercado inicial
    const shuffledPlayers = shuffleArray(mappedPlayers);

    // 6. Inserción Masiva (Upsert)
    // Si el jugador ya existe (por api_id), actualiza sus datos en lugar de duplicarlos
    const { error: upsertError } = await supabaseClient
      .from('real_players')
      .upsert(shuffledPlayers, { onConflict: 'api_football_player_id' })

    if (upsertError) throw upsertError

    return new Response(JSON.stringify({ 
      success: true,
      message: "¡Jugadores barajados e insertados con lógica de mercado!", 
      count: shuffledPlayers.length 
    }), { 
      headers: { "Content-Type": "application/json" },
      status: 200 
    })

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { 
      headers: { "Content-Type": "application/json" },
      status: 400 
    })
  }
})