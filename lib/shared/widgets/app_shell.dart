import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(currentRoute: currentRoute),
          Container(width: 1, color: AppColors.divider),
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
    return Container(
      width: 220,
      color: AppColors.surface,
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
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'FastADB',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.divider),

          // Nav items
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.devices_outlined,
                  label: 'Mis Dispositivos',
                  isActive: currentRoute == 'devices',
                  onTap: () => _navigate(context, 'devices'),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.usb_outlined,
                  label: 'USB Detectados',
                  isActive: currentRoute == 'usb',
                  onTap: () => _navigate(context, 'usb'),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.flash_on_outlined,
                  label: 'Accesos Rápidos',
                  isActive: currentRoute == 'shortcuts',
                  onTap: () => _navigate(context, 'shortcuts'),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(height: 1, color: AppColors.divider),

          // Settings at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
            child: _NavItem(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              isActive: currentRoute == 'settings',
              onTap: () => _navigate(context, 'settings'),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.navActive : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
