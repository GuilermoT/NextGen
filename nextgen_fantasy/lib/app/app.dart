import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextgen_fantasy/app/router/app_router.dart';
import 'package:nextgen_fantasy/core/theme/app_theme.dart';
import 'package:nextgen_fantasy/features/auth/presentation/providers/auth_notifier.dart';

class NextGenFantasyApp extends ConsumerWidget {
  const NextGenFantasyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dispara la re-evaluación del redirect de GoRouter cada vez
    // que el estado de autenticación cambia.
    ref.listen(authNotifierProvider, (_, __) => refreshAppRouter());

    return MaterialApp.router(
      title: 'NextGen Fantasy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
