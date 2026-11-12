import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const shellTabLocations = ['/home', '/search', '/add', '/settings'];

StatefulNavigationShell? libraryNavigationShell;

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.location,
    required this.navigationShell,
  });

  final Widget child;
  final String location;
  final StatefulNavigationShell? navigationShell;

  @override
  Widget build(BuildContext context) {
    final onBook = location == '/book' || location.startsWith('/book/');
    final selected = navigationShell?.currentIndex ?? 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (index) {
          final shell = navigationShell;
          if (onBook || shell == null) {
            context.go(shellTabLocations[index]);
            return;
          }
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Поиск',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Добавить',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
