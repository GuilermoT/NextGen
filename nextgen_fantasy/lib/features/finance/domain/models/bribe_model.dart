import 'package:flutter/foundation.dart';

enum BribeStatus { pending, accepted, rejected }

BribeStatus _statusFromString(String value) {
  switch (value) {
    case 'pending':
      return BribeStatus.pending;
    case 'accepted':
      return BribeStatus.accepted;
    case 'rejected':
      return BribeStatus.rejected;
    default:
      throw ArgumentError('Unknown bribe status: $value');
  }
}

String _statusToString(BribeStatus status) {
  switch (status) {
    case BribeStatus.pending:
      return 'pending';
    case BribeStatus.accepted:
      return 'accepted';
    case BribeStatus.rejected:
      return 'rejected';
  }
}

@immutable
class BribeModel {
  final String id;
  final String senderTeamId;
  final String receiverTeamId;
  final String targetPlayerId;
  final int amount;
  final BribeStatus status;
  final String jornadaId;

  const BribeModel({
    required this.id,
    required this.senderTeamId,
    required this.receiverTeamId,
    required this.targetPlayerId,
    required this.amount,
    required this.status,
    required this.jornadaId,
  });

  factory BribeModel.fromJson(Map<String, dynamic> json) {
    return BribeModel(
      id: json['id'] as String,
      senderTeamId: json['sender_team_id'] as String,
      receiverTeamId: json['receiver_team_id'] as String,
      targetPlayerId: json['target_player_id'] as String,
      amount: json['amount'] as int,
      status: _statusFromString(json['status'] as String),
      jornadaId: json['jornada_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_team_id': senderTeamId,
      'receiver_team_id': receiverTeamId,
      'target_player_id': targetPlayerId,
      'amount': amount,
      'status': _statusToString(status),
      'jornada_id': jornadaId,
    };
  }

  BribeModel copyWith({
    String? id,
    String? senderTeamId,
    String? receiverTeamId,
    String? targetPlayerId,
    int? amount,
    BribeStatus? status,
    String? jornadaId,
  }) {
    return BribeModel(
      id: id ?? this.id,
      senderTeamId: senderTeamId ?? this.senderTeamId,
      receiverTeamId: receiverTeamId ?? this.receiverTeamId,
      targetPlayerId: targetPlayerId ?? this.targetPlayerId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      jornadaId: jornadaId ?? this.jornadaId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BribeModel &&
        other.id == id &&
        other.senderTeamId == senderTeamId &&
        other.receiverTeamId == receiverTeamId &&
        other.targetPlayerId == targetPlayerId &&
        other.amount == amount &&
        other.status == status &&
        other.jornadaId == jornadaId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        senderTeamId,
        receiverTeamId,
        targetPlayerId,
        amount,
        status,
        jornadaId,
      );

  @override
  String toString() {
    return 'BribeModel(id: $id, senderTeamId: $senderTeamId, receiverTeamId: $receiverTeamId, amount: $amount, status: $status)';
  }
}
