import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nextgen_fantasy/core/providers/supabase_provider.dart';
import 'package:nextgen_fantasy/features/lineup/data/repositories/squad_repository.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/squad_player_model.dart';
import 'package:nextgen_fantasy/features/market/presentation/providers/team_provider.dart';

part 'squad_provider.g.dart';

@Riverpod(keepAlive: true)
SquadRepository squadRepository(SquadRepositoryRef ref) {
  return SquadRepository(ref.watch(supabaseClientProvider));
}

/// Expone la plantilla completa del equipo en sesión.
/// Retorna lista vacía si no hay sesión activa o el equipo aún no existe.
/// Se recalcula automáticamente cuando [currentTeamProvider] cambia.
@Riverpod(keepAlive: true)
Future<List<SquadPlayerModel>> currentSquad(CurrentSquadRef ref) async {
  final repo = ref.watch(squadRepositoryProvider);
  final team = await ref.watch(currentTeamProvider.future);
  if (team == null) return [];
  return repo.fetchSquad(team.id);
}
