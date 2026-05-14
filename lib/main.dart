import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'config/app_info.dart';
import 'core/models/device.dart';
import 'core/models/shortcut.dart';
import 'core/models/tools_config.dart';
import 'core/models/connection_status.dart';
import 'config/router.dart';
import 'shared/theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'providers/tools_config_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  PrintLogCollector? marionetteLogCollector;

  await runZonedGuarded(
    () async {
      marionetteLogCollector = _ensureFlutterBinding();
      _configureDevelopmentLogging(marionetteLogCollector);

      await _bootstrap();
    },
    (error, stackTrace) {
      marionetteLogCollector?.addLog('[zone:error] $error\n$stackTrace');
      unawaited(Sentry.captureException(error, stackTrace: stackTrace));
    },
  );
}

PrintLogCollector? _ensureFlutterBinding() {
  if (kDebugMode) {
    final logCollector = PrintLogCollector();
    MarionetteBinding.ensureInitialized(
      MarionetteConfiguration(logCollector: logCollector),
    );
    logCollector.addLog('[marionette] development log collection enabled');
    return logCollector;
  }

  WidgetsFlutterBinding.ensureInitialized();
  return null;
}

void _configureDevelopmentLogging(PrintLogCollector? logCollector) {
  if (!kDebugMode || logCollector == null) return;

  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && message.isNotEmpty) {
      logCollector.addLog('[debugPrint] $message');
    }
    originalDebugPrint(message, wrapWidth: wrapWidth);
  };

  final originalFlutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    logCollector.addLog(
      '[flutter:error] ${details.exceptionAsString()}\n${details.stack ?? ''}',
    );
    originalFlutterError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logCollector.addLog('[platform:error] $error\n$stackTrace');
    return false;
  };
}

Future<void> _bootstrap() async {
  await Hive.initFlutter();

  Hive.registerAdapter(DeviceAdapter());
  Hive.registerAdapter(ShortcutAdapter());
  Hive.registerAdapter(ToolsConfigAdapter());
  Hive.registerAdapter(ConnectionTypeAdapter());

  await Hive.openBox<Device>('devices');
  await Hive.openBox<Shortcut>('shortcuts');
  await Hive.openBox('tools_config');

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://53140b49631c22e040fe03023c423f9e@sentry.krakenstain.com/2';
      options.release = '${AppInfo.name}@${AppInfo.version}';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // Configure Session Replay for beta verification.
      options.replay.sessionSampleRate = 1.0;
      options.replay.onErrorSampleRate = 1.0;
      options.privacy.maskAllText = true;
      options.privacy.maskAllImages = true;
    },
    appRunner: () =>
        runApp(SentryWidget(child: const ProviderScope(child: FastADBApp()))),
  );
}

class FastADBApp extends ConsumerWidget {
  const FastADBApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref
        .watch(toolsConfigProvider)
        .maybeWhen(
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
