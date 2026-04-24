import 'package:flutter/foundation.dart';

@immutable
class TeamModel {
  final String id;
  final String leagueId;
  final String userId;
  final String name;
  // budget mapea int4 de la tabla `teams` (tabla pendiente de crear por Jacobo, fase 1.6)
  final int budget;

  const TeamModel({
    required this.id,
    required this.leagueId,
    required this.userId,
    required this.name,
    required this.budget,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      leagueId: json['league_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      budget: json['budget'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'league_id': leagueId,
      'user_id': userId,
      'name': name,
      'budget': budget,
    };
  }

  TeamModel copyWith({
    String? id,
    String? leagueId,
    String? userId,
    String? name,
    int? budget,
  }) {
    return TeamModel(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      budget: budget ?? this.budget,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamModel &&
        other.id == id &&
        other.leagueId == leagueId &&
        other.userId == userId &&
        other.name == name &&
        other.budget == budget;
  }

  @override
  int get hashCode => Object.hash(id, leagueId, userId, name, budget);

  @override
  String toString() {
    return 'TeamModel(id: $id, leagueId: $leagueId, userId: $userId, name: $name, budget: $budget)';
  }
}
