import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    return BottomNavigationBar(
      currentIndex: _getSelectedIndex(location),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.push('/profile');
            break;
        }
      },
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/profile':
        return 1;
      case '/home':
      default:
        return 0;
    }
  }
}
