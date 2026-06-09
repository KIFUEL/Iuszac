import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final updatesAsync = ref.watch(legalUpdatesProvider);
    
    // Obtener el conteo de alertas recientes (últimos 7 días)
    final alertsCount = updatesAsync.maybeWhen(
      data: (updates) {
        final now = DateTime.now();
        return updates.where((u) => now.difference(u.createdAt).inDays <= 7).length;
      },
      orElse: () => 0,
    );
    
    int getIndex() {
      if (location == '/') return 0;
      if (location.startsWith('/forum')) return 1;
      if (location.startsWith('/alerts')) return 2;
      if (location.startsWith('/mentorship')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    final bool isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildAlertsIcon(bool isSelected) {
      final baseIcon = Icon(isSelected ? Icons.notifications : Icons.notifications_outlined);
      if (alertsCount > 0) {
        return Badge(
          label: Text(alertsCount.toString()),
          child: baseIcon,
        );
      }
      return baseIcon;
    }

    return Scaffold(
      body: isLargeScreen
          ? Row(
              children: [
                NavigationRail(
                  extended: MediaQuery.of(context).size.width >= 1100,
                  // Subtle gavel logo at the top of the rail
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Inicio'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.forum_outlined),
                      selectedIcon: Icon(Icons.forum),
                      label: Text('Foros'),
                    ),
                    NavigationRailDestination(
                      icon: buildAlertsIcon(false),
                      selectedIcon: buildAlertsIcon(true),
                      label: const Text('Alertas'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: Text('Mentorías'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Perfil'),
                    ),
                  ],
                  selectedIndex: getIndex(),
                  onDestinationSelected: (index) {
                    switch (index) {
                      case 0: context.go('/'); break;
                      case 1: context.go('/forum'); break;
                      case 2: context.go('/alerts'); break;
                      case 3: context.go('/mentorship'); break;
                      case 4: context.go('/profile'); break;
                    }
                  },
                ),
                // Subtle separator instead of plain VerticalDivider
                Container(width: 1, color: Colors.grey.withValues(alpha: 0.08)),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: !isLargeScreen
          ? NavigationBar(
              elevation: 2,
              surfaceTintColor: colorScheme.primary,
              selectedIndex: getIndex(),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0: context.go('/'); break;
                  case 1: context.go('/forum'); break;
                  case 2: context.go('/alerts'); break;
                  case 3: context.go('/mentorship'); break;
                  case 4: context.go('/profile'); break;
                }
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum),
                  label: 'Foros',
                ),
                NavigationDestination(
                  icon: buildAlertsIcon(false),
                  selectedIcon: buildAlertsIcon(true),
                  label: 'Alertas',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: 'Mentorías',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            )
          : null,
    );
  }
}
