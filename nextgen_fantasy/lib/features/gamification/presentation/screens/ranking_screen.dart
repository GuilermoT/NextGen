import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';
import 'package:nextgen_fantasy/shared/widgets/ranking_row.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  static const String _myTeam = 'Mi Equipo FC';
  static const List<int> _jornadas = [30, 31, 32];
  int _selectedJornada = 32;

  static final _standings = <int, List<Map<String, dynamic>>>{
    30: [
      {'name': 'Los Galácticos FC', 'points': 842.5},
      {'name': 'Equipo Naranjito', 'points': 821.0},
      {'name': 'Cracks del Bernabéu', 'points': 810.5},
      {'name': 'Mi Equipo FC', 'points': 798.0},
      {'name': 'Vikingos del Sur', 'points': 782.5},
      {'name': 'Diablos Rojos FC', 'points': 775.0},
      {'name': 'La Armada Azul', 'points': 765.5},
      {'name': 'Furia Española', 'points': 755.0},
    ],
    31: [
      {'name': 'Los Galácticos FC', 'points': 862.5},
      {'name': 'Mi Equipo FC', 'points': 831.0},
      {'name': 'Equipo Naranjito', 'points': 829.5},
      {'name': 'Cracks del Bernabéu', 'points': 820.5},
      {'name': 'Diablos Rojos FC', 'points': 805.0},
      {'name': 'Vikingos del Sur', 'points': 795.5},
      {'name': 'La Armada Azul', 'points': 785.0},
      {'name': 'Furia Española', 'points': 772.0},
    ],
    32: [
      {'name': 'Los Galácticos FC', 'points': 882.5},
      {'name': 'Equipo Naranjito', 'points': 851.0},
      {'name': 'Mi Equipo FC', 'points': 848.5},
      {'name': 'Cracks del Bernabéu', 'points': 835.5},
      {'name': 'Diablos Rojos FC', 'points': 820.0},
      {'name': 'La Armada Azul', 'points': 808.5},
      {'name': 'Vikingos del Sur', 'points': 800.5},
      {'name': 'Furia Española', 'points': 785.0},
    ],
  };

  int _trend(String teamName) {
    final idx = _jornadas.indexOf(_selectedJornada);
    if (idx <= 0) return 0;
    final prevJornada = _jornadas[idx - 1];
    final currentList = _standings[_selectedJornada]!;
    final prevList = _standings[prevJornada]!;
    final currentPos = currentList.indexWhere((e) => e['name'] == teamName) + 1;
    final prevPos = prevList.indexWhere((e) => e['name'] == teamName) + 1;
    return prevPos - currentPos;
  }

  void _prevJornada() {
    final idx = _jornadas.indexOf(_selectedJornada);
    if (idx > 0) setState(() => _selectedJornada = _jornadas[idx - 1]);
  }

  void _nextJornada() {
    final idx = _jornadas.indexOf(_selectedJornada);
    if (idx < _jornadas.length - 1) {
      setState(() => _selectedJornada = _jornadas[idx + 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final standings = _standings[_selectedJornada]!;
    final jornPos = _jornadas.indexOf(_selectedJornada);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Clasificación'),
        backgroundColor: AppColors.backgroundDark,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: jornPos > 0 ? _prevJornada : null,
                  icon: const Icon(Icons.chevron_left),
                  color: AppColors.textPrimary,
                  disabledColor: AppColors.textDisabled,
                ),
                Text(
                  'Jornada $_selectedJornada',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: jornPos < _jornadas.length - 1 ? _nextJornada : null,
                  icon: const Icon(Icons.chevron_right),
                  color: AppColors.textPrimary,
                  disabledColor: AppColors.textDisabled,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                key: ValueKey(_selectedJornada),
                children: [
                  for (int i = 0; i < standings.length; i++)
                    _buildRow(standings[i], i + 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> entry, int position) {
    final name = entry['name'] as String;
    final points = entry['points'] as double;
    final isMyTeam = name == _myTeam;
    final delay = Duration(milliseconds: 40 * (position - 1));

    Widget row = RankingRow(
      position: position,
      teamName: name,
      points: points,
      trend: _trend(name),
    );

    if (isMyTeam) {
      row = ColoredBox(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        child: row,
      );
    }

    return row
        .animate()
        .fadeIn(delay: delay, duration: 300.ms)
        .slideX(begin: 0.1, delay: delay, duration: 300.ms);
  }
}
