import 'package:flutter/foundation.dart';

enum Position { goalkeeper, defender, midfielder, forward }

Position _positionFromString(String value) {
  switch (value) {
    case 'Goalkeeper':
      return Position.goalkeeper;
    case 'Defender':
      return Position.defender;
    case 'Midfielder':
      return Position.midfielder;
    case 'Attacker':
      return Position.forward;
    default:
      throw ArgumentError('Unknown position value: $value');
  }
}

String _positionToString(Position position) {
  switch (position) {
    case Position.goalkeeper:
      return 'Goalkeeper';
    case Position.defender:
      return 'Defender';
    case Position.midfielder:
      return 'Midfielder';
    case Position.forward:
      return 'Attacker';
  }
}

@immutable
class PlayerModel {
  final String id;
  final int apiFootballPlayerId;
  final String? clubId;
  final String name;
  final String? firstName;
  final String? lastName;
  final int? age;
  final Position position;
  final String? photoUrl;
  final int marketValue;
  final String status;

  const PlayerModel({
    required this.id,
    required this.apiFootballPlayerId,
    this.clubId,
    required this.name,
    this.firstName,
    this.lastName,
    this.age,
    required this.position,
    this.photoUrl,
    required this.marketValue,
    required this.status,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      apiFootballPlayerId: json['api_football_player_id'] as int,
      clubId: json['club_id'] as String?,
      name: json['name'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      age: json['age'] as int?,
      position: _positionFromString(json['position'] as String),
      photoUrl: json['photo_url'] as String?,
      marketValue: (json['market_value'] as int?) ?? 1000000,
      status: (json['status'] as String?) ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'api_football_player_id': apiFootballPlayerId,
      'club_id': clubId,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'position': _positionToString(position),
      'photo_url': photoUrl,
      'market_value': marketValue,
      'status': status,
    };
  }

  PlayerModel copyWith({
    String? id,
    int? apiFootballPlayerId,
    String? clubId,
    String? name,
    String? firstName,
    String? lastName,
    int? age,
    Position? position,
    String? photoUrl,
    int? marketValue,
    String? status,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      apiFootballPlayerId: apiFootballPlayerId ?? this.apiFootballPlayerId,
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl,
      marketValue: marketValue ?? this.marketValue,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerModel &&
        other.id == id &&
        other.apiFootballPlayerId == apiFootballPlayerId &&
        other.clubId == clubId &&
        other.name == name &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.age == age &&
        other.position == position &&
        other.photoUrl == photoUrl &&
        other.marketValue == marketValue &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
        id,
        apiFootballPlayerId,
        clubId,
        name,
        firstName,
        lastName,
        age,
        position,
        photoUrl,
        marketValue,
        status,
      );

  @override
  String toString() {
    return 'PlayerModel(id: $id, name: $name, position: $position, marketValue: $marketValue, status: $status)';
  }
}
