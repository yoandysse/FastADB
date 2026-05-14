class AdbOutputParser {
  static const String unauthorizedDeviceMessage =
      'Device is unauthorized. Unlock the Android device and accept the USB debugging prompt, then try again.';
  static const String offlineDeviceMessage =
      'Device is offline. Reconnect the USB cable or restart ADB with "adb kill-server" and "adb start-server".';
  static const String linuxUsbPermissionMessage =
      'ADB cannot access the USB device. On Linux, install Android udev rules, add your user to plugdev, then reconnect the device.';
  static const String noDevicesMessage =
      'No ADB devices found. Connect a device, enable USB debugging, or verify the WiFi address and port.';
  static const String adbNotFoundMessage =
      'ADB was not found. Configure the adb path in Settings or install Android platform-tools.';
  static const String scrcpyNotFoundMessage =
      'scrcpy was not found. Configure the scrcpy path in Settings or install scrcpy for your platform.';

  /// Parse output from `adb devices` command
  /// Returns list of (serial, state) tuples
  static List<(String serial, String state)> parseDevices(String output) {
    final lines = output.split('\n');
    final devices = <(String, String)>[];

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty ||
          _isDevicesHeader(trimmed) ||
          trimmed.contains('adb server version')) {
        continue;
      }

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final serial = parts[0].trim();
        final state = parts.sublist(1).join(' ').trim();

        if (serial.isNotEmpty && state.isNotEmpty) {
          devices.add((serial, state));
        }
      }
    }

    return devices;
  }

  static bool _isDevicesHeader(String line) {
    final normalized = line.toLowerCase();
    return normalized == 'list of devices attached' ||
        normalized == 'list of attached devices';
  }

  /// Check if a device state is valid (connected)
  static bool isDeviceConnected(String state) {
    return state.toLowerCase() == 'device';
  }

  /// Extract IP address from `adb shell ip route` output
  /// Format: "0.0.0.0/0 via 192.168.1.1 dev wlan0 proto static"
  /// Returns the gateway IP (usually the local IP of the device)
  static String? parseIpRoute(String output) {
    final lines = output.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.contains('via')) {
        final parts = trimmed.split(' ');
        final viaIndex = parts.indexOf('via');

        if (viaIndex != -1 && viaIndex + 1 < parts.length) {
          return parts[viaIndex + 1];
        }
      }
    }

    return null;
  }

  /// Parse version output from `adb version`
  /// Example: "Android Debug Bridge version 1.0.41"
  static String? parseAdbVersion(String output) {
    final lines = output.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('Android Debug Bridge version')) {
        return trimmed;
      }
    }

    return null;
  }

  /// Check if output contains an ADB error
  static bool hasError(String output) {
    final lowerOutput = output.toLowerCase();
    return lowerOutput.contains('error') ||
        lowerOutput.contains('failed') ||
        lowerOutput.contains('cannot') ||
        lowerOutput.contains('unable') ||
        lowerOutput.contains('no devices/emulators found') ||
        lowerOutput.contains('no permissions') ||
        lowerOutput.contains('offline') ||
        lowerOutput.contains('unauthorized');
  }

  /// Extract error message from ADB output
  static String? extractError(String output) {
    final friendly = friendlyError(output);
    if (friendly != null) return friendly;

    final lines = output.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.toLowerCase().startsWith('error:')) {
        return trimmed.replaceFirst(
          RegExp(r'error:\s*', caseSensitive: false),
          '',
        );
      }
    }

    return null;
  }

  /// Convert common ADB/scrcpy failures into actionable desktop UI messages.
  static String? friendlyError(String output, {String? fallback}) {
    final trimmed = output.trim();
    final lowerOutput = trimmed.toLowerCase();

    if (lowerOutput.isEmpty) return fallback;

    if (lowerOutput.contains('unauthorized')) {
      return unauthorizedDeviceMessage;
    }
    if (lowerOutput.contains('offline')) {
      return offlineDeviceMessage;
    }
    if (lowerOutput.contains('no permissions') ||
        lowerOutput.contains('insufficient permissions') ||
        lowerOutput.contains('udev')) {
      return linuxUsbPermissionMessage;
    }
    if (lowerOutput.contains('no devices/emulators found') ||
        lowerOutput.contains('device not found') ||
        lowerOutput.contains('more than one device/emulator')) {
      return noDevicesMessage;
    }
    if (lowerOutput.contains('unable to connect')) {
      return 'Unable to connect to the device. Verify that WiFi ADB is enabled, both devices are on the same network, and the port is correct.';
    }
    if (lowerOutput.contains('connection refused')) {
      return 'Connection refused. Enable WiFi ADB on the device and verify the selected port.';
    }
    if (lowerOutput.contains('connection timed out') ||
        lowerOutput.contains('operation timed out') ||
        lowerOutput.contains('timed out')) {
      return 'Connection timed out. Verify the device IP address, network, firewall, and ADB TCP port.';
    }
    if (lowerOutput.contains('cannot connect to daemon') ||
        lowerOutput.contains('failed to start daemon')) {
      return 'ADB server could not start. Check that platform-tools is installed correctly and no other ADB server is blocking it.';
    }
    if (lowerOutput.contains('adb: command not found') ||
        lowerOutput.contains('no such file or directory') &&
            lowerOutput.contains('adb')) {
      return adbNotFoundMessage;
    }
    if (lowerOutput.contains('scrcpy') &&
        (lowerOutput.contains('command not found') ||
            lowerOutput.contains('no such file or directory'))) {
      return scrcpyNotFoundMessage;
    }

    for (final line in trimmed.split('\n')) {
      final clean = line.trim();
      if (clean.isEmpty) continue;
      final lowerLine = clean.toLowerCase();
      if (lowerLine.startsWith('error:')) {
        return clean.replaceFirst(
          RegExp(r'error:\s*', caseSensitive: false),
          '',
        );
      }
      if (lowerLine.contains('failed') ||
          lowerLine.contains('cannot') ||
          lowerLine.contains('unable')) {
        return clean;
      }
    }

    return fallback ?? trimmed;
  }
}
