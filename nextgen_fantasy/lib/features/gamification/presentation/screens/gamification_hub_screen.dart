import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';
import 'package:nextgen_fantasy/features/gamification/presentation/widgets/last_place_banner.dart';
import 'package:nextgen_fantasy/features/gamification/presentation/widgets/podium_widget.dart';

class GamificationHubScreen extends StatelessWidget {
  const GamificationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    final topThree = [
      {'name': 'Los Galácticos FC', 'points': 842.5},
      {'name': 'Equipo Naranjito', 'points': 821.0},
      {'name': 'Cracks del Bernabéu', 'points': 810.5},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Gamificación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sobre de Táctica card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accentGold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text('Sobre de Táctica', style: theme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Abre tu sobre y descubre el bonus de la jornada',
                    style: theme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/home/gamification/sobre'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.backgroundDark,
                    ),
                    child: const Text(
                      'Abrir sobre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Liga card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text('Liga — Jornada 32', style: theme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PodiumWidget(topThree: topThree),
                  const SizedBox(height: 20),
                  LastPlaceBanner(
                    teamName: 'Vikingos del Sur',
                    points: 762.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
