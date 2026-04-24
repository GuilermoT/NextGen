import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

Deno.serve(async (req) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const apiFootballKey = Deno.env.get('API_FOOTBALL_KEY')

    if (!apiFootballKey) {
      throw new Error("No se ha encontrado la API_FOOTBALL_KEY")
    }

    const response = await fetch('https://v3.football.api-sports.io/teams?league=140&season=2024', {
      headers: {
        'x-apisports-key': apiFootballKey,
        'x-rapidapi-host': 'v3.football.api-sports.io'
      }
    })

    const data = await response.json()

    // MEJORA 1: Atrapar errores en formato objeto (que es como los manda API-Football en la v3)
    if (data.errors && Object.keys(data.errors).length > 0) {
      return new Response(JSON.stringify({ error_api_oculto: data.errors }), { status: 400 })
    }

    // MEJORA 2: Si el array viene vacío, imprimir todo el JSON para investigar
    if (!data.response || data.response.length === 0) {
      return new Response(JSON.stringify({ 
        alerta: "La API se conectó pero no devolvió equipos.", 
        respuesta_cruda: data 
      }), { status: 400 })
    }

    const clubs = data.response.map((item: any) => ({
      api_football_team_id: item.team.id,
      name: item.team.name,
      short_name: item.team.code ?? item.team.name,
      logo_url: item.team.logo,
      venue_name: item.venue.name,
      season: '2024-2025'
    }))

    const { data: insertedData, error } = await supabaseClient
      .from('real_clubs')
      .upsert(clubs, { onConflict: 'api_football_team_id' })
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify({ message: "¡Éxito! Equipos insertados", count: clubs.length }),
      { headers: { "Content-Type": "application/json" }, status: 200 },
    )

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
})