import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/devices/devices_screen.dart';
import '../screens/usb/usb_screen.dart';
import '../screens/shortcuts/shortcuts_screen.dart';
import '../screens/settings/settings_screen.dart';

Page<void> _noTransition(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    );

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'devices',
      pageBuilder: (context, state) => _noTransition(const DevicesScreen(), state),
    ),
    GoRoute(
      path: '/usb',
      name: 'usb',
      pageBuilder: (context, state) => _noTransition(const UsbScreen(), state),
    ),
    GoRoute(
      path: '/shortcuts',
      name: 'shortcuts',
      pageBuilder: (context, state) => _noTransition(const ShortcutsScreen(), state),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => _noTransition(const SettingsScreen(), state),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
