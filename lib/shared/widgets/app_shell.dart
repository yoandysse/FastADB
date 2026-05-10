import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    Key? key,
    required this.child,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      backgroundColor: p.background,
      body: Row(
        children: [
          _Sidebar(currentRoute: currentRoute),
          Container(width: 1, color: p.divider),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentRoute;

  const _Sidebar({required this.currentRoute});

  void _navigate(BuildContext context, String name) {
    context.goNamed(name);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);

    return Container(
      width: 220,
      color: p.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.bolt, color: p.accent, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'FastADB',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: p.divider),

          // Nav items
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.devices_outlined,
                  label: l.navDevices,
                  isActive: currentRoute == 'devices',
                  onTap: () => _navigate(context, 'devices'),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.usb_outlined,
                  label: l.navUsb,
                  isActive: currentRoute == 'usb',
                  onTap: () => _navigate(context, 'usb'),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.flash_on_outlined,
                  label: l.navShortcuts,
                  isActive: currentRoute == 'shortcuts',
                  onTap: () => _navigate(context, 'shortcuts'),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(height: 1, color: p.divider),

          // Settings at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: _NavItem(
              icon: Icons.settings_outlined,
              label: l.navSettings,
              isActive: currentRoute == 'settings',
              onTap: () => _navigate(context, 'settings'),
            ),
          ),

          // Version label
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 10,
                  color: p.textDisabled,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? p.navActive : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? p.textPrimary : p.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? p.textPrimary : p.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
