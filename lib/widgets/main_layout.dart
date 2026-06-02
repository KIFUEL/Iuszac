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
      if (location.startsWith('/mentorship')) return 2;
      if (location.startsWith('/profile')) return 3;
      return 0;
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 800,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Actualizaciones'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum),
                label: Text('Foro'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people),
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
                case 2: context.go('/mentorship'); break;
                case 3: context.go('/profile'); break;
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
