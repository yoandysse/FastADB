import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/devices/devices_screen.dart';
import '../screens/usb/usb_screen.dart';
import '../screens/shortcuts/shortcuts_screen.dart';
import '../screens/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'devices',
      builder: (context, state) => const DevicesScreen(),
    ),
    GoRoute(
      path: '/usb',
      name: 'usb',
      builder: (context, state) => const UsbScreen(),
    ),
    GoRoute(
      path: '/shortcuts',
      name: 'shortcuts',
      builder: (context, state) => const ShortcutsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
