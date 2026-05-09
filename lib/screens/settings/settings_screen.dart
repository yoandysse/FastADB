import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/tools_config_provider.dart';
import '../../core/models/tools_config.dart';
import '../../core/services/tools_config_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(toolsConfigProvider);
    final notifier = ref.read(toolsConfigProvider.notifier);

    return AppShell(
      currentRoute: 'settings',
      child: Column(
        children: [
          // Top bar
          _TopBar(),
          Container(height: 1, color: AppColors.divider),
          // Content
          Expanded(
            child: configAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (config) => _SettingsBody(config: config, notifier: notifier),
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.background,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Configuración',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final ToolsConfig config;
  final ToolsConfigNotifier notifier;

  const _SettingsBody({required this.config, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Herramientas Externas'),
          const SizedBox(height: 6),
          const Text(
            'Configura las rutas de ADB y scrcpy instaladas en tu sistema. La app nunca almacenará para toda las sesiones.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _ToolRow(
            name: 'Android Debug Bridge (ADB)',
            subtitle: 'Herramienta de depuración Android',
            path: config.adbPath,
            onAutoDetect: () => notifier.autoDetectAdb(),
            onVerify: (path) async {
              final svc = await notifier.getService();
              return svc.verifyAdb(path);
            },
            onPathChanged: (p) => notifier.saveConfig(config.copyWith(adbPath: p)),
          ),
          const SizedBox(height: 16),
          _ToolRow(
            name: 'scrcpy',
            subtitle: 'Espejo de pantalla Android',
            path: config.scrcpyPath,
            onAutoDetect: () => notifier.autoDetectScrcpy(),
            onVerify: (path) async {
              final svc = await notifier.getService();
              return svc.verifyScrcpy(path);
            },
            onPathChanged: (p) => notifier.saveConfig(config.copyWith(scrcpyPath: p)),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Windows: visita github.com/Genymobile/scrcpy para instalar scrcpy. La app no incluye scrcpy internamente.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _SectionTitle(title: 'General'),
          const SizedBox(height: 16),
          _ToggleRow(
            title: 'Reconexión automática al inicio',
            subtitle: 'Intentar reconectar dispositivos WiFi al iniciar la app',
            value: config.autoReconnectOnStart,
            onChanged: (v) => notifier.saveConfig(config.copyWith(autoReconnectOnStart: v)),
          ),
          Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(vertical: 12)),
          _ToggleRow(
            title: 'Iniciar minimizado',
            subtitle: 'La app inicia en segundo plano sin ventana visible',
            value: config.startMinimized,
            onChanged: (v) => notifier.saveConfig(config.copyWith(startMinimized: v)),
          ),

          const SizedBox(height: 32),
          _SectionTitle(title: 'Apariencia'),
          const SizedBox(height: 16),
          Row(
            children: [
              _ThemeOption(
                label: 'Sistema',
                sublabel: 'Sigue el modo del SO',
                selected: config.theme == 'system',
                onTap: () => notifier.saveConfig(config.copyWith(theme: 'system')),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                label: 'Oscuro',
                sublabel: 'Siempre modo oscuro',
                selected: config.theme == 'dark',
                onTap: () => notifier.saveConfig(config.copyWith(theme: 'dark')),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                label: 'Claro',
                sublabel: 'Siempre modo claro',
                selected: config.theme == 'light',
                onTap: () => notifier.saveConfig(config.copyWith(theme: 'light')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
    );
  }
}

class _ToolRow extends StatefulWidget {
  final String name;
  final String subtitle;
  final String path;
  final Future<String?> Function() onAutoDetect;
  final Future<ToolVerifyResult> Function(String) onVerify;
  final Function(String) onPathChanged;

  const _ToolRow({
    required this.name,
    required this.subtitle,
    required this.path,
    required this.onAutoDetect,
    required this.onVerify,
    required this.onPathChanged,
  });

  @override
  State<_ToolRow> createState() => _ToolRowState();
}

class _ToolRowState extends State<_ToolRow> {
  late TextEditingController _controller;
  bool _detecting = false;
  bool _verifying = false;
  ToolVerifyResult? _result;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPath = _controller.text.trim().isNotEmpty;
    final verified = _result?.success == true;
    final failed = _result?.success == false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
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
                    Text(widget.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(widget.subtitle,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              if (verified)
                _StatusTag(label: '● Detectado · ${_result!.version ?? ""}', color: AppColors.statusConnected)
              else if (failed)
                _StatusTag(label: '● No configurado', color: AppColors.statusError)
              else if (hasPath)
                _StatusTag(label: '● Sin verificar', color: AppColors.statusReconnecting),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onPathChanged,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '/usr/local/bin/adb',
                    hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.background,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.borderColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.primaryBlue)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'Explorar...',
                onTap: _detect,
                loading: _detecting,
              ),
              const SizedBox(width: 6),
              _SmallButton(
                label: 'Verificar',
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

  Future<void> _detect() async {
    setState(() => _detecting = true);
    final p = await widget.onAutoDetect();
    if (p != null) {
      _controller.text = p;
      widget.onPathChanged(p);
    }
    setState(() => _detecting = false);
  }

  Future<void> _verify() async {
    setState(() => _verifying = true);
    final result = await widget.onVerify(_controller.text);
    setState(() {
      _result = result;
      _verifying = false;
    });
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

  const _SmallButton({required this.label, this.onTap, this.loading = false, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primary ? AppColors.primaryBlue.withValues(alpha: 0.15) : AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: primary ? AppColors.primaryBlue.withValues(alpha: 0.4) : AppColors.borderColor,
          ),
        ),
        child: loading
            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5))
            : Text(
                label,
                style: TextStyle(
                  color: primary ? AppColors.primaryBlue : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
          inactiveTrackColor: AppColors.surfaceHighlight,
          inactiveThumbColor: AppColors.textSecondary,
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 2),
            Text(sublabel,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
