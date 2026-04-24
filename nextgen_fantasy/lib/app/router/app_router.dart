import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen_fantasy/features/auth/presentation/screens/login_screen.dart';
import 'package:nextgen_fantasy/features/auth/presentation/screens/splash_screen.dart';
import 'package:nextgen_fantasy/features/finance/presentation/screens/finance_screen.dart';
import 'package:nextgen_fantasy/features/gamification/presentation/screens/gamification_hub_screen.dart';
import 'package:nextgen_fantasy/features/gamification/presentation/screens/sobre_tactica_screen.dart';
import 'package:nextgen_fantasy/features/home/presentation/screens/home_screen.dart';
import 'package:nextgen_fantasy/features/lineup/presentation/screens/lineup_screen.dart';
import 'package:nextgen_fantasy/features/market/presentation/screens/market_screen.dart';

// TODO Dev 2 (Fase 2.9): añadir redirect guard aquí
//   redirect: (context, state) { ... consultar authNotifierProvider ... }

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        int selectedIndex = 0;
        final path = state.uri.path;
        if (path.startsWith('/home/lineup')) {
          selectedIndex = 1;
        } else if (path.startsWith('/home/market')) {
          selectedIndex = 2;
        } else if (path.startsWith('/home/finance')) {
          selectedIndex = 3;
        } else if (path.startsWith('/home/gamification')) {
          selectedIndex = 4;
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                case 1:
                  context.go('/home/lineup');
                case 2:
                  context.go('/home/market');
                case 3:
                  context.go('/home/finance');
                case 4:
                  context.go('/home/gamification');
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_soccer_outlined),
                selectedIcon: Icon(Icons.sports_soccer),
                label: 'Alineación',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Mercado',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Finanzas',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Jugar',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/home/lineup',
          builder: (context, state) => const LineupScreen(),
        ),
        GoRoute(
          path: '/home/market',
          builder: (context, state) => const MarketScreen(),
        ),
        GoRoute(
          path: '/home/finance',
          builder: (context, state) => const FinanceScreen(),
        ),
        GoRoute(
          path: '/home/gamification',
          builder: (context, state) => const GamificationHubScreen(),
        ),
        GoRoute(
          path: '/home/gamification/sobre',
          builder: (context, state) => const SobreTacticaScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/league/join/:inviteCode',
      builder: (context, state) {
        final code = state.pathParameters['inviteCode']!;
        return Scaffold(
          body: Center(child: Text('Unirse a liga: $code')),
        );
      },
    ),
  ],
);
