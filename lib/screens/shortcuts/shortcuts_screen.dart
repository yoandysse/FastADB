import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../core/models/shortcut.dart';
import '../../providers/shortcuts_provider.dart';
import '../../l10n/app_localizations.dart';

class ShortcutsScreen extends ConsumerWidget {
  const ShortcutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final shortcutsAsync = ref.watch(shortcutsProvider);
    final notifier = ref.read(shortcutsProvider.notifier);

    return AppShell(
      currentRoute: 'shortcuts',
      child: Column(
        children: [
          _TopBar(onAdd: () => _showEditModal(context, notifier, null)),
          Container(height: 1, color: p.divider),
          Expanded(
            child: shortcutsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: p.statusError))),
              data: (shortcuts) => shortcuts.isEmpty
                  ? _EmptyState(onAdd: () => _showEditModal(context, notifier, null))
                  : _ShortcutList(
                      shortcuts: shortcuts,
                      onEdit: (s) => _showEditModal(context, notifier, s),
                      onDelete: (s) => _confirmDelete(context, s, notifier),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, ShortcutsNotifier notifier, Shortcut? existing) {
    showDialog(
      context: context,
      builder: (_) => _ShortcutModal(
        existing: existing,
        onSave: (s) => existing == null ? notifier.addShortcut(s) : notifier.updateShortcut(s),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Shortcut shortcut, ShortcutsNotifier notifier) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l.shortcutsDeleteTitle, style: TextStyle(color: p.textPrimary)),
        content: Text(l.shortcutsDeleteConfirm(shortcut.name), style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () {
              notifier.deleteShortcut(shortcut.id);
              Navigator.pop(ctx);
            },
            child: Text(l.actionDelete, style: TextStyle(color: p.statusError)),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onAdd;

  const _TopBar({required this.onAdd});

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
            l.shortcutsTitle,
            style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(l.shortcutsNew),
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

class _ShortcutList extends StatelessWidget {
  final List<Shortcut> shortcuts;
  final void Function(Shortcut) onEdit;
  final void Function(Shortcut) onDelete;

  const _ShortcutList({
    required this.shortcuts,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...shortcuts.map((s) => _ShortcutCard(shortcut: s, onEdit: onEdit, onDelete: onDelete)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.surfaceHighlight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: p.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.shortcutsDeviceHint,
                    style: TextStyle(fontSize: 11, color: p.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final Shortcut shortcut;
  final void Function(Shortcut) onEdit;
  final void Function(Shortcut) onDelete;

  const _ShortcutCard({
    required this.shortcut,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _resolveIcon(String name) {
    return switch (name) {
      'terminal' => Icons.terminal,
      'list_alt' => Icons.list_alt,
      'folder' => Icons.folder_outlined,
      'photo_camera' => Icons.photo_camera_outlined,
      'restart_alt' => Icons.restart_alt,
      'install_mobile' => Icons.install_mobile,
      'bug_report' => Icons.bug_report_outlined,
      'memory' => Icons.memory,
      'settings' => Icons.settings_outlined,
      'wifi' => Icons.wifi,
      _ => Icons.bolt,
    };
  }

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_resolveIcon(shortcut.icon), size: 18, color: p.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortcut.name,
                    style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    shortcut.commandTemplate,
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                _IconBtn(
                  icon: Icons.copy_outlined,
                  tooltip: l.shortcutsCopyCmd,
                  color: p.textSecondary,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shortcut.commandTemplate));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.shortcutsCopyCmd), duration: const Duration(seconds: 2)),
                    );
                  },
                ),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.edit_outlined, tooltip: l.actionEdit, color: p.textSecondary, onTap: () => onEdit(shortcut)),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.delete_outline, tooltip: l.actionDelete, color: p.statusError, onTap: () => onDelete(shortcut)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: p.surfaceHighlight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
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
          Icon(Icons.bolt, size: 48, color: p.textDisabled),
          const SizedBox(height: 16),
          Text(l.shortcutsEmptyTitle,
              style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(l.shortcutsEmptySubtitle,
              style: TextStyle(color: p.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(l.shortcutsCreate),
            style: ElevatedButton.styleFrom(backgroundColor: p.primaryBlue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Modal ────────────────────────────────────────────────────────────────────

class _ShortcutModal extends StatefulWidget {
  final Shortcut? existing;
  final void Function(Shortcut) onSave;

  const _ShortcutModal({this.existing, required this.onSave});

  @override
  State<_ShortcutModal> createState() => _ShortcutModalState();
}

class _ShortcutModalState extends State<_ShortcutModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _cmdCtrl;
  late bool _isGlobal;
  late String _selectedIcon;
  String? _nameError;
  String? _cmdError;

  static const _icons = [
    ('terminal', Icons.terminal, 'Shell'),
    ('list_alt', Icons.list_alt, 'Logcat'),
    ('folder', Icons.folder_outlined, 'Files'),
    ('photo_camera', Icons.photo_camera_outlined, 'Screenshot'),
    ('restart_alt', Icons.restart_alt, 'Reboot'),
    ('install_mobile', Icons.install_mobile, 'Install'),
    ('bug_report', Icons.bug_report_outlined, 'Debug'),
    ('memory', Icons.memory, 'Memory'),
    ('settings', Icons.settings_outlined, 'Config'),
    ('wifi', Icons.wifi, 'WiFi'),
    ('bolt', Icons.bolt, 'General'),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _cmdCtrl = TextEditingController(text: e?.commandTemplate ?? '');
    _isGlobal = e?.isGlobal ?? false;
    _selectedIcon = e?.icon ?? 'bolt';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cmdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? l.shortcutsModalNameRequired : null;
      _cmdError = _cmdCtrl.text.trim().isEmpty ? l.shortcutsModalCmdRequired : null;
    });
    if (_nameError != null || _cmdError != null) return;

    widget.onSave(Shortcut(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      icon: _selectedIcon,
      commandTemplate: _cmdCtrl.text.trim(),
      isGlobal: _isGlobal,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final isEdit = widget.existing != null;

    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEdit ? l.shortcutsModalEditTitle : l.shortcutsModalCreateTitle,
                    style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 18, color: p.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(l.shortcutsModalNameLabel,
                  style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              _ModalField(controller: _nameCtrl, hint: l.shortcutsModalNameHint, error: _nameError),
              const SizedBox(height: 16),

              Text(l.shortcutsModalCmdLabel,
                  style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              _ModalField(controller: _cmdCtrl, hint: 'adb -s %DEVICE% shell', error: _cmdError, mono: true),
              const SizedBox(height: 4),
              Text(l.shortcutsModalCmdHint, style: TextStyle(fontSize: 10, color: p.textDisabled)),
              const SizedBox(height: 16),

              Text(l.shortcutsModalIconLabel,
                  style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((entry) {
                  final (key, icon, label) = entry;
                  final selected = _selectedIcon == key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = key),
                    child: Tooltip(
                      message: label,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected ? p.primaryBlue.withValues(alpha: 0.15) : p.surfaceHighlight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? p.primaryBlue : p.borderColor,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Icon(icon, size: 17, color: selected ? p.primaryBlue : p.textSecondary),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.shortcutsModalGlobalTitle,
                            style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(l.shortcutsModalGlobalSubtitle,
                            style: TextStyle(color: p.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isGlobal,
                    onChanged: (v) => setState(() => _isGlobal = v),
                    activeThumbColor: p.accent,
                    activeTrackColor: p.accent.withValues(alpha: 0.3),
                    inactiveTrackColor: p.surfaceHighlight,
                    inactiveThumbColor: p.textSecondary,
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(isEdit ? l.actionSave : l.actionCreate),
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

class _ModalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? error;
  final bool mono;

  const _ModalField({
    required this.controller,
    required this.hint,
    this.error,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return TextField(
      controller: controller,
      style: TextStyle(
        color: p.textPrimary,
        fontSize: 13,
        fontFamily: mono ? 'monospace' : null,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textDisabled, fontSize: 13),
        filled: true,
        fillColor: p.background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        errorText: error,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.statusError),
        ),
      ),
    );
  }
}
