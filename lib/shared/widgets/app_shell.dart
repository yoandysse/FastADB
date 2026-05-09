import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String? currentRoute;

  const AppShell({
    Key? key,
    required this.child,
    this.currentRoute,
  }) : super(key: key);

  void _navigate(BuildContext context, String path) {
    context.goNamed(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastADB'),
        elevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _getSelectedIndex(currentRoute),
            onDestinationSelected: (int index) {
              final routes = ['devices', 'usb', 'shortcuts', 'settings'];
              if (index < routes.length) {
                _navigate(context, routes[index]);
              }
            },
            backgroundColor: AppColors.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.devices),
                label: Text('Devices'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.usb),
                label: Text('USB'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flash_on),
                label: Text('Shortcuts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String? route) {
    final routes = ['devices', 'usb', 'shortcuts', 'settings'];
    final index = routes.indexOf(route ?? 'devices');
    return index >= 0 ? index : 0;
  }
}
