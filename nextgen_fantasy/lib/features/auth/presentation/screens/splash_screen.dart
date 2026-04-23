import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NEXTGEN',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primaryGreen,
                  ),
            ),
            Text(
              'FANTASY',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              'LaLiga Edition',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
      ),
    );
  }
}
