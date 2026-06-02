import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    int getIndex() {
      if (location == '/') return 0;
      if (location.startsWith('/forum')) return 1;
      if (location.startsWith('/alerts')) return 2;
      if (location.startsWith('/mentorship')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    final bool isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: isLargeScreen
          ? Row(
              children: [
                NavigationRail(
                  extended: MediaQuery.of(context).size.width >= 1100,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Inicio'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.forum_outlined),
                      selectedIcon: Icon(Icons.forum),
                      label: Text('Foros'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications),
                      label: Text('Alertas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: Text('Mentorías'),
                    ),
                    NavigationRailDestination(
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
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: !isLargeScreen
          ? NavigationBar(
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum),
                  label: 'Foros',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Alertas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: 'Mentorías',
                ),
                NavigationDestination(
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
