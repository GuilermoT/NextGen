import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';
import 'package:nextgen_fantasy/shared/widgets/player_card.dart';
import 'package:nextgen_fantasy/shared/widgets/points_badge.dart';
import 'package:nextgen_fantasy/shared/widgets/ranking_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int _daysUntilNextMatchday() {
    final nextMatchday = DateTime(2026, 5, 3);
    final diff = nextMatchday.difference(DateTime.now());
    return diff.inDays.clamp(0, 999);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    const mockPlayers = [
      {'name': 'Ter Stegen', 'pos': 'POR', 'pts': 8.0, 'captain': false},
      {'name': 'Carvajal', 'pos': 'DEF', 'pts': 11.5, 'captain': false},
      {'name': 'Pedri', 'pos': 'MED', 'pts': 14.0, 'captain': true},
      {'name': 'Bellingham', 'pos': 'MED', 'pts': 12.0, 'captain': false},
      {'name': 'Lewandowski', 'pos': 'DEL', 'pts': 17.0, 'captain': false},
    ];

    const mockRanking = [
      {'pos': 1, 'team': 'Los Galácticos FC', 'pts': 842.5, 'trend': 1},
      {'pos': 2, 'team': 'Equipo Naranjito', 'pts': 821.0, 'trend': -1},
      {'pos': 3, 'team': 'Cracks del Bernabéu', 'pts': 810.5, 'trend': 1},
      {'pos': 4, 'team': 'Mi Equipo', 'pts': 798.0, 'trend': 0},
      {'pos': 5, 'team': 'Vikingos del Sur', 'pts': 762.5, 'trend': -2},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // TODO Dev 2: conectar a currentTeamProvider cuando TeamRepository esté listo
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: saludo + puntos de jornada
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, Entrenador 👋', style: theme.titleLarge)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.1),
                      const SizedBox(height: 4),
                      Text('Jornada 32', style: theme.bodyMedium)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 80.ms),
                    ],
                  ),
                  PointsBadge(points: 62.5, label: 'J32')
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 40.ms),
                ],
              ),

              const SizedBox(height: 20),

              // Countdown card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: AppColors.accentGold,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Próxima jornada en', style: theme.bodySmall),
                        Text(
                          '${_daysUntilNextMatchday()} días',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Tu equipo esta jornada
              Text('Tu equipo esta jornada', style: theme.titleMedium)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 240.ms),
              const SizedBox(height: 12),
              SizedBox(
                height: 175,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockPlayers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final p = mockPlayers[index];
                    return PlayerCard(
                      playerName: p['name'] as String,
                      position: p['pos'] as String,
                      points: p['pts'] as double,
                      isCaptain: p['captain'] as bool,
                    )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: (320 + index * 80).ms)
                        .slideX(begin: 0.1);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Clasificación de tu liga
              Text('Clasificación de tu liga', style: theme.titleMedium)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: List.generate(mockRanking.length, (index) {
                    final r = mockRanking[index];
                    return RankingRow(
                      position: r['pos'] as int,
                      teamName: r['team'] as String,
                      points: r['pts'] as double,
                      trend: r['trend'] as int,
                    )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: (480 + index * 60).ms)
                        .slideX(begin: -0.05);
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Botón gamificación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home/gamification'),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('Ver gamificación'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 560.ms)
                    .slideY(begin: 0.1),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
