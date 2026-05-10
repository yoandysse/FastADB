import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tools_config.dart';
import 'process_runner.dart';

class ToolVerifyResult {
  final bool success;
  final String? version;
  final String? error;

  ToolVerifyResult({required this.success, this.version, this.error});
}

class ToolsConfigService {
  static const String _adbPathKey = 'adb_path';
  static const String _scrcpyPathKey = 'scrcpy_path';
  static const String _autoReconnectKey = 'auto_reconnect_on_start';
  static const String _startMinimizedKey = 'start_minimized';
  static const String _themeKey = 'theme';

  final ProcessRunner _processRunner;
  late SharedPreferences _prefs;

  ToolsConfigService({ProcessRunner? processRunner})
    : _processRunner = processRunner ?? DefaultProcessRunner();

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<ToolsConfig> load() async {
    await _init();

    final adbPath = _prefs.getString(_adbPathKey) ?? '';
    final scrcpyPath = _prefs.getString(_scrcpyPathKey) ?? '';
    final autoReconnect = _prefs.getBool(_autoReconnectKey) ?? true;
    final startMinimized = _prefs.getBool(_startMinimizedKey) ?? false;
    final theme = _prefs.getString(_themeKey) ?? 'system';

    return ToolsConfig(
      adbPath: adbPath,
      scrcpyPath: scrcpyPath,
      autoReconnectOnStart: autoReconnect,
      startMinimized: startMinimized,
      theme: theme,
    );
  }

  Future<void> save(ToolsConfig config) async {
    await _init();

    await Future.wait([
      _prefs.setString(_adbPathKey, config.adbPath),
      _prefs.setString(_scrcpyPathKey, config.scrcpyPath),
      _prefs.setBool(_autoReconnectKey, config.autoReconnectOnStart),
      _prefs.setBool(_startMinimizedKey, config.startMinimized),
      _prefs.setString(_themeKey, config.theme),
    ]);
  }

  Future<String?> autoDetectAdb() async {
    final platform = Platform.operatingSystem;

    if (platform == 'windows') {
      return _detectAdbWindows();
    } else if (platform == 'macos') {
      return _detectAdbMacOS();
    } else if (platform == 'linux') {
      return _detectAdbLinux();
    }

    return null;
  }

  Future<String?> _detectAdbWindows() async {
    try {
      final androidHome = Platform.environment['ANDROID_HOME'];
      if (androidHome != null) {
        final adbPath = '$androidHome\\platform-tools\\adb.exe';
        if (File(adbPath).existsSync()) {
          return adbPath;
        }
      }

      final androidSdkRoot = Platform.environment['ANDROID_SDK_ROOT'];
      if (androidSdkRoot != null) {
        final adbPath = '$androidSdkRoot\\platform-tools\\adb.exe';
        if (File(adbPath).existsSync()) {
          return adbPath;
        }
      }

      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        final adbPath = '$localAppData\\Android\\Sdk\\platform-tools\\adb.exe';
        if (File(adbPath).existsSync()) {
          return adbPath;
        }
      }

      final result = await _processRunner.run(['where', 'adb.exe']);
      if (result.exitCode == 0) {
        return (result.stdout as String).split('\n').first.trim();
      }
    } catch (e) {
      // silently fail
    }

    return null;
  }

  Future<String?> _detectAdbMacOS() async {
    try {
      final homebrewPath = '/usr/local/bin/adb';
      if (File(homebrewPath).existsSync()) {
        return homebrewPath;
      }

      final m1Path = '/opt/homebrew/bin/adb';
      if (File(m1Path).existsSync()) {
        return m1Path;
      }

      final result = await _processRunner.run(['which', 'adb']);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
    } catch (e) {
      // silently fail
    }

    return null;
  }

  Future<String?> _detectAdbLinux() async {
    try {
      final result = await _processRunner.run(['which', 'adb']);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
    } catch (e) {
      // silently fail
    }

    return null;
  }

  Future<String?> autoDetectScrcpy() async {
    try {
      final platform = Platform.operatingSystem;
      if (platform == 'macos') {
        final commonPaths = [
          '/opt/homebrew/bin/scrcpy',
          '/usr/local/bin/scrcpy',
          '/opt/local/bin/scrcpy',
        ];

        for (final path in commonPaths) {
          if (File(path).existsSync()) {
            return path;
          }
        }
      }

      if (platform == 'linux') {
        final commonPaths = [
          '/usr/bin/scrcpy',
          '/usr/local/bin/scrcpy',
          '/snap/bin/scrcpy',
          '/var/lib/flatpak/exports/bin/scrcpy',
        ];

        for (final path in commonPaths) {
          if (File(path).existsSync()) {
            return path;
          }
        }
      }

      final command = platform == 'windows'
          ? ['where', 'scrcpy.exe']
          : ['which', 'scrcpy'];

      final result = await _processRunner.run(command);
      if (result.exitCode == 0) {
        return (result.stdout as String).split('\n').first.trim();
      }
    } catch (e) {
      // silently fail
    }

    return null;
  }

  Future<ToolVerifyResult> verifyAdb(String path) async {
    try {
      if (!File(path).existsSync()) {
        return ToolVerifyResult(success: false, error: 'File not found: $path');
      }

      final result = await _processRunner.run([path, 'version']);

      if (result.exitCode != 0) {
        return ToolVerifyResult(
          success: false,
          error: result.stderr?.toString() ?? 'Unknown error',
        );
      }

      final output = result.stdout.toString();
      final versionLine = output.split('\n').first;

      return ToolVerifyResult(success: true, version: versionLine);
    } catch (e) {
      return ToolVerifyResult(success: false, error: e.toString());
    }
  }

  Future<ToolVerifyResult> verifyScrcpy(String path) async {
    try {
      if (!File(path).existsSync()) {
        return ToolVerifyResult(success: false, error: 'File not found: $path');
      }

      final result = await _processRunner.run([path, '--version']);

      if (result.exitCode != 0) {
        return ToolVerifyResult(
          success: false,
          error: result.stderr?.toString() ?? 'Unknown error',
        );
      }

      final output = result.stdout.toString();
      final version = output.split('\n').first;

      return ToolVerifyResult(success: true, version: version);
    } catch (e) {
      return ToolVerifyResult(success: false, error: e.toString());
    }
  }
}
