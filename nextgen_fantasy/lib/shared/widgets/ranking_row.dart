import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class RankingRow extends StatelessWidget {
  final int position;
  final String teamName;
  final double points;
  final int trend;

  const RankingRow({
    super.key,
    required this.position,
    required this.teamName,
    required this.points,
    required this.trend,
  });

  Color _positionColor() {
    switch (position) {
      case 1:
        return AppColors.accentGold;
      case 2:
        return Colors.grey;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _trendIcon() {
    if (trend > 0) {
      return const Icon(Icons.arrow_upward, color: AppColors.primaryGreen, size: 16)
          .animate()
          .fadeIn(duration: 300.ms);
    } else if (trend < 0) {
      return const Icon(Icons.arrow_downward, color: AppColors.dangerRed, size: 16)
          .animate()
          .fadeIn(duration: 300.ms);
    }
    return const Icon(Icons.remove, color: AppColors.textSecondary, size: 16)
        .animate()
        .fadeIn(duration: 300.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position',
              style: TextStyle(
                color: _positionColor(),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              teamName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _trendIcon(),
          const SizedBox(width: 8),
          Text(
            '${points.toStringAsFixed(1)} pts',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
