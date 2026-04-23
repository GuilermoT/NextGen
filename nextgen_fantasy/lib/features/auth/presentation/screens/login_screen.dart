import 'package:flutter/material.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NEXTGEN FANTASY',
                style: theme.displayLarge?.copyWith(color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'LaLiga Edition',
                style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
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
                    Icon(Icons.login),
                    SizedBox(width: 8),
                    Text('Continuar con Google'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Al continuar aceptas los términos de uso',
                style: theme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
