import 'dart:io';
import '../models/device.dart';
import '../models/connection_status.dart';
import '../../shared/utils/adb_output_parser.dart';
import 'process_runner.dart';

class AdbResult {
  final bool success;
  final String? message;
  final String? error;

  AdbResult({required this.success, this.message, this.error});

  @override
  String toString() =>
      'AdbResult(success: $success, message: $message, error: $error)';
}

class AdbService {
  final String adbPath;
  final ProcessRunner _runner;

  AdbService({required this.adbPath, ProcessRunner? runner})
    : _runner = runner ?? DefaultProcessRunner();

  String _combinedOutput(ProcessResult result) {
    final stdout = result.stdout?.toString().trim() ?? '';
    final stderr = result.stderr?.toString().trim() ?? '';
    if (stdout.isEmpty) return stderr;
    if (stderr.isEmpty) return stdout;
    return '$stdout\n$stderr';
  }

  String _friendlyProcessError(ProcessResult result, String fallback) {
    return AdbOutputParser.friendlyError(
          _combinedOutput(result),
          fallback: fallback,
        ) ??
        fallback;
  }

  String _friendlyException(Object error, String fallback) {
    if (error is ProcessException) {
      return AdbOutputParser.friendlyError(
            '${error.message}\n${error.executable}',
            fallback: fallback,
          ) ??
          fallback;
    }
    return AdbOutputParser.friendlyError(
          error.toString(),
          fallback: fallback,
        ) ??
        fallback;
  }

  /// Connect to a device via WiFi/TCP-IP
  Future<AdbResult> connect(String host, int port) async {
    if (host.trim().isEmpty) {
      return AdbResult(
        success: false,
        error: 'Device host is empty. Enter an IP address or hostname.',
      );
    }

    try {
      final result = await _runner.run([adbPath, 'connect', '$host:$port']);
      final output = _combinedOutput(result);

      if (result.exitCode != 0) {
        return AdbResult(
          success: false,
          error: _friendlyProcessError(result, 'Connection failed'),
        );
      }

      final stdout = output.toLowerCase();

      if (stdout.contains('connected to')) {
        return AdbResult(success: true, message: 'Connected');
      } else if (stdout.contains('already connected')) {
        return AdbResult(success: true, message: 'Already connected');
      } else if (stdout.contains('unable to connect')) {
        return AdbResult(
          success: false,
          error: AdbOutputParser.friendlyError(output),
        );
      } else if (AdbOutputParser.hasError(output)) {
        return AdbResult(
          success: false,
          error: AdbOutputParser.extractError(output) ?? 'Connection error',
        );
      }

      return AdbResult(success: true, message: 'Connected');
    } catch (e) {
      return AdbResult(
        success: false,
        error: _friendlyException(e, 'Connection failed'),
      );
    }
  }

  /// Disconnect from a device
  Future<AdbResult> disconnect(String serial) async {
    try {
      final result = await _runner.run([adbPath, 'disconnect', serial]);

      if (result.exitCode != 0) {
        return AdbResult(
          success: false,
          error: _friendlyProcessError(result, 'Disconnect failed'),
        );
      }

      return AdbResult(success: true, message: 'Disconnected');
    } catch (e) {
      return AdbResult(
        success: false,
        error: _friendlyException(e, 'Disconnect failed'),
      );
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
      final parsed = AdbOutputParser.parseDevices(_combinedOutput(result));

      for (final (serial, state) in parsed) {
        ConnectionStatus status = ConnectionStatus.offline;

        final normalizedState = state.toLowerCase();
        if (AdbOutputParser.isDeviceConnected(normalizedState)) {
          status = ConnectionStatus.connected;
        } else if (normalizedState == 'unauthorized' ||
            normalizedState == 'offline' ||
            normalizedState == 'no permissions') {
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

      final output = _combinedOutput(result).toLowerCase();
      if (output.contains('unauthorized')) return 'unauthorized';
      if (output.contains('offline')) return 'offline';
      if (output.contains('no permissions')) return 'no permissions';
      return 'offline';
    } catch (e) {
      return 'offline';
    }
  }

  /// Get device model via `adb shell getprop`
  Future<String> getModel(String serial) async {
    try {
      final result = await _runner.run([
        adbPath,
        '-s',
        serial,
        'shell',
        'getprop',
        'ro.product.model',
      ]);

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
      final result = await _runner.run([
        adbPath,
        '-s',
        serial,
        'shell',
        'getprop',
        'ro.build.version.release',
      ]);

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
      final result = await _runner.run([
        adbPath,
        '-s',
        serial,
        'tcpip',
        '$port',
      ]);

      if (result.exitCode != 0) {
        return AdbResult(
          success: false,
          error: _friendlyProcessError(result, 'Failed to enable TCP/IP'),
        );
      }

      final stdout = _combinedOutput(result);

      if (AdbOutputParser.hasError(stdout)) {
        return AdbResult(
          success: false,
          error:
              AdbOutputParser.extractError(stdout) ?? 'Failed to enable TCP/IP',
        );
      }

      if (stdout.contains('restarting') || stdout.contains('tcp')) {
        return AdbResult(success: true, message: 'TCP/IP enabled');
      }

      return AdbResult(success: true, message: 'TCP/IP enabled');
    } catch (e) {
      return AdbResult(
        success: false,
        error: _friendlyException(e, 'Failed to enable TCP/IP'),
      );
    }
  }

  /// Get suggested IP address from device (via `adb shell ip route`)
  Future<String?> getSuggestedIp(String serial) async {
    try {
      final result = await _runner.run([
        adbPath,
        '-s',
        serial,
        'shell',
        'ip',
        'route',
      ]);

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
        error: _friendlyProcessError(result, 'Failed to start server'),
      );
    } catch (e) {
      return AdbResult(
        success: false,
        error: _friendlyException(e, 'Failed to start server'),
      );
    }
  }

  /// Run an arbitrary shortcut command template against a device.
  ///
  /// Substitutes `%DEVICE%` with [deviceSerial] and replaces a leading `adb`
  /// token with the configured [adbPath], then executes via the platform shell
  /// so that pipes and redirects work.
  Future<AdbResult> runShortcutCommand(
    String commandTemplate,
    String deviceSerial,
  ) async {
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
      final output = [stdout, stderr].where((s) => s.isNotEmpty).join('\n');
      final friendlyError = result.exitCode == 0
          ? null
          : AdbOutputParser.friendlyError(
              output,
              fallback: stderr.isNotEmpty ? stderr : 'Command failed',
            );

      return AdbResult(
        success: result.exitCode == 0,
        message: stdout.isNotEmpty ? stdout : null,
        error: friendlyError ?? (stderr.isNotEmpty ? stderr : null),
      );
    } catch (e) {
      return AdbResult(
        success: false,
        error: _friendlyException(e, 'Command failed'),
      );
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
