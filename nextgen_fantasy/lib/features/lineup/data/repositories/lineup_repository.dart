import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/core/constants/app_constants.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/lineup_entry_model.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/lineup_model.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/player_model.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/squad_player_model.dart';

class LineupRepository {
  // ignore: unused_field — reservado para query real cuando existan las tablas `lineups` / `lineup_entries`
  final SupabaseClient _client;

  const LineupRepository(this._client);

  /// Devuelve la alineación guardada del equipo [teamId], o null si aún no existe.
  /// Usa datos mock hasta que Jacobo cree las tablas (fase backend 1.10).
  /// La query real que reemplaza este bloque:
  ///
  ///   final data = await _client
  ///       .from('lineups')
  ///       .select('*, lineup_entries(*, squad_players(*, real_players(*)))')
  ///       .eq('team_id', teamId)
  ///       .maybeSingle();
  ///   if (data == null) return null;
  ///   return LineupModel.fromJson(data);
  Future<LineupModel?> fetchCurrentLineup(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockLineup(teamId);
  }

  /// Guarda la alineación [lineup] del equipo.
  /// Lanza [ArgumentError] si se incumple alguna regla del juego:
  ///   - Exactamente [AppConstants.maxStartersCount] titulares
  ///   - Máximo [AppConstants.maxBenchCount] suplentes
  ///   - Exactamente un capitán, que debe ser titular
  /// La query real que reemplaza el bloque mock:
  ///
  ///   final lineupRow = await _client
  ///       .from('lineups')
  ///       .upsert({'id': lineup.id, 'team_id': lineup.teamId})
  ///       .select('id')
  ///       .single();
  ///   await _client
  ///       .from('lineup_entries')
  ///       .delete()
  ///       .eq('lineup_id', lineupRow['id'] as String);
  ///   await _client.from('lineup_entries').insert(
  ///     lineup.entries
  ///         .map((e) => {...e.toJson(), 'lineup_id': lineupRow['id']})
  ///         .toList(),
  ///   );
  Future<void> saveLineup(LineupModel lineup) async {
    _validate(lineup);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _validate(LineupModel lineup) {
    final starterCount = lineup.starters.length;
    final benchCount = lineup.bench.length;
    final captains = lineup.entries.where((e) => e.isCaptain).toList();

    if (starterCount != AppConstants.maxStartersCount) {
      throw ArgumentError(
        'La alineación debe tener exactamente ${AppConstants.maxStartersCount} '
        'titulares. Recibidos: $starterCount.',
      );
    }
    if (benchCount > AppConstants.maxBenchCount) {
      throw ArgumentError(
        'El banquillo no puede superar ${AppConstants.maxBenchCount} jugadores. '
        'Recibidos: $benchCount.',
      );
    }
    if (captains.length != 1) {
      throw ArgumentError(
        'La alineación debe tener exactamente 1 capitán. '
        'Recibidos: ${captains.length}.',
      );
    }
    if (!captains.first.isStarter) {
      throw ArgumentError('El capitán debe ser titular.');
    }
  }

  // IDs idénticos a SquadRepository._mockSquad para garantizar coherencia entre mocks.
  LineupModel _mockLineup(String teamId) {
    final squad = _mockSquad(teamId);
    const starterIds = {
      'mock-sp-01', // Ter Stegen — POR
      'mock-sp-02', // Carvajal — DEF
      'mock-sp-03', // Rüdiger — DEF
      'mock-sp-04', // Mendy — DEF
      'mock-sp-05', // Jordi Alba — DEF
      'mock-sp-06', // Pedri — MED
      'mock-sp-07', // Bellingham — MED (capitán)
      'mock-sp-08', // Koke — MED
      'mock-sp-10', // Lewandowski — DEL
      'mock-sp-11', // Vinicius — DEL
      'mock-sp-12', // Griezmann — DEL
    };

    final entries = squad.map((sp) {
      return LineupEntryModel(
        id: 'mock-le-${sp.id.split('-').last}',
        squadPlayer: sp,
        isStarter: starterIds.contains(sp.id),
        isCaptain: sp.id == 'mock-sp-07',
      );
    }).toList();

    return LineupModel(
      id: 'mock-lineup-01',
      teamId: teamId,
      entries: entries,
    );
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
