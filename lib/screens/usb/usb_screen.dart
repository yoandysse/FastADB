import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/usb_devices_provider.dart';
import '../../providers/devices_provider.dart';
import '../../providers/tools_config_provider.dart';
import '../../core/models/device.dart';
import '../../core/models/connection_status.dart';
import '../../core/services/adb_service.dart';
import '../../l10n/app_localizations.dart';

class UsbScreen extends ConsumerWidget {
  const UsbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final usbAsync = ref.watch(usbDevicesProvider);
    final savedDevicesAsync = ref.watch(devicesProvider);

    final savedHostPorts = savedDevicesAsync.maybeWhen(
      data: (states) => states
          .map((s) => '${s.device.host}:${s.device.port ?? 5555}')
          .toSet(),
      orElse: () => <String>{},
    );

    return AppShell(
      currentRoute: 'usb',
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: p.background,
            child: Row(
              children: [
                Text(
                  l.usbTitle,
                  style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                usbAsync.maybeWhen(
                  data: (list) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l.usbDeviceCount(list.length),
                      style: TextStyle(fontSize: 12, color: p.textSecondary),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const Spacer(),
                usbAsync.isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5))
                    : Icon(Icons.refresh, size: 16, color: p.textSecondary),
                const SizedBox(width: 6),
                Text(l.usbRefresh, style: TextStyle(color: p.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(height: 1, color: p.divider),

          Expanded(
            child: usbAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Error: $e', style: TextStyle(color: p.textSecondary))),
              data: (devices) {
                final usbDevices = devices
                    .where((d) => !AdbService.isTcpIpSerial(d.serial))
                    .toList();
                final tcpDevices = devices
                    .where((d) => AdbService.isTcpIpSerial(d.serial))
                    .toList();

                if (usbDevices.isEmpty && tcpDevices.isEmpty) {
                  return const _EmptyState();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (usbDevices.isNotEmpty) ...[
                        _SectionLabel(label: l.usbSectionUsb, icon: Icons.usb, count: usbDevices.length),
                        const SizedBox(height: 10),
                        ...usbDevices.map((d) => _UsbDeviceCard(
                              device: d,
                              onActivateWifi: () => _showActivateWifiFlow(context, ref, d),
                            )),
                      ],

                      if (tcpDevices.isNotEmpty) ...[
                        if (usbDevices.isNotEmpty) const SizedBox(height: 24),
                        _SectionLabel(label: l.usbSectionWifi, icon: Icons.wifi, count: tcpDevices.length),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            l.usbWifiSubtitle,
                            style: TextStyle(color: p.textSecondary, fontSize: 12),
                          ),
                        ),
                        ...tcpDevices.map((d) {
                          final alreadySaved = savedHostPorts.contains(d.serial);
                          return _TcpDeviceCard(
                            device: d,
                            alreadySaved: alreadySaved,
                            onSave: alreadySaved ? null : () => _showSaveWifiDialog(context, ref, d),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActivateWifiFlow(BuildContext context, WidgetRef ref, UsbDevice device) async {
    final l = AppLocalizations.of(context)!;
    final config = ref.read(toolsConfigProvider).maybeWhen(data: (c) => c, orElse: () => null);

    if (config == null || config.adbPath.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.usbAdbNotConfigured)),
        );
      }
      return;
    }

    final adb = AdbService(adbPath: config.adbPath);
    await adb.enableTcpip(device.serial);
    final suggestedIp = await adb.getSuggestedIp(device.serial);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => _ActivateWifiDialog(
        device: device,
        initialIp: suggestedIp ?? '',
        onConfirm: (ip, port) {
          final newDevice = Device(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            alias: device.model ?? device.serial,
            host: ip,
            port: port,
            type: ConnectionType.wifi,
          );
          final notifier = ref.read(devicesProvider.notifier);
          notifier.addDevice(newDevice).then((_) => notifier.connect(newDevice));
        },
      ),
    );
  }

  void _showSaveWifiDialog(BuildContext context, WidgetRef ref, UsbDevice device) {
    final lastColon = device.serial.lastIndexOf(':');
    final host = lastColon != -1 ? device.serial.substring(0, lastColon) : device.serial;
    final port = lastColon != -1 ? (int.tryParse(device.serial.substring(lastColon + 1)) ?? 5555) : 5555;

    showDialog(
      context: context,
      builder: (_) => _SaveWifiDialog(
        device: device,
        host: host,
        port: port,
        onSave: (alias) {
          final newDevice = Device(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            alias: alias,
            host: host,
            port: port,
            serial: device.serial,
            type: ConnectionType.wifi,
          );
          ref.read(devicesProvider.notifier).addDevice(newDevice);
        },
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;

  const _SectionLabel({required this.label, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Row(
      children: [
        Icon(icon, size: 13, color: p.textSecondary),
        const SizedBox(width: 6),
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
          decoration: BoxDecoration(
            color: p.surfaceHighlight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$count', style: TextStyle(fontSize: 11, color: p.textSecondary)),
        ),
      ],
    );
  }
}

// ── USB device card ───────────────────────────────────────────────────────────

class _UsbDeviceCard extends StatelessWidget {
  final UsbDevice device;
  final VoidCallback onActivateWifi;

  const _UsbDeviceCard({required this.device, required this.onActivateWifi});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final isConnected = device.status == ConnectionStatus.connected;
    final statusColor = isConnected ? p.statusConnected : p.statusError;

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
            height: 80,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      device.model ?? l.usbUnknownDevice,
                      style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (device.status == ConnectionStatus.error) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.statusReconnecting.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(l.usbUnauthorized,
                            style: TextStyle(fontSize: 11, color: p.statusReconnecting)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 16),
                    Text(device.serial, style: TextStyle(color: p.textSecondary, fontSize: 12)),
                    if (device.androidVersion != null) ...[
                      Text(' · ', style: TextStyle(color: p.textDisabled)),
                      Text('Android ${device.androidVersion}',
                          style: TextStyle(color: p.textSecondary, fontSize: 12)),
                    ],
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              key: ValueKey('activate_wifi_${device.serial}'),
              onPressed: isConnected ? onActivateWifi : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? p.accent.withValues(alpha: 0.12)
                    : p.surfaceHighlight,
                foregroundColor: isConnected ? p.accent : p.textDisabled,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                side: BorderSide(
                  color: isConnected ? p.accent.withValues(alpha: 0.4) : p.borderColor,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              child: Text(l.usbActivateWifi),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TCP/IP device card ────────────────────────────────────────────────────────

class _TcpDeviceCard extends StatelessWidget {
  final UsbDevice device;
  final bool alreadySaved;
  final VoidCallback? onSave;

  const _TcpDeviceCard({required this.device, required this.alreadySaved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
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
              color: p.statusConnected,
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
                  Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: p.statusConnected, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      device.model ?? device.serial,
                      style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.statusConnected.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: p.statusConnected.withValues(alpha: 0.3)),
                      ),
                      child: Text(l.statusConnected,
                          style: TextStyle(fontSize: 11, color: p.statusConnected, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 16),
                    Text(device.serial, style: TextStyle(color: p.textSecondary, fontSize: 12)),
                    if (device.androidVersion != null) ...[
                      Text(' · ', style: TextStyle(color: p.textDisabled)),
                      Text('Android ${device.androidVersion}',
                          style: TextStyle(color: p.textSecondary, fontSize: 12)),
                    ],
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: alreadySaved
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: p.surfaceHighlight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.borderColor),
                    ),
                    child: Text(l.usbAlreadySaved,
                        style: TextStyle(fontSize: 12, color: p.textDisabled, fontWeight: FontWeight.w500)),
                  )
                : ElevatedButton.icon(
                    key: ValueKey('save_wifi_${device.serial}'),
                    onPressed: onSave,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 13),
                    label: Text(l.usbSaveDevice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primaryBlue.withValues(alpha: 0.12),
                      foregroundColor: p.primaryBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      side: BorderSide(color: p.primaryBlue.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Save WiFi dialog ──────────────────────────────────────────────────────────

class _SaveWifiDialog extends StatefulWidget {
  final UsbDevice device;
  final String host;
  final int port;
  final Function(String alias) onSave;

  const _SaveWifiDialog({required this.device, required this.host, required this.port, required this.onSave});

  @override
  State<_SaveWifiDialog> createState() => _SaveWifiDialogState();
}

class _SaveWifiDialogState extends State<_SaveWifiDialog> {
  late TextEditingController _aliasController;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.device.model ?? widget.host);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.usbSaveWifiTitle,
                  style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('${widget.host}:${widget.port}',
                  style: TextStyle(color: p.textSecondary, fontSize: 12)),
              if (widget.device.androidVersion != null)
                Text('Android ${widget.device.androidVersion}',
                    style: TextStyle(color: p.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),
              Text(l.usbSaveWifiNameLabel,
                  style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _aliasController,
                autofocus: true,
                style: TextStyle(color: p.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: p.background,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.primaryBlue)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.actionCancel, style: TextStyle(color: p.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final alias = _aliasController.text.trim();
                      if (alias.isNotEmpty) {
                        widget.onSave(alias);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l.actionSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Activate WiFi ADB dialog ──────────────────────────────────────────────────

class _ActivateWifiDialog extends StatefulWidget {
  final UsbDevice device;
  final String initialIp;
  final Function(String ip, int port) onConfirm;

  const _ActivateWifiDialog({required this.device, this.initialIp = '', required this.onConfirm});

  @override
  State<_ActivateWifiDialog> createState() => _ActivateWifiDialogState();
}

class _ActivateWifiDialogState extends State<_ActivateWifiDialog> {
  late final TextEditingController _ipController;
  final _portController = TextEditingController(text: '5555');

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.initialIp);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.usbActivateWifiTitle,
                  style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l.usbActivateWifiDevice(widget.device.model ?? widget.device.serial),
                  style: TextStyle(color: p.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),
              Text(l.usbActivateWifiIpLabel,
                  style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _ipController,
                      style: TextStyle(color: p.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '192.168.1.100',
                        hintStyle: TextStyle(color: p.textDisabled, fontSize: 13),
                        filled: true,
                        fillColor: p.background,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.primaryBlue)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: p.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: p.background,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.primaryBlue)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.actionCancel, style: TextStyle(color: p.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final ip = _ipController.text.trim();
                      final port = int.tryParse(_portController.text) ?? 5555;
                      if (ip.isNotEmpty) {
                        widget.onConfirm(ip, port);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l.usbActivateWifiConfirm),
                  ),
                ],
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 48, color: p.textDisabled),
          const SizedBox(height: 16),
          Text(l.usbEmptyTitle,
              style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(l.usbEmptySubtitle,
              style: TextStyle(color: p.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(l.usbEmptyHint,
              style: TextStyle(color: p.textDisabled, fontSize: 12)),
        ],
      ),
    );
  }
}
