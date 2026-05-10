import 'dart:io';
import '../models/device.dart';
import '../models/connection_status.dart';
import '../../shared/utils/adb_output_parser.dart';
import 'process_runner.dart';

class AdbResult {
  final bool success;
  final String? message;
  final String? error;

  AdbResult({
    required this.success,
    this.message,
    this.error,
  });

  @override
  String toString() => 'AdbResult(success: $success, message: $message, error: $error)';
}

class AdbService {
  final String adbPath;
  final ProcessRunner _runner;

  AdbService({
    required this.adbPath,
    ProcessRunner? runner,
  }) : _runner = runner ?? DefaultProcessRunner();

  /// Connect to a device via WiFi/TCP-IP
  Future<AdbResult> connect(String host, int port) async {
    try {
      final result = await _runner.run([adbPath, 'connect', '$host:$port']);

      if (result.exitCode != 0) {
        return AdbResult(
          success: false,
          error: result.stderr?.toString() ?? 'Connection failed',
        );
      }

      final stdout = result.stdout.toString().toLowerCase();

      if (stdout.contains('connected to')) {
        return AdbResult(success: true, message: 'Connected');
      } else if (stdout.contains('already connected')) {
        return AdbResult(success: true, message: 'Already connected');
      } else if (stdout.contains('unable to connect')) {
        return AdbResult(success: false, error: 'Unable to connect to $host:$port');
      } else if (stdout.contains('error')) {
        return AdbResult(
          success: false,
          error: AdbOutputParser.extractError(stdout) ?? 'Connection error',
        );
      }

      return AdbResult(success: true, message: 'Connected');
    } catch (e) {
      return AdbResult(success: false, error: e.toString());
    }
  }

  /// Disconnect from a device
  Future<AdbResult> disconnect(String serial) async {
    try {
      final result = await _runner.run([adbPath, 'disconnect', serial]);

      if (result.exitCode != 0) {
        return AdbResult(
          success: false,
          error: result.stderr?.toString() ?? 'Disconnect failed',
        );
      }

      return AdbResult(success: true, message: 'Disconnected');
    } catch (e) {
      return AdbResult(success: false, error: e.toString());
    }
  }

  /// Returns true if the serial corresponds to a TCP/IP (WiFi) connection.
  /// TCP/IP serials have the form `host:port` where port is a number
  /// (e.g. "192.168.1.1:5555", "[fe80::1%eth0]:5555").
  /// USB serials are pure alphanumeric strings with no trailing numeric port.
  static bool isTcpIpSerial(String serial) {
    final lastColon = serial.lastIndexOf(':');
    if (lastColon == -1) return false;
    final afterColon = serial.substring(lastColon + 1);
    return int.tryParse(afterColon) != null;
  }

  /// List all ADB-connected devices (both USB and TCP/IP).
  /// Use [isTcpIpSerial] to distinguish them at the call site.
  Future<List<UsbDevice>> listUsbDevices() async {
    try {
      final result = await _runner.run([adbPath, 'devices']);

      if (result.exitCode != 0) {
        return [];
      }

      final devices = <UsbDevice>[];
      final parsed = AdbOutputParser.parseDevices(result.stdout.toString());

      for (final (serial, state) in parsed) {
        ConnectionStatus status = ConnectionStatus.offline;

        if (AdbOutputParser.isDeviceConnected(state)) {
          status = ConnectionStatus.connected;
        } else if (state.toLowerCase() == 'unauthorized') {
          status = ConnectionStatus.error;
        }

        devices.add(UsbDevice(serial: serial, status: status));
      }

      return devices;
    } catch (e) {
      return [];
    }
  }

  /// Get the state of a device (device, offline, unauthorized, etc.)
  Future<String> getDeviceState(String serial) async {
    try {
      final result = await _runner.run([adbPath, '-s', serial, 'get-state']);

      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }

      return 'offline';
    } catch (e) {
      return 'offline';
    }
  }

  /// Get device model via `adb shell getprop`
  Future<String> getModel(String serial) async {
    try {
      final result = await _runner.run(
        [adbPath, '-s', serial, 'shell', 'getprop', 'ro.product.model'],
      );

      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }

      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get Android version via `adb shell getprop`
  Future<String> getAndroidVersion(String serial) async {
    try {
      final result = await _runner.run(
        [adbPath, '-s', serial, 'shell', 'getprop', 'ro.build.version.release'],
      );

      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }

      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Enable TCP/IP mode (WiFi ADB) on a USB-connected device
  Future<AdbResult> enableTcpip(String serial, {int port = 5555}) async {
    try {
      final result = await _runner.run([adbPath, '-s', serial, 'tcpip', '$port']);

      if (result.exitCode != 0) {
        return AdbResult(
          success: false,
          error: result.stderr?.toString() ?? 'Failed to enable TCP/IP',
        );
      }

      final stdout = result.stdout.toString();

      if (stdout.contains('restarting') || stdout.contains('tcp')) {
        return AdbResult(success: true, message: 'TCP/IP enabled');
      }

      return AdbResult(success: true, message: 'TCP/IP enabled');
    } catch (e) {
      return AdbResult(success: false, error: e.toString());
    }
  }

  /// Get suggested IP address from device (via `adb shell ip route`)
  Future<String?> getSuggestedIp(String serial) async {
    try {
      final result = await _runner.run(
        [adbPath, '-s', serial, 'shell', 'ip', 'route'],
      );

      if (result.exitCode == 0) {
        return AdbOutputParser.parseIpRoute(result.stdout.toString());
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Start ADB server (ensure it's running)
  Future<AdbResult> startServer() async {
    try {
      final result = await _runner.run([adbPath, 'start-server']);

      if (result.exitCode == 0) {
        return AdbResult(success: true, message: 'Server started');
      }

      return AdbResult(
        success: false,
        error: result.stderr?.toString() ?? 'Failed to start server',
      );
    } catch (e) {
      return AdbResult(success: false, error: e.toString());
    }
  }

  /// Run an arbitrary shortcut command template against a device.
  ///
  /// Substitutes `%DEVICE%` with [deviceSerial] and replaces a leading `adb`
  /// token with the configured [adbPath], then executes via the platform shell
  /// so that pipes and redirects work.
  Future<AdbResult> runShortcutCommand(String commandTemplate, String deviceSerial) async {
    try {
      var cmd = commandTemplate.replaceAll('%DEVICE%', deviceSerial);

      // Replace leading 'adb' token (with trailing space or end of string)
      // with the configured adb binary path.
      if (cmd == 'adb' || cmd.startsWith('adb ')) {
        cmd = '$adbPath${cmd.substring(3)}';
      }

      final shellArgs = Platform.isWindows
          ? ['cmd', '/c', cmd]
          : ['sh', '-c', cmd];

      final result = await _runner.run(shellArgs);
      final stdout = result.stdout?.toString().trim() ?? '';
      final stderr = result.stderr?.toString().trim() ?? '';

      return AdbResult(
        success: result.exitCode == 0,
        message: stdout.isNotEmpty ? stdout : null,
        error: stderr.isNotEmpty ? stderr : null,
      );
    } catch (e) {
      return AdbResult(success: false, error: e.toString());
    }
  }

  /// Check if device is authorized (requires manual tap on device)
  Future<bool> isDeviceAuthorized(String serial) async {
    try {
      final state = await getDeviceState(serial);
      return state == 'device';
    } catch (e) {
      return false;
    }
  }
}
