import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/devices_provider.dart';
import '../../providers/shortcuts_provider.dart';
import '../../providers/tools_config_provider.dart';
import '../../core/models/connection_status.dart';
import '../../core/models/device.dart';
import '../../core/models/shortcut.dart';
import '../../core/services/adb_service.dart';
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

class _DeviceList extends ConsumerStatefulWidget {
  final List<DeviceState> states;
  final DevicesNotifier notifier;
  final VoidCallback onAdd;

  const _DeviceList({
    required this.states,
    required this.notifier,
    required this.onAdd,
  });

  @override
  ConsumerState<_DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends ConsumerState<_DeviceList> {
  String? _selectedDeviceId;

  Device? get _selectedDevice {
    if (_selectedDeviceId == null) return null;
    return widget.states
        .where((s) => s.device.id == _selectedDeviceId)
        .map((s) => s.device)
        .firstOrNull;
  }

  void _toggleSelection(String deviceId) {
    setState(() => _selectedDeviceId = _selectedDeviceId == deviceId ? null : deviceId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Auto-clear selection if the device was deleted
    if (_selectedDeviceId != null &&
        !widget.states.any((s) => s.device.id == _selectedDeviceId)) {
      _selectedDeviceId = null;
    }

    final wifiDevices = widget.states.where((s) => s.device.type == ConnectionType.wifi).toList();
    final usbDevices = widget.states.where((s) => s.device.type == ConnectionType.usb).toList();

    final scrcpyPath = ref.watch(toolsConfigProvider).maybeWhen(
      data: (c) => c.scrcpyPath,
      orElse: () => '',
    );
    final hasScrcpy = scrcpyPath.isNotEmpty;

    if (widget.states.isEmpty) {
      return _EmptyState(onAdd: widget.onAdd);
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
              isSelected: s.device.id == _selectedDeviceId,
              onSelect: () => _toggleSelection(s.device.id),
              onConnect: () => widget.notifier.connect(s.device),
              onDisconnect: () => widget.notifier.disconnect(s.device),
              onDelete: () => _confirmDelete(context, s.device, widget.notifier),
              onScrcpy: hasScrcpy ? () => widget.notifier.launchScrcpy(s.device) : null,
            )),
          ],
          if (usbDevices.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionLabel(label: l.devicesSectionUsb, count: usbDevices.length),
            const SizedBox(height: 10),
            ...usbDevices.map((s) => _DeviceCard(
              state: s,
              isSelected: s.device.id == _selectedDeviceId,
              onSelect: () => _toggleSelection(s.device.id),
              onConnect: () => widget.notifier.connect(s.device),
              onDisconnect: () => widget.notifier.disconnect(s.device),
              onDelete: () => _confirmDelete(context, s.device, widget.notifier),
              onScrcpy: hasScrcpy ? () => widget.notifier.launchScrcpy(s.device) : null,
            )),
          ],
          const SizedBox(height: 24),
          _GlobalShortcuts(
            allStates: widget.states,
            selectedDevice: _selectedDevice,
            notifier: widget.notifier,
          ),
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

// ── Device card ───────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final DeviceState state;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onDelete;
  final VoidCallback? onScrcpy;

  const _DeviceCard({
    required this.state,
    required this.isSelected,
    required this.onSelect,
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

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? p.primaryBlue.withValues(alpha: 0.06) : p.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? p.primaryBlue : p.borderColor,
          width: isSelected ? 1.5 : 1,
        ),
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
                  child: Tooltip(
                    message: l.actionDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: p.statusError.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.delete_outline, size: 16, color: p.statusError),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ), // AnimatedContainer
    ); // GestureDetector
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

// ── Shortcut run dialog ───────────────────────────────────────────────────────

class _ShortcutRunDialog extends StatefulWidget {
  final Shortcut shortcut;
  final String deviceAlias;
  final Future<AdbResult?> Function() runFn;

  const _ShortcutRunDialog({
    required this.shortcut,
    required this.deviceAlias,
    required this.runFn,
  });

  @override
  State<_ShortcutRunDialog> createState() => _ShortcutRunDialogState();
}

class _ShortcutRunDialogState extends State<_ShortcutRunDialog> {
  AdbResult? _result;

