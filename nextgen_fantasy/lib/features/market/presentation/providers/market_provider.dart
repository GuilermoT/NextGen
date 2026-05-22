import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nextgen_fantasy/core/providers/supabase_provider.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/player_model.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/squad_player_model.dart';
import 'package:nextgen_fantasy/features/market/data/repositories/market_repository.dart';
import 'package:nextgen_fantasy/features/market/presentation/providers/team_provider.dart';

part 'market_provider.g.dart';

@Riverpod(keepAlive: true)
MarketRepository marketRepository(MarketRepositoryRef ref) {
  return MarketRepository(ref.watch(supabaseClientProvider));
}

/// Expone los jugadores en venta en la liga del equipo en sesión.
/// Retorna lista vacía si no hay sesión activa o el equipo aún no existe.
/// Invalidar con [ref.invalidate(marketListingsProvider)] tras cualquier fichaje o venta.
@Riverpod(keepAlive: true)
Future<List<SquadPlayerModel>> marketListings(MarketListingsRef ref) async {
  final repo = ref.watch(marketRepositoryProvider);
  final team = await ref.watch(currentTeamProvider.future);
  if (team == null) return [];
  return repo.fetchMarketListings(team.leagueId);
}

/// Expone los agentes libres disponibles para fichar en la liga del equipo en sesión.
/// Retorna lista vacía si no hay sesión activa o el equipo aún no existe.
/// Invalidar con [ref.invalidate(freeAgentsProvider)] tras cualquier fichaje.
@Riverpod(keepAlive: true)
Future<List<PlayerModel>> freeAgents(FreeAgentsRef ref) async {
  final repo = ref.watch(marketRepositoryProvider);
  final team = await ref.watch(currentTeamProvider.future);
  if (team == null) return [];
  return repo.fetchFreeAgents(team.leagueId);
}
