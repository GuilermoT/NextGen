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
            ).animate().fadeIn(duration: 500.ms),
            Text(
              'FANTASY',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            Text(
              'LaLiga Edition',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
            const SizedBox(height: 40),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: AppColors.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 4,
                  ),
                );
              },
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
