import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/devices_provider.dart';
import '../../providers/tools_config_provider.dart';
import '../../core/models/connection_status.dart';
import '../../core/models/device.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/add_device_modal.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);
    final notifier = ref.read(devicesProvider.notifier);

    return AppShell(
      currentRoute: 'devices',
      child: Column(
        children: [
          _TopBar(
            deviceCount: devicesAsync.maybeWhen(
              data: (list) => list.length,
              orElse: () => 0,
            ),
            onAdd: () => _showAddModal(context, ref),
          ),
          Builder(builder: (context) {
            final p = AppPalette.of(context);
            return Container(height: 1, color: p.divider);
          }),
          Expanded(
            child: devicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Builder(builder: (context) {
                final p = AppPalette.of(context);
                return Center(child: Text('Error: $e', style: TextStyle(color: p.textSecondary)));
              }),
              data: (states) => _DeviceList(
                states: states,
                notifier: notifier,
                onAdd: () => _showAddModal(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AddDeviceModal(
        onSave: (device) => ref.read(devicesProvider.notifier).addDevice(device),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int deviceCount;
  final VoidCallback onAdd;

  const _TopBar({required this.deviceCount, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: p.background,
      child: Row(
        children: [
          Text(
            l.devicesTitle,
            style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: p.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l.devicesCount(deviceCount),
              style: TextStyle(fontSize: 12, color: p.textSecondary),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(l.devicesNewDevice),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceList extends ConsumerWidget {
  final List<DeviceState> states;
  final DevicesNotifier notifier;
  final VoidCallback onAdd;

  const _DeviceList({
    required this.states,
    required this.notifier,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final wifiDevices = states.where((s) => s.device.type == ConnectionType.wifi).toList();
    final usbDevices = states.where((s) => s.device.type == ConnectionType.usb).toList();

    final scrcpyPath = ref.watch(toolsConfigProvider).maybeWhen(
      data: (c) => c.scrcpyPath,
      orElse: () => '',
    );
    final hasScrcpy = scrcpyPath.isNotEmpty;

    if (states.isEmpty) {
      return _EmptyState(onAdd: onAdd);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wifiDevices.isNotEmpty) ...[
            _SectionLabel(label: l.devicesSectionWifi, count: wifiDevices.length),
            const SizedBox(height: 10),
            ...wifiDevices.map((s) => _DeviceCard(
              state: s,
              onConnect: () => notifier.connect(s.device),
              onDisconnect: () => notifier.disconnect(s.device),
              onDelete: () => _confirmDelete(context, s.device, notifier),
              onScrcpy: hasScrcpy ? () => notifier.launchScrcpy(s.device) : null,
            )),
          ],
          if (usbDevices.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionLabel(label: l.devicesSectionUsb, count: usbDevices.length),
            const SizedBox(height: 10),
            ...usbDevices.map((s) => _DeviceCard(
              state: s,
              onConnect: () => notifier.connect(s.device),
              onDisconnect: () => notifier.disconnect(s.device),
              onDelete: () => _confirmDelete(context, s.device, notifier),
              onScrcpy: hasScrcpy ? () => notifier.launchScrcpy(s.device) : null,
            )),
          ],
          const SizedBox(height: 24),
          _GlobalShortcuts(),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Device device, DevicesNotifier notifier) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l.devicesDeleteTitle, style: TextStyle(color: p.textPrimary)),
        content: Text(l.devicesDeleteConfirm(device.alias), style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () {
              notifier.deleteDevice(device.id);
              Navigator.pop(ctx);
            },
            child: Text(l.actionDelete, style: TextStyle(color: p.statusError)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;

  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: p.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: p.surfaceHighlight, borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: TextStyle(fontSize: 11, color: p.textSecondary)),
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final DeviceState state;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onDelete;
  final VoidCallback? onScrcpy;

  const _DeviceCard({
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    this.onScrcpy,
  });

  Color _statusColor(AppPalette p) => switch (state.status) {
    ConnectionStatus.connected => p.statusConnected,
    ConnectionStatus.reconnecting => p.statusReconnecting,
    ConnectionStatus.offline => p.statusOffline,
    ConnectionStatus.error => p.statusError,
  };

  String _statusLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (state.status) {
      ConnectionStatus.connected => l.statusConnected,
      ConnectionStatus.reconnecting => l.statusReconnecting,
      ConnectionStatus.offline => l.statusOffline,
      ConnectionStatus.error => l.statusError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final isConnected = state.status == ConnectionStatus.connected;
    final statusColor = _statusColor(p);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 72,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(state.device.alias, style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _StatusBadge(label: _statusLabel(context), color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        state.device.serial ?? '${state.device.host}:${state.device.port}',
                        style: TextStyle(color: p.textSecondary, fontSize: 12),
                      ),
                      if (state.device.lastConnected != null) ...[
                        Text(' · ', style: TextStyle(color: p.textDisabled)),
                        Text(
                          l.devicesTimeAgo(_timeAgo(state.device.lastConnected!)),
                          style: TextStyle(color: p.textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (isConnected && onScrcpy != null) ...[
                  _ActionButton(label: 'scrcpy', color: p.accent, icon: Icons.cast, onTap: onScrcpy!),
                  const SizedBox(width: 8),
                ],
                if (isConnected)
                  _ActionButton(label: l.actionDisconnect, color: p.statusError, onTap: onDisconnect)
                else
                  _ActionButton(label: l.actionConnect, color: p.statusConnected, onTap: onConnect),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.more_horiz, size: 18, color: p.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}min';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const _ActionButton({required this.label, required this.color, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 5)],
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _GlobalShortcuts extends StatelessWidget {
  const _GlobalShortcuts();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l.devicesGlobalShortcuts, style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(child: Text(l.actionEdit, style: TextStyle(color: p.primaryBlue, fontSize: 12))),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ShortcutChip(label: 'Shell', icon: Icons.terminal),
            _ShortcutChip(label: 'Logcat', icon: Icons.list_alt),
            _ShortcutChip(label: 'File Manager', icon: Icons.folder_outlined),
            _ShortcutChip(label: 'Capturas', icon: Icons.photo_camera_outlined),
          ],
        ),
      ],
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ShortcutChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: p.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: p.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices, size: 48, color: p.textDisabled),
          const SizedBox(height: 16),
          Text(l.devicesEmptyTitle, style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(l.devicesEmptySubtitle, style: TextStyle(color: p.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(l.devicesAddDevice),
            style: ElevatedButton.styleFrom(backgroundColor: p.primaryBlue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
