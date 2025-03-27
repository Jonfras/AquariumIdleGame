import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({required this.child, Key? key}) : super(key: key);

  int _getCurrentIndex(String? location) {
    if (location == '/') return 0;
    if (location == '/shop') return 1;
    if (location == '/settings') return 2;
    return 0; // Standard: Aquarium
  }

  @override
  Widget build(BuildContext context) {
    final String? currentLocation = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Aquarium'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.upgrade), label: 'Upgrades'),
        ],
        currentIndex: _getCurrentIndex(currentLocation),
        selectedItemColor: Colors.blue,
        onTap: (index) {
          if (index == 0) context.go('/');
          if (index == 1) context.go('/shop');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }
}
