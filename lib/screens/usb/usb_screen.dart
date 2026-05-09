import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/usb_devices_provider.dart';
import '../../providers/devices_provider.dart';
import '../../core/models/device.dart';
import '../../core/models/connection_status.dart';

class UsbScreen extends ConsumerWidget {
  const UsbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usbAsync = ref.watch(usbDevicesProvider);

    return AppShell(
      currentRoute: 'usb',
      child: Column(
        children: [
          // Top bar
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: AppColors.background,
            child: Row(
              children: [
                const Text(
                  'USB Detectados',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                usbAsync.maybeWhen(
                  data: (list) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${list.length} dispositivo${list.length != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const Spacer(),
                // Polling indicator
                usbAsync.isLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5))
                    : const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                const Text('Actualiza cada 5s', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.divider),

          Expanded(
            child: usbAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: AppColors.textSecondary)),
              ),
              data: (devices) {
                if (devices.isEmpty) {
                  return const _EmptyUsb();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: devices.length,
                  itemBuilder: (context, i) => _UsbDeviceCard(
                    device: devices[i],
                    onActivateWifi: () => _showActivateWifiFlow(context, ref, devices[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActivateWifiFlow(BuildContext context, WidgetRef ref, UsbDevice device) {
    showDialog(
      context: context,
      builder: (_) => _ActivateWifiDialog(
        device: device,
        onConfirm: (ip, port) {
          final newDevice = Device(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            alias: device.model ?? device.serial,
            host: ip,
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

class _UsbDeviceCard extends StatelessWidget {
  final UsbDevice device;
  final VoidCallback onActivateWifi;

  const _UsbDeviceCard({required this.device, required this.onActivateWifi});

  @override
  Widget build(BuildContext context) {
    final isConnected = device.status == ConnectionStatus.connected;
    final statusColor = isConnected ? AppColors.statusConnected : AppColors.statusError;

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
            height: 80,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        device.model ?? 'Dispositivo desconocido',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (device.status == ConnectionStatus.error) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statusReconnecting.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Sin autorizar',
                              style: TextStyle(fontSize: 11, color: AppColors.statusReconnecting)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(device.serial,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      if (device.androidVersion != null) ...[
                        const Text(' · ', style: TextStyle(color: AppColors.textDisabled)),
                        Text('Android ${device.androidVersion}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: isConnected ? onActivateWifi : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isConnected
                        ? AppColors.accent.withValues(alpha: 0.4)
                        : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  'Activar WiFi ADB',
                  style: TextStyle(
                    fontSize: 12,
                    color: isConnected ? AppColors.accent : AppColors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivateWifiDialog extends StatefulWidget {
  final UsbDevice device;
  final Function(String ip, int port) onConfirm;

  const _ActivateWifiDialog({required this.device, required this.onConfirm});

  @override
  State<_ActivateWifiDialog> createState() => _ActivateWifiDialogState();
}

class _ActivateWifiDialogState extends State<_ActivateWifiDialog> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '5555');

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Activar WiFi ADB',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Dispositivo: ${widget.device.model ?? widget.device.serial}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),
              const Text('Dirección IP del dispositivo',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _ipController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '192.168.1.100',
                        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primaryBlue),
                        ),
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
                    child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
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
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Conectar y Guardar'),
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

class _EmptyUsb extends StatelessWidget {
  const _EmptyUsb();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.usb, size: 48, color: AppColors.textDisabled),
          SizedBox(height: 16),
          Text('Sin dispositivos USB detectados',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Conecta un dispositivo Android vía USB',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          SizedBox(height: 4),
          Text('Se detecta automáticamente cada 5 segundos',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
        ],
      ),
    );
  }
}