  @override
  void initState() {
    super.initState();
    widget.runFn().then((r) {
      if (mounted) setState(() => _result = r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final l = AppLocalizations.of(context)!;
    final result = _result;
    final isLoading = result == null;

    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Icon(Icons.bolt, size: 16, color: p.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.shortcut.name,
                    style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 18, color: p.textSecondary),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                widget.deviceAlias,
                style: TextStyle(color: p.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Command preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: p.borderColor),
                ),
                child: Text(
                  widget.shortcut.commandTemplate,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: p.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Body
              Flexible(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(strokeWidth: 2),
                            const SizedBox(height: 12),
                            Text(l.shortcutsRunning, style: TextStyle(color: p.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    : _OutputBody(result: result, p: p),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isLoading ? l.actionCancel : l.actionClose,
                      style: TextStyle(color: p.primaryBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutputBody extends StatelessWidget {
  final AdbResult result;
  final AppPalette p;

  const _OutputBody({required this.result, required this.p});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasOutput = result.message != null && result.message!.isNotEmpty;
    final hasError = result.error != null && result.error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status row
        Row(children: [
          Icon(
            result.success ? Icons.check_circle_outline : Icons.error_outline,
            size: 14,
            color: result.success ? p.statusConnected : p.statusError,
          ),
          const SizedBox(width: 6),
          Text(
            result.success ? l.shortcutsCompleted : l.shortcutsFailed,
            style: TextStyle(
              color: result.success ? p.statusConnected : p.statusError,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),

        if (hasOutput || hasError) ...[
          const SizedBox(height: 10),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.borderColor),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasOutput)
                      SelectableText(
                        result.message!,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: p.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    if (hasOutput && hasError) const SizedBox(height: 8),
                    if (hasError)
                      SelectableText(
                        result.error!,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: p.statusError,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Text(l.shortcutsNoOutput, style: TextStyle(color: p.textDisabled, fontSize: 12)),
        ],
      ],
    );
  }
}

// ── Global shortcuts ──────────────────────────────────────────────────────────

class _GlobalShortcuts extends ConsumerWidget {
  final List<DeviceState> allStates;
  final Device? selectedDevice;
  final DevicesNotifier notifier;

  const _GlobalShortcuts({
    required this.allStates,
    required this.selectedDevice,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);

    final globalShortcuts = ref.watch(shortcutsProvider).maybeWhen(
      data: (s) => s,
      orElse: () => <Shortcut>[],
    );

    if (globalShortcuts.isEmpty) return const SizedBox.shrink();

    final connected = allStates
        .where((s) => s.status == ConnectionStatus.connected)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l.navShortcuts,
                style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            if (selectedDevice != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: p.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  selectedDevice!.alias,
                  style: TextStyle(fontSize: 11, color: p.primaryBlue, fontWeight: FontWeight.w500),
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/shortcuts'),
              child: Text(l.actionEdit, style: TextStyle(color: p.primaryBlue, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: globalShortcuts
              .map((s) => _ShortcutChip(
                    shortcut: s,
                    onTap: () => _handleTap(context, s, connected),
                  ))
              .toList(),
        ),
        if (selectedDevice == null && connected.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.devicesShortcutHint,
              style: TextStyle(fontSize: 11, color: p.textDisabled),
            ),
          ),
      ],
    );
  }

  void _handleTap(
    BuildContext context,
    Shortcut shortcut,
    List<DeviceState> connected,
  ) {
    // Priority 1: use the selected device directly — no picker needed
    if (selectedDevice != null) {
      _runOn(context, shortcut, selectedDevice!);
      return;
    }

    if (connected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.devicesNoConnected),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Priority 2: single connected device — auto-dispatch
    if (connected.length == 1) {
      _runOn(context, shortcut, connected.first.device);
      return;
    }

    // Multiple connected — show device picker
    showDialog(
      context: context,
      builder: (_) => _DevicePickerDialog(
        shortcut: shortcut,
        devices: connected,
        onSelect: (device) => _runOn(context, shortcut, device),
      ),
    );
  }

  void _runOn(BuildContext context, Shortcut shortcut, Device device) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ShortcutRunDialog(
        shortcut: shortcut,
        deviceAlias: device.alias,
        runFn: () => notifier.runShortcut(device, shortcut.commandTemplate),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final Shortcut shortcut;
  final VoidCallback onTap;

  const _ShortcutChip({required this.shortcut, required this.onTap});

  IconData _icon() => switch (shortcut.icon) {
    'terminal' => Icons.terminal,
    'list_alt' => Icons.list_alt,
    'folder' => Icons.folder_outlined,
    'photo_camera' => Icons.photo_camera_outlined,
    'restart_alt' => Icons.restart_alt,
    'install_mobile' => Icons.install_mobile,
    _ => Icons.bolt,
  };

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: p.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(), size: 14, color: p.textSecondary),
            const SizedBox(width: 6),
            Text(shortcut.name, style: TextStyle(fontSize: 12, color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Device picker dialog (for global shortcuts with 2+ connected devices) ─────

class _DevicePickerDialog extends StatelessWidget {
  final Shortcut shortcut;
  final List<DeviceState> devices;
  final void Function(Device) onSelect;

  const _DevicePickerDialog({
    required this.shortcut,
    required this.devices,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final l = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shortcut.name,
                style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(l.devicesSelectDevice,
                  style: TextStyle(color: p.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
              ...devices.map((ds) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(ds.device);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: p.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: p.borderColor),
                      ),
                      child: Row(children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: p.statusConnected,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ds.device.alias,
                                  style: TextStyle(
                                      color: p.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                ds.device.serial ?? '${ds.device.host}:${ds.device.port}',
                                style: TextStyle(color: p.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16, color: p.textDisabled),
                      ]),
                    ),
                  )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.actionCancel, style: TextStyle(color: p.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

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
          Text(l.devicesEmptyTitle,
              style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
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
