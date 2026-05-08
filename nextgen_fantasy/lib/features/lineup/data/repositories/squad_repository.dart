import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/player_model.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/squad_player_model.dart';

class SquadRepository {
  // ignore: unused_field — reservado para query real cuando existan las tablas `squad_players` / `real_players`
  final SupabaseClient _client;

  const SquadRepository(this._client);

  /// Devuelve la plantilla completa del equipo [teamId].
  /// Usa datos mock hasta que Jacobo cree la tabla `squad_players` (fase backend 1.8).
  /// La query real que reemplaza este bloque:
  ///
  ///   final rows = await _client
  ///       .from('squad_players')
  ///       .select('*, real_players(*)')
  ///       .eq('team_id', teamId);
  ///   return rows.map(SquadPlayerModel.fromJson).toList();
  Future<List<SquadPlayerModel>> fetchSquad(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSquad(teamId);
  }

  List<SquadPlayerModel> _mockSquad(String teamId) {
    return [
      _make('mock-sp-01', teamId, 'Ter Stegen', Position.goalkeeper, 8000000),
      _make('mock-sp-02', teamId, 'Carvajal', Position.defender, 18000000),
      _make('mock-sp-03', teamId, 'Rüdiger', Position.defender, 22000000),
      _make('mock-sp-04', teamId, 'Mendy', Position.defender, 14000000),
      _make('mock-sp-05', teamId, 'Jordi Alba', Position.defender, 10000000),
      _make('mock-sp-06', teamId, 'Pedri', Position.midfielder, 35000000),
      _make('mock-sp-07', teamId, 'Bellingham', Position.midfielder, 42000000),
      _make('mock-sp-08', teamId, 'Koke', Position.midfielder, 14000000),
      _make('mock-sp-09', teamId, 'De Paul', Position.midfielder, 18000000),
      _make('mock-sp-10', teamId, 'Lewandowski', Position.forward, 28000000),
      _make('mock-sp-11', teamId, 'Vinicius', Position.forward, 45000000),
      _make('mock-sp-12', teamId, 'Griezmann', Position.forward, 32000000),
      _make('mock-sp-13', teamId, 'Oblak', Position.goalkeeper, 20000000),
      _make('mock-sp-14', teamId, 'Gavi', Position.midfielder, 30000000),
      _make('mock-sp-15', teamId, 'Morata', Position.forward, 15000000),
    ];
  }

  SquadPlayerModel _make(
    String id,
    String teamId,
    String name,
    Position position,
    int marketValue,
  ) {
    return SquadPlayerModel(
      id: id,
      teamId: teamId,
      player: PlayerModel(
        id: 'mock-player-${id.split('-').last}',
        apiFootballPlayerId: int.parse(id.split('-').last),
        name: name,
        position: position,
        marketValue: marketValue,
        status: 'active',
      ),
      clause: (marketValue * 1.5).round(),
      isOnMarket: false,
    );
  }
}
