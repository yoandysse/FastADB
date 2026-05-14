import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/tools_config_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/update_provider.dart';
import '../../core/models/tools_config.dart';
import '../../core/services/tools_config_service.dart';
import '../../config/app_info.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final configAsync = ref.watch(toolsConfigProvider);
    final notifier = ref.read(toolsConfigProvider.notifier);
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return AppShell(
      currentRoute: 'settings',
      child: Column(
        children: [
          _TopBar(),
          Container(height: 1, color: p.divider),
          Expanded(
            child: configAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (config) => _SettingsBody(
                config: config,
                notifier: notifier,
                locale: locale,
                onSetLocale: (l) => localeNotifier.setLocale(l),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: p.background,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l.settingsTitle,
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final ToolsConfig config;
  final ToolsConfigNotifier notifier;
  final Locale? locale;
  final void Function(Locale?) onSetLocale;

  const _SettingsBody({
    required this.config,
    required this.notifier,
    required this.locale,
    required this.onSetLocale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final updateState = ref.watch(updateProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: l.settingsToolsSection),
          const SizedBox(height: 6),
          Text(
            l.settingsToolsSubtitle,
            style: TextStyle(color: p.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _ToolRow(
            name: l.settingsAdbName,
            subtitle: l.settingsAdbSubtitle,
            path: config.adbPath,
            verifiedVersion: config.adbVerification?.version,
            onAutoDetect: () => notifier.autoDetectAdb(),
            onVerify: (path) async {
              final svc = await notifier.getService();
              final result = await svc.verifyAdb(path);
              if (result.success && result.version != null) {
                await notifier.saveConfig(
                  config.copyWith(
                    adbPath: path,
                    verifiedAdbPath: path,
                    verifiedAdbVersion: result.version,
                  ),
                );
              }
              return result;
            },
            onPathChanged: (p) => notifier.saveConfig(
              config.copyWith(adbPath: p, clearAdbVerification: true),
            ),
          ),
          const SizedBox(height: 16),
          _ToolRow(
            name: l.settingsScrcpyName,
            subtitle: l.settingsScrcpySubtitle,
            path: config.scrcpyPath,
            verifiedVersion: config.scrcpyVerification?.version,
            onAutoDetect: () => notifier.autoDetectScrcpy(),
            onVerify: (path) async {
              final svc = await notifier.getService();
              final result = await svc.verifyScrcpy(path);
              if (result.success && result.version != null) {
                await notifier.saveConfig(
                  config.copyWith(
                    scrcpyPath: path,
                    verifiedScrcpyPath: path,
                    verifiedScrcpyVersion: result.version,
                  ),
                );
              }
              return result;
            },
            onPathChanged: (p) => notifier.saveConfig(
              config.copyWith(scrcpyPath: p, clearScrcpyVerification: true),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: p.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.settingsWindowsNote,
                  style: TextStyle(color: p.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _SectionTitle(title: l.settingsGeneralSection),
          const SizedBox(height: 16),
          _ToggleRow(
            title: l.settingsAutoReconnectTitle,
            subtitle: l.settingsAutoReconnectSubtitle,
            value: config.autoReconnectOnStart,
            onChanged: (v) =>
                notifier.saveConfig(config.copyWith(autoReconnectOnStart: v)),
          ),
          Container(
            height: 1,
            color: p.divider,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          _ToggleRow(
            title: l.settingsStartMinimizedTitle,
            subtitle: l.settingsStartMinimizedSubtitle,
            value: config.startMinimized,
            onChanged: (v) =>
                notifier.saveConfig(config.copyWith(startMinimized: v)),
          ),

          const SizedBox(height: 32),
          _SectionTitle(title: l.settingsAppearanceSection),
          const SizedBox(height: 16),
          Row(
            children: [
              _ThemeOption(
                label: l.settingsThemeSystem,
                sublabel: l.settingsThemeSystemSub,
                selected: config.theme == 'system',
                onTap: () =>
                    notifier.saveConfig(config.copyWith(theme: 'system')),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                label: l.settingsThemeDark,
                sublabel: l.settingsThemeDarkSub,
                selected: config.theme == 'dark',
                onTap: () =>
                    notifier.saveConfig(config.copyWith(theme: 'dark')),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                label: l.settingsThemeLight,
                sublabel: l.settingsThemeLightSub,
                selected: config.theme == 'light',
                onTap: () =>
                    notifier.saveConfig(config.copyWith(theme: 'light')),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _SectionTitle(title: l.settingsLanguageSection),
          const SizedBox(height: 16),
          Row(
            children: [
              _LanguageOption(
                label: l.settingsLangAuto,
                sublabel: l.settingsLangAutoSub,
                selected: locale == null,
                onTap: () => onSetLocale(null),
              ),
              const SizedBox(width: 12),
              _LanguageOption(
                label: l.settingsLangEs,
                sublabel: l.settingsLangEsSub,
                selected: locale?.languageCode == 'es',
                onTap: () => onSetLocale(const Locale('es')),
              ),
              const SizedBox(width: 12),
              _LanguageOption(
                label: l.settingsLangEn,
                sublabel: l.settingsLangEnSub,
                selected: locale?.languageCode == 'en',
                onTap: () => onSetLocale(const Locale('en')),
              ),
            ],
          ),

          const SizedBox(height: 40),
          Container(height: 1, color: p.divider),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bolt, color: p.accent, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppInfo.name,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.aboutVersion(AppInfo.version),
                    style: TextStyle(color: p.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.aboutDescription,
            style: TextStyle(color: p.textDisabled, fontSize: 11),
          ),
          const SizedBox(height: 16),
          _UpdateSettingsRow(
            state: updateState,
            onCheck: () => ref.read(updateProvider.notifier).check(),
            onUpdate: () async {
              final opened = await ref
                  .read(updateProvider.notifier)
                  .openUpdate();
              if (!context.mounted || opened) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l.updateOpenFailed)));
            },
          ),
        ],
      ),
    );
  }
}

class _UpdateSettingsRow extends StatelessWidget {
  final UpdateState state;
  final VoidCallback onCheck;
  final VoidCallback onUpdate;

  const _UpdateSettingsRow({
    required this.state,
    required this.onCheck,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final update = state.update;

    final status = update != null
        ? l.updateAvailableShort('v${update.version}')
        : state.error != null
        ? l.updateCheckFailed
        : l.updateUpToDate;
    final statusColor = update != null
        ? p.accent
        : state.error != null
        ? p.statusError
        : p.textSecondary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.system_update_alt, size: 16, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (update != null) ...[
            _SettingsUpdateButton(
              label: l.updateAction,
              icon: Icons.download_outlined,
              onTap: onUpdate,
              primary: true,
            ),
            const SizedBox(width: 8),
          ],
          _SettingsUpdateButton(
            label: l.updateCheckAction,
            icon: Icons.refresh,
            onTap: state.checking ? null : onCheck,
            loading: state.checking,
          ),
        ],
      ),
    );
  }
}

class _SettingsUpdateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  final bool primary;

  const _SettingsUpdateButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final color = primary ? p.accent : p.primaryBlue;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: onTap == null
                ? p.surfaceHighlight
                : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: onTap == null
                  ? p.borderColor
                  : color.withValues(alpha: 0.42),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: p.textDisabled,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 14,
                  color: onTap == null ? p.textDisabled : color,
                ),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onTap == null ? p.textDisabled : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Text(
      title,
      style: TextStyle(
        color: p.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ToolRow extends StatefulWidget {
  final String name;
  final String subtitle;
  final String path;
  final String? verifiedVersion;
  final Future<String?> Function() onAutoDetect;
  final Future<ToolVerifyResult> Function(String) onVerify;
  final Function(String) onPathChanged;

  const _ToolRow({
    required this.name,
    required this.subtitle,
    required this.path,
    required this.verifiedVersion,
    required this.onAutoDetect,
    required this.onVerify,
    required this.onPathChanged,
  });

  @override
  State<_ToolRow> createState() => _ToolRowState();
}

class _ToolRowState extends State<_ToolRow> {
  late TextEditingController _controller;
  bool _picking = false;
  bool _detecting = false;
  bool _verifying = false;
  ToolVerifyResult? _result;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.path);
    final verifiedVersion = widget.verifiedVersion;
    if (verifiedVersion != null) {
      _result = ToolVerifyResult(success: true, version: verifiedVersion);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = AppPalette.of(context);
    final hasPath = _controller.text.trim().isNotEmpty;
    final verified = _result?.success == true;
    final failed = _result?.success == false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(color: p.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (verified)
                _StatusTag(
                  label: l.settingsStatusDetected(_result!.version ?? ''),
                  color: p.statusConnected,
                )
              else if (failed)
                _StatusTag(
                  label: l.settingsStatusNotConfigured,
                  color: p.statusError,
                )
              else if (hasPath)
                _StatusTag(
                  label: l.settingsStatusUnverified,
                  color: p.statusReconnecting,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onPathChanged,
                  style: TextStyle(color: p.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '/usr/local/bin/adb',
                    hintStyle: TextStyle(color: p.textDisabled, fontSize: 12),
                    filled: true,
                    fillColor: p.background,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
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
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: l.actionBrowse,
                onTap: _pickFile,
                loading: _picking,
              ),
              const SizedBox(width: 4),
              _AutoDetectButton(
                tooltip: l.settingsAutoDetect,
                onTap: _autoDetect,
                loading: _detecting,
              ),
              const SizedBox(width: 6),
              _SmallButton(
                label: l.actionVerify,
                onTap: hasPath ? _verify : null,
                loading: _verifying,
                primary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        dialogTitle: AppLocalizations.of(context)!.actionBrowse,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        _controller.text = path;
        widget.onPathChanged(path);
        await _verify();
      }
    } catch (e) {
      _showMessage('Could not open file picker: $e');
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _autoDetect() async {
    setState(() => _detecting = true);
    try {
      final path = await widget.onAutoDetect();
      if (path != null) {
        _controller.text = path;
        widget.onPathChanged(path);
        await _verify();
      } else {
        _showMessage(
          'Could not auto-detect ${widget.name}. Select the executable manually.',
        );
      }
    } catch (e) {
      _showMessage('Auto-detect failed: $e');
    } finally {
      if (mounted) {
        setState(() => _detecting = false);
      }
    }
  }

  Future<void> _verify() async {
    setState(() => _verifying = true);
    try {
      final result = await widget.onVerify(_controller.text);
      if (!mounted) return;
      setState(() {
        _result = result;
        _verifying = false;
      });
      if (!result.success && result.error != null) {
        _showMessage(result.error!);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _verifying = false);
        _showMessage('Verification failed: $e');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool primary;

  const _SmallButton({
    required this.label,
    this.onTap,
    this.loading = false,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primary
              ? p.primaryBlue.withValues(alpha: 0.15)
              : p.surfaceHighlight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: primary
                ? p.primaryBlue.withValues(alpha: 0.4)
                : p.borderColor,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              )
            : Text(
                label,
                style: TextStyle(
                  color: primary ? p.primaryBlue : p.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class _AutoDetectButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final bool loading;

  const _AutoDetectButton({
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: p.surfaceHighlight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: p.borderColor),
          ),
          child: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              : Icon(Icons.manage_search, size: 14, color: p.textSecondary),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: p.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: p.accent,
          activeTrackColor: p.accent.withValues(alpha: 0.3),
          inactiveTrackColor: p.surfaceHighlight,
          inactiveThumbColor: p.textSecondary,
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? p.primaryBlue.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? p.primaryBlue : p.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? p.textPrimary : p.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(color: p.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? p.primaryBlue.withValues(alpha: 0.1) : p.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? p.primaryBlue : p.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? p.textPrimary : p.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(color: p.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
