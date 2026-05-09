import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../providers/tools_config_provider.dart';
import '../../core/models/tools_config.dart';
import 'widgets/tool_path_row.dart';

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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error loading settings: $error'),
          ),
          data: (config) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ToolPathRow(
                  label: 'ADB',
                  iconName: 'adb',
                  currentPath: config.adbPath,
                  onAutoDetect: () => notifier.autoDetectAdb(),
                  onVerify: (path) async {
                    final service = await notifier.getService();
                    return service.verifyAdb(path);
                  },
                  onPathChanged: (path) {
                    final updated = config.copyWith(adbPath: path);
                    notifier.saveConfig(updated);
                  },
                ),
                const SizedBox(height: 12),
                ToolPathRow(
                  label: 'scrcpy',
                  iconName: 'scrcpy',
                  currentPath: config.scrcpyPath,
                  onAutoDetect: () => notifier.autoDetectScrcpy(),
                  onVerify: (path) async {
                    final service = await notifier.getService();
                    return service.verifyScrcpy(path);
                  },
                  onPathChanged: (path) {
                    final updated = config.copyWith(scrcpyPath: path);
                    notifier.saveConfig(updated);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'General',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Auto-reconnect on start'),
                  value: config.autoReconnectOnStart,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.saveConfig(config.copyWith(autoReconnectOnStart: value));
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Start minimized'),
                  value: config.startMinimized,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.saveConfig(config.copyWith(startMinimized: value));
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: config.theme,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      notifier.saveConfig(config.copyWith(theme: value));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
