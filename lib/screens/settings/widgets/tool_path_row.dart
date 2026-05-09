import 'package:flutter/material.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/connection_status.dart';
import '../../../core/services/tools_config_service.dart';

class ToolPathRow extends StatefulWidget {
  final String label;
  final String iconName;
  final String currentPath;
  final Future<String?> Function() onAutoDetect;
  final Future<ToolVerifyResult> Function(String path) onVerify;
  final Function(String path) onPathChanged;

  const ToolPathRow({
    Key? key,
    required this.label,
    required this.iconName,
    required this.currentPath,
    required this.onAutoDetect,
    required this.onVerify,
    required this.onPathChanged,
  }) : super(key: key);

  @override
  State<ToolPathRow> createState() => _ToolPathRowState();
}

class _ToolPathRowState extends State<ToolPathRow> {
  late TextEditingController _controller;
  bool _isDetecting = false;
  bool _isVerifying = false;
  ToolVerifyResult? _verifyResult;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPath);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAutoDetect() async {
    setState(() => _isDetecting = true);
    try {
      final detectedPath = await widget.onAutoDetect();
      if (detectedPath != null) {
        _controller.text = detectedPath;
        widget.onPathChanged(detectedPath);
      } else {
        _showSnackBar('Could not detect ${widget.label} automatically');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  Future<void> _handleVerify() async {
    setState(() => _isVerifying = true);
    try {
      final result = await widget.onVerify(_controller.text);
      setState(() => _verifyResult = result);

      if (result.success) {
        _showSnackBar('${widget.label} verified: ${result.version}');
      } else {
        _showSnackBar('Verification failed: ${result.error}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _verifyResult?.success ?? false ? ConnectionStatus.connected : ConnectionStatus.offline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconData(), size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_verifyResult != null)
                StatusPill(
                  status: status,
                  small: true,
                  label: _verifyResult!.success ? 'Verified' : 'Failed',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onPathChanged,
                  decoration: InputDecoration(
                    hintText: 'Enter path to ${widget.label.toLowerCase()}',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Auto-detect',
                onPressed: _isDetecting ? null : _handleAutoDetect,
                icon: _isDetecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.find_in_page),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Verify',
                onPressed: _isVerifying || _controller.text.isEmpty ? null : _handleVerify,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconData() {
    return switch (widget.iconName) {
      'adb' => Icons.phone_android,
      'scrcpy' => Icons.screenshot_monitor,
      _ => Icons.build,
    };
  }
}
