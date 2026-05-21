// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$squadRepositoryHash() => r'3e4d709f2fa92127e0696c4943dcdafa0bcd6691';

/// See also [squadRepository].
@ProviderFor(squadRepository)
final squadRepositoryProvider = Provider<SquadRepository>.internal(
  squadRepository,
  name: r'squadRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$squadRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SquadRepositoryRef = ProviderRef<SquadRepository>;
String _$currentSquadHash() => r'c7876fa52ba5da264e4e150e704ab89649ffb1d3';

/// Expone la plantilla completa del equipo en sesión.
/// Retorna lista vacía si no hay sesión activa o el equipo aún no existe.
/// Se recalcula automáticamente cuando [currentTeamProvider] cambia.
///
/// Copied from [currentSquad].
@ProviderFor(currentSquad)
final currentSquadProvider = FutureProvider<List<SquadPlayerModel>>.internal(
  currentSquad,
  name: r'currentSquadProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSquadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSquadRef = FutureProviderRef<List<SquadPlayerModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
