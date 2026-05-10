import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'core/models/device.dart';
import 'core/models/shortcut.dart';
import 'core/models/tools_config.dart';
import 'core/models/connection_status.dart';
import 'config/router.dart';
import 'shared/theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'providers/tools_config_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  await Hive.initFlutter();

  Hive.registerAdapter(DeviceAdapter());
  Hive.registerAdapter(ShortcutAdapter());
  Hive.registerAdapter(ToolsConfigAdapter());
  Hive.registerAdapter(ConnectionTypeAdapter());

  await Hive.openBox<Device>('devices');
  await Hive.openBox<Shortcut>('shortcuts');
  await Hive.openBox('tools_config');

  runApp(const ProviderScope(child: FastADBApp()));
}

class FastADBApp extends ConsumerWidget {
  const FastADBApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(toolsConfigProvider).maybeWhen(
      data: (c) => switch (c.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      orElse: () => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'FastADB',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
