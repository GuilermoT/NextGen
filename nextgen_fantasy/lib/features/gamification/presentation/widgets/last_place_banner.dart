import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class LastPlaceBanner extends StatelessWidget {
  final String teamName;
  final double points;

  const LastPlaceBanner({
    super.key,
    required this.teamName,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Text('💀', style: TextStyle(fontSize: 28))
              .animate(onPlay: (c) => c.repeat())
              .shake(hz: 3, duration: 600.ms, offset: const Offset(3, 0))
              .then(delay: 1400.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Cuidado! Estás en peligro',
                  style: theme.titleMedium?.copyWith(
                    color: AppColors.dangerRed,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$teamName · ${points.toStringAsFixed(1)} pts',
                  style: theme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
