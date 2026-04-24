import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Decorative blurred circles for depth
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXTGEN FANTASY',
                    style: theme.displayLarge
                        ?.copyWith(color: AppColors.primaryGreen),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1),
                  const SizedBox(height: 8),
                  Text(
                    'LaLiga Edition',
                    style: theme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1),
                  const SizedBox(height: 64),
                  ElevatedButton(
                    onPressed: () {
                      // TODO Dev 2: llamar a ref.read(authNotifierProvider.notifier).signInWithGoogle()
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GoogleLogo(),
                        SizedBox(width: 10),
                        Text('Continuar con Google'),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 80.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.borderColor),
                      disabledForegroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Continuar como invitado'),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 160.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  Text(
                    'Al continuar aceptas los términos de uso',
                    style: theme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 240.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const SweepGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFFEA4335),
            Color(0xFFFBBC05),
            Color(0xFF34A853),
            Color(0xFF4285F4),
          ],
        ).createShader(bounds);
      },
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
