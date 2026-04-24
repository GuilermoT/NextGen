import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class PlayerCard extends StatelessWidget {
  final String playerName;
  final String position;
  final double points;
  final String? imageUrl;
  final bool isCaptain;
  final bool isLoading;

  const PlayerCard({
    super.key,
    required this.playerName,
    required this.position,
    required this.points,
    this.imageUrl,
    this.isCaptain = false,
    this.isLoading = false,
  });

  Color _positionColor() {
    switch (position) {
      case 'POR':
        return AppColors.accentGold;
      case 'DEF':
        return const Color(0xFF007AFF);
      case 'MED':
        return AppColors.primaryGreen;
      case 'DEL':
        return AppColors.dangerRed;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _positionColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _positionColor().withValues(alpha: 0.6),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  position,
                  style: TextStyle(
                    color: _positionColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCaptain)
                Text(
                  '👑',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.accentGold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: imageUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.surfaceDark,
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.surfaceDark,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceDark,
                    child: Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            playerName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${points.toStringAsFixed(1)} pts',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (!isLoading) return card;

    // Loading shimmer via flutter_animate (skeletonizer incompatible with current SDK)
    return card
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppColors.surfaceDark,
        );
  }
}
