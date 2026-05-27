import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/shared/widgets/bottom_navigation.dart';

class BottomNavPage extends StatelessWidget {
  const BottomNavPage({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _routes = [
    '/',
    '/news',
    '/leagues',
    '/favorites',
    '/more',
  ];

  int _selectedIndex(String location) {
    final index = _routes.indexWhere((route) => location == route);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(currentLocation);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: FoverBottomNavigationBar(
        selectedIndex: selectedIndex,
        onTap: (index) {
          context.go(_routes[index]);
        },
      ),
    );
  }
}

