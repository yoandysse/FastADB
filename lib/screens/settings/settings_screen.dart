import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../../providers/tools_config_provider.dart';
import '../../providers/locale_provider.dart';
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
    final p = AppPalette.of(context);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: p.background,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Configuración',
          style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Herramientas Externas'),
          const SizedBox(height: 6),
          Text(
            'Configura las rutas de ADB y scrcpy instaladas en tu sistema. La app nunca almacenará para toda las sesiones.',
            style: TextStyle(color: p.textSecondary, fontSize: 12),
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
            children: [
              Icon(Icons.info_outline, size: 13, color: p.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Windows: visita github.com/Genymobile/scrcpy para instalar scrcpy. La app no incluye scrcpy internamente.',
                  style: TextStyle(color: p.textSecondary, fontSize: 11),
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
          Container(height: 1, color: p.divider, margin: const EdgeInsets.symmetric(vertical: 12)),
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

          const SizedBox(height: 32),
          _SectionTitle(title: 'Idioma'),
          const SizedBox(height: 16),
          Row(
            children: [
              _LanguageOption(
                label: 'Sistema',
                sublabel: 'Idioma del SO',
                selected: locale == null,
                onTap: () => onSetLocale(null),
              ),
              const SizedBox(width: 12),
              _LanguageOption(
                label: 'Español',
                sublabel: 'Spanish',
                selected: locale?.languageCode == 'es',
                onTap: () => onSetLocale(const Locale('es')),
              ),
              const SizedBox(width: 12),
              _LanguageOption(
                label: 'English',
                sublabel: 'Inglés',
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
                  Text('FastADB',
                      style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Versión 1.0.0',
                      style: TextStyle(color: p.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gestor de conexiones ADB para Android — Windows, macOS y Linux',
            style: TextStyle(color: p.textDisabled, fontSize: 11),
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
    final p = AppPalette.of(context);
    return Text(
      title,
      style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
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
    if (widget.path.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(widget.name,
                        style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(widget.subtitle,
                        style: TextStyle(color: p.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              if (verified)
                _StatusTag(label: '● Detectado · ${_result!.version ?? ""}', color: p.statusConnected)
              else if (failed)
                _StatusTag(label: '● No configurado', color: p.statusError)
              else if (hasPath)
                _StatusTag(label: '● Sin verificar', color: p.statusReconnecting),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: p.primaryBlue)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SmallButton(label: 'Explorar...', onTap: _detect, loading: _detecting),
              const SizedBox(width: 6),
              _SmallButton(label: 'Verificar', onTap: hasPath ? _verify : null, loading: _verifying, primary: true),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _detect() async {
    setState(() => _detecting = true);
    final path = await widget.onAutoDetect();
    if (path != null) {
      _controller.text = path;
      widget.onPathChanged(path);
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
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primary ? p.primaryBlue.withValues(alpha: 0.15) : p.surfaceHighlight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: primary ? p.primaryBlue.withValues(alpha: 0.4) : p.borderColor,
          ),
        ),
        child: loading
            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5))
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
              Text(title, style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: p.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: p.accent,
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
            Text(label,
                style: TextStyle(
                  color: selected ? p.textPrimary : p.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 2),
            Text(sublabel, style: TextStyle(color: p.textSecondary, fontSize: 11)),
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
            Text(label,
                style: TextStyle(
                  color: selected ? p.textPrimary : p.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 2),
            Text(sublabel, style: TextStyle(color: p.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
