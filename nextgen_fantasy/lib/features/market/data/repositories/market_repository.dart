import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/core/constants/app_constants.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/player_model.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/squad_player_model.dart';
import 'package:nextgen_fantasy/features/market/domain/models/team_model.dart';

class MarketRepository {
  // ignore: unused_field — reservado para queries reales cuando existan las tablas `squad_players` / `real_players` / `teams`
  final SupabaseClient _client;

  const MarketRepository(this._client);

  /// Devuelve los jugadores en venta de todos los equipos de la liga [leagueId].
  /// Usa datos mock hasta que Jacobo cree la tabla `squad_players` (fase backend 1.8).
  /// La query real que reemplaza este bloque:
  ///
  ///   final rows = await _client
  ///       .from('squad_players')
  ///       .select('*, real_players(*), teams!inner(league_id)')
  ///       .eq('is_on_market', true)
  ///       .eq('teams.league_id', leagueId);
  ///   return rows.map(SquadPlayerModel.fromJson).toList();
  Future<List<SquadPlayerModel>> fetchMarketListings(String leagueId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMarketListings(leagueId);
  }

  /// Devuelve jugadores reales no asignados a ningún equipo de la liga [leagueId].
  /// Usa datos mock hasta que Jacobo cree la tabla `real_players` (fase backend 1.5).
  /// La query real que reemplaza este bloque:
  ///
  ///   final teamRows = await _client
  ///       .from('teams')
  ///       .select('id')
  ///       .eq('league_id', leagueId);
  ///   final teamIds = teamRows.map((r) => r['id'] as String).toList();
  ///   final claimedIds = await _client
  ///       .from('squad_players')
  ///       .select('real_player_id')
  ///       .inFilter('team_id', teamIds);
  ///   final claimed = claimedIds.map((r) => r['real_player_id'] as String).toList();
  ///   final freeRows = await _client
  ///       .from('real_players')
  ///       .select()
  ///       .not('id', 'in', claimed);
  ///   return freeRows.map(PlayerModel.fromJson).toList();
  Future<List<PlayerModel>> fetchFreeAgents(String leagueId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockFreeAgents(leagueId);
  }

