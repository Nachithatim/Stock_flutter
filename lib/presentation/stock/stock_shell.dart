import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';

class StockShell extends ConsumerWidget {
  const StockShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseReady = ref.watch(firebaseReadyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de stock'),
        actions: [
          if (!firebaseReady)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Chip(label: Text('Demo locale')),
            ),
          IconButton(
            tooltip: 'Deconnexion',
            onPressed: firebaseReady
                ? () => ref.read(authRepositoryProvider).signOut()
                : null,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produits',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert_circle_outlined),
            selectedIcon: Icon(Icons.swap_vert_circle),
            label: 'Mouvements',
          ),
        ],
      ),
    );
  }
}
