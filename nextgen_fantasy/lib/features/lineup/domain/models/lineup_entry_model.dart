import 'package:flutter/foundation.dart';
import 'squad_player_model.dart';

@immutable
class LineupEntryModel {
  final String id;
  final SquadPlayerModel squadPlayer;
  final bool isStarter;
  final bool isCaptain;

  const LineupEntryModel({
    required this.id,
    required this.squadPlayer,
    required this.isStarter,
    required this.isCaptain,
  });

  // Espera JSON con join: .select('*, lineup_entries(*, squad_players(*, real_players(*)))')
  factory LineupEntryModel.fromJson(Map<String, dynamic> json) {
    return LineupEntryModel(
      id: json['id'] as String,
      squadPlayer: SquadPlayerModel.fromJson(
          json['squad_players'] as Map<String, dynamic>),
      isStarter: json['is_starter'] as bool,
      isCaptain: json['is_captain'] as bool,
    );
  }

  // toJson emite squad_player_id (FK) para escrituras en lineup_entries
  Map<String, dynamic> toJson() {
    return {
      'squad_player_id': squadPlayer.id,
      'is_starter': isStarter,
      'is_captain': isCaptain,
    };
  }

  LineupEntryModel copyWith({
    String? id,
    SquadPlayerModel? squadPlayer,
    bool? isStarter,
    bool? isCaptain,
  }) {
    return LineupEntryModel(
      id: id ?? this.id,
      squadPlayer: squadPlayer ?? this.squadPlayer,
      isStarter: isStarter ?? this.isStarter,
      isCaptain: isCaptain ?? this.isCaptain,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LineupEntryModel &&
        other.id == id &&
        other.squadPlayer == squadPlayer &&
        other.isStarter == isStarter &&
        other.isCaptain == isCaptain;
  }

  @override
  int get hashCode => Object.hash(id, squadPlayer, isStarter, isCaptain);

  @override
  String toString() {
    return 'LineupEntryModel(id: $id, player: ${squadPlayer.player.name}, '
        'isStarter: $isStarter, isCaptain: $isCaptain)';
  }
}
