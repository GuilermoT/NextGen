// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketRepositoryHash() => r'1e871a0d5602675c16b1e4b065d73f57444e6c9e';

/// See also [marketRepository].
@ProviderFor(marketRepository)
final marketRepositoryProvider = Provider<MarketRepository>.internal(
  marketRepository,
  name: r'marketRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarketRepositoryRef = ProviderRef<MarketRepository>;
String _$marketListingsHash() => r'11512bb103bada5e1e5a5f58d49f35fbcce5549e';

/// Expone los jugadores en venta en la liga del equipo en sesión.
/// Retorna lista vacía si no hay sesión activa o el equipo aún no existe.
/// Invalidar con [ref.invalidate(marketListingsProvider)] tras cualquier fichaje o venta.
///
/// Copied from [marketListings].
@ProviderFor(marketListings)
final marketListingsProvider = FutureProvider<List<SquadPlayerModel>>.internal(
  marketListings,
  name: r'marketListingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketListingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarketListingsRef = FutureProviderRef<List<SquadPlayerModel>>;
String _$freeAgentsHash() => r'48352ca24256ac94a91b1e687c4b8311ecde3637';

/// Expone los agentes libres disponibles para fichar en la liga del equipo en sesión.
/// Retorna lista vacía si no hay sesión activa o el equipo aún no existe.
/// Invalidar con [ref.invalidate(freeAgentsProvider)] tras cualquier fichaje.
///
/// Copied from [freeAgents].
@ProviderFor(freeAgents)
final freeAgentsProvider = FutureProvider<List<PlayerModel>>.internal(
  freeAgents,
  name: r'freeAgentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$freeAgentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FreeAgentsRef = FutureProviderRef<List<PlayerModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
