import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/stock/movements_screen.dart';
import '../../presentation/stock/products_screen.dart';
import '../../presentation/stock/stock_shell.dart';
import '../../providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  return GoRouter(
    initialLocation: firebaseReady ? '/login' : '/dashboard',
    redirect: (context, state) {
      if (!firebaseReady) {
        return state.matchedLocation == '/login' ? '/dashboard' : null;
      }
      final isLogin = state.matchedLocation == '/login';
      if (user == null && !isLogin) {
        return '/login';
      }
      if (user != null && isLogin) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StockShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movements',
                builder: (context, state) => const MovementsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route introuvable: ${state.uri}'))),
  );
});
