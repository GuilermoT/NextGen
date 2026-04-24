import 'package:flutter/foundation.dart';

enum TransactionType { signing, sale, clauseTax, bribe, penalty }

TransactionType _typeFromString(String value) {
  switch (value) {
    case 'signing':
      return TransactionType.signing;
    case 'sale':
      return TransactionType.sale;
    case 'clause_tax':
      return TransactionType.clauseTax;
    case 'bribe':
      return TransactionType.bribe;
    case 'penalty':
      return TransactionType.penalty;
    default:
      throw ArgumentError('Unknown transaction type: $value');
  }
}

String _typeToString(TransactionType type) {
  switch (type) {
    case TransactionType.signing:
      return 'signing';
    case TransactionType.sale:
      return 'sale';
    case TransactionType.clauseTax:
      return 'clause_tax';
    case TransactionType.bribe:
      return 'bribe';
    case TransactionType.penalty:
      return 'penalty';
  }
}

@immutable
class TransactionModel {
  final String id;
  final String teamId;
  final TransactionType type;
  final int amount;
  final String? description;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.teamId,
    required this.type,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      type: _typeFromString(json['type'] as String),
      amount: json['amount'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'type': _typeToString(type),
      'amount': amount,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? teamId,
    TransactionType? type,
    int? amount,
    String? description,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.teamId == teamId &&
        other.type == type &&
        other.amount == amount &&
        other.description == description &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, teamId, type, amount, description, createdAt);

  @override
  String toString() {
    return 'TransactionModel(id: $id, teamId: $teamId, type: $type, amount: $amount, createdAt: $createdAt)';
  }
}
