// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teamRepositoryHash() => r'7b1d367b5efbb144473b7bf9d276f2f850407fe6';

/// See also [teamRepository].
@ProviderFor(teamRepository)
final teamRepositoryProvider = Provider<TeamRepository>.internal(
  teamRepository,
  name: r'teamRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$teamRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeamRepositoryRef = ProviderRef<TeamRepository>;
String _$currentTeamHash() => r'22d9f0174a93be30cf30e96f80ae650b8e005801';

/// Expone el equipo del usuario autenticado en sesión.
/// Retorna null si no hay sesión activa o el usuario no tiene equipo aún.
/// Se recalcula automáticamente cuando [authNotifierProvider] cambia.
///
/// Copied from [currentTeam].
@ProviderFor(currentTeam)
final currentTeamProvider = FutureProvider<TeamModel?>.internal(
  currentTeam,
  name: r'currentTeamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentTeamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentTeamRef = FutureProviderRef<TeamModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
