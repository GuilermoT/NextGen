import 'package:flutter/foundation.dart';
import 'lineup_entry_model.dart';

@immutable
class LineupModel {
  final String id;
  final String teamId;
  final List<LineupEntryModel> entries;

  const LineupModel({
    required this.id,
    required this.teamId,
    required this.entries,
  });

  List<LineupEntryModel> get starters =>
      entries.where((e) => e.isStarter).toList();

  List<LineupEntryModel> get bench =>
      entries.where((e) => !e.isStarter).toList();

  LineupEntryModel? get captain {
    for (final e in entries) {
      if (e.isCaptain) return e;
    }
    return null;
  }

  // Espera JSON: .select('*, lineup_entries(*, squad_players(*, real_players(*)))')
  factory LineupModel.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['lineup_entries'] as List<dynamic>;
    return LineupModel(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      entries: entriesJson
          .map((e) => LineupEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // toJson solo emite los campos de la tabla lineups (las entradas se gestionan por separado)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
    };
  }

  LineupModel copyWith({
    String? id,
    String? teamId,
    List<LineupEntryModel>? entries,
  }) {
    return LineupModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      entries: entries ?? this.entries,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LineupModel &&
        other.id == id &&
        other.teamId == teamId &&
        listEquals(other.entries, entries);
  }

  @override
  int get hashCode => Object.hash(id, teamId, Object.hashAll(entries));

  @override
  String toString() {
    return 'LineupModel(id: $id, teamId: $teamId, '
        'starters: ${starters.length}, bench: ${bench.length})';
  }
}
