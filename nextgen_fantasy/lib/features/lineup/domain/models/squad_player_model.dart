import 'package:flutter/foundation.dart';
import 'player_model.dart';

@immutable
class SquadPlayerModel {
  final String id;
  final String teamId;
  // Objeto completo del jugador real (join con real_players via real_player_id en DB)
  final PlayerModel player;
  final int clause;
  final bool isOnMarket;

  const SquadPlayerModel({
    required this.id,
    required this.teamId,
    required this.player,
    required this.clause,
    required this.isOnMarket,
  });

  // Espera JSON con join: .select('*, real_players(*)') en Supabase
  factory SquadPlayerModel.fromJson(Map<String, dynamic> json) {
    return SquadPlayerModel(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      player: PlayerModel.fromJson(
          json['real_players'] as Map<String, dynamic>),
      clause: json['clause'] as int,
      isOnMarket: json['is_on_market'] as bool,
    );
  }

  // toJson emite real_player_id (FK) para escrituras en DB, no el objeto anidado
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'real_player_id': player.id,
      'clause': clause,
      'is_on_market': isOnMarket,
    };
  }

  SquadPlayerModel copyWith({
    String? id,
    String? teamId,
    PlayerModel? player,
    int? clause,
    bool? isOnMarket,
  }) {
    return SquadPlayerModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      player: player ?? this.player,
      clause: clause ?? this.clause,
      isOnMarket: isOnMarket ?? this.isOnMarket,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SquadPlayerModel &&
        other.id == id &&
        other.teamId == teamId &&
        other.player == player &&
        other.clause == clause &&
        other.isOnMarket == isOnMarket;
  }

  @override
  int get hashCode => Object.hash(id, teamId, player, clause, isOnMarket);

  @override
  String toString() {
    return 'SquadPlayerModel(id: $id, teamId: $teamId, player: ${player.name}, clause: $clause, isOnMarket: $isOnMarket)';
  }
}
