import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/devices_provider.dart';
import '../../core/models/connection_status.dart';
import '../../core/models/device.dart';
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
          // Top bar
          _TopBar(
            deviceCount: devicesAsync.maybeWhen(
              data: (list) => list.length,
              orElse: () => 0,
            ),
            onAdd: () => _showAddModal(context, ref),
          ),
          Container(height: 1, color: AppColors.divider),

          // Content
          Expanded(
            child: devicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.textSecondary))),
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.background,
      child: Row(
        children: [
          const Text(
            'Mis Dispositivos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$deviceCount dispositivo${deviceCount != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add device'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.borderColor),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nuevo Dispositivo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
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

class _DeviceList extends StatelessWidget {
  final List<DeviceState> states;
  final DevicesNotifier notifier;
  final VoidCallback onAdd;

  const _DeviceList({
    required this.states,
    required this.notifier,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final wifiDevices = states.where((s) => s.device.type == ConnectionType.wifi).toList();
    final usbDevices = states.where((s) => s.device.type == ConnectionType.usb).toList();

    if (states.isEmpty) {
      return _EmptyState(onAdd: onAdd);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wifiDevices.isNotEmpty) ...[
            _SectionLabel(label: 'WiFi / TCP-IP', count: wifiDevices.length),
            const SizedBox(height: 10),
            ...wifiDevices.map((s) => _DeviceCard(
              state: s,
              onConnect: () => notifier.connect(s.device),
              onDisconnect: () => notifier.disconnect(s.device),
              onDelete: () => _confirmDelete(context, s.device, notifier),
            )),
          ],
          if (usbDevices.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionLabel(label: 'USB / TCP-IP', count: usbDevices.length),
            const SizedBox(height: 10),
            ...usbDevices.map((s) => _DeviceCard(
              state: s,
              onConnect: () => notifier.connect(s.device),
              onDisconnect: () => notifier.disconnect(s.device),
              onDelete: () => _confirmDelete(context, s.device, notifier),
            )),
          ],
          const SizedBox(height: 24),
          _GlobalShortcuts(),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Device device, DevicesNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar dispositivo', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Eliminar "${device.alias}"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              notifier.deleteDevice(device.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.statusError)),
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
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
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

  const _DeviceCard({
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
  });

  Color get _statusColor {
    return switch (state.status) {
      ConnectionStatus.connected => AppColors.statusConnected,
      ConnectionStatus.reconnecting => AppColors.statusReconnecting,
      ConnectionStatus.offline => AppColors.statusOffline,
      ConnectionStatus.error => AppColors.statusError,
    };
  }

  String get _statusLabel {
    return switch (state.status) {
      ConnectionStatus.connected => 'Conectado',
      ConnectionStatus.reconnecting => 'Reconectando...',
      ConnectionStatus.offline => 'Sin conexión',
      ConnectionStatus.error => 'Sin red',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = state.status == ConnectionStatus.connected;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          // Left status bar
          Container(
            width: 3,
            height: 72,
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),

          // Device info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.device.alias,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(label: _statusLabel, color: _statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        state.device.serial ?? '${state.device.host}:${state.device.port}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (state.device.lastConnected != null) ...[
                        const Text(' · ', style: TextStyle(color: AppColors.textDisabled)),
                        Text(
                          'Hace ${_timeAgo(state.device.lastConnected!)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (isConnected)
                  _ActionButton(
                    label: 'Desconectar',
                    color: AppColors.statusError,
                    onTap: onDisconnect,
                  )
                else
                  _ActionButton(
                    label: 'Conectar',
                    color: AppColors.statusConnected,
                    onTap: onConnect,
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
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
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _GlobalShortcuts extends StatelessWidget {
  const _GlobalShortcuts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Accesos Rápidos Globales',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              child: const Text('Editar', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices, size: 48, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          const Text('Sin dispositivos guardados', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Agrega un dispositivo WiFi para comenzar', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar Dispositivo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
