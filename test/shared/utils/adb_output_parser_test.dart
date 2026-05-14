import 'package:fastadb/shared/utils/adb_output_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdbOutputParser', () {
    test('parses adb devices output with tabs and spaces', () {
      const output = '''
List of devices attached
emulator-5554	device
R58M123456 unauthorized
192.168.1.20:5555	offline
''';

      expect(AdbOutputParser.parseDevices(output), [
        ('emulator-5554', 'device'),
        ('R58M123456', 'unauthorized'),
        ('192.168.1.20:5555', 'offline'),
      ]);
    });

    test('ignores legacy adb devices header wording', () {
      const output = '''
List of attached devices
emulator-5554	device
''';

      expect(AdbOutputParser.parseDevices(output), [
        ('emulator-5554', 'device'),
      ]);
    });

    test('extracts route gateway from ip route output', () {
      expect(
        AdbOutputParser.parseIpRoute(
          '192.168.1.0/24 dev wlan0 proto kernel\n'
          'default via 192.168.1.1 dev wlan0',
        ),
        '192.168.1.1',
      );
    });

    test('extracts adb version line', () {
      expect(
        AdbOutputParser.parseAdbVersion(
          'Android Debug Bridge version 1.0.41\nVersion 35.0.2',
        ),
        'Android Debug Bridge version 1.0.41',
      );
    });

    test('normalizes unauthorized and Linux USB permission errors', () {
      expect(
        AdbOutputParser.extractError('error: device unauthorized'),
        contains('USB debugging prompt'),
      );
      expect(
        AdbOutputParser.extractError('no permissions (udev rules); see docs'),
        contains('udev rules'),
      );
    });

    test('normalizes adb connect failures', () {
      expect(
        AdbOutputParser.friendlyError(
          'failed to connect to 10.0.0.2:5555: Connection timed out',
        ),
        contains('timed out'),
      );
      expect(
        AdbOutputParser.friendlyError('unable to connect to 10.0.0.2:5555'),
        contains('Unable to connect'),
      );
    });
  });
}
