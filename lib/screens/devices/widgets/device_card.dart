import 'package:flutter/material.dart';
import '../../../core/models/device.dart';
import '../../../core/models/connection_status.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../shared/theme/app_colors.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final ConnectionStatus status;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeviceCard({
    super.key,
    required this.device,
    required this.status,
    this.onConnect,
    this.onDisconnect,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == ConnectionStatus.connected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.alias,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSubtitle(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(status: status, small: true),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isConnected)
                  ElevatedButton.icon(
                    onPressed: onDisconnect,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusError,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onConnect,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Connect'),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    if (device.host != null && device.port != null) {
      return '${device.host}:${device.port}';
    } else if (device.serial != null) {
      return device.serial!;
    }
    return 'No connection info';
  }
}
