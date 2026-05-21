// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lineup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lineupRepositoryHash() => r'bada44b69808717636b0ec60a2a2d0c06e049ac8';

/// See also [lineupRepository].
@ProviderFor(lineupRepository)
final lineupRepositoryProvider = Provider<LineupRepository>.internal(
  lineupRepository,
  name: r'lineupRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lineupRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LineupRepositoryRef = ProviderRef<LineupRepository>;
String _$currentLineupHash() => r'eccc6889778c2c9706b065afb934a42902222b4e';

/// Expone la alineación guardada del equipo en sesión.
/// Retorna null si no hay sesión activa, el equipo no existe, o aún no tiene alineación guardada.
/// Se recalcula automáticamente cuando [currentTeamProvider] cambia.
///
/// Copied from [currentLineup].
@ProviderFor(currentLineup)
final currentLineupProvider = FutureProvider<LineupModel?>.internal(
  currentLineup,
  name: r'currentLineupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLineupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLineupRef = FutureProviderRef<LineupModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
