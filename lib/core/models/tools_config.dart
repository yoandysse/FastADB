import 'package:hive/hive.dart';

part 'tools_config.g.dart';

@HiveType(typeId: 2)
class ToolsConfig {
  @HiveField(0)
  final String adbPath;

  @HiveField(1)
  final String scrcpyPath;

  @HiveField(2)
  final bool autoReconnectOnStart;

  @HiveField(3)
  final bool startMinimized;

  @HiveField(4)
  final String theme;

  @HiveField(5)
  final String? verifiedAdbPath;

  @HiveField(6)
  final String? verifiedAdbVersion;

  @HiveField(7)
  final String? verifiedScrcpyPath;

  @HiveField(8)
  final String? verifiedScrcpyVersion;

  ToolsConfig({
    required this.adbPath,
    required this.scrcpyPath,
    this.autoReconnectOnStart = true,
    this.startMinimized = false,
    this.theme = 'system',
    this.verifiedAdbPath,
    this.verifiedAdbVersion,
    this.verifiedScrcpyPath,
    this.verifiedScrcpyVersion,
  });

  ToolsConfig copyWith({
    String? adbPath,
    String? scrcpyPath,
    bool? autoReconnectOnStart,
    bool? startMinimized,
    String? theme,
    String? verifiedAdbPath,
    String? verifiedAdbVersion,
    String? verifiedScrcpyPath,
    String? verifiedScrcpyVersion,
    bool clearAdbVerification = false,
    bool clearScrcpyVerification = false,
  }) {
    return ToolsConfig(
      adbPath: adbPath ?? this.adbPath,
      scrcpyPath: scrcpyPath ?? this.scrcpyPath,
      autoReconnectOnStart: autoReconnectOnStart ?? this.autoReconnectOnStart,
      startMinimized: startMinimized ?? this.startMinimized,
      theme: theme ?? this.theme,
      verifiedAdbPath: clearAdbVerification
          ? null
          : verifiedAdbPath ?? this.verifiedAdbPath,
      verifiedAdbVersion: clearAdbVerification
          ? null
          : verifiedAdbVersion ?? this.verifiedAdbVersion,
      verifiedScrcpyPath: clearScrcpyVerification
          ? null
          : verifiedScrcpyPath ?? this.verifiedScrcpyPath,
      verifiedScrcpyVersion: clearScrcpyVerification
          ? null
          : verifiedScrcpyVersion ?? this.verifiedScrcpyVersion,
    );
  }

  bool get isValid => adbPath.isNotEmpty && scrcpyPath.isNotEmpty;

  ToolVerification? get adbVerification {
    if (adbPath.isEmpty || adbPath != verifiedAdbPath) return null;
    final version = verifiedAdbVersion;
    if (version == null || version.isEmpty) return null;
    return ToolVerification(path: adbPath, version: version);
  }

  ToolVerification? get scrcpyVerification {
    if (scrcpyPath.isEmpty || scrcpyPath != verifiedScrcpyPath) return null;
    final version = verifiedScrcpyVersion;
    if (version == null || version.isEmpty) return null;
    return ToolVerification(path: scrcpyPath, version: version);
  }
}

class ToolVerification {
  final String path;
  final String version;

  const ToolVerification({required this.path, required this.version});
}
