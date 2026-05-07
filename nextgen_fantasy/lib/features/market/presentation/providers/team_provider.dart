import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nextgen_fantasy/core/providers/supabase_provider.dart';
import 'package:nextgen_fantasy/features/auth/presentation/providers/auth_notifier.dart';
import 'package:nextgen_fantasy/features/market/data/repositories/team_repository.dart';
import 'package:nextgen_fantasy/features/market/domain/models/team_model.dart';

part 'team_provider.g.dart';

@Riverpod(keepAlive: true)
TeamRepository teamRepository(TeamRepositoryRef ref) {
  return TeamRepository(ref.watch(supabaseClientProvider));
}

/// Expone el equipo del usuario autenticado en sesión.
/// Retorna null si no hay sesión activa o el usuario no tiene equipo aún.
/// Se recalcula automáticamente cuando [authNotifierProvider] cambia.
@Riverpod(keepAlive: true)
Future<TeamModel?> currentTeam(CurrentTeamRef ref) async {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(teamRepositoryProvider).fetchCurrentTeam(user.id);
}
