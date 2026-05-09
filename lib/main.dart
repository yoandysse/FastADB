import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/device.dart';
import 'core/models/shortcut.dart';
import 'core/models/tools_config.dart';
import 'config/router.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(DeviceAdapter());
  Hive.registerAdapter(ShortcutAdapter());
  Hive.registerAdapter(ToolsConfigAdapter());

  // Initialize Hive boxes
  await Hive.openBox('devices');
  await Hive.openBox('shortcuts');
  await Hive.openBox('tools_config');

  runApp(const ProviderScope(child: FastADBApp()));
}

class FastADBApp extends StatelessWidget {
  const FastADBApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FastADB',
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
