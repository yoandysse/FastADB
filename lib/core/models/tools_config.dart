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

  ToolsConfig({
    required this.adbPath,
    required this.scrcpyPath,
    this.autoReconnectOnStart = true,
    this.startMinimized = false,
    this.theme = 'system',
  });

  ToolsConfig copyWith({
    String? adbPath,
    String? scrcpyPath,
    bool? autoReconnectOnStart,
    bool? startMinimized,
    String? theme,
  }) {
    return ToolsConfig(
      adbPath: adbPath ?? this.adbPath,
      scrcpyPath: scrcpyPath ?? this.scrcpyPath,
      autoReconnectOnStart: autoReconnectOnStart ?? this.autoReconnectOnStart,
      startMinimized: startMinimized ?? this.startMinimized,
      theme: theme ?? this.theme,
    );
  }

  bool get isValid => adbPath.isNotEmpty && scrcpyPath.isNotEmpty;
}
