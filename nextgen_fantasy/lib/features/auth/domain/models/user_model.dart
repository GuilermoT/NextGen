import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String username;
  final String? avatarUrl;
  // balance no existe aún en DB (tabla profiles). Default 0 hasta que Jacobo añada la columna.
  final int balance;

  const UserModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.balance = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      balance: (json['balance'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'balance': balance,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    int? balance,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      balance: balance ?? this.balance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.avatarUrl == avatarUrl &&
        other.balance == balance;
  }

  @override
  int get hashCode => Object.hash(id, username, avatarUrl, balance);

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, avatarUrl: $avatarUrl, balance: $balance)';
  }
}