  /// Ficha un agente libre [player] para el equipo [buyerTeam].
  /// Lanza [ArgumentError] si:
  ///   - el presupuesto es insuficiente
  ///   - la plantilla ya alcanzó el máximo de jugadores (18)
  ///   - el jugador no está disponible (status != 'active')
  /// La query real que reemplaza el bloque mock:
  ///
  ///   await _client.from('squad_players').insert({
  ///     'team_id': buyerTeam.id,
  ///     'real_player_id': player.id,
  ///     'clause': (player.marketValue * 1.5).round(),
  ///     'is_on_market': false,
  ///   });
  ///   await _client.from('teams')
  ///       .update({'budget': buyerTeam.budget - player.marketValue})
  ///       .eq('id', buyerTeam.id);
  Future<void> signFreeAgent({
    required TeamModel buyerTeam,
    required PlayerModel player,
    required int currentSquadSize,
  }) async {
    _validateSigning(
      budget: buyerTeam.budget,
      cost: player.marketValue,
      currentSquadSize: currentSquadSize,
      playerName: player.name,
      playerStatus: player.status,
    );
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// Activa la cláusula del jugador [targetSquadPlayer] para el equipo [buyerTeam].
  /// Lanza [ArgumentError] si:
  ///   - el comprador es el mismo equipo que el vendedor
  ///   - el presupuesto es insuficiente para cubrir la cláusula
  ///   - la plantilla ya alcanzó el máximo de jugadores (18)
  ///   - el jugador no está disponible (status != 'active')
  /// La query real que reemplaza el bloque mock:
  ///
  ///   await _client.from('squad_players')
  ///       .update({'team_id': buyerTeam.id, 'is_on_market': false})
  ///       .eq('id', targetSquadPlayer.id);
  ///   await _client.from('teams')
  ///       .update({'budget': buyerTeam.budget - targetSquadPlayer.clause})
  ///       .eq('id', buyerTeam.id);
  ///   // El aumento de presupuesto del vendedor lo gestiona FinanceRepository (fase 2.14).
  Future<void> triggerClause({
    required TeamModel buyerTeam,
    required SquadPlayerModel targetSquadPlayer,
    required int currentSquadSize,
  }) async {
    if (buyerTeam.id == targetSquadPlayer.teamId) {
      throw ArgumentError(
        'No puedes activar la cláusula de un jugador de tu propio equipo.',
      );
    }
    _validateSigning(
      budget: buyerTeam.budget,
      cost: targetSquadPlayer.clause,
      currentSquadSize: currentSquadSize,
      playerName: targetSquadPlayer.player.name,
      playerStatus: targetSquadPlayer.player.status,
    );
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// Pone al jugador [squadPlayer] en el mercado para su venta.
  /// Lanza [ArgumentError] si el jugador no pertenece al equipo [ownerTeamId]
  /// o ya está listado.
  /// La query real que reemplaza el bloque mock:
  ///
  ///   await _client.from('squad_players')
  ///       .update({'is_on_market': true})
  ///       .eq('id', squadPlayer.id);
  Future<void> listPlayerForSale({
    required SquadPlayerModel squadPlayer,
    required String ownerTeamId,
  }) async {
    if (squadPlayer.teamId != ownerTeamId) {
      throw ArgumentError(
        'Solo puedes listar jugadores de tu propia plantilla.',
      );
    }
    if (squadPlayer.isOnMarket) {
      throw ArgumentError(
        'El jugador ${squadPlayer.player.name} ya está en el mercado.',
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Retira al jugador [squadPlayer] del mercado.
  /// Lanza [ArgumentError] si el jugador no pertenece al equipo [ownerTeamId]
  /// o no está listado.
  /// La query real que reemplaza el bloque mock:
  ///
  ///   await _client.from('squad_players')
  ///       .update({'is_on_market': false})
  ///       .eq('id', squadPlayer.id);
  Future<void> removePlayerFromMarket({
    required SquadPlayerModel squadPlayer,
    required String ownerTeamId,
  }) async {
    if (squadPlayer.teamId != ownerTeamId) {
      throw ArgumentError(
        'Solo puedes retirar jugadores de tu propia plantilla.',
      );
    }
    if (!squadPlayer.isOnMarket) {
      throw ArgumentError(
        'El jugador ${squadPlayer.player.name} no está en el mercado.',
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _validateSigning({
    required int budget,
    required int cost,
    required int currentSquadSize,
    required String playerName,
    required String playerStatus,
  }) {
    final maxSquadSize =
        AppConstants.maxStartersCount + AppConstants.maxBenchCount;
    if (budget < cost) {
      throw ArgumentError(
        'Fondos insuficientes. Presupuesto: $budget, coste: $cost.',
      );
    }
    if (currentSquadSize >= maxSquadSize) {
      throw ArgumentError(
        'Plantilla completa. No se pueden fichar más de $maxSquadSize jugadores.',
      );
    }
    if (playerStatus != 'active') {
      throw ArgumentError(
        'El jugador $playerName no está disponible para fichar (status: $playerStatus).',
      );
    }
  }

  List<SquadPlayerModel> _mockMarketListings(String leagueId) {
    return [
      _makeSquadPlayer(
        id: 'mock-sp-rival-01',
        teamId: 'mock-team-02',
        playerId: 'mock-player-r01',
        apiId: 101,
        name: 'Kroos',
        position: Position.midfielder,
        marketValue: 20000000,
        isOnMarket: true,
      ),
      _makeSquadPlayer(
        id: 'mock-sp-rival-02',
        teamId: 'mock-team-02',
        playerId: 'mock-player-r02',
        apiId: 102,
        name: 'Yamal',
        position: Position.forward,
        marketValue: 60000000,
        isOnMarket: true,
      ),
      _makeSquadPlayer(
        id: 'mock-sp-rival-03',
        teamId: 'mock-team-03',
        playerId: 'mock-player-r03',
        apiId: 103,
        name: 'Alaba',
        position: Position.defender,
        marketValue: 16000000,
        isOnMarket: true,
      ),
    ];
  }

  List<PlayerModel> _mockFreeAgents(String leagueId) {
    return [
      _makePlayer('mock-fa-01', 201, 'Rodrigo', Position.midfielder, 12000000),
      _makePlayer('mock-fa-02', 202, 'Joselu', Position.forward, 8000000),
      _makePlayer('mock-fa-03', 203, 'Courtois', Position.goalkeeper, 22000000),
      _makePlayer('mock-fa-04', 204, 'Nacho', Position.defender, 10000000),
      _makePlayer('mock-fa-05', 205, 'Isco', Position.midfielder, 9000000),
    ];
  }

  SquadPlayerModel _makeSquadPlayer({
    required String id,
    required String teamId,
    required String playerId,
    required int apiId,
    required String name,
    required Position position,
    required int marketValue,
    required bool isOnMarket,
  }) {
    return SquadPlayerModel(
      id: id,
      teamId: teamId,
      player: PlayerModel(
        id: playerId,
        apiFootballPlayerId: apiId,
        name: name,
        position: position,
        marketValue: marketValue,
        status: 'active',
      ),
      clause: (marketValue * 1.5).round(),
      isOnMarket: isOnMarket,
    );
  }

  PlayerModel _makePlayer(
    String id,
    int apiId,
    String name,
    Position position,
    int marketValue,
  ) {
    return PlayerModel(
      id: id,
      apiFootballPlayerId: apiId,
      name: name,
      position: position,
      marketValue: marketValue,
      status: 'active',
    );
  }
}
