import 'package:fastadb/core/models/connection_status.dart';
import 'package:fastadb/core/services/adb_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_process_runner.dart';

void main() {
  group('AdbService', () {
    test('connect succeeds for connected output', () async {
      final runner = FakeProcessRunner(
        (_) async => processResult(stdout: 'connected to 192.168.1.10:5555'),
      );
      final service = AdbService(adbPath: '/usr/bin/adb', runner: runner);

      final result = await service.connect('192.168.1.10', 5555);

      expect(result.success, isTrue);
      expect(result.message, 'Connected');
      expect(runner.calls.single, [
        '/usr/bin/adb',
        'connect',
        '192.168.1.10:5555',
      ]);
    });

    test('connect returns actionable error for timeout', () async {
      final service = AdbService(
        adbPath: 'adb',
        runner: FakeProcessRunner(
          (_) async => processResult(
            exitCode: 1,
            stderr: 'failed to connect: Connection timed out',
          ),
        ),
      );

      final result = await service.connect('192.168.1.10', 5555);

      expect(result.success, isFalse);
      expect(result.error, contains('timed out'));
    });

    test(
      'listUsbDevices maps unauthorized, offline and permissions to error',
      () async {
        final service = AdbService(
          adbPath: 'adb',
          runner: FakeProcessRunner(
            (_) async => processResult(
              stdout: '''
List of attached devices
device-1	device
device-2	unauthorized
device-3	offline
device-4	no permissions
''',
            ),
          ),
        );

        final devices = await service.listUsbDevices();

        expect(devices.map((d) => d.serial), [
          'device-1',
          'device-2',
          'device-3',
          'device-4',
        ]);
        expect(devices[0].status, ConnectionStatus.connected);
        expect(devices[1].status, ConnectionStatus.error);
        expect(devices[2].status, ConnectionStatus.error);
        expect(devices[3].status, ConnectionStatus.error);
      },
    );

    test('enableTcpip reports unauthorized state', () async {
      final service = AdbService(
        adbPath: 'adb',
        runner: FakeProcessRunner(
          (_) async =>
              processResult(exitCode: 1, stderr: 'error: device unauthorized'),
        ),
      );

      final result = await service.enableTcpip('device-1');

      expect(result.success, isFalse);
      expect(result.error, contains('USB debugging prompt'));
    });

    test('runShortcutCommand replaces adb and device placeholders', () async {
      late List<String> captured;
      final service = AdbService(
        adbPath: '/opt/android/adb',
        runner: FakeProcessRunner((args) async {
          captured = args;
          return processResult(stdout: 'ok');
        }),
      );

      final result = await service.runShortcutCommand(
        'adb -s %DEVICE% shell getprop ro.product.model',
        'serial-1',
      );

      expect(result.success, isTrue);
      expect(result.message, 'ok');
      expect(captured.last, contains('/opt/android/adb -s serial-1'));
    });
  });
}
