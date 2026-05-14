import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_info.dart';
import '../../providers/update_provider.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

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

class _Sidebar extends ConsumerWidget {
  final String currentRoute;

  const _Sidebar({required this.currentRoute});

  void _navigate(BuildContext context, String name) {
    context.goNamed(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final updateState = ref.watch(updateProvider);

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
            child: _UpdateStatus(
              state: updateState,
              onRefresh: () => ref.read(updateProvider.notifier).check(),
              onUpdate: () async {
                final opened = await ref
                    .read(updateProvider.notifier)
                    .openUpdate();
                if (!context.mounted || opened) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.updateOpenFailed)));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateStatus extends StatelessWidget {
  final UpdateState state;
  final VoidCallback onRefresh;
  final VoidCallback onUpdate;

  const _UpdateStatus({
    required this.state,
    required this.onRefresh,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final update = state.update;

    if (update == null) {
      return Tooltip(
        message: state.checking ? l.updateChecking : l.updateUpToDate,
        child: InkWell(
          onTap: state.checking ? null : onRefresh,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppInfo.versionLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: p.textDisabled,
                    letterSpacing: 0.3,
                  ),
                ),
                if (state.checking) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.4,
                      color: p.textDisabled,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.updateAvailableShort('v${update.version}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.accent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: OutlinedButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.download_outlined, size: 13),
              label: Text(
                l.updateAction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.accent,
                side: BorderSide(color: p.accent.withValues(alpha: 0.45)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? p.textPrimary : p.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
