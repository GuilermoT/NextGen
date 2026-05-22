import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nextgen_fantasy/core/providers/supabase_provider.dart';
import 'package:nextgen_fantasy/features/lineup/data/repositories/lineup_repository.dart';
import 'package:nextgen_fantasy/features/lineup/domain/models/lineup_model.dart';
import 'package:nextgen_fantasy/features/market/presentation/providers/team_provider.dart';

part 'lineup_provider.g.dart';

@Riverpod(keepAlive: true)
LineupRepository lineupRepository(LineupRepositoryRef ref) {
  return LineupRepository(ref.watch(supabaseClientProvider));
}

/// Expone la alineación guardada del equipo en sesión.
/// Retorna null si no hay sesión activa, el equipo no existe, o aún no tiene alineación guardada.
/// Se recalcula automáticamente cuando [currentTeamProvider] cambia.
@Riverpod(keepAlive: true)
Future<LineupModel?> currentLineup(CurrentLineupRef ref) async {
  final repo = ref.watch(lineupRepositoryProvider);
  final team = await ref.watch(currentTeamProvider.future);
  if (team == null) return null;
  return repo.fetchCurrentLineup(team.id);
}
