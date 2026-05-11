import 'dart:io';

import 'package:fastadb/core/models/tools_config.dart';
import 'package:fastadb/core/services/tools_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_process_runner.dart';

void main() {
  group('ToolsConfigService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load returns defaults when preferences are empty', () async {
      final config = await ToolsConfigService().load();

      expect(config.adbPath, isEmpty);
      expect(config.scrcpyPath, isEmpty);
      expect(config.autoReconnectOnStart, isTrue);
      expect(config.startMinimized, isFalse);
      expect(config.theme, 'system');
    });

    test('save persists all values', () async {
      final service = ToolsConfigService();

      await service.save(
        ToolsConfig(
          adbPath: '/tmp/adb',
          scrcpyPath: '/tmp/scrcpy',
          autoReconnectOnStart: false,
          startMinimized: true,
          theme: 'dark',
        ),
      );

      final loaded = await service.load();
      expect(loaded.adbPath, '/tmp/adb');
      expect(loaded.scrcpyPath, '/tmp/scrcpy');
      expect(loaded.autoReconnectOnStart, isFalse);
      expect(loaded.startMinimized, isTrue);
      expect(loaded.theme, 'dark');
    });

    test('verifyAdb returns parsed version for existing path', () async {
      final file = await _temporaryExecutable('adb');
      final service = ToolsConfigService(
        processRunner: FakeProcessRunner(
          (_) async => processResult(
            stdout: 'Android Debug Bridge version 1.0.41\nVersion 35.0.2',
          ),
        ),
      );

      final result = await service.verifyAdb(file.path);

      expect(result.success, isTrue);
      expect(result.version, 'Android Debug Bridge version 1.0.41');
    });

    test('verifyAdb reports missing file with actionable message', () async {
      final result = await ToolsConfigService().verifyAdb('/missing/adb');

      expect(result.success, isFalse);
      expect(result.error, contains('platform-tools'));
    });

    test('verifyScrcpy normalizes process failure', () async {
      final file = await _temporaryExecutable('scrcpy');
      final service = ToolsConfigService(
        processRunner: FakeProcessRunner(
          (_) async => processResult(exitCode: 1, stderr: 'scrcpy: not found'),
        ),
      );

      final result = await service.verifyScrcpy(file.path);

      expect(result.success, isFalse);
      expect(result.error, isNotEmpty);
    });
  });
}

Future<File> _temporaryExecutable(String name) async {
  final dir = await Directory.systemTemp.createTemp('fastadb_test_');
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  await file.writeAsString('');
  return file;
}
