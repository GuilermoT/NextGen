import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/core/constants/app_constants.dart';
import 'package:nextgen_fantasy/features/market/domain/models/team_model.dart';

class TeamRepository {
  // ignore: unused_field — reservado para query real cuando exista la tabla `teams`
  final SupabaseClient _client;

  const TeamRepository(this._client);

  /// Devuelve el equipo del usuario [userId] desde la tabla [teams].
  /// Usa datos mock hasta que Jacobo cree la tabla (fase backend 1.6).
  /// Para activar la query real, eliminar el bloque mock y descomentar:
  ///
  ///   final data = await _client
  ///       .from('teams')
  ///       .select()
  ///       .eq('user_id', userId)
  ///       .maybeSingle();
  ///   if (data == null) return null;
  ///   return TeamModel.fromJson(data);
  Future<TeamModel?> fetchCurrentTeam(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTeam(userId);
  }

  TeamModel _mockTeam(String userId) {
    return TeamModel(
      id: 'mock-team-01',
      leagueId: 'mock-league-01',
      userId: userId,
      name: 'Los Galácticos FC',
      budget: (AppConstants.initialTeamBalance * 0.45).round(),
    );
  }
}
