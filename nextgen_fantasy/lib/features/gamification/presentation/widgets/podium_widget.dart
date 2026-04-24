import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class PodiumWidget extends StatelessWidget {
  final List<Map<String, dynamic>> topThree;

  const PodiumWidget({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    // Display order: 2nd left, 1st center, 3rd right
    final displayOrder = [
      if (topThree.length > 1) topThree[1],
      if (topThree.isNotEmpty) topThree[0],
      if (topThree.length > 2) topThree[2],
    ];
    final heights = [100.0, 140.0, 80.0];
    final colors = [
      Colors.grey.shade400,
      AppColors.accentGold,
      const Color(0xFFCD7F32),
    ];
    final medals = ['🥈', '🥇', '🥉'];
    final positions = [2, 1, 3];
    final delays = [150.ms, 0.ms, 300.ms];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(displayOrder.length, (i) {
        final entry = displayOrder[i];
        final color = colors[i];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  entry['name'] as String,
                  style: theme.bodySmall?.copyWith(color: color),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(entry['points'] as double).toStringAsFixed(0)} pts',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: heights[i],
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    border: Border(
                      top: BorderSide(color: color, width: 2),
                      left: BorderSide(color: color.withValues(alpha: 0.4)),
                      right: BorderSide(color: color.withValues(alpha: 0.4)),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${positions[i]}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: delays[i], duration: 400.ms)
                .slideY(begin: 0.3, delay: delays[i], duration: 400.ms),
          ),
        );
      }),
    );
  }
}
