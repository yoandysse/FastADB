class AdbOutputParser {
  /// Parse output from `adb devices` command
  /// Returns list of (serial, state) tuples
  static List<(String serial, String state)> parseDevices(String output) {
    final lines = output.split('\n');
    final devices = <(String, String)>[];

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty || trimmed == 'List of attached devices' || trimmed.contains('adb server version')) {
        continue;
      }

      final parts = trimmed.split('\t');
      if (parts.length >= 2) {
        final serial = parts[0].trim();
        final state = parts[1].trim();

        if (serial.isNotEmpty && state.isNotEmpty) {
          devices.add((serial, state));
        }
      }
    }

    return devices;
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
        lowerOutput.contains('offline') ||
        lowerOutput.contains('unauthorized');
  }

  /// Extract error message from ADB output
  static String? extractError(String output) {
    final lines = output.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.toLowerCase().startsWith('error:')) {
        return trimmed.replaceFirst(RegExp(r'error:\s*', caseSensitive: false), '');
      }
    }

    return null;
  }
}
