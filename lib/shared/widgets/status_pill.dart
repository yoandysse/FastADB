import 'package:flutter/material.dart';
import '../../core/models/connection_status.dart';
import '../theme/app_colors.dart';

class StatusPill extends StatelessWidget {
  final ConnectionStatus status;
  final String? label;
  final bool small;

  const StatusPill({
    Key? key,
    required this.status,
    this.label,
    this.small = false,
  }) : super(key: key);

  Color _getStatusColor() {
    return switch (status) {
      ConnectionStatus.connected => AppColors.statusConnected,
      ConnectionStatus.reconnecting => AppColors.statusReconnecting,
      ConnectionStatus.offline => AppColors.statusOffline,
      ConnectionStatus.error => AppColors.statusError,
    };
  }

  String _getStatusLabel() {
    if (label != null) return label!;
    return switch (status) {
      ConnectionStatus.connected => 'Connected',
      ConnectionStatus.reconnecting => 'Reconnecting...',
      ConnectionStatus.offline => 'Offline',
      ConnectionStatus.error => 'Error',
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final text = _getStatusLabel();
    final fontSize = small ? 11.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
