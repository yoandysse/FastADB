import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/device.dart';
import '../../../core/models/connection_status.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class AddDeviceModal extends StatefulWidget {
  final Function(Device) onSave;
  final Device? editDevice;

  const AddDeviceModal({super.key, required this.onSave, this.editDevice});

  @override
  State<AddDeviceModal> createState() => _AddDeviceModalState();
}

class _AddDeviceModalState extends State<AddDeviceModal> {
  ConnectionType _type = ConnectionType.wifi;
  final _aliasController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '5555');
  bool _autoReconnect = false;

  @override
  void initState() {
    super.initState();
    if (widget.editDevice != null) {
      final d = widget.editDevice!;
      _type = d.type;
      _aliasController.text = d.alias;
      _ipController.text = d.host ?? '';
      _portController.text = d.port?.toString() ?? '5555';
      _autoReconnect = d.autoReconnect;
    }
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _save() {
    if (_aliasController.text.trim().isEmpty) return;
    if (_type == ConnectionType.wifi && _ipController.text.trim().isEmpty) return;

    final device = Device(
      id: widget.editDevice?.id ?? const Uuid().v4(),
      alias: _aliasController.text.trim(),
      host: _type == ConnectionType.wifi ? _ipController.text.trim() : null,
      port: _type == ConnectionType.wifi ? int.tryParse(_portController.text) ?? 5555 : null,
      type: _type,
      autoReconnect: _autoReconnect,
    );

    widget.onSave(device);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Center(
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxHeight: 680),
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModalHeader(
                title: widget.editDevice == null ? l.modalAddTitle : l.modalEditTitle,
                subtitle: l.modalSubtitle,
                onClose: () => Navigator.pop(context),
              ),
              Container(height: 1, color: p.divider),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.modalConnectionType,
                          style: TextStyle(color: p.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeOption(
                              icon: Icons.wifi,
                              title: l.modalWifiTitle,
                              subtitle: l.modalWifiSubtitle,
                              selected: _type == ConnectionType.wifi,
                              onTap: () => setState(() => _type = ConnectionType.wifi),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeOption(
                              icon: Icons.usb,
                              title: l.modalUsbTitle,
                              subtitle: l.modalUsbSubtitle,
                              selected: _type == ConnectionType.usb,
                              onTap: () => setState(() => _type = ConnectionType.usb),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _FieldLabel(label: l.modalAliasLabel),
                      const SizedBox(height: 8),
                      _StyledField(controller: _aliasController, hint: l.modalAliasHint),

                      if (_type == ConnectionType.wifi) ...[
                        const SizedBox(height: 20),
                        _FieldLabel(label: l.modalIpPortLabel),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _StyledField(controller: _ipController, hint: '192.168.1.100', keyboardType: TextInputType.number),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StyledField(controller: _portController, hint: '5555', keyboardType: TextInputType.number),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => setState(() => _autoReconnect = !_autoReconnect),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _autoReconnect ? p.primaryBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _autoReconnect ? p.primaryBlue : p.borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: _autoReconnect ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.modalAutoReconnectTitle,
                                      style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                                  Text(l.modalAutoReconnectSubtitle,
                                      style: TextStyle(color: p.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(l.modalShortcutsLabel,
                          style: TextStyle(color: p.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: const [
                          _ShortcutTag(label: 'scrcpy', selected: true),
                          _ShortcutTag(label: 'Shell', selected: false),
                          _ShortcutTag(label: 'Logcat', selected: false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: p.divider),
              _ModalFooter(onCancel: () => Navigator.pop(context), onSave: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _ModalHeader({required this.title, required this.subtitle, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      color: p.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: p.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: p.surfaceHighlight, borderRadius: BorderRadius.circular(6)),
              child: Icon(Icons.close, size: 16, color: p.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ModalFooter({required this.onCancel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      color: p.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(color: p.surfaceHighlight, borderRadius: BorderRadius.circular(6)),
              child: Text(l.actionCancel, style: TextStyle(color: p.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(color: p.primaryBlue, borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  const Icon(Icons.save_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(l.modalSaveDevice, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? p.primaryBlue.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? p.primaryBlue : p.borderColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? p.primaryBlue : p.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: selected ? p.textPrimary : p.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: p.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Text(label, style: TextStyle(color: p.textSecondary, fontSize: 13, fontWeight: FontWeight.w500));
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _StyledField({required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: p.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textDisabled, fontSize: 13),
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.primaryBlue, width: 1.5)),
        isDense: true,
      ),
    );
  }
}

class _ShortcutTag extends StatelessWidget {
  final String label;
  final bool selected;

  const _ShortcutTag({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? p.accent.withValues(alpha: 0.12) : p.surfaceHighlight,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: selected ? p.accent.withValues(alpha: 0.4) : p.borderColor),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: selected ? p.accent : p.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}
