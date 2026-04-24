import 'package:flutter/material.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class PointsBadge extends StatelessWidget {
  final double points;
  final String label;

  const PointsBadge({
    super.key,
    required this.points,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${points.toStringAsFixed(1)} pts',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
